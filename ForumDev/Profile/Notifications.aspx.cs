using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Profile
{
    public partial class Notifications : Page
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
                LoadNotifications("All");
            }
        }

        protected void btnAll_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnAll);
            LoadNotifications("All");
        }

        protected void btnUnread_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnUnread);
            LoadNotifications("Unread");
        }

        protected void btnSystem_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnSystem);
            LoadNotifications("System");
        }

        protected void btnTask_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnTask);
            LoadNotifications("Task");
        }

        protected void btnAchievement_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnAchievement);
            LoadNotifications("Achievement");
        }

        protected void btnMarkAllRead_Click(object sender, EventArgs e)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                MarkAllAsRead(currentUser.UserID);
                ShowSuccess("已將所有通知標記為已讀");
                LoadNotifications(ViewState["CurrentFilter"]?.ToString() ?? "All");
            }
            catch (Exception ex)
            {
                ShowError("操作失敗: " + ex.Message);
            }
        }

        protected void btnDeleteAll_Click(object sender, EventArgs e)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                DeleteAllNotifications(currentUser.UserID);
                ShowSuccess("已刪除所有通知");
                LoadNotifications(ViewState["CurrentFilter"]?.ToString() ?? "All");
            }
            catch (Exception ex)
            {
                ShowError("刪除失敗: " + ex.Message);
            }
        }

        private void SetActiveTab(LinkButton activeButton)
        {
            btnAll.CssClass = "nav-link";
            btnUnread.CssClass = "nav-link";
            btnSystem.CssClass = "nav-link";
            btnTask.CssClass = "nav-link";
            btnAchievement.CssClass = "nav-link";
            activeButton.CssClass = "nav-link active";
        }

        private void LoadNotifications(string filter)
        {
            ViewState["CurrentFilter"] = filter;

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                List<Notification> notifications = GetNotifications(currentUser.UserID, filter);

                if (notifications.Count == 0)
                {
                    pnlNoNotifications.Visible = true;
                    rptNotifications.Visible = false;
                }
                else
                {
                    pnlNoNotifications.Visible = false;
                    rptNotifications.Visible = true;
                    rptNotifications.DataSource = notifications;
                    rptNotifications.DataBind();
                }

                // 更新統計
                UpdateStats(currentUser.UserID);
            }
            catch (Exception ex)
            {
                ShowError("載入通知時發生錯誤: " + ex.Message);
            }
        }

        private List<Notification> GetNotifications(int userId, string filter)
        {
            List<Notification> notifications = new List<Notification>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        NotificationID,
                        Type,
                        Title,
                        Content,
                        IsRead,
                        CreatedDate
                    FROM Notifications
                    WHERE UserID = @UserID";

                // 根據篩選條件添加 WHERE 子句
                switch (filter)
                {
                    case "Unread":
                        query += " AND IsRead = 0";
                        break;
                    case "System":
                        query += " AND Type = 'System'";
                        break;
                    case "Task":
                        query += " AND Type = 'Task'";
                        break;
                    case "Achievement":
                        query += " AND Type = 'Achievement'";
                        break;
                }

                query += " ORDER BY IsRead ASC, CreatedDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            notifications.Add(new Notification
                            {
                                NotificationID = Convert.ToInt32(reader["NotificationID"]),
                                Type = reader["Type"].ToString(),
                                Title = reader["Title"].ToString(),
                                Content = reader["Content"].ToString(),
                                IsRead = Convert.ToBoolean(reader["IsRead"]),
                                CreatedDate = Convert.ToDateTime(reader["CreatedDate"])
                            });
                        }
                    }
                }
            }

            return notifications;
        }

        private void UpdateStats(int userId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // 未讀數量
                string queryUnread = "SELECT COUNT(*) FROM Notifications WHERE UserID = @UserID AND IsRead = 0";
                using (SqlCommand cmd = new SqlCommand(queryUnread, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    lblUnreadCount.Text = cmd.ExecuteScalar().ToString();
                }

                // 已讀數量
                string queryRead = "SELECT COUNT(*) FROM Notifications WHERE UserID = @UserID AND IsRead = 1";
                using (SqlCommand cmd = new SqlCommand(queryRead, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    lblReadCount.Text = cmd.ExecuteScalar().ToString();
                }

                // 總數量
                string queryTotal = "SELECT COUNT(*) FROM Notifications WHERE UserID = @UserID";
                using (SqlCommand cmd = new SqlCommand(queryTotal, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    lblTotalCount.Text = cmd.ExecuteScalar().ToString();
                }
            }
        }

        private void MarkAllAsRead(int userId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "UPDATE Notifications SET IsRead = 1 WHERE UserID = @UserID AND IsRead = 0";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void DeleteAllNotifications(int userId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "DELETE FROM Notifications WHERE UserID = @UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void rptNotifications_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "MarkRead")
            {
                MarkAsRead(notificationId);
                ShowSuccess("已標記為已讀");
                LoadNotifications(ViewState["CurrentFilter"]?.ToString() ?? "All");
            }
            else if (e.CommandName == "Delete")
            {
                DeleteNotification(notificationId);
                ShowSuccess("通知已刪除");
                LoadNotifications(ViewState["CurrentFilter"]?.ToString() ?? "All");
            }
        }

        private void MarkAsRead(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "UPDATE Notifications SET IsRead = 1 WHERE NotificationID = @NotificationID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationID", notificationId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void DeleteNotification(int notificationId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "DELETE FROM Notifications WHERE NotificationID = @NotificationID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@NotificationID", notificationId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // 輔助方法
        protected bool IsRead(object isReadObj)
        {
            return isReadObj != null && Convert.ToBoolean(isReadObj);
        }

        protected string GetTypeIcon(string type)
        {
            switch (type)
            {
                case "System": return "gear-fill";
                case "Task": return "clipboard-check-fill";
                case "Achievement": return "trophy-fill";
                case "Social": return "people-fill";
                case "Shop": return "cart-fill";
                default: return "bell-fill";
            }
        }

        protected string GetTypeColor(string type)
        {
            switch (type)
            {
                case "System": return "primary";
                case "Task": return "success";
                case "Achievement": return "warning";
                case "Social": return "info";
                case "Shop": return "danger";
                default: return "secondary";
            }
        }

        protected string GetTimeAgo(object timestampObj)
        {
            if (timestampObj == null || timestampObj == DBNull.Value)
                return "未知時間";

            DateTime timestamp = Convert.ToDateTime(timestampObj);
            TimeSpan timeAgo = DateTime.Now - timestamp;

            if (timeAgo.TotalMinutes < 1)
                return "剛剛";
            else if (timeAgo.TotalMinutes < 60)
                return $"{(int)timeAgo.TotalMinutes} 分鐘前";
            else if (timeAgo.TotalHours < 24)
                return $"{(int)timeAgo.TotalHours} 小時前";
            else if (timeAgo.TotalDays < 7)
                return $"{(int)timeAgo.TotalDays} 天前";
            else
                return timestamp.ToString("yyyy/MM/dd HH:mm");
        }

        private void ShowError(string message)
        {
            lblMessage.Text = "<i class='bi bi-exclamation-circle-fill'></i> " + message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-danger";
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = "<i class='bi bi-check-circle-fill'></i> " + message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-success";
        }
    }
}
