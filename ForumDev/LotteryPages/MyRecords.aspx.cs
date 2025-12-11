using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.LotteryPages
{
    public partial class MyRecords : Page
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
                LoadRecords();
            }

            // 無論是否回傳，維持「領取全部」按鈕狀態與顏色
            UpdateClaimAllButtonState();
        }

        private void LoadRecords(bool onlyUnclaimed = false)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                List<LotteryRecord> records = LotteryService.GetUserLotteryRecords(currentUser.UserID, onlyUnclaimed);

                // 更新待領取徽章
                int unclaimedCount = records.Count(r => !r.IsClaimed);
                if (unclaimedCount > 0)
                {
                    lblUnclaimedBadge.Text = unclaimedCount.ToString();
                    lblUnclaimedBadge.Visible = true;
                }
                else
                {
                    lblUnclaimedBadge.Visible = false;
                }

                // 顯示記錄
                if (records.Count == 0)
                {
                    pnlNoRecords.Visible = true;
                    rptRecords.Visible = false;
                }
                else
                {
                    pnlNoRecords.Visible = false;
                    rptRecords.Visible = true;
                    rptRecords.DataSource = records;
                    rptRecords.DataBind();
                }

                // 更新「領取全部」按鈕狀態
                UpdateClaimAllButtonState();
            }
            catch (Exception ex)
            {
                ShowError("載入記錄時發生錯誤: " + ex.Message);
            }
        }

        private void UpdateClaimAllButtonState()
        {
            try
            {
                if (btnClaimAll == null) return;
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                // 查詢是否有待領取
                var all = LotteryService.GetUserLotteryRecords(currentUser.UserID);
                int unclaimed = all.Count(r => !r.IsClaimed);

                if (unclaimed > 0)
                {
                    btnClaimAll.Enabled = true;
                    btnClaimAll.CssClass = "btn btn-success";
                }
                else
                {
                    btnClaimAll.Enabled = false;
                    btnClaimAll.CssClass = "btn btn-secondary";
                }
            }
            catch
            {
                // 略過狀態更新錯誤
            }
        }

        protected void btnShowAll_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowAll);
            LoadRecords(false);
        }

        protected void btnShowUnclaimed_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowUnclaimed);
            LoadRecords(true);
        }

        protected void btnShowClaimed_Click(object sender, EventArgs e)
        {
            SetActiveTab(btnShowClaimed);
            
            // 載入所有記錄後過濾已領取的
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            if (currentUser != null)
            {
                List<LotteryRecord> allRecords = LotteryService.GetUserLotteryRecords(currentUser.UserID);
                List<LotteryRecord> claimedRecords = allRecords.Where(r => r.IsClaimed).ToList();

                if (claimedRecords.Count == 0)
                {
                    pnlNoRecords.Visible = true;
                    rptRecords.Visible = false;
                }
                else
                {
                    pnlNoRecords.Visible = false;
                    rptRecords.Visible = true;
                    rptRecords.DataSource = claimedRecords;
                    rptRecords.DataBind();
                }
            }

            UpdateClaimAllButtonState();
        }

        private void SetActiveTab(LinkButton activeButton)
        {
            btnShowAll.CssClass = "nav-link";
            btnShowUnclaimed.CssClass = "nav-link";
            btnShowClaimed.CssClass = "nav-link";
            activeButton.CssClass = "nav-link active";
        }

        protected void rptRecords_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Claim")
            {
                try
                {
                    int recordId = Convert.ToInt32(e.CommandArgument);
                    User currentUser = UserService.GetUserByUserName(User.Identity.Name);

                    if (currentUser != null)
                    {
                        bool success = LotteryService.ClaimPrize(currentUser.UserID, recordId);

                        if (success)
                        {
                            ShowSuccess("獎品領取成功！已發放到您的帳戶。");
                            LoadRecords();
                        }
                        else
                        {
                            ShowError("領取獎品失敗，請稍後再試");
                        }
                    }
                }
                catch (Exception ex)
                {
                    ShowError(ex.Message);
                }
            }
        }

        protected void btnClaimAll_Click(object sender, EventArgs e)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                int count = LotteryService.ClaimAllUnclaimed(currentUser.UserID);
                if (count > 0)
                {
                    ShowSuccess($"已領取 {count} 筆獎品！");
                }
                else
                {
                    ShowError("目前沒有可領取的獎品。");
                }

                LoadRecords();
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        // 輔助方法：獲取獎品圖片 URL
        protected string GetPrizeImageUrl(string prizeType, int prizeValue, string iconUrl, string itemIconUrl)
        {
            switch (prizeType)
            {
                case "Points":
                    // 積分獎勵使用積分圖示
                    return ResolveUrl("~/Images/Icons/coin_rmbg.png");
                    
                case "Experience":
                    // 經驗值獎勵使用經驗圖示
                    return ResolveUrl("~/Images/Icons/exp.png");
                    
                case "Item":
                    // 道具獎勵優先使用 Items 表的圖片
                    if (!string.IsNullOrEmpty(itemIconUrl))
                    {
                        if (itemIconUrl.StartsWith("~/"))
                        {
                            return ResolveUrl(itemIconUrl);
                        }
                        else if (itemIconUrl.StartsWith("http://") || itemIconUrl.StartsWith("https://"))
                        {
                            return itemIconUrl;
                        }
                        else
                        {
                            return ResolveUrl("~/Images/Items/" + itemIconUrl);
                        }
                    }
                    // 備用：使用預設道具圖示
                    return ResolveUrl("~/Images/Icons/item-default.png");
                    
                case "Special":
                    // 特殊獎勵使用特殊圖示
                    return ResolveUrl("~/Images/Icons/special.png");
                    
                default:
                    // 預設圖示
                    return ResolveUrl("~/Images/Icons/gift.png");
            }
        }

        // 輔助方法：獲取獎品顏色
        protected string GetPrizeColor(string prizeType)
        {
            switch (prizeType)
            {
                case "Points": return "text-points";
                case "Experience": return "text-experience";
                case "Item": return "text-item";
                case "Special": return "text-special";
                default: return "text-secondary";
            }
        }

        // 輔助方法：獲取狀態顏色
        protected string GetStatusColor(object isClaimedObj)
        {
            bool isClaimed = Convert.ToBoolean(isClaimedObj);
            return isClaimed ? "success" : "warning";
        }

        // 輔助方法：獲取狀態文字
        protected string GetStatusText(object isClaimedObj)
        {
            bool isClaimed = Convert.ToBoolean(isClaimedObj);
            return isClaimed ? "已領取" : "待領取";
        }

        // 輔助方法：獲取獎品類型文字
        protected string GetPrizeTypeText(string prizeType)
        {
            switch (prizeType)
            {
                case "Points": return "積分獎勵";
                case "Experience": return "經驗獎勵";
                case "Item": return "道具獎勵";
                case "Special": return "特殊獎勵";
                default: return "其他";
            }
        }

        // 輔助方法：獲取獎品價值文字
        protected string GetPrizeValueText(string prizeType, object prizeValueObj)
        {
            int value = Convert.ToInt32(prizeValueObj);

            switch (prizeType)
            {
                case "Points":
                    return $"{value:N0} 積分";
                case "Experience":
                    return $"{value:N0} 經驗值";
                case "Item":
                    return "道具 x1";
                case "Special":
                    return "特殊獎品";
                default:
                    return "-";
            }
        }

        // 輔助方法：獲取已領取資訊
        protected string GetClaimedInfo(object isClaimedObj, object claimedDateObj)
        {
            bool isClaimed = Convert.ToBoolean(isClaimedObj);
            
            if (isClaimed && claimedDateObj != null && claimedDateObj != DBNull.Value)
            {
                DateTime claimedDate = Convert.ToDateTime(claimedDateObj);
                return $@"<div class='alert alert-success mb-0 py-2'>
                            <i class='bi bi-check-circle-fill'></i> 
                            已於 {claimedDate:yyyy/MM/dd HH:mm} 領取
                          </div>";
            }

            return "";
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
