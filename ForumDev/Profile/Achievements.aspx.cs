using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Profile
{
    public partial class Achievements : Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + 
                    Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            if (!IsPostBack)
            {
                // 進入頁面時自動檢查並解鎖符合條件的成就
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser != null)
                {
                    try
                    {
                        AchievementTracker.CheckAllAchievements(currentUser.UserID);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error checking achievements: {ex.Message}");
                    }
                }

                LoadAchievements("");
            }
        }

        protected void btnAll_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnAll);
            LoadAchievements("");
        }

        protected void btnTask_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnTask);
            LoadAchievements("Task");
        }

        protected void btnLevel_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnLevel);
            LoadAchievements("Level");
        }

        protected void btnSocial_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnSocial);
            LoadAchievements("Social");
        }

        protected void btnSpecial_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnSpecial);
            LoadAchievements("Special");
        }

        private void SetActiveTab(LinkButton activeButton)
        {
            btnAll.CssClass = "nav-link";
            btnTask.CssClass = "nav-link";
            btnLevel.CssClass = "nav-link";
            btnSocial.CssClass = "nav-link";
            btnSpecial.CssClass = "nav-link";
            activeButton.CssClass = "nav-link active";
        }

        private void LoadAchievements(string category)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                List<AchievementViewModel> achievements = GetAchievements(currentUser.UserID, category);

                if (achievements.Count == 0)
                {
                    pnlNoAchievements.Visible = true;
                    rptAchievements.Visible = false;
                }
                else
                {
                    pnlNoAchievements.Visible = false;
                    rptAchievements.Visible = true;
                    rptAchievements.DataSource = achievements;
                    rptAchievements.DataBind();
                }

                // 計算統計數據
                CalculateStats(achievements);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading achievements: " + ex.Message);
            }
        }

        private List<AchievementViewModel> GetAchievements(int userId, string category)
        {
            List<AchievementViewModel> achievements = new List<AchievementViewModel>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        A.AchievementID,
                        A.Name,
                        A.Description,
                        A.Category,
                        A.Condition,
                        A.BadgeIcon,
                        A.Rarity,
                        A.Points,
                        A.IsHidden,
                        UA.UserAchievementID,
                        UA.UnlockDate
                    FROM Achievements A
                    LEFT JOIN UserAchievements UA ON A.AchievementID = UA.AchievementID AND UA.UserID = @UserID
                    WHERE (@Category = '' OR A.Category = @Category)
                    ORDER BY 
                        CASE WHEN UA.UserAchievementID IS NULL THEN 1 ELSE 0 END,
                        UA.UnlockDate DESC,
                        A.Points DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Category", category ?? "");

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            bool isUnlocked = reader["UserAchievementID"] != DBNull.Value;
                            
                            achievements.Add(new AchievementViewModel
                            {
                                Achievement = new Achievement
                                {
                                    AchievementID = Convert.ToInt32(reader["AchievementID"]),
                                    Name = reader["Name"].ToString(),
                                    Description = reader["Description"].ToString(),
                                    Category = reader["Category"].ToString(),
                                    Condition = reader["Condition"] != DBNull.Value ? 
                                        reader["Condition"].ToString() : "",
                                    BadgeIcon = reader["BadgeIcon"] != DBNull.Value ? 
                                        reader["BadgeIcon"].ToString() : "??",
                                    Rarity = reader["Rarity"].ToString(),
                                    Points = Convert.ToInt32(reader["Points"]),
                                    IsHidden = Convert.ToBoolean(reader["IsHidden"])
                                },
                                IsUnlocked = isUnlocked,
                                UnlockedDate = isUnlocked ? 
                                    (DateTime?)Convert.ToDateTime(reader["UnlockDate"]) : null
                            });
                        }
                    }
                }
            }

            return achievements;
        }

        private void CalculateStats(List<AchievementViewModel> achievements)
        {
            int totalCount = achievements.Count;
            int unlockedCount = achievements.Count(a => a.IsUnlocked);
            int lockedCount = totalCount - unlockedCount;
            int totalPoints = achievements.Where(a => a.IsUnlocked)
                .Sum(a => a.Achievement.Points);

            lblUnlockedCount.Text = unlockedCount.ToString();
            lblLockedCount.Text = lockedCount.ToString();
            lblTotalPoints.Text = totalPoints.ToString();

            int completionRate = totalCount > 0 ? (int)((double)unlockedCount / totalCount * 100) : 0;
            lblCompletionRate.Text = completionRate.ToString();
            lblProgressText.Text = $"{unlockedCount} / {totalCount}";

            // 設定進度條
            achievementProgress.Style["width"] = completionRate + "%";
            achievementProgress.InnerText = completionRate + "%";
        }

        // 輔助方法
        protected bool IsUnlocked(object isUnlockedObj)
        {
            return isUnlockedObj != null && Convert.ToBoolean(isUnlockedObj);
        }

        protected string GetRarityClass(string rarity)
        {
            switch (rarity?.ToLower())
            {
                case "common": return "rarity-common";
                case "rare": return "rarity-rare";
                case "epic": return "rarity-epic";
                case "legendary": return "rarity-legendary";
                default: return "rarity-common";
            }
        }

        protected string GetRarityText(string rarity)
        {
            switch (rarity?.ToLower())
            {
                case "common": return "普通";
                case "rare": return "稀有";
                case "epic": return "史詩";
                case "legendary": return "傳說";
                default: return "普通";
            }
        }

        protected string GetUnlockStatus(object isUnlockedObj, object unlockedDateObj)
        {
            bool isUnlocked = IsUnlocked(isUnlockedObj);

            if (isUnlocked && unlockedDateObj != null)
            {
                DateTime unlockedDate = Convert.ToDateTime(unlockedDateObj);
                return $"<span class='badge bg-success'><i class='bi bi-check-circle-fill'></i> 於 {unlockedDate:yyyy/MM/dd} 解鎖</span>";
            }
            else
            {
                return "<span class='badge bg-secondary'><i class='bi bi-lock-fill'></i> 尚未解鎖</span>";
            }
        }

        // 內部類別用於顯示
        public class AchievementViewModel
        {
            public Achievement Achievement { get; set; }
            public bool IsUnlocked { get; set; }
            public DateTime? UnlockedDate { get; set; }
        }
    }
}
