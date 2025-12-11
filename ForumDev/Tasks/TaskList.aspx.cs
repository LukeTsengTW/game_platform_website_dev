using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Tasks
{
    public partial class TaskList : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTasks();
            }
        }

        private void LoadTasks()
        {
            try
            {
                // 取得所有可用任務
                List<GameTask> tasks = TaskService.GetAvailableTasks();

                // 應用篩選
                string category = ddlCategory.SelectedValue;
                if (!string.IsNullOrEmpty(category))
                {
                    tasks = tasks.Where(t => t.Category == category).ToList();
                }

                // 應用排序
                string sort = ddlSort.SelectedValue;
                switch (sort)
                {
                    case "exp_desc":
                        tasks = tasks.OrderByDescending(t => t.ExpReward).ToList();
                        break;
                    case "points_desc":
                        tasks = tasks.OrderByDescending(t => t.PointsReward).ToList();
                        break;
                    case "level_asc":
                        tasks = tasks.OrderBy(t => t.RequiredLevel).ToList();
                        break;
                    default:
                        // 保持預設排序 (DisplayOrder)
                        break;
                }

                // 檢查是否有已完成但未領取的任務（顯示領取所有獎勵按鈕）
                UpdateClaimAllButton();

                if (tasks.Count == 0)
                {
                    pnlNoTasks.Visible = true;
                    lblTaskCount.Text = "";
                }
                else
                {
                    pnlNoTasks.Visible = false;
                    lblTaskCount.Text = $"共 {tasks.Count} 個任務";
                }

                rptTasks.DataSource = tasks;
                rptTasks.DataBind();
            }
            catch (Exception ex)
            {
                // 記錄錯誤
                System.Diagnostics.Debug.WriteLine("Error loading tasks: " + ex.Message);
            }
        }

        private void UpdateClaimAllButton()
        {
            if (!User.Identity.IsAuthenticated)
            {
                btnClaimAll.Visible = false;
                return;
            }

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser != null)
                {
                    List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                    int completedCount = userTasks.Count(t => t.Status == "Completed");
                    
                    btnClaimAll.Visible = completedCount > 0;
                    if (completedCount > 0)
                    {
                        btnClaimAll.Text = $"🎁 領取所有獎勵 ({completedCount})";
                    }
                }
            }
            catch
            {
                btnClaimAll.Visible = false;
            }
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadTasks();
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            ddlCategory.SelectedIndex = 0;
            ddlSort.SelectedIndex = 0;
            LoadTasks();
        }

        protected void btnClaimAll_Click(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                
                if (currentUser == null) return;

                // 獲取所有已完成但未領取的任務
                List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                List<UserTask> completedTasks = userTasks.Where(t => t.Status == "Completed").ToList();

                if (completedTasks.Count == 0)
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "alert",
                        "alert('目前沒有可領取的獎勵');", true);
                    return;
                }

                int successCount = 0;
                int failCount = 0;
                int totalExp = 0;
                int totalPoints = 0;

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

                    message += "\\n\\n是否前往「我的任務」查看？";

                    ClientScript.RegisterStartupScript(this.GetType(), "claimAllResult",
                        $"if(confirm('{message}')) {{ window.location.href = '/Tasks/MyTasks.aspx'; }}", true);
                }
                else
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "alert",
                        "alert('領取獎勵失敗，請稍後再試');", true);
                }

                // 重新載入任務列表
                LoadTasks();
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert",
                    $"alert('領取獎勵時發生錯誤: {ex.Message}');", true);
            }
        }

        protected void btnAcceptAll_Click(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                
                if (currentUser != null)
                {
                    // 獲取所有可用任務
                    List<GameTask> allTasks = TaskService.GetAvailableTasks();
                    
                    // 獲取用戶已接收的任務
                    List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                    
                    int acceptedCount = 0;
                    int skippedCount = 0;
                    List<string> errors = new List<string>();

                    foreach (var task in allTasks)
                    {
                        // 檢查是否已經接收過該任務
                        bool alreadyAccepted = userTasks.Any(ut => ut.TaskID == task.TaskID);
                        
                        if (!alreadyAccepted)
                        {
                            // 檢查等級要求
                            if (currentUser.Level >= task.RequiredLevel)
                            {
                                try
                                {
                                    bool success = TaskService.StartTask(currentUser.UserID, task.TaskID);
                                    if (success)
                                    {
                                        acceptedCount++;
                                    }
                                    else
                                    {
                                        skippedCount++;
                                    }
                                }
                                catch (Exception ex)
                                {
                                    errors.Add($"任務「{task.TaskName}」接收失敗: {ex.Message}");
                                    skippedCount++;
                                }
                            }
                            else
                            {
                                // 等級不足，跳過
                                skippedCount++;
                            }
                        }
                        else
                        {
                            // 已接收過，跳過
                            skippedCount++;
                        }
                    }

                    // 顯示結果消息
                    string message = $"成功接收 {acceptedCount} 個任務";
                    
                    if (skippedCount > 0)
                    {
                        message += $"\\n跳過 {skippedCount} 個任務（已接收或等級不足）";
                    }
                    
                    if (errors.Count > 0)
                    {
                        message += "\\n\\n部分任務接收失敗：\\n" + string.Join("\\n", errors.Take(3));
                        if (errors.Count > 3)
                        {
                            message += $"\\n...還有 {errors.Count - 3} 個錯誤";
                        }
                    }

                    if (acceptedCount > 0)
                    {
                        message += "\\n\\n是否前往「我的任務」查看？";
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", 
                            $"if(confirm('{message}')) {{ window.location.href = '/Tasks/MyTasks.aspx'; }}", true);
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", 
                            $"alert('{message}');", true);
                    }

                    // 重新載入任務列表
                    LoadTasks();
                }
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", 
                    $"alert('接收任務時發生錯誤: {ex.Message}');", true);
            }
        }

        protected void rptTasks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            try
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);

                if (currentUser != null)
                {
                    if (e.CommandName == "StartTask")
                    {
                        bool success = TaskService.StartTask(currentUser.UserID, taskId);
                        if (success)
                        {
                            Response.Redirect("~/Tasks/MyTasks.aspx");
                        }
                    }
                    else if (e.CommandName == "ClaimReward")
                    {
                        bool success = TaskService.ClaimTaskReward(currentUser.UserID, taskId);
                        if (success)
                        {
                            // 顯示成功訊息並重新載入
                            ClientScript.RegisterStartupScript(this.GetType(), "alert", 
                                "alert('獎勵領取成功！經驗值和積分已增加。');", true);
                            LoadTasks();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // 顯示錯誤訊息
                ClientScript.RegisterStartupScript(this.GetType(), "alert", 
                    $"alert('錯誤: {ex.Message}');", true);
            }
        }

        protected void rptTasks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // 獲取控件
                LinkButton btnStartTask = (LinkButton)e.Item.FindControl("btnStartTask");
                LinkButton btnClaimReward = (LinkButton)e.Item.FindControl("btnClaimReward");
                HyperLink lnkInProgress = (HyperLink)e.Item.FindControl("lnkInProgress");
                Label lblCompleted = (Label)e.Item.FindControl("lblCompleted");
                HyperLink lnkLoginToStart = (HyperLink)e.Item.FindControl("lnkLoginToStart");

                // 檢查用戶是否登入
                if (!User.Identity.IsAuthenticated)
                {
                    lnkLoginToStart.Visible = true;
                    return;
                }

                // 獲取任務資料
                GameTask task = (GameTask)e.Item.DataItem;
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);

                if (currentUser != null && task != null)
                {
                    // 獲取用戶的任務狀態
                    List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                    UserTask userTask = userTasks.FirstOrDefault(ut => ut.TaskID == task.TaskID);

                    if (userTask != null)
                    {
                        // 根據任務狀態顯示相應按鈕
                        switch (userTask.Status)
                        {
                            case "InProgress":
                                lnkInProgress.Visible = true;
                                break;

                            case "Completed":
                                btnClaimReward.Visible = true;
                                break;

                            case "Claimed":
                                lblCompleted.Visible = true;
                                break;

                            default:
                                btnStartTask.Visible = true;
                                break;
                        }
                    }
                    else
                    {
                        // 還沒開始，顯示「開始任務」
                        btnStartTask.Visible = true;
                    }
                }
                else
                {
                    btnStartTask.Visible = true;
                }
            }
        }

        // 輔助方法：取得類別顏色
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

        // 輔助方法：取得類別名稱
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

        // 輔助方法：取得任務類型名稱
        protected string GetTaskTypeName(string type)
        {
            switch (type)
            {
                case "Once": return "單次任務";
                case "Daily": return "每日可重複";
                case "Weekly": return "每週可重複";
                case "Sequential": return "序列任務";
                case "Conditional": return "條件任務";
                default: return "一般任務";
            }
        }

        // 輔助方法：取得任務進度條 (如果用戶已開始此任務)
        protected string GetTaskProgressBar(object taskIdObj)
        {
            if (!User.Identity.IsAuthenticated)
                return "";

            try
            {
                int taskId = Convert.ToInt32(taskIdObj);
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                
                if (currentUser != null)
                {
                    List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                    UserTask userTask = userTasks.FirstOrDefault(ut => ut.TaskID == taskId);

                    if (userTask != null && userTask.Status != "Claimed")
                    {
                        string statusClass = GetStatusClass(userTask.Status);
                        return $@"
                            <div class='card-footer bg-light'>
                                <div class='d-flex justify-content-between align-items-center mb-1'>
                                    <small class='text-muted'>進度</small>
                                    <span class='badge bg-{statusClass}'>{GetStatusText(userTask.Status)}</span>
                                </div>
                                <div class='progress' style='height: 8px;'>
                                    <div class='progress-bar bg-{statusClass}' role='progressbar' 
                                         style='width: {userTask.Progress}%' 
                                         aria-valuenow='{userTask.Progress}' aria-valuemin='0' aria-valuemax='100'>
                                    </div>
                                </div>
                            </div>";
                    }
                }
            }
            catch { }

            return "";
        }

        private string GetStatusClass(string status)
        {
            switch (status)
            {
                case "InProgress": return "warning";
                case "Completed": return "success";
                default: return "secondary";
            }
        }

        private string GetStatusText(string status)
        {
            switch (status)
            {
                case "InProgress": return "進行中";
                case "Completed": return "已完成";
                case "Claimed": return "已領取";
                default: return "未開始";
            }
        }

        // 輔助方法：獲得任務按鈕（根據任務狀態顯示不同按鈕）
        protected string GetTaskButton(object taskIdObj)
        {
            if (!User.Identity.IsAuthenticated)
            {
                return @"<a href='/Account/Login.aspx' class='btn btn-outline-primary w-100'>
                    <i class='bi bi-box-arrow-in-right'></i> 登入後開始
                </a>";
            }

            try
            {
                int taskId = Convert.ToInt32(taskIdObj);
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                
                if (currentUser != null)
                {
                    List<UserTask> userTasks = TaskService.GetUserTasks(currentUser.UserID);
                    UserTask userTask = userTasks.FirstOrDefault(ut => ut.TaskID == taskId);

                    if (userTask != null)
                    {
                        switch (userTask.Status)
                        {
                            case "InProgress":
                                return $@"<a href='/Tasks/MyTasks.aspx' class='btn btn-info w-100'>
                                    <i class='bi bi-hourglass-split'></i> 進行中
                                </a>";

                            case "Completed":
                                // 返回一個特殊的標記，讓前端渲染 LinkButton
                                return "CLAIM:" + taskId;

                            case "Claimed":
                                return @"<button class='btn btn-secondary w-100' disabled>
                                    <i class='bi bi-check-circle-fill'></i> 已完成
                                </button>";
                        }
                    }
                }

                // 如果沒有開始過，返回特殊標記
                return "START:" + taskId;
            }
            catch
            {
                return @"<button class='btn btn-primary w-100' disabled>開始任務</button>";
            }
        }
    }
}
