using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;
using System.Data.SqlClient;
using System.Configuration;
using ForumDev.Models;
using System.Collections.Generic;
using System.Web;

namespace ForumDev
{
    public partial class _Default : Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadPageData();
            }
        }

        private void LoadPageData()
        {
            // 檢查用戶是否登入
            if (User.Identity.IsAuthenticated)
            {
                LoadUserInfo();
                pnlUserInfo.Visible = true;
                lnkStartNow.Visible = false;
                lnkMyTasks.Visible = true;
                lnkPlatformTour.Visible = true;
            }
            else
            {
                pnlUserInfo.Visible = false;
                lnkStartNow.Visible = true;
                lnkMyTasks.Visible = false;
                lnkPlatformTour.Visible = false;
            }

            // 載入熱門任務
            LoadPopularTasks();

            // 載入統計數據
            LoadStatistics();
        }

        private void LoadUserInfo()
        {
            try
            {
                string userName = User.Identity.Name;
                int userId = GetCurrentUserId();
                
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT 
                            U.Level, 
                            U.Points, 
                            U.TotalExp,
                            (SELECT COUNT(*) FROM UserTasks WHERE UserID = U.UserID AND Status = 'Completed') AS TasksCompleted
                        FROM Users U
                        WHERE U.UserName = @UserName";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserName", userName);
                        
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                int userLevel = Convert.ToInt32(reader["Level"]);
                                int tasksCompleted = Convert.ToInt32(reader["TasksCompleted"]);
                                
                                lblLevel.Text = userLevel.ToString();
                                lblPoints.Text = reader["Points"].ToString();
                                lblExp.Text = reader["TotalExp"].ToString();
                                lblTasksCompleted.Text = tasksCompleted.ToString();
                                
                                // 顯示新手導覽提示（等級 <= 3 且任務完成數 <= 5）
                                if (userLevel <= 3 && tasksCompleted <= 5)
                                {
                                    pnlTourTip.Visible = true;
                                }
                                else
                                {
                                    pnlTourTip.Visible = false;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Log error (可以實作錯誤記錄機制)
                System.Diagnostics.Debug.WriteLine("Error loading user info: " + ex.Message);
            }
        }

        /// <summary>
        /// 获取当前登录用户的ID
        /// </summary>
        private int GetCurrentUserId()
        {
            if (User.Identity.IsAuthenticated)
            {
                HttpCookie authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
                if (authCookie != null)
                {
                    FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(authCookie.Value);
                    if (ticket != null && !string.IsNullOrEmpty(ticket.UserData))
                    {
                        return Convert.ToInt32(ticket.UserData);
                    }
                }
            }
            return 0;
        }

        private void LoadPopularTasks()
        {
            try
            {
                List<GameTask> popularTasks = new List<GameTask>();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT TOP 6 
                            T.TaskID,
                            T.TaskName,
                            T.Description,
                            T.Category,
                            T.ExpReward,
                            T.PointsReward
                        FROM Tasks T
                        WHERE T.IsActive = 1
                            AND (T.StartDate IS NULL OR T.StartDate <= GETDATE())
                            AND (T.EndDate IS NULL OR T.EndDate >= GETDATE())
                        ORDER BY T.DisplayOrder, T.TaskID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                popularTasks.Add(new GameTask
                                {
                                    TaskID = Convert.ToInt32(reader["TaskID"]),
                                    TaskName = reader["TaskName"].ToString(),
                                    Description = reader["Description"] != DBNull.Value ? 
                                        reader["Description"].ToString() : "",
                                    Category = reader["Category"].ToString(),
                                    ExpReward = Convert.ToInt32(reader["ExpReward"]),
                                    PointsReward = Convert.ToInt32(reader["PointsReward"])
                                });
                            }
                        }
                    }
                }

                rptPopularTasks.DataSource = popularTasks;
                rptPopularTasks.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading popular tasks: " + ex.Message);
            }
        }

        private void LoadStatistics()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    
                    // 取得總用戶數
                    string queryUsers = "SELECT COUNT(*) FROM Users WHERE IsActive = 1";
                    using (SqlCommand cmd = new SqlCommand(queryUsers, conn))
                    {
                        lblTotalUsers.Text = cmd.ExecuteScalar().ToString();
                    }

                    // 取得總任務數
                    string queryTasks = "SELECT COUNT(*) FROM Tasks WHERE IsActive = 1";
                    using (SqlCommand cmd = new SqlCommand(queryTasks, conn))
                    {
                        lblTotalTasks.Text = cmd.ExecuteScalar().ToString();
                    }

                    // 取得完成次數
                    string queryCompleted = "SELECT COUNT(*) FROM UserTasks WHERE Status = 'Completed'";
                    using (SqlCommand cmd = new SqlCommand(queryCompleted, conn))
                    {
                        lblCompletedTasks.Text = cmd.ExecuteScalar().ToString();
                    }

                    // 取得獎勵發放數
                    string queryRewards = "SELECT COUNT(*) FROM Transactions WHERE Type = 'TaskReward'";
                    using (SqlCommand cmd = new SqlCommand(queryRewards, conn))
                    {
                        lblTotalRewards.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading statistics: " + ex.Message);
                // 設定預設值
                lblTotalUsers.Text = "0";
                lblTotalTasks.Text = "0";
                lblCompletedTasks.Text = "0";
                lblTotalRewards.Text = "0";
            }
        }
    }
}