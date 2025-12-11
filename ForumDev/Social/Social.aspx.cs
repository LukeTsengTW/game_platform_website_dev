using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;

namespace ForumDev.Social
{
    public partial class Social : System.Web.UI.Page
    {
        private int currentUserId = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            currentUserId = GetCurrentUserId();

            if (currentUserId == 0)
            {
                pnlNotLoggedIn.Visible = true;
                pnlMainContent.Visible = false;
                statsPanel.Visible = false;
                return;
            }

            // 無論是否 PostBack，都需要綁定聊天室資料，以便按鈕事件能正確觸發
            LoadChatRooms();

            if (!IsPostBack)
            {
                LoadUserInfo();
                LoadStats();
                LoadMessages();
                LoadFriends();
            }
            else
            {
                // PostBack 時恢復標籤頁狀態
                RestoreTabState();
            }
        }

        #region 載入資料

        private void LoadUserInfo()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;
                using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT Avatar FROM Users WHERE UserID = @UserID";
                    using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", currentUserId);
                        object result = cmd.ExecuteScalar();
                        string avatarUrl = result != DBNull.Value ? result.ToString() : null;
                        imgCurrentUserAvatar.ImageUrl = GetAvatarUrl(avatarUrl);
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadUserInfo Error: " + ex.Message);
            }
        }

        private void LoadStats()
        {
            try
            {
                var stats = SocialService.GetSocialStats(currentUserId);
                lblFriendCount.Text = stats.FriendCount.ToString();
                lblRoomCount.Text = stats.JoinedRooms.ToString();
                lblMessageCount.Text = stats.PostedMessages.ToString();

                if (stats.PendingRequests > 0)
                {
                    lblPendingBadge.Text = stats.PendingRequests.ToString();
                    lblPendingBadge.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadStats Error: " + ex.Message);
            }
        }

        private void LoadMessages()
        {
            try
            {
                var messages = SocialService.GetMessages();
                if (messages.Count > 0)
                {
                    rptMessages.DataSource = messages;
                    rptMessages.DataBind();
                    pnlNoMessages.Visible = false;
                }
                else
                {
                    pnlNoMessages.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadMessages Error: " + ex.Message);
                pnlNoMessages.Visible = true;
            }
        }

        private void LoadFriends()
        {
            try
            {
                // 載入待處理請求
                var pendingRequests = SocialService.GetPendingRequests(currentUserId);
                if (pendingRequests.Count > 0)
                {
                    rptPendingRequests.DataSource = pendingRequests;
                    rptPendingRequests.DataBind();
                    pnlPendingRequests.Visible = true;
                }
                else
                {
                    pnlPendingRequests.Visible = false;
                }

                // 載入好友列表
                var friends = SocialService.GetFriends(currentUserId);
                if (friends.Count > 0)
                {
                    rptFriends.DataSource = friends;
                    rptFriends.DataBind();
                    pnlNoFriends.Visible = false;
                }
                else
                {
                    pnlNoFriends.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadFriends Error: " + ex.Message);
            }
        }

        private void LoadChatRooms()
        {
            try
            {
                var rooms = SocialService.GetChatRooms(currentUserId);
                if (rooms.Count > 0)
                {
                    rptChatRooms.DataSource = rooms;
                    rptChatRooms.DataBind();
                    pnlNoRooms.Visible = false;
                }
                else
                {
                    pnlNoRooms.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadChatRooms Error: " + ex.Message);
                pnlNoRooms.Visible = true;
            }
        }

        protected void rptChatRooms_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var dataItem = e.Item.DataItem as ChatRoom;
                if (dataItem != null)
                {
                    System.Diagnostics.Debug.WriteLine($"ItemDataBound: RoomID={dataItem.RoomID}, IsMember={dataItem.IsMember}");
                }
            }
        }

        private void LoadChatMessages(int roomId)
        {
            try
            {
                var messages = SocialService.GetChatMessages(roomId);
                rptChatMessages.DataSource = messages;
                rptChatMessages.DataBind();
                hfCurrentRoomId.Value = roomId.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadChatMessages Error: " + ex.Message);
            }
        }

        #endregion

        #region 留言板功能

        protected void btnPostMessage_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtNewMessage.Text.Trim();
                if (string.IsNullOrEmpty(content))
                {
                    ShowMessage("請輸入留言內容", "warning");
                    return;
                }

                SocialService.PostMessage(currentUserId, content);
                txtNewMessage.Text = "";
                ShowMessage("發布成功！", "success");
                LoadMessages();
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMessage("發布失敗：" + ex.Message, "danger");
            }
        }

        protected void rptMessages_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int messageId = Convert.ToInt32(e.CommandArgument);

            try
            {
                switch (e.CommandName)
                {
                    case "Like":
                        bool liked = SocialService.LikeMessage(messageId, currentUserId);
                        LoadMessages();
                        break;

                    case "Delete":
                        SocialService.DeleteMessage(messageId, currentUserId);
                        ShowMessage("留言已刪除", "success");
                        LoadMessages();
                        LoadStats();
                        break;
                }
            }
            catch (Exception ex)
            {
                ShowMessage("操作失敗：" + ex.Message, "danger");
            }
        }

        #endregion

        #region 好友功能

        protected void btnSearchUser_Click(object sender, EventArgs e)
        {
            try
            {
                string keyword = txtSearchUser.Text.Trim();
                if (string.IsNullOrEmpty(keyword))
                {
                    pnlSearchResults.Visible = false;
                    SwitchToTab("friends");
                    return;
                }

                var users = SocialService.SearchUsers(keyword, currentUserId);
                if (users.Count > 0)
                {
                    rptSearchResults.DataSource = users;
                    rptSearchResults.DataBind();
                    pnlSearchResults.Visible = true;
                }
                else
                {
                    pnlSearchResults.Visible = false;
                    ShowMessage("沒有找到符合的用戶", "info");
                }
                
                // 保持在好友標籤頁
                SwitchToTab("friends");
            }
            catch (Exception ex)
            {
                ShowMessage("搜尋失敗：" + ex.Message, "danger");
                SwitchToTab("friends");
            }
        }

        protected void rptSearchResults_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "AddFriend")
            {
                try
                {
                    int friendId = Convert.ToInt32(e.CommandArgument);
                    bool sent = SocialService.SendFriendRequest(currentUserId, friendId);
                    if (sent)
                    {
                        ShowMessage("好友請求已發送！", "success");
                    }
                    else
                    {
                        ShowMessage("已經發送過請求或已是好友", "warning");
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("發送請求失敗：" + ex.Message, "danger");
                }
                
                // 保持在好友標籤頁
                SwitchToTab("friends");
            }
        }

        protected void rptPendingRequests_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int friendshipId = Convert.ToInt32(e.CommandArgument);

            try
            {
                switch (e.CommandName)
                {
                    case "Accept":
                        SocialService.AcceptFriendRequest(friendshipId, currentUserId);
                        ShowMessage("已接受好友請求！", "success");
                        break;

                    case "Reject":
                        SocialService.RejectFriendRequest(friendshipId, currentUserId);
                        ShowMessage("已拒絕好友請求", "info");
                        break;
                }

                LoadFriends();
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMessage("操作失敗：" + ex.Message, "danger");
            }
            
            // 保持在好友標籤頁
            SwitchToTab("friends");
        }

        protected void rptFriends_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Remove")
            {
                try
                {
                    int friendshipId = Convert.ToInt32(e.CommandArgument);
                    SocialService.RemoveFriend(friendshipId, currentUserId);
                    ShowMessage("已移除好友", "success");
                    LoadFriends();
                    LoadStats();
                }
                catch (Exception ex)
                {
                    ShowMessage("移除失敗：" + ex.Message, "danger");
                }
                
                // 保持在好友標籤頁
                SwitchToTab("friends");
            }
        }

        #endregion

        #region 聊天室功能

        protected void btnCreateRoom_Click(object sender, EventArgs e)
        {
            try
            {
                string roomName = txtRoomName.Text.Trim();
                string roomDesc = txtRoomDesc.Text.Trim();
                string roomType = ddlRoomType.SelectedValue;

                if (string.IsNullOrEmpty(roomName))
                {
                    ShowMessage("請輸入聊天室名稱", "warning");
                    SwitchToTab("chatrooms");
                    return;
                }

                int roomId = SocialService.CreateChatRoom(currentUserId, roomName, roomDesc, roomType);
                txtRoomName.Text = "";
                txtRoomDesc.Text = "";
                ShowMessage("聊天室創建成功！", "success");
                LoadChatRooms();
                LoadStats();
            }
            catch (Exception ex)
            {
                ShowMessage("創建失敗：" + ex.Message, "danger");
            }
            
            // 保持在聊天室標籤頁
            SwitchToTab("chatrooms");
        }

        protected void btnJoinRoom_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                RepeaterItem item = (RepeaterItem)btn.NamingContainer;
                HiddenField hfRoomId = (HiddenField)item.FindControl("hfRoomId");
                int roomId = Convert.ToInt32(hfRoomId.Value);

                System.Diagnostics.Debug.WriteLine($"btnJoinRoom_Click: RoomID={roomId}");

                SocialService.JoinChatRoom(roomId, currentUserId);
                ShowMessage("已加入聊天室！", "success");
                LoadChatRooms();
                LoadStats();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in btnJoinRoom_Click: {ex.Message}");
                ShowMessage("加入失敗：" + ex.Message, "danger");
            }
            
            SwitchToTab("chatrooms");
        }

        protected void btnEnterRoom_Click(object sender, EventArgs e)
        {
            try
            {
                Button btn = (Button)sender;
                RepeaterItem item = (RepeaterItem)btn.NamingContainer;
                HiddenField hfRoomId = (HiddenField)item.FindControl("hfRoomId");
                int roomId = Convert.ToInt32(hfRoomId.Value);

                System.Diagnostics.Debug.WriteLine($"btnEnterRoom_Click: RoomID={roomId}");

                // 取得聊天室名稱
                string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;
                using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
                {
                    conn.Open();
                    using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT RoomName FROM ChatRooms WHERE RoomID = @RoomID", conn))
                    {
                        cmd.Parameters.AddWithValue("@RoomID", roomId);
                        object result = cmd.ExecuteScalar();
                        lblChatRoomName.Text = result != null ? result.ToString() : "聊天室";
                    }
                }
                LoadChatMessages(roomId);
                // 重新載入聊天室列表以更新成員數
                LoadChatRooms();
                // 重新載入統計資料
                LoadStats();
                SwitchToTabAndShowChat("chatrooms");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in btnEnterRoom_Click: {ex.Message}");
                ShowMessage("進入失敗：" + ex.Message, "danger");
                SwitchToTab("chatrooms");
            }
        }

        protected void rptChatRooms_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // 如果 CommandArgument 為空或 CommandName 為空，忽略此事件
            // （這發生在使用 OnClick 事件處理程序時）
            if (string.IsNullOrEmpty(e.CommandName) || e.CommandArgument == null || string.IsNullOrEmpty(e.CommandArgument.ToString()))
            {
                System.Diagnostics.Debug.WriteLine("rptChatRooms_ItemCommand: Empty command, ignoring");
                return;
            }
            
            // 調試：確認事件被觸發
            System.Diagnostics.Debug.WriteLine($"rptChatRooms_ItemCommand triggered: CommandName={e.CommandName}, CommandArgument={e.CommandArgument}");

            int roomId;
            if (!int.TryParse(e.CommandArgument.ToString(), out roomId))
            {
                System.Diagnostics.Debug.WriteLine($"rptChatRooms_ItemCommand: Invalid RoomID format: {e.CommandArgument}");
                return;
            }

            try
            {
                switch (e.CommandName)
                {
                    case "Join":
                        System.Diagnostics.Debug.WriteLine($"Joining room {roomId}");
                        SocialService.JoinChatRoom(roomId, currentUserId);
                        ShowMessage("已加入聊天室！", "success");
                        LoadChatRooms();
                        LoadStats();
                        SwitchToTab("chatrooms");
                        break;

                    case "Enter":
                        System.Diagnostics.Debug.WriteLine($"Entering room {roomId}");
                        // 取得聊天室名稱
                        string connectionString = ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;
                        using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
                        {
                            conn.Open();
                            using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT RoomName FROM ChatRooms WHERE RoomID = @RoomID", conn))
                            {
                                cmd.Parameters.AddWithValue("@RoomID", roomId);
                                object result = cmd.ExecuteScalar();
                                lblChatRoomName.Text = result != null ? result.ToString() : "聊天室";
                            }
                        }
                        LoadChatMessages(roomId);
                        // 使用新的方法同時切換標籤頁並顯示 Modal
                        SwitchToTabAndShowChat("chatrooms");
                        break;
                        
                    default:
                        System.Diagnostics.Debug.WriteLine($"Unknown command: {e.CommandName}");
                        SwitchToTab("chatrooms");
                        break;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in rptChatRooms_ItemCommand: {ex.Message}");
                ShowMessage("操作失敗：" + ex.Message, "danger");
                SwitchToTab("chatrooms");
            }
        }

        protected void btnSendChat_Click(object sender, EventArgs e)
        {
            try
            {
                string content = txtChatMessage.Text.Trim();
                int roomId = Convert.ToInt32(hfCurrentRoomId.Value);

                if (string.IsNullOrEmpty(content) || roomId == 0)
                {
                    SwitchToTabAndShowChat("chatrooms");
                    return;
                }

                SocialService.SendChatMessage(roomId, currentUserId, content);
                txtChatMessage.Text = "";
                LoadChatMessages(roomId);
                // 使用新的方法同時切換標籤頁並顯示 Modal
                SwitchToTabAndShowChat("chatrooms");
            }
            catch (Exception ex)
            {
                ShowMessage("發送失敗：" + ex.Message, "danger");
                SwitchToTabAndShowChat("chatrooms");
            }
        }

        #endregion

        #region 輔助方法

        /// <summary>
        /// 切換到指定的標籤頁
        /// </summary>
        private void SwitchToTab(string tabId)
        {
            // 記錄當前標籤頁狀態
            // JavaScript 會在頁面載入時讀取這些值並恢復狀態
            hfActiveTab.Value = tabId;
            hfShowChatModal.Value = "false";
        }
        
        /// <summary>
        /// 切換到指定的標籤頁並顯示聊天室 Modal
        /// </summary>
        private void SwitchToTabAndShowChat(string tabId)
        {
            // 記錄當前標籤頁狀態和 Modal 顯示狀態
            // JavaScript 會在頁面載入時讀取這些值並恢復狀態
            hfActiveTab.Value = tabId;
            hfShowChatModal.Value = "true";
        }

        /// <summary>
        /// 恢復標籤頁狀態
        /// </summary>
        private void RestoreTabState()
        {
            // 標籤頁和 Modal 狀態由隱藏欄位保存，
            // 頁面載入後的 JavaScript 會自動讀取並恢復狀態
            // 這裡不需要額外的 ScriptManager.RegisterStartupScript
        }

        private int GetCurrentUserId()
        {
            if (User.Identity.IsAuthenticated)
            {
                var authCookie = Request.Cookies[FormsAuthentication.FormsCookieName];
                if (authCookie != null)
                {
                    var ticket = FormsAuthentication.Decrypt(authCookie.Value);
                    if (ticket != null && !string.IsNullOrEmpty(ticket.UserData))
                    {
                        return Convert.ToInt32(ticket.UserData);
                    }
                }
            }
            return 0;
        }

        protected string GetAvatarUrl(object avatarUrl)
        {
            // 如果為空或 null，使用外部預設頭像
            if (avatarUrl == null || avatarUrl == DBNull.Value || string.IsNullOrEmpty(avatarUrl.ToString()))
            {
                return "https://i.pravatar.cc/150?img=1";
            }
            
            string avatar = avatarUrl.ToString();
            
            // 如果是應用程式相對路徑（以 ~/ 開頭），使用 ResolveUrl 轉換
            if (avatar.StartsWith("~/"))
            {
                return ResolveUrl(avatar);
            }
            
            // 如果是外部 URL 或其他格式，直接返回
            return avatar;
        }

        protected string GetTimeAgo(DateTime dateTime)
        {
            TimeSpan span = DateTime.Now - dateTime;

            if (span.TotalMinutes < 1)
                return "剛剛";
            if (span.TotalMinutes < 60)
                return $"{(int)span.TotalMinutes} 分鐘前";
            if (span.TotalHours < 24)
                return $"{(int)span.TotalHours} 小時前";
            if (span.TotalDays < 7)
                return $"{(int)span.TotalDays} 天前";
            if (span.TotalDays < 30)
                return $"{(int)(span.TotalDays / 7)} 週前";
            if (span.TotalDays < 365)
                return $"{(int)(span.TotalDays / 30)} 個月前";
            
            return dateTime.ToString("yyyy/MM/dd");
        }

        protected bool IsOwner(object userId)
        {
            if (userId == null) return false;
            return Convert.ToInt32(userId) == currentUserId;
        }

        protected bool IsCurrentUser(object userId)
        {
            if (userId == null) return false;
            return Convert.ToInt32(userId) == currentUserId;
        }

        private void ShowMessage(string message, string type)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = $"alert alert-{type}";
            lblMessage.Text = message;
        }

        #endregion
    }
}
