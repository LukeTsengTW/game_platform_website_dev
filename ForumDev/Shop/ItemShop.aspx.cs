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

namespace ForumDev.Shop
{
    public partial class ItemShop : Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadUserPoints();
                LoadItems();
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

        private void LoadItems()
        {
            try
            {
                List<Item> items = GetItems();

                // 應用篩選
                string category = ddlCategory.SelectedValue;
                if (!string.IsNullOrEmpty(category))
                {
                    items = items.Where(i => i.Type == category).ToList();
                }

                // 應用排序
                string sort = ddlSort.SelectedValue;
                switch (sort)
                {
                    case "price_asc":
                        items = items.OrderBy(i => i.Price).ToList();
                        break;
                    case "price_desc":
                        items = items.OrderByDescending(i => i.Price).ToList();
                        break;
                    case "popular":
                        // 可以根據購買次數排序，這裡先使用預設
                        break;
                    default:
                        items = items.OrderBy(i => i.DisplayOrder).ToList();
                        break;
                }

                if (items.Count == 0)
                {
                    pnlNoItems.Visible = true;
                    rptItems.Visible = false;
                }
                else
                {
                    pnlNoItems.Visible = false;
                    rptItems.Visible = true;
                    rptItems.DataSource = items;
                    rptItems.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowError("載入商品時發生錯誤: " + ex.Message);
            }
        }

        private List<Item> GetItems()
        {
            List<Item> items = new List<Item>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT ItemID, ItemName, Type, Description, IconUrl, 
                           Price, Stock, IsActive, CreatedDate, DisplayOrder
                    FROM Items
                    WHERE IsActive = 1
                    ORDER BY DisplayOrder, ItemID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new Item
                            {
                                ItemID = Convert.ToInt32(reader["ItemID"]),
                                ItemName = reader["ItemName"].ToString(),
                                Type = reader["Type"].ToString(),
                                Description = reader["Description"] != DBNull.Value ? 
                                    reader["Description"].ToString() : "",
                                IconUrl = reader["IconUrl"] != DBNull.Value ? 
                                    reader["IconUrl"].ToString() : "??",
                                Price = Convert.ToInt32(reader["Price"]),
                                Stock = reader["Stock"] != DBNull.Value ? 
                                    (int?)Convert.ToInt32(reader["Stock"]) : null,
                                IsActive = Convert.ToBoolean(reader["IsActive"]),
                                CreatedDate = Convert.ToDateTime(reader["CreatedDate"]),
                                DisplayOrder = Convert.ToInt32(reader["DisplayOrder"])
                            });
                        }
                    }
                }
            }

            return items;
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItems();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadItems();
        }

        protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Purchase")
            {
                PurchaseItemById(Convert.ToInt32(e.CommandArgument));
            }
        }

        protected void btnPurchaseInModal_Click(object sender, EventArgs e)
        {
            // 從 HiddenField 取得選中的商品 ID
            if (int.TryParse(hfSelectedItemID.Value, out int itemId))
            {
                PurchaseItemById(itemId);
            }
        }

        private void PurchaseItemById(int itemId)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + 
                    Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);

                if (currentUser != null)
                {
                    bool success = PurchaseItem(currentUser.UserID, itemId);
                    if (success)
                    {
                        ShowSuccess("兌換成功！商品已加入您的道具庫存。");
                        LoadUserPoints();
                        LoadItems();
                        
                        // 觸發 JavaScript 顯示成功 Modal
                        ClientScript.RegisterStartupScript(this.GetType(), "showModal", 
                            "showSuccessModal();", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        private bool PurchaseItem(int userId, int itemId)
        {
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    // 1. 取得商品資訊
                    string queryItem = "SELECT Price, Stock FROM Items WHERE ItemID = @ItemID";
                    int price;
                    int? stock;

                    using (SqlCommand cmd = new SqlCommand(queryItem, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@ItemID", itemId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read())
                            {
                                throw new Exception("商品不存在");
                            }
                            price = Convert.ToInt32(reader["Price"]);
                            stock = reader["Stock"] != DBNull.Value ? 
                                (int?)Convert.ToInt32(reader["Stock"]) : null;
                        }
                    }

                    // 2. 檢查庫存
                    if (stock.HasValue && stock.Value <= 0)
                    {
                        throw new Exception("商品庫存不足");
                    }

                    // 3. 檢查積分是否足夠
                    string queryPoints = "SELECT Points FROM Users WHERE UserID = @UserID";
                    int currentPoints;
                    using (SqlCommand cmd = new SqlCommand(queryPoints, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        currentPoints = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    if (currentPoints < price)
                    {
                        throw new Exception("積分不足，還需要 " + (price - currentPoints) + " 積分");
                    }

                    // 4. 扣除積分
                    string queryDeduct = "UPDATE Users SET Points = Points - @Price WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(queryDeduct, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@Price", price);
                        cmd.ExecuteNonQuery();
                    }

                    // 5. 減少庫存
                    if (stock.HasValue)
                    {
                        string queryStock = "UPDATE Items SET Stock = Stock - 1 WHERE ItemID = @ItemID";
                        using (SqlCommand cmd = new SqlCommand(queryStock, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@ItemID", itemId);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // 6. 加入用戶道具
                    string queryAddItem = @"
                        IF EXISTS (SELECT 1 FROM UserItems WHERE UserID = @UserID AND ItemID = @ItemID)
                            UPDATE UserItems SET Quantity = Quantity + 1 WHERE UserID = @UserID AND ItemID = @ItemID
                        ELSE
                            INSERT INTO UserItems (UserID, ItemID, Quantity, ObtainDate)
                            VALUES (@UserID, @ItemID, 1, GETDATE())";
                    
                    using (SqlCommand cmd = new SqlCommand(queryAddItem, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@ItemID", itemId);
                        cmd.ExecuteNonQuery();
                    }

                    // 7. 記錄交易
                    string queryTransaction = @"
                        INSERT INTO Transactions (UserID, Type, Amount, BalanceAfter, ItemID, Description, Timestamp)
                        VALUES (@UserID, 'Purchase', @Amount, @BalanceAfter, @ItemID, @Description, GETDATE())";
                    
                    using (SqlCommand cmd = new SqlCommand(queryTransaction, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@Amount", -price);
                        cmd.Parameters.AddWithValue("@BalanceAfter", currentPoints - price);
                        cmd.Parameters.AddWithValue("@ItemID", itemId);
                        cmd.Parameters.AddWithValue("@Description", "購買商品");
                        cmd.ExecuteNonQuery();
                    }

                    transaction.Commit();
                    
                    // 8. 觸發任務進度檢查
                    try
                    {
                        TaskProgressTracker.OnItemPurchased(userId, itemId, 1);
                    }
                    catch (Exception ex)
                    {
                        // 任務追蹤失敗不影響購買流程
                        System.Diagnostics.Debug.WriteLine($"Task tracking error: {ex.Message}");
                    }
                    
                    return true;
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        // 輔助方法
        protected string GetTypeColor(string type)
        {
            switch (type)
            {
                case "Booster": return "warning";
                case "Coupon": return "success";
                case "Physical": return "primary";
                case "Ticket": return "danger";
                default: return "secondary";
            }
        }

        protected string GetTypeName(string type)
        {
            switch (type)
            {
                case "Booster": return "加速道具";
                case "Coupon": return "優惠券";
                case "Physical": return "實體商品";
                case "Ticket": return "抽獎券";
                default: return "其他";
            }
        }

        protected string GetStockText(object stockObj)
        {
            if (stockObj == null || stockObj == DBNull.Value)
                return "庫存充足";

            int stock = Convert.ToInt32(stockObj);
            if (stock > 10)
                return "庫存充足";
            else if (stock > 0)
                return "剩餘 " + stock;
            else
                return "已售完";
        }

        protected bool IsInStock(object stockObj)
        {
            if (stockObj == null || stockObj == DBNull.Value)
                return true;

            int stock = Convert.ToInt32(stockObj);
            return stock > 0;
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
        /// 根據IconUrl返回圖示HTML
        /// 支援Font Awesome圖示、Bootstrap Icons和本地圖片
        /// </summary>
        protected string GetItemIcon(string iconUrl)
        {
            if (string.IsNullOrEmpty(iconUrl))
            {
                // 預設圖示
                return "<i class='fa-solid fa-box fa-4x text-primary'></i>";
            }

            // 判斷是Font Awesome圖示還是Bootstrap Icons
            if (iconUrl.StartsWith("fa-"))
            {
                return $"<i class='fa-solid {iconUrl} fa-4x text-primary'></i>";
            }
            else if (iconUrl.StartsWith("bi-"))
            {
                return $"<i class='bi {iconUrl}' style='font-size: 4rem; color: var(--bs-primary);'></i>";
            }
            // 判斷是否為完整URL路徑
            else if (iconUrl.StartsWith("/") || iconUrl.StartsWith("~/") || 
                     iconUrl.StartsWith("http://") || iconUrl.StartsWith("https://"))
            {
                // 處理ASP.NET的 ~/ 路徑
                string imagePath = iconUrl.StartsWith("~/") ? ResolveUrl(iconUrl) : iconUrl;
                return $"<img src='{imagePath}' alt='商品圖示' class='item-image' />";
            }
            else
            {
                // 相對路徑，自動補充 /Images/Items/
                return $"<img src='/Images/Items/{iconUrl}' alt='商品圖示' class='item-image' />";
            }
        }
    }
}
