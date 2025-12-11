using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Profile
{
    public partial class MyProfile : Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Account/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        protected void btnUploadAvatar_Click(object sender, EventArgs e)
        {
            try
            {
                // 獲取當前用戶
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null)
                {
                    ShowMessage("找不到用戶資訊", "danger");
                    return;
                }

                byte[] imageBytes = null;
                string fileExtension = ".png"; // 裁切後統一使用 PNG 格式

                // 檢查是否有裁切後的圖片數據（Base64）
                if (!string.IsNullOrEmpty(hfCroppedImage.Value))
                {
                    try
                    {
                        // 從 Base64 字串獲取圖片數據
                        string base64Data = hfCroppedImage.Value;
                        
                        // 移除 data:image/png;base64, 前綴
                        if (base64Data.Contains(","))
                        {
                            base64Data = base64Data.Substring(base64Data.IndexOf(",") + 1);
                        }
                        
                        imageBytes = Convert.FromBase64String(base64Data);
                        
                        // 驗證圖片數據
                        if (imageBytes == null || imageBytes.Length == 0)
                        {
                            ShowMessage("圖片數據無效！", "danger");
                            return;
                        }

                        // 檢查檔案大小（10MB）
                        if (imageBytes.Length > 10 * 1024 * 1024)
                        {
                            ShowMessage("圖片檔案大小不能超過 10MB！", "danger");
                            return;
                        }

                        // 驗證是否為有效圖片
                        using (var ms = new MemoryStream(imageBytes))
                        {
                            try
                            {
                                using (var img = Image.FromStream(ms))
                                {
                                    if (img.Width <= 0 || img.Height <= 0)
                                    {
                                        ShowMessage("無效的圖片檔案！", "danger");
                                        return;
                                    }
                                }
                            }
                            catch
                            {
                                ShowMessage("無法讀取圖片檔案，請確認檔案格式正確！", "danger");
                                return;
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowMessage($"圖片處理失敗：{ex.Message}", "danger");
                        System.Diagnostics.Debug.WriteLine($"Error processing base64 image: {ex.Message}");
                        return;
                    }
                }
                // 如果沒有裁切數據，檢查是否有直接上傳的檔案
                else if (fuAvatar.HasFile)
                {
                    // 驗證檔案類型
                    fileExtension = Path.GetExtension(fuAvatar.FileName).ToLower();
                    string[] allowedExtensions = { ".png", ".jpg", ".jpeg", ".gif" };
                    
                    if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                    {
                        ShowMessage("僅支援 PNG、JPG、JPEG、GIF 格式的圖片檔案！", "danger");
                        return;
                    }

                    // 驗證檔案大小（10MB）
                    if (fuAvatar.PostedFile.ContentLength > 10 * 1024 * 1024)
                    {
                        ShowMessage("圖片檔案大小不能超過 10MB！", "danger");
                        return;
                    }

                    // 讀取檔案數據
                    imageBytes = fuAvatar.FileBytes;

                    // 驗證是否為有效圖片
                    using (var ms = new MemoryStream(imageBytes))
                    {
                        try
                        {
                            using (var img = Image.FromStream(ms))
                            {
                                if (img.Width <= 0 || img.Height <= 0)
                                {
                                    ShowMessage("無效的圖片檔案！", "danger");
                                    return;
                                }
                            }
                        }
                        catch
                        {
                            ShowMessage("無法讀取圖片檔案，請確認檔案格式正確！", "danger");
                            return;
                        }
                    }
                }
                else
                {
                    ShowMessage("請選擇要上傳的圖片檔案。", "warning");
                    return;
                }

                // 創建上傳目錄
                string uploadFolder = Server.MapPath("~/Uploads/Avatars/");
                if (!Directory.Exists(uploadFolder))
                {
                    Directory.CreateDirectory(uploadFolder);
                }

                // 生成唯一檔名
                string fileName = $"{currentUser.UserID}_{DateTime.Now:yyyyMMddHHmmss}{fileExtension}";
                string filePath = Path.Combine(uploadFolder, fileName);

                // 刪除舊頭像（如果存在且不是預設頭像）
                if (!string.IsNullOrEmpty(currentUser.Avatar) && 
                    !currentUser.Avatar.Contains("pravatar.cc") &&
                    currentUser.Avatar.StartsWith("~/"))
                {
                    try
                    {
                        string oldAvatarPath = Server.MapPath(currentUser.Avatar);
                        if (File.Exists(oldAvatarPath))
                        {
                            File.Delete(oldAvatarPath);
                        }
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"無法刪除舊頭像: {ex.Message}");
                    }
                }

                // 保存新頭像
                File.WriteAllBytes(filePath, imageBytes);

                // 驗證檔案是否成功保存
                if (!File.Exists(filePath))
                {
                    ShowMessage("檔案保存失敗，請檢查伺服器權限設定。", "danger");
                    return;
                }

                // 更新資料庫
                string avatarUrl = $"~/Uploads/Avatars/{fileName}";
                bool success = UserService.UpdateProfile(currentUser.UserID, avatarUrl, currentUser.Bio);

                if (success)
                {
                    ShowMessage("頭像更換成功！", "success");
                    
                    // 設定圖片路徑並添加時間戳避免快取
                    string displayUrl = ResolveUrl(avatarUrl) + "?t=" + DateTime.Now.Ticks;
                    imgAvatar.ImageUrl = displayUrl;
                    
                    // 清空 HiddenField
                    hfCroppedImage.Value = string.Empty;
                    
                    // 記錄成功訊息
                    System.Diagnostics.Debug.WriteLine($"頭像上傳成功: {filePath}");
                    System.Diagnostics.Debug.WriteLine($"資料庫路徑: {avatarUrl}");
                    System.Diagnostics.Debug.WriteLine($"顯示路徑: {displayUrl}");
                }
                else
                {
                    ShowMessage("頭像更新失敗，請稍後再試。", "danger");
                    
                    // 刪除已上傳的檔案
                    if (File.Exists(filePath))
                    {
                        File.Delete(filePath);
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage($"上傳失敗：{ex.Message}", "danger");
                System.Diagnostics.Debug.WriteLine($"Error uploading avatar: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");
            }
        }

        private void ShowMessage(string message, string type)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = $"alert alert-{type} alert-dismissible fade show";
            lblMessage.Text = message;
        }

        private void LoadUserProfile()
        {
            try
            {
                User currentUser = UserService.GetUserByUserName(User.Identity.Name);
                if (currentUser == null) return;

                // 載入基本資訊
                lblUserName.Text = currentUser.UserName;
                lblLevel.Text = currentUser.Level.ToString();
                lblBio.Text = string.IsNullOrEmpty(currentUser.Bio) ? "這個用戶很懶，什麼都沒留下..." : currentUser.Bio;
                lblPoints.Text = currentUser.Points.ToString();
                lblTotalExp.Text = currentUser.TotalExp.ToString();
                lblRegisterDate.Text = currentUser.RegisterDate.ToString("yyyy/MM/dd");

                // 正確載入頭像
                if (!string.IsNullOrEmpty(currentUser.Avatar))
                {
                    // 使用 ResolveUrl 來正確處理相對路徑
                    string avatarUrl = ResolveUrl(currentUser.Avatar);
                    
                    // 添加時間戳避免瀏覽器快取
                    if (currentUser.Avatar.StartsWith("~/"))
                    {
                        string physicalPath = Server.MapPath(currentUser.Avatar);
                        if (File.Exists(physicalPath))
                        {
                            FileInfo fileInfo = new FileInfo(physicalPath);
                            avatarUrl += "?t=" + fileInfo.LastWriteTime.Ticks;
                        }
                    }
                    
                    imgAvatar.ImageUrl = avatarUrl;
                    
                    // 記錄載入資訊
                    System.Diagnostics.Debug.WriteLine($"載入頭像: {avatarUrl}");
                }

                // 載入統計數據
                UserStats stats = UserService.GetUserStats(currentUser.UserID);
                lblTasksCompleted.Text = stats.TasksCompleted.ToString();
                lblAchievements.Text = stats.AchievementsUnlocked.ToString();

                // 計算等級進度
                CalculateLevelProgress(currentUser);

                // 載入最近活動
                LoadRecentActivities(currentUser.UserID);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading profile: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");
            }
        }

        private void CalculateLevelProgress(User user)
        {
            int currentLevel = user.Level;
            int nextLevel = currentLevel + 1;
            
            // 簡單的升級公式: 每級需要 100 經驗值
            int currentLevelBaseExp = (currentLevel - 1) * 100;
            int nextLevelExp = currentLevel * 100;
            int expInCurrentLevel = user.TotalExp - currentLevelBaseExp;
            int expNeededForLevel = nextLevelExp - currentLevelBaseExp;
            int expToNextLevel = nextLevelExp - user.TotalExp;

            lblCurrentLevel.Text = currentLevel.ToString();
            lblNextLevel.Text = nextLevel.ToString();
            lblExpProgress.Text = expInCurrentLevel.ToString();
            lblExpRequired.Text = expNeededForLevel.ToString();
            lblExpToNext.Text = expToNextLevel > 0 ? expToNextLevel.ToString() : "0";
            
            decimal progressPercent = expNeededForLevel > 0 ? 
                Math.Round((decimal)expInCurrentLevel / expNeededForLevel * 100, 1) : 100;
            lblLevelPercent.Text = progressPercent.ToString("0.0");
            
            ViewState["LevelProgressWidth"] = progressPercent.ToString("0.0");
        }

        protected string GetLevelProgressWidth()
        {
            return ViewState["LevelProgressWidth"]?.ToString() ?? "0";
        }

        private void LoadRecentActivities(int userId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT TOP 10 
                            Type,
                            Amount,
                            Description,
                            Timestamp
                        FROM Transactions
                        WHERE UserID = @UserID
                        ORDER BY Timestamp DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            adapter.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                rptRecentActivities.DataSource = dt;
                                rptRecentActivities.DataBind();
                                pnlNoActivities.Visible = false;
                            }
                            else
                            {
                                pnlNoActivities.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error loading recent activities: " + ex.Message);
                pnlNoActivities.Visible = true;
            }
        }

        // 輔助方法
        protected string GetActivityIcon(string type)
        {
            switch (type)
            {
                case "TaskReward": return "trophy-fill";
                case "Purchase": return "cart-fill";
                case "Refund": return "arrow-counterclockwise";
                case "Gift": return "gift-fill";
                default: return "circle-fill";
            }
        }

        protected string GetActivityColor(string type)
        {
            switch (type)
            {
                case "TaskReward": return "success";
                case "Purchase": return "danger";
                case "Refund": return "warning";
                case "Gift": return "info";
                default: return "secondary";
            }
        }

        protected string GetAmountDisplay(object amountObj)
        {
            if (amountObj == null || amountObj == DBNull.Value)
                return "<strong class='text-secondary'>0</strong>";

            int amount = Convert.ToInt32(amountObj);
            
            if (amount > 0)
            {
                // 正數：綠色，顯示 +
                return $"<strong class='text-success'>+{amount}</strong>";
            }
            else if (amount < 0)
            {
                // 負數：紅色，只顯示數字（已經包含負號）
                return $"<strong class='text-danger'>{amount}</strong>";
            }
            else
            {
                // 零：灰色
                return "<strong class='text-secondary'>0</strong>";
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
    }
}
