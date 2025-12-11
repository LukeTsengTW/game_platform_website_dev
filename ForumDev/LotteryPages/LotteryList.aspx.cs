using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Serialization;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.LotteryPages
{
    public partial class LotteryList : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserPoints();
                LoadUserStats();
                LoadLotteries();
            }
        }

        private void LoadUserPoints()
        {
            if (User.Identity.IsAuthenticated)
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser != null)
                {
                    lblUserPoints.Text = currentUser.Points.ToString("N0");
                }
            }
            else
            {
                lblUserPoints.Text = "請登入";
            }
        }

        private void LoadUserStats()
        {
            if (User.Identity.IsAuthenticated)
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser != null)
                {
                    // 獲取用戶抽獎記錄
                    List<LotteryRecord> records = LotteryService.GetUserLotteryRecords(currentUser.UserID);
                    
                    // 總參與次數
                    lblTotalDraws.Text = records.Count.ToString();
                    
                    // 待領取獎品數量
                    int unclaimedCount = records.Count(r => !r.IsClaimed);
                    lblUnclaimedPrizes.Text = unclaimedCount.ToString();
                    
                    // 累計獲得（計算積分和經驗值總價值）
                    int totalValue = 0;
                    foreach (var record in records.Where(r => r.IsClaimed))
                    {
                        if (record.Prize.PrizeType == "Points" || record.Prize.PrizeType == "Experience")
                        {
                            totalValue += record.Prize.PrizeValue;
                        }
                    }
                    lblTotalValue.Text = totalValue.ToString("N0");
                }
            }
            else
            {
                lblTotalDraws.Text = "0";
                lblUnclaimedPrizes.Text = "0";
                lblTotalValue.Text = "0";
            }
        }

        private void LoadLotteries()
        {
            try
            {
                List<Models.Lottery> lotteries = LotteryService.GetAvailableLotteries();

                if (lotteries.Count == 0)
                {
                    pnlNoLotteries.Visible = true;
                    rptLotteries.Visible = false;
                }
                else
                {
                    pnlNoLotteries.Visible = false;
                    rptLotteries.Visible = true;
                    rptLotteries.DataSource = lotteries;
                    rptLotteries.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowError("載入抽獎活動時發生錯誤: " + ex.Message);
            }
        }

        protected void rptLotteries_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            User currentUser = UserService.GetUserByUserName(User.Identity.Name);

            // 重置動畫標記
            hfAnimationPlayed.Value = "0";

            if (e.CommandName == "Draw")
            {
                try
                {
                    int lotteryId = Convert.ToInt32(e.CommandArgument);
                    
                    // 執行單抽（使用積分）
                    LotteryPrize prize = LotteryService.DrawLottery(currentUser.UserID, lotteryId, false);

                    // 顯示抽獎結果（動畫已在前端顯示）
                    string script = $@"
                        <script>
                            showResultAfterPostback('{EscapeJsString(prize.PrizeName)}', '{prize.IconUrl}', '{prize.PrizeType}');
                        </script>";

                    ClientScript.RegisterStartupScript(this.GetType(), "showResult", script, false);

                    // 重新載入頁面資料
                    LoadUserPoints();
                    LoadLotteries();
                    LoadUserStats();
                }
                catch (Exception ex)
                {
                    // 隱藏動畫並顯示錯誤
                    string errorScript = $@"
                        <script>
                            hideDrawingAnimation();
                            alert('{EscapeJsString(ex.Message)}');
                        </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "showError", errorScript, false);
                }
            }
            else if (e.CommandName == "Draw10")
            {
                try
                {
                    int lotteryId = Convert.ToInt32(e.CommandArgument);
                    
                    // 執行十連抽（使用積分）
                    List<LotteryPrize> prizes = LotteryService.DrawLottery10(currentUser.UserID, lotteryId, false);

                    // 序列化結果
                    var serializer = new JavaScriptSerializer();
                    var prizesData = prizes.Select(p => new {
                        PrizeName = p.PrizeName,
                        IconUrl = p.IconUrl,
                        PrizeType = p.PrizeType,
                        PrizeValue = p.PrizeValue
                    }).ToList();
                    string prizesJson = serializer.Serialize(prizesData);

                    // 顯示十連抽結果（動畫已在前端顯示）
                    string script = $@"
                        <script>
                            showResult10AfterPostback('{prizesJson.Replace("'", "\\'")}');
                        </script>";

                    ClientScript.RegisterStartupScript(this.GetType(), "showResult10", script, false);

                    // 重新載入頁面資料
                    LoadUserPoints();
                    LoadLotteries();
                    LoadUserStats();
                }
                catch (Exception ex)
                {
                    string errorScript = $@"
                        <script>
                            hideDrawingAnimation();
                            alert('{EscapeJsString(ex.Message)}');
                        </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "showError", errorScript, false);
                }
            }
            else if (e.CommandName == "DrawWithTicket")
            {
                try
                {
                    int lotteryId = Convert.ToInt32(e.CommandArgument);
                    
                    // 執行單抽（使用抽獎券）
                    LotteryPrize prize = LotteryService.DrawLottery(currentUser.UserID, lotteryId, true);

                    // 顯示抽獎結果（動畫已在前端顯示）
                    string script = $@"
                        <script>
                            showResultAfterPostback('{EscapeJsString(prize.PrizeName)}', '{prize.IconUrl}', '{prize.PrizeType}');
                        </script>";

                    ClientScript.RegisterStartupScript(this.GetType(), "showResult", script, false);

                    // 重新載入頁面資料
                    LoadUserPoints();
                    LoadLotteries();
                    LoadUserStats();
                }
                catch (Exception ex)
                {
                    string errorScript = $@"
                        <script>
                            hideDrawingAnimation();
                            alert('{EscapeJsString(ex.Message)}');
                        </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "showError", errorScript, false);
                }
            }
            else if (e.CommandName == "DrawWithTicket10")
            {
                try
                {
                    int lotteryId = Convert.ToInt32(e.CommandArgument);
                    
                    // 執行十連抽（使用抽獎券）
                    List<LotteryPrize> prizes = LotteryService.DrawLottery10(currentUser.UserID, lotteryId, true);

                    // 序列化結果
                    var serializer = new JavaScriptSerializer();
                    var prizesData = prizes.Select(p => new {
                        PrizeName = p.PrizeName,
                        IconUrl = p.IconUrl,
                        PrizeType = p.PrizeType,
                        PrizeValue = p.PrizeValue
                    }).ToList();
                    string prizesJson = serializer.Serialize(prizesData);

                    // 顯示十連抽結果（動畫已在前端顯示）
                    string script = $@"
                        <script>
                            showResult10AfterPostback('{prizesJson.Replace("'", "\\'")}');
                        </script>";

                    ClientScript.RegisterStartupScript(this.GetType(), "showResult10", script, false);

                    // 重新載入頁面資料
                    LoadUserPoints();
                    LoadLotteries();
                    LoadUserStats();
                }
                catch (Exception ex)
                {
                    string errorScript = $@"
                        <script>
                            hideDrawingAnimation();
                            alert('{EscapeJsString(ex.Message)}');
                        </script>";
                    ClientScript.RegisterStartupScript(this.GetType(), "showError", errorScript, false);
                }
            }
        }

        /// <summary>
        /// 轉義 JavaScript 字串中的特殊字元
        /// </summary>
        private string EscapeJsString(string str)
        {
            if (string.IsNullOrEmpty(str)) return str;
            return str.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r");
        }

        /// <summary>
        /// 生成抽獎券選項HTML
        /// </summary>
        protected string GetTicketOption(object allowedItemIdObj, object lotteryIdObj)
        {
            if (!User.Identity.IsAuthenticated || allowedItemIdObj == null || allowedItemIdObj == DBNull.Value)
                return "";

            int allowedItemId = Convert.ToInt32(allowedItemIdObj);
            int lotteryId = Convert.ToInt32(lotteryIdObj);
            
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            int ticketCount = LotteryService.GetUserItemQuantity(currentUser.UserID, allowedItemId);

            return $@"
                <div class='mt-2 pt-2 border-top'>
                    <div class='d-flex justify-content-between align-items-center'>
                        <span class='text-muted'>
                            <i class='bi bi-ticket-perforated'></i> 或使用抽獎券：
                        </span>
                        <span class='badge bg-{(ticketCount > 0 ? "success" : "secondary")}');
                            {ticketCount} 張
                        </span>
                    </div>
                </div>";
        }

        /// <summary>
        /// 獲取抽獎按鈕樣式
        /// </summary>
        protected string GetDrawButtonClass(object costPointsObj)
        {
            int costPoints = Convert.ToInt32(costPointsObj);
            return costPoints == 0 ? "btn btn-success btn-lg" : "btn btn-primary btn-lg";
        }

        /// <summary>
        /// 獲取抽獎按鈕文字
        /// </summary>
        protected string GetDrawButtonText(object costPointsObj)
        {
            int costPoints = Convert.ToInt32(costPointsObj);
            return costPoints == 0 ? "立即抽獎（免費）" : $"使用 {costPoints} 積分抽獎";
        }

        /// <summary>
        /// 獲取消耗顯示 HTML
        /// </summary>
        protected string GetCostDisplay(object costPointsObj, object allowedItemIdObj)
        {
            int costPoints = Convert.ToInt32(costPointsObj);
            bool hasAllowedItem = allowedItemIdObj != null && allowedItemIdObj != DBNull.Value;

            if (costPoints > 0)
            {
                // 積分抽獎
                return $"<h5 class='mb-0 text-primary'><img src='/Images/Icons/coin_rmbg.png' alt='積分' class='coin-icon-inline' />{costPoints} 積分</h5>";
            }
            else if (hasAllowedItem)
            {
                // 抽獎券抽獎
                return "<h5 class='mb-0 text-success'><img src='/Images/Items/ticket_rmbg.png' alt='抽獎券' class='ticket-icon-inline' /> 1 抽獎券</h5>";
            }
            else
            {
                // 免費抽獎
                return "<h5 class='mb-0 text-success'><i class='bi bi-gift-fill'></i> 免費</h5>";
            }
        }

        /// <summary>
        /// 檢查是否為免費抽獎（CostPoints=0 且 AllowedItemID 為空）
        /// </summary>
        protected bool IsFreeLottery(object costPointsObj, object allowedItemIdObj)
        {
            int costPoints = Convert.ToInt32(costPointsObj);
            bool hasAllowedItem = allowedItemIdObj != null && allowedItemIdObj != DBNull.Value;
            return costPoints == 0 && !hasAllowedItem;
        }

        /// <summary>
        /// 是否顯示抽獎券按鈕
        /// </summary>
        protected bool ShowTicketButton(object allowedItemIdObj)
        {
            if (!User.Identity.IsAuthenticated || allowedItemIdObj == null || allowedItemIdObj == DBNull.Value)
                return false;

            int allowedItemId = Convert.ToInt32(allowedItemIdObj);
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            int ticketCount = LotteryService.GetUserItemQuantity(currentUser.UserID, allowedItemId);

            return ticketCount > 0;
        }

        /// <summary>
        /// 是否顯示購買抽獎券按鈕
        /// </summary>
        protected bool ShowBuyTicketButton(object allowedItemIdObj)
        {
            if (!User.Identity.IsAuthenticated || allowedItemIdObj == null || allowedItemIdObj == DBNull.Value)
                return false;

            int allowedItemId = Convert.ToInt32(allowedItemIdObj);
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            int ticketCount = LotteryService.GetUserItemQuantity(currentUser.UserID, allowedItemId);

            return ticketCount == 0;
        }

        /// <summary>
        /// 獲取用戶擁有的抽獎券數量
        /// </summary>
        protected int GetUserTicketCount(object allowedItemIdObj)
        {
            if (!User.Identity.IsAuthenticated || allowedItemIdObj == null || allowedItemIdObj == DBNull.Value)
                return 0;

            int allowedItemId = Convert.ToInt32(allowedItemIdObj);
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            return LotteryService.GetUserItemQuantity(currentUser.UserID, allowedItemId);
        }

        /// <summary>
        /// 是否顯示抽獎券十連抽按鈕（需要至少10張）
        /// </summary>
        protected bool ShowTicket10Button(object allowedItemIdObj)
        {
            if (!User.Identity.IsAuthenticated || allowedItemIdObj == null || allowedItemIdObj == DBNull.Value)
                return false;

            int allowedItemId = Convert.ToInt32(allowedItemIdObj);
            User currentUser = UserService.GetUserByUserName(User.Identity.Name);
            int ticketCount = LotteryService.GetUserItemQuantity(currentUser.UserID, allowedItemId);

            return ticketCount >= 10;
        }

        // 輔助方法：獲取限制次數資訊
        protected string GetLimitInfo(object maxDrawsObj, object lotteryIdObj)
        {
            if (maxDrawsObj == null || maxDrawsObj == DBNull.Value)
            {
                return @"<small class='text-muted d-block mb-3'>
                            <i class='bi bi-infinity'></i> 無限次抽獎
                        </small>";
            }

            if (!User.Identity.IsAuthenticated)
            {
                return "";
            }

            try
            {
                int maxDraws = Convert.ToInt32(maxDrawsObj);
                int lotteryId = Convert.ToInt32(lotteryIdObj);
                
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser != null)
                {
                    List<LotteryRecord> records = LotteryService.GetUserLotteryRecords(currentUser.UserID);
                    int usedDraws = records.Count(r => r.LotteryID == lotteryId);
                    int remainingDraws = maxDraws - usedDraws;

                    string colorClass = remainingDraws > 0 ? "text-success" : "text-danger";
                    return $@"<small class='{colorClass} d-block mb-3'>
                                <i class='bi bi-clock-fill'></i> 
                                剩餘次數：{remainingDraws}/{maxDraws}
                            </small>";
                }
            }
            catch { }

            return "";
        }

        // 輔助方法：獲取活動時間文字
        protected string GetDateRangeText(object startDateObj, object endDateObj)
        {
            DateTime? startDate = startDateObj != DBNull.Value ? 
                (DateTime?)Convert.ToDateTime(startDateObj) : null;
            DateTime? endDate = endDateObj != DBNull.Value ? 
                (DateTime?)Convert.ToDateTime(endDateObj) : null;

            if (!startDate.HasValue && !endDate.HasValue)
            {
                return "長期活動";
            }
            else if (startDate.HasValue && !endDate.HasValue)
            {
                return $"從 {startDate.Value:yyyy/MM/dd} 開始";
            }
            else if (!startDate.HasValue && endDate.HasValue)
            {
                return $"至 {endDate.Value:yyyy/MM/dd}";
            }
            else
            {
                return $"{startDate.Value:yyyy/MM/dd} ~ {endDate.Value:yyyy/MM/dd}";
            }
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

        /// <summary>
        /// 獲取獎品池資料 (AJAX WebMethod)
        /// </summary>
        [WebMethod]
        public static string GetPrizePool(int lotteryId)
        {
            try
            {
                // 獲取抽獎活動資訊
                var lottery = LotteryService.GetLotteryById(lotteryId);
                if (lottery == null)
                {
                    return null;
                }

                // 獲取獎品列表
                var prizes = LotteryService.GetLotteryPrizes(lotteryId);

                // 組合結果
                var result = new
                {
                    lotteryName = lottery.LotteryName,
                    prizes = prizes.Select(p => new
                    {
                        PrizeID = p.PrizeID,
                        PrizeName = p.PrizeName,
                        PrizeType = p.PrizeType,
                        PrizeValue = p.PrizeValue,
                        IconUrl = p.IconUrl,
                        Probability = p. Probability,
                        Stock = p.Stock,
                        RemainingStock = p.RemainingStock
                    }).ToList()
                };

                // 序列化為 JSON
                var serializer = new JavaScriptSerializer();
                return serializer.Serialize(result);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"GetPrizePool Error: {ex.Message}");
                return null;
            }
        }
    }
}
