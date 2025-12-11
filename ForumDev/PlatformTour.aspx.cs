using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.Services;
using System.Data.SqlClient;
using System.Configuration;
using ForumDev.BLL;

namespace ForumDev
{
    public partial class PlatformTour : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (!User.Identity.IsAuthenticated)
                {
                    Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Request.RawUrl);
                    return;
                }
                LoadUserTourProgress();
                CheckTourTaskStatus();
            }
        }

        private void CheckTourTaskStatus()
        {
            try
            {
                int userId = GetCurrentUserId();
                if (userId == 0) return;
                int tourTaskId = FindTourTaskId();
                if (tourTaskId == 0) return;
                var userTasks = TaskService.GetUserTasks(userId);
                var userTask = userTasks.Find(ut => ut.TaskID == tourTaskId);
                hfTaskClaimed.Value = (userTask != null && userTask.Status == "Claimed") ? "true" : "false";
            }
            catch
            {
                hfTaskClaimed.Value = "false";
            }
        }

        private void LoadUserTourProgress()
        {
            int userId = GetCurrentUserId();
            if (userId == 0) return;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = "SELECT COALESCE(TourProgress,'0,0,0,0,0,0') FROM Users WHERE UserID=@UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    var result = cmd.ExecuteScalar();
                    hfTourProgress.Value = result != null ? result.ToString() : "0,0,0,0,0,0";
                }
            }
        }

        [WebMethod]
        public static bool SaveTourProgress(string progress)
        {
            var ctx = HttpContext.Current;
            if (ctx == null || !ctx.Request.IsAuthenticated) return false;
            HttpCookie authCookie = ctx.Request.Cookies[FormsAuthentication.FormsCookieName];
            if (authCookie == null) return false;
            FormsAuthenticationTicket ticket = FormsAuthentication.Decrypt(authCookie.Value);
            if (ticket == null || string.IsNullOrEmpty(ticket.UserData)) return false;
            int userId = Convert.ToInt32(ticket.UserData);
            string cs = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"UPDATE Users SET TourProgress=@TourProgress, TourCompletedDate=CASE WHEN @TourProgress='1,1,1,1,1,1' AND TourCompletedDate IS NULL THEN GETDATE() ELSE TourCompletedDate END WHERE UserID=@UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TourProgress", progress);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    return cmd.ExecuteNonQuery() > 0;
                }
            }
        }

        [WebMethod]
        public static string DebugAuth()
        {
            var ctx = HttpContext.Current;
            if (ctx == null) return "NO_CONTEXT";
            bool auth = ctx.Request.IsAuthenticated;
            string user = auth ? ctx.User.Identity.Name : "(anonymous)";
            HttpCookie c = ctx.Request.Cookies[FormsAuthentication.FormsCookieName];
            return $"Auth={auth};User={user};AuthCookie={(c!=null)}";
        }

        protected void btnCompleteTour_Click(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated) { Response.Redirect("~/Account/Login.aspx"); return; }
            int userId = GetCurrentUserId();
            if (hfTourProgress.Value == "1,1,1,1,1,1")
            {
                var task = TaskService.GetTaskById(FindTourTaskId());
                if (task != null)
                {
                    var userTasks = TaskService.GetUserTasks(userId);
                    var userTask = userTasks.Find(ut => ut.TaskID == task.TaskID);
                    if (userTask != null && userTask.Status == "InProgress")
                    {
                        TaskService.CompleteTask(userId, task.TaskID);
                        SaveUserTourProgress(userId, hfTourProgress.Value);
                        Session["SuccessMessage"] = "恭喜！您已完成平台導覽任務。";
                        Response.Redirect("~/Tasks/MyTasks.aspx");
                    }
                }
            }
        }

        private void SaveUserTourProgress(int userId, string progress)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"UPDATE Users SET TourProgress=@TourProgress, TourCompletedDate=CASE WHEN @TourProgress='1,1,1,1,1,1' THEN GETDATE() ELSE TourCompletedDate END WHERE UserID=@UserID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@TourProgress", progress);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

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
                        int id; if (int.TryParse(ticket.UserData, out id)) return id;
                    }
                }
            }
            return 0;
        }

        private int FindTourTaskId()
        {
            try
            {
                var tasks = TaskService.GetAvailableTasks();
                foreach (var task in tasks)
                {
                    if (task.TaskName.Contains("平台導覽") || task.TaskName.Contains("導覽") || (task.Description ?? "").Contains("導覽"))
                        return task.TaskID;
                }
            }
            catch { }
            return 0;
        }
    }
}
