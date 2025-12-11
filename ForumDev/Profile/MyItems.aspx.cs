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
    public partial class MyItems : Page
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
                LoadMyItems();
            }
        }

        private void LoadMyItems()
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                List<UserItem> userItems = GetUserItems(currentUser.UserID);

                if (userItems.Count == 0)
                {
                    pnlNoItems.Visible = true;
                    rptMyItems.Visible = false;
                    lblTotalItems.Text = "0";
                    lblItemTypes.Text = "0";
                    lblTotalValue.Text = "0";
                }
                else
                {
                    pnlNoItems.Visible = false;
                    rptMyItems.Visible = true;
                    rptMyItems.DataSource = userItems;
                    rptMyItems.DataBind();

                    // 計算統計
                    int totalQuantity = 0;
                    int totalValue = 0;
                    foreach (var item in userItems)
                    {
                        totalQuantity += item.Quantity;
                        totalValue += item.Quantity * item.Item.Price;
                    }

                    lblTotalItems.Text = totalQuantity.ToString();
                    lblItemTypes.Text = userItems.Count.ToString();
                    lblTotalValue.Text = totalValue.ToString("N0");
                }
            }
            catch (Exception ex)
            {
                ShowError("載入道具時發生錯誤: " + ex.Message);
            }
        }

        private List<UserItem> GetUserItems(int userId)
        {
            List<UserItem> items = new List<UserItem>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string query = @"
                    SELECT 
                        UI.UserItemID,
                        UI.Quantity,
                        UI.ObtainDate,
                        I.ItemID,
                        I.ItemName,
                        I.Type,
                        I.Description,
                        I.IconUrl,
                        I.Price
                    FROM UserItems UI
                    INNER JOIN Items I ON UI.ItemID = I.ItemID
                    WHERE UI.UserID = @UserID
                    ORDER BY UI.ObtainDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new UserItem
                            {
                                UserItemID = Convert.ToInt32(reader["UserItemID"]),
                                Quantity = Convert.ToInt32(reader["Quantity"]),
                                ObtainDate = Convert.ToDateTime(reader["ObtainDate"]),
                                Item = new Item
                                {
                                    ItemID = Convert.ToInt32(reader["ItemID"]),
                                    ItemName = reader["ItemName"].ToString(),
                                    Type = reader["Type"].ToString(),
                                    Description = reader["Description"] != DBNull.Value ? 
                                        reader["Description"].ToString() : "",
                                    IconUrl = reader["IconUrl"] != DBNull.Value ? 
                                        reader["IconUrl"].ToString() : "??",
                                    Price = Convert.ToInt32(reader["Price"])
                                }
                            });
                        }
                    }
                }
            }

            return items;
        }

        protected void rptMyItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int userItemId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Use")
            {
                UseItem(userItemId);
            }
        }

        protected void btnUseInModal_Click(object sender, EventArgs e)
        {
            // 從 HiddenField 取得選中的道具 ID
            if (int.TryParse(hfSelectedItemID.Value, out int userItemId))
            {
                UseItem(userItemId);
            }
        }

        private void UseItem(int userItemId)
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    SqlTransaction transaction = conn.BeginTransaction();

                    try
                    {
                        // 1. 取得道具資訊
                        string queryItem = @"
                            SELECT UI.Quantity, I.ItemName, I.Type, I.Description
                            FROM UserItems UI
                            INNER JOIN Items I ON UI.ItemID = I.ItemID
                            WHERE UI.UserItemID = @UserItemID AND UI.UserID = @UserID";

                        string itemName = "";
                        string itemType = "";
                        int quantity = 0;

                        using (SqlCommand cmd = new SqlCommand(queryItem, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserItemID", userItemId);
                            cmd.Parameters.AddWithValue("@UserID", currentUser.UserID);

                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (!reader.Read())
                                {
                                    throw new Exception("找不到該道具");
                                }
                                quantity = Convert.ToInt32(reader["Quantity"]);
                                itemName = reader["ItemName"].ToString();
                                itemType = reader["Type"].ToString();
                            }
                        }

                        // 2. 根據道具類型執行效果
                        string effectMessage = ApplyItemEffect(currentUser.UserID, itemType, conn, transaction);

                        // 3. 減少道具數量
                        if (quantity <= 1)
                        {
                            // 刪除道具記錄
                            string queryDelete = "DELETE FROM UserItems WHERE UserItemID = @UserItemID";
                            using (SqlCommand cmd = new SqlCommand(queryDelete, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@UserItemID", userItemId);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            // 減少數量
                            string queryUpdate = "UPDATE UserItems SET Quantity = Quantity - 1 WHERE UserItemID = @UserItemID";
                            using (SqlCommand cmd = new SqlCommand(queryUpdate, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@UserItemID", userItemId);
                                cmd.ExecuteNonQuery();
                            }
                        }

                        transaction.Commit();
                        ShowSuccess($"成功使用【{itemName}】！{effectMessage}");
                        LoadMyItems();
                    }
                    catch
                    {
                        transaction.Rollback();
                        throw;
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("使用道具失敗: " + ex.Message);
            }
        }

        private string ApplyItemEffect(int userId, string itemType, SqlConnection conn, SqlTransaction transaction)
        {
            string message = "";

            switch (itemType)
            {
                case "Booster":
                    // 經驗值加速道具: +50 經驗
                    string queryExp = "UPDATE Users SET TotalExp = TotalExp + 50 WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(queryExp, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.ExecuteNonQuery();
                    }
                    message = "獲得 50 經驗值！";
                    break;

                case "Coupon":
                    // 優惠券: +100 積分
                    string queryPoints = "UPDATE Users SET Points = Points + 100 WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(queryPoints, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.ExecuteNonQuery();
                    }
                    message = "獲得 100 積分！";
                    break;

                case "Ticket":
                    // 抽獎券: 不應該在這裡使用，應該到抽獎頁面使用
                    throw new Exception("抽獎券請到【抽獎中心】使用！");

                case "Physical":
                    // 實體商品: 標記已使用（需要人工處理）
                    message = "已登記兌換！請聯繫客服領取！";
                    break;

                default:
                    message = "道具效果已套用！";
                    break;
            }

            return message;
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

        protected bool CanUseItem(string type)
        {
            // 實體商品不能直接使用
            return type != "Physical";
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

        private void ShowInfo(string message)
        {
            lblMessage.Text = "<i class='bi bi-info-circle-fill'></i> " + message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-info";
        }

        /// <summary>
        /// 處理IconUrl的顯示HTML
        /// 支援Font Awesome與Bootstrap Icons，並且可以顯示本地圖片URL
        /// </summary>
        protected string GetItemIcon(string iconUrl)
        {
            if (string.IsNullOrEmpty(iconUrl))
            {
                // 預設圖示
                return "<i class='fa-solid fa-box fa-4x text-primary'></i>";
            }

            // 解析Font Awesome或Bootstrap Icons
            if (iconUrl.StartsWith("fa-"))
            {
                return $"<i class='fa-solid {iconUrl} fa-4x text-primary'></i>";
            }
            else if (iconUrl.StartsWith("bi-"))
            {
                return $"<i class='bi {iconUrl}' style='font-size: 4rem; color: var(--bs-primary);'></i>";
            }
            // 解析絕對或相對URL
            else if (iconUrl.StartsWith("/") || iconUrl.StartsWith("~/") || 
                     iconUrl.StartsWith("http://") || iconUrl.StartsWith("https://"))
            {
                // 對應ASP.NET的 ~/ 寫法
                string imagePath = iconUrl.StartsWith("~/") ? ResolveUrl(iconUrl) : iconUrl;
                return $"<img src='{imagePath}' alt='道具圖示' class='item-image' />";
            }
            else
            {
                // 預設路徑 /Images/Items/
                return $"<img src='/Images/Items/{iconUrl}' alt='道具圖示' class='item-image' />";
            }
        }
    }
}
