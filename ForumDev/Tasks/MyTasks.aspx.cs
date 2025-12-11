using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Tasks
{
    public partial class MyTasks : Page
    {
        private string currentFilter = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            // 檢查是否登入
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            if (!IsPostBack)
            {
                LoadMyTasks();
            }
        }

        private void LoadMyTasks(string statusFilter = null)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                // 載入用戶任務
                List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID, statusFilter);

                // 更新統計
                UpdateStatistics(userTasks);

                // 檢查是否有已完成但未領取的任務，顯示「領取所有獎勵」按鈕
                int completedCount = userTasks.Count(t => t.Status == "Completed");
                btnClaimAll.Visible = completedCount > 0;
                if (completedCount > 0)
                {
                    btnClaimAll.Text = $"🎁 領取所有獎勵 ({completedCount})";
                }

                // 顯示任務列表
                if (userTasks.Count == 0)
                {
                    pnlNoTasks.Visible = true;
                    rptMyTasks.Visible = false;
                }
                else
                {
                    pnlNoTasks.Visible = false;
                    rptMyTasks.Visible = true;
                    rptMyTasks.DataSource = userTasks;
                    rptMyTasks.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowError("載入任務時發生錯誤: " + ex.Message);
            }
        }

        private void UpdateStatistics(List<UserTask> userTasks)
        {
            // 進行中：狀態為 InProgress 的任務
            lblInProgressCount.Text = userTasks.Count(t => t.Status == "InProgress").ToString();
            
            // 待領取：狀態為 Completed 的任務（已完成但尚未領取獎勵）
            lblCompletedCount.Text = userTasks.Count(t => t.Status == "Completed").ToString();
            
            // 已領取：狀態為 Claimed 的任務
            int claimedCount = userTasks.Count(t => t.Status == "Claimed");
            lblClaimedCount.Text = claimedCount.ToString();
            
            // 總完成數：已領取的任務數量（真正完成的任務）
            int totalCompleted = userTasks.Count(t => t.Status == "Completed" || t.Status == "Claimed");
            lblTotalCount.Text = totalCompleted.ToString();
        }

        protected void btnShowAll_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowAll);
            LoadMyTasks();
        }

        protected void btnShowInProgress_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowInProgress);
            LoadMyTasks("InProgress");
        }

        protected void btnShowCompleted_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowCompleted);
            LoadMyTasks("Completed");
        }

        protected void btnShowClaimed_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowClaimed);
            LoadMyTasks("Claimed");
        }

        protected void btnClaimAll_Click(object sender, EventArgs e)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                // 獲取所有已完成但未領取的任務
                List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                List<UserTask> completedTasks = userTasks.Where(t => t.Status == "Completed").ToList();

                if (completedTasks.Count == 0)
                {
                    ShowError("目前沒有可領取的獎勵");
                    return;
                }

                int successCount = 0;
                int failCount = 0;
                int totalExp = 0;
                int totalPoints = 0;
                List<string> claimedTasks = new List<string>();

                foreach (var task in completedTasks)
                {
                    try
                    {
                        bool success = TaskService.ClaimTaskReward(currentUser.UserID, task.TaskID);
                        if (success)
                        {
                            successCount++;
                            totalExp += task.Task.ExpReward;
                            totalPoints += task.Task.PointsReward;
                            claimedTasks.Add(task.Task.TaskName);
                        }
                        else
                        {
                            failCount++;
                        }
                    }
                    catch
                    {
                        failCount++;
                    }
                }

                // 顯示結果
                if (successCount > 0)
                {
                    string message = $"🎉 成功領取 {successCount} 個任務的獎勵！\\n" +
                                   $"獲得：{totalExp} EXP + {totalPoints} 積分";
                    
                    if (failCount > 0)
                    {
                        message += $"\\n（{failCount} 個任務領取失敗）";
                    }

                    ShowSuccess($"成功領取 {successCount} 個任務的獎勵！獲得 {totalExp} EXP + {totalPoints} 積分");
                    
                    ClientScript.RegisterStartupScript(this.GetType(), "claimAllResult",
                        $"alert('{message}');", true);
                }
                else
                {
                    ShowError("領取獎勵失敗，請稍後再試");
                }

                // 重新載入任務列表
                LoadMyTasks();
            }
            catch (Exception ex)
            {
                ShowError("領取獎勵時發生錯誤: " + ex.Message);
            }
        }

        private void SetActiveTab(LinkButton activeButton)
        {
            btnShowAll.CssClass = "nav-link";
            btnShowInProgress.CssClass = "nav-link";
            btnShowCompleted.CssClass = "nav-link";
            btnShowClaimed.CssClass = "nav-link";
            activeButton.CssClass = "nav-link active";
        }

        protected void rptMyTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                if (e.CommandName == "Claim")
                {
                    string[] args = e.CommandArgument.ToString().Split(',');
                    int userTaskId = Convert.ToInt32(args[0]);
                    int taskId = Convert.ToInt32(args[1]);

                    bool success = TaskService.ClaimTaskReward(currentUser.UserID, taskId);
                    
                    if (success)
                    {
                        ShowSuccess("恭喜！獎勵已成功領取！");
                        LoadMyTasks();
                    }
                    else
                    {
                        ShowError("領取獎勵失敗，請稍後再試");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        // 輔助方法
        protected string GetCategoryColor(string category)
        {
            switch (category)
            {
                case "Daily": return "primary";
                case "Learning": return "info";
                case "Shopping": return "success";
                case "Social": return "warning";
                case "Event": return "danger";
                default: return "secondary";
            }
        }

        protected string GetCategoryName(string category)
        {
            switch (category)
            {
                case "Daily": return "每日任務";
                case "Learning": return "學習任務";
                case "Shopping": return "購物任務";
                case "Social": return "社交任務";
                case "Event": return "限時活動";
                default: return "一般任務";
            }
        }

        protected string GetStatusColor(string status)
        {
            switch (status)
            {
                case "InProgress": return "warning";
                case "Completed": return "success";
                case "Claimed": return "info";
                default: return "secondary";
            }
        }

        protected string GetStatusText(string status)
        {
            switch (status)
            {
                case "InProgress": return "進行中";
                case "Completed": return "已完成";
                case "Claimed": return "已領取";
                default: return "未開始";
            }
        }

        protected string GetStatusIcon(string status)
        {
            switch (status)
            {
                case "InProgress": return "hourglass-split";
                case "Completed": return "check-circle-fill";
                case "Claimed": return "trophy-fill";
                default: return "circle";
            }
        }

        protected string GetCompletedDateInfo(object completedDateObj)
        {
            if (completedDateObj == null || completedDateObj == DBNull.Value)
                return "";

            DateTime completedDate = Convert.ToDateTime(completedDateObj);
            return $@"<small class='text-muted d-block'>
                        <i class='bi bi-check-circle-fill text-success'></i>
                        完成時間: {completedDate:yyyy/MM/dd HH:mm}
                      </small>";
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
