using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev
{
    public partial class Leaderboard : Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;
        private string currentType = "Level";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadLeaderboard("Level");
            }
        }

        protected void btnLevel_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnLevel);
            LoadLeaderboard("Level");
        }

        protected void btnPoints_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnPoints);
            LoadLeaderboard("Points");
        }

        protected void btnTasks_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnTasks);
            LoadLeaderboard("Tasks");
        }

        private void SetActiveTab(LinkButton activeButton)
        {
            btnLevel.CssClass = "nav-link";
            btnPoints.CssClass = "nav-link";
            btnTasks.CssClass = "nav-link";
            activeButton.CssClass = "nav-link active";
        }

        private void LoadLeaderboard(string type)
        {
            currentType = type;
            ViewState["LeaderboardType"] = type;

            try
            {
                DataTable dt = GetLeaderboardData(type);

                if (dt.Rows.Count == 0)
                {
                    pnlEmpty.Visible = true;
                    rptLeaderboard.Visible = false;
                }
                else
                {
                    pnlEmpty.Visible = false;
                    rptLeaderboard.Visible = true;
                    rptLeaderboard.DataSource = dt;
                    rptLeaderboard.DataBind();
                }

                // 設定分數欄位標題
                switch (type)
                {
                    case "Level":
                        lblScoreColumn.Text = "經驗值";
                        break;
                    case "Points":
                        lblScoreColumn.Text = "積分";
                        break;
                    case "Tasks":
                        lblScoreColumn.Text = "完成任務數";
                        break;
                }

                // 載入當前用戶排名
                LoadUserRank(type);

                // 更新時間
                lblUpdateTime.Text = DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading leaderboard: " + ex.Message);
            }
        }

        private DataTable GetLeaderboardData(string type)
        {
            string query = "";

            switch (type)
            {
                case "Level":
                    query = @"
                        SELECT TOP 100 
                            UserID,
                            UserName,
                            Avatar,
                            Level,
                            TotalExp AS Score
                        FROM Users
                        WHERE IsActive = 1
                        ORDER BY Level DESC, TotalExp DESC, UserID";
                    break;

                case "Points":
                    query = @"
                        SELECT TOP 100 
                            UserID,
                            UserName,
                            Avatar,
                            Level,
                            Points AS Score
                        FROM Users
                        WHERE IsActive = 1
                        ORDER BY Points DESC, Level DESC, UserID";
                    break;

                case "Tasks":
                    // 計算已完成(Completed)和已領取(Claimed)的任務總數
                    query = @"
                        SELECT TOP 100 
                            U.UserID,
                            U.UserName,
                            U.Avatar,
                            U.Level,
                            COUNT(UT.UserTaskID) AS Score
                        FROM Users U
                        LEFT JOIN UserTasks UT ON U.UserID = UT.UserID AND UT.Status IN ('Completed', 'Claimed')
                        WHERE U.IsActive = 1
                        GROUP BY U.UserID, U.UserName, U.Avatar, U.Level
                        ORDER BY Score DESC, U.Level DESC, U.UserID";
                    break;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlDataAdapter adapter = new SqlDataAdapter(query, conn))
                {
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }

        private void LoadUserRank(string type)
        {
            if (!User.Identity.IsAuthenticated)
            {
                pnlUserRank.Visible = false;
                return;
            }

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                string query = "";
                string scoreLabel = "";
                int userScore = 0;

                switch (type)
                {
                    case "Level":
                        userScore = currentUser.TotalExp;
                        query = @"
                            SELECT 
                                (SELECT COUNT(*) + 1 
                                 FROM Users 
                                 WHERE IsActive = 1 
                                   AND (Level > @Level OR (Level = @Level AND TotalExp > @Score))
                                ) AS Rank,
                                @Score AS Score";
                        scoreLabel = currentUser.TotalExp.ToString("N0") + " EXP";
                        break;

                    case "Points":
                        userScore = currentUser.Points;
                        query = @"
                            SELECT 
                                (SELECT COUNT(*) + 1 
                                 FROM Users 
                                 WHERE IsActive = 1 
                                   AND Points > @Score
                                ) AS Rank,
                                @Score AS Score";
                        scoreLabel = currentUser.Points.ToString("N0") + " 積分";
                        break;

                    case "Tasks":
                        // 先查詢用戶的任務完成數（Completed + Claimed）
                        string queryTaskCount = "SELECT COUNT(*) FROM UserTasks WHERE UserID = @UserID AND Status IN ('Completed', 'Claimed')";
                        using (SqlConnection conn = new SqlConnection(connectionString))
                        {
                            conn.Open();
                            using (SqlCommand cmd = new SqlCommand(queryTaskCount, conn))
                            {
                                cmd.Parameters.AddWithValue("@UserID", currentUser.UserID);
                                userScore = Convert.ToInt32(cmd.ExecuteScalar());
                                scoreLabel = userScore.ToString("N0") + " 個任務";
                            }
                        }
                        
                        // 計算排名
                        query = @"
                            SELECT 
                                (SELECT COUNT(DISTINCT U2.UserID) + 1
                                 FROM Users U2
                                 LEFT JOIN UserTasks UT2 ON U2.UserID = UT2.UserID AND UT2.Status IN ('Completed', 'Claimed')
                                 WHERE U2.IsActive = 1
                                 GROUP BY U2.UserID
                                 HAVING COUNT(UT2.UserTaskID) > @Score
                                ) AS Rank,
                                @Score AS Score";
                        break;
                }

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Level", currentUser.Level);
                        cmd.Parameters.AddWithValue("@Score", userScore);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int rank = reader["Rank"] != DBNull.Value ? 
                                    Convert.ToInt32(reader["Rank"]) : 1;
                                
                                pnlUserRank.Visible = true;
                                lblUserRank.Text = rank.ToString();
                                lblUserRankNumber.Text = rank.ToString();
                                lblUserScore.Text = scoreLabel;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading user rank: " + ex.Message);
                pnlUserRank.Visible = false;
            }
        }

        // 輔助方法
        protected string GetRowClass(int index)
        {
            if (User.Identity.IsAuthenticated)
            {
                // 可以加入高亮當前用戶的邏輯
            }
            return "";
        }

        protected string GetRankBadgeClass(int rank)
        {
            switch (rank)
            {
                case 1: return "rank-gold";
                case 2: return "rank-silver";
                case 3: return "rank-bronze";
                default: return "rank-normal";
            }
        }

        protected string GetRankDisplay(int rank)
        {
            switch (rank)
            {
                case 1: return "<i class='bi bi-trophy-fill text-warning' style='font-size: 1.3rem; filter: drop-shadow(2px 2px 3px rgba(0,0,0,0.5));'></i> " + rank;
                case 2: return "<i class='bi bi-award-fill text-secondary' style='font-size: 1.3rem; filter: drop-shadow(2px 2px 3px rgba(0,0,0,0.5));'></i> " + rank;
                case 3: return "<i class='bi bi-patch-check-fill' style='color: #CD7F32; font-size: 1.3rem; filter: drop-shadow(2px 2px 3px rgba(0,0,0,0.5));'></i> " + rank;
                default: return rank.ToString();
            }
        }

        protected string GetAvatar(object avatarObj)
        {
            if (avatarObj == null || avatarObj == DBNull.Value || string.IsNullOrEmpty(avatarObj.ToString()))
            {
                return "https://i.pravatar.cc/150?img=1";
            }
            
            string avatar = avatarObj.ToString();
            
            // 如果是應用程式相對路徑（以 ~ 開頭），使用 ResolveUrl 轉換
            if (avatar.StartsWith("~/"))
            {
                return ResolveUrl(avatar);
            }
            
            // 如果是外部 URL 或其他格式，直接返回
            return avatar;
        }

        protected string IsCurrentUser(string userName)
        {
            if (User.Identity.IsAuthenticated && User.Identity.Name == userName)
            {
                return "<span class='badge bg-primary ms-2'>我</span>";
            }
            return "";
        }

        protected string FormatScore(object scoreObj)
        {
            if (scoreObj == null || scoreObj == DBNull.Value)
                return "0";

            string type = ViewState["LeaderboardType"]?.ToString() ?? "Level";
            int score = Convert.ToInt32(scoreObj);

            switch (type)
            {
                case "Level":
                    return score.ToString("N0") + " EXP";
                case "Points":
                    return score.ToString("N0") + " 積分";
                case "Tasks":
                    return score.ToString("N0") + " 個";
                default:
                    return score.ToString("N0");
            }
        }
    }
}
