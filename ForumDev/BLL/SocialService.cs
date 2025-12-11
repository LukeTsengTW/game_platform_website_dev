using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ForumDev.DAL;
using ForumDev.Models;

namespace ForumDev.BLL
{
    /// <summary>
    /// 社交功能服務層
    /// </summary>
    public static class SocialService
    {
        #region 留言板功能

        /// <summary>
        /// 取得留言板訊息（分頁）
        /// </summary>
        public static List<BoardMessage> GetMessages(int page = 1, int pageSize = 20)
        {
            List<BoardMessage> messages = new List<BoardMessage>();
            int offset = (page - 1) * pageSize;

            string query = @"
                SELECT 
                    M.MessageID, M.UserID, M.Content, M.PostedDate, M.LikeCount,
                    U.UserName, U.Avatar, U.Level
                FROM MessageBoard M
                INNER JOIN Users U ON M.UserID = U.UserID
                WHERE M.IsDeleted = 0
                ORDER BY M.PostedDate DESC
                OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

            SqlParameter[] parameters = {
                new SqlParameter("@Offset", offset),
                new SqlParameter("@PageSize", pageSize)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                messages.Add(new BoardMessage
                {
                    MessageID = Convert.ToInt32(row["MessageID"]),
                    UserID = Convert.ToInt32(row["UserID"]),
                    UserName = row["UserName"].ToString(),
                    AvatarUrl = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                    UserLevel = Convert.ToInt32(row["Level"]),
                    Content = row["Content"].ToString(),
                    PostedDate = Convert.ToDateTime(row["PostedDate"]),
                    LikeCount = Convert.ToInt32(row["LikeCount"])
                });
            }

            return messages;
        }

        /// <summary>
        /// 發布留言
        /// </summary>
        public static int PostMessage(int userId, string content)
        {
            if (string.IsNullOrWhiteSpace(content))
                throw new ArgumentException("留言內容不能為空");

            if (content.Length > 1000)
                throw new ArgumentException("留言內容不能超過1000字");

            string query = @"
                INSERT INTO MessageBoard (UserID, Content, PostedDate)
                VALUES (@UserID, @Content, GETDATE());
                SELECT SCOPE_IDENTITY();";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Content", content.Trim())
            };

            object result = DBHelper.ExecuteScalar(query, parameters);
            return Convert.ToInt32(result);
        }

        /// <summary>
        /// 刪除留言
        /// </summary>
        public static bool DeleteMessage(int messageId, int userId)
        {
            string query = @"
                UPDATE MessageBoard 
                SET IsDeleted = 1 
                WHERE MessageID = @MessageID AND UserID = @UserID";

            SqlParameter[] parameters = {
                new SqlParameter("@MessageID", messageId),
                new SqlParameter("@UserID", userId)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 按讚留言
        /// </summary>
        public static bool LikeMessage(int messageId, int userId)
        {
            string checkQuery = "SELECT COUNT(*) FROM MessageLikes WHERE MessageID = @MessageID AND UserID = @UserID";
            SqlParameter[] checkParams = {
                new SqlParameter("@MessageID", messageId),
                new SqlParameter("@UserID", userId)
            };

            int exists = Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams));

            if (exists > 0)
            {
                // 已按讚，取消 - 創建新的參數陣列
                string deleteQuery = @"
                    DELETE FROM MessageLikes WHERE MessageID = @MessageID AND UserID = @UserID;
                    UPDATE MessageBoard SET LikeCount = LikeCount - 1 WHERE MessageID = @MessageID;";
                SqlParameter[] deleteParams = {
                    new SqlParameter("@MessageID", messageId),
                    new SqlParameter("@UserID", userId)
                };
                DBHelper.ExecuteNonQuery(deleteQuery, deleteParams);
                return false;
            }
            else
            {
                // 未按讚，新增 - 創建新的參數陣列
                string insertQuery = @"
                    INSERT INTO MessageLikes (MessageID, UserID) VALUES (@MessageID, @UserID);
                    UPDATE MessageBoard SET LikeCount = LikeCount + 1 WHERE MessageID = @MessageID;";
                SqlParameter[] insertParams = {
                    new SqlParameter("@MessageID", messageId),
                    new SqlParameter("@UserID", userId)
                };
                DBHelper.ExecuteNonQuery(insertQuery, insertParams);
                return true;
            }
        }

        /// <summary>
        /// 檢查使用者是否已按讚
        /// </summary>
        public static bool HasLiked(int messageId, int userId)
        {
            string query = "SELECT COUNT(*) FROM MessageLikes WHERE MessageID = @MessageID AND UserID = @UserID";
            SqlParameter[] parameters = {
                new SqlParameter("@MessageID", messageId),
                new SqlParameter("@UserID", userId)
            };

            return Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters)) > 0;
        }

        #endregion

        #region 好友功能

        /// <summary>
        /// 搜尋使用者
        /// </summary>
        public static List<UserInfo> SearchUsers(string keyword, int currentUserId)
        {
            List<UserInfo> users = new List<UserInfo>();

            string query = @"
                SELECT UserID, UserName, Avatar, Level
                FROM Users
                WHERE UserID != @CurrentUserID 
                  AND (UserName LIKE @Keyword OR Email LIKE @Keyword)
                ORDER BY Level DESC";

            SqlParameter[] parameters = {
                new SqlParameter("@CurrentUserID", currentUserId),
                new SqlParameter("@Keyword", "%" + keyword + "%")
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                users.Add(new UserInfo
                {
                    UserID = Convert.ToInt32(row["UserID"]),
                    UserName = row["UserName"].ToString(),
                    AvatarUrl = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                    Level = Convert.ToInt32(row["Level"])
                });
            }

            return users;
        }

        /// <summary>
        /// 發送好友請求
        /// </summary>
        public static bool SendFriendRequest(int userId, int friendId)
        {
            if (userId == friendId)
                throw new ArgumentException("不能加自己為好友");

            // 檢查是否已有關係（使用正確的欄位名稱 UserID 和 FriendID）
            string checkQuery = @"
                SELECT COUNT(*) FROM Friendships 
                WHERE (UserID = @UserID AND FriendID = @FriendID) 
                   OR (UserID = @FriendID AND FriendID = @UserID)";

            SqlParameter[] checkParams = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@FriendID", friendId)
            };

            if (Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams)) > 0)
                return false;

            // 新增好友請求
            string insertQuery = @"
                INSERT INTO Friendships (UserID, FriendID, Status, RequestDate)
                VALUES (@UserID, @FriendID, 'Pending', GETDATE())";

            SqlParameter[] insertParams = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@FriendID", friendId)
            };

            return DBHelper.ExecuteNonQuery(insertQuery, insertParams) > 0;
        }

        /// <summary>
        /// 接受好友請求
        /// </summary>
        public static bool AcceptFriendRequest(int friendshipId, int userId)
        {
            // 先獲取發送請求者的 ID
            string getRequesterQuery = @"
                SELECT UserID FROM Friendships 
                WHERE FriendshipID = @FriendshipID AND FriendID = @UserID AND Status = 'Pending'";
            
            SqlParameter[] getParams = {
                new SqlParameter("@FriendshipID", friendshipId),
                new SqlParameter("@UserID", userId)
            };
            
            object requesterIdObj = DBHelper.ExecuteScalar(getRequesterQuery, getParams);
            
            // 使用正確的欄位名稱 FriendID，並更新 AcceptDate
            string query = @"
                UPDATE Friendships 
                SET Status = 'Accepted', AcceptDate = GETDATE()
                WHERE FriendshipID = @FriendshipID AND FriendID = @UserID AND Status = 'Pending'";

            SqlParameter[] parameters = {
                new SqlParameter("@FriendshipID", friendshipId),
                new SqlParameter("@UserID", userId)
            };

            bool success = DBHelper.ExecuteNonQuery(query, parameters) > 0;
            
            // 如果成功接受好友，觸發任務追蹤
            if (success)
            {
                try
                {
                    // 追蹤接受者的好友任務
                    TaskProgressTracker.OnFriendAdded(userId);
                    
                    // 追蹤發送者的好友任務
                    if (requesterIdObj != null && requesterIdObj != DBNull.Value)
                    {
                        int requesterId = Convert.ToInt32(requesterIdObj);
                        TaskProgressTracker.OnFriendAdded(requesterId);
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Error tracking friend task: {ex.Message}");
                }
            }
            
            return success;
        }

        /// <summary>
        /// 拒絕好友請求
        /// </summary>
        public static bool RejectFriendRequest(int friendshipId, int userId)
        {
            // 使用正確的欄位名稱 FriendID
            string query = @"
                UPDATE Friendships 
                SET Status = 'Rejected'
                WHERE FriendshipID = @FriendshipID AND FriendID = @UserID AND Status = 'Pending'";

            SqlParameter[] parameters = {
                new SqlParameter("@FriendshipID", friendshipId),
                new SqlParameter("@UserID", userId)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 取得好友列表
        /// </summary>
        public static List<FriendInfo> GetFriends(int userId)
        {
            List<FriendInfo> friends = new List<FriendInfo>();

            // 使用正確的欄位名稱 UserID 和 FriendID，AcceptDate
            string query = @"
                SELECT 
                    F.FriendshipID,
                    CASE WHEN F.UserID = @UserID THEN F.FriendID ELSE F.UserID END AS FriendUserID,
                    U.UserName, U.Avatar, U.Level,
                    F.AcceptDate
                FROM Friendships F
                INNER JOIN Users U ON U.UserID = CASE WHEN F.UserID = @UserID THEN F.FriendID ELSE F.UserID END
                WHERE (F.UserID = @UserID OR F.FriendID = @UserID) AND F.Status = 'Accepted'
                ORDER BY U.UserName";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                friends.Add(new FriendInfo
                {
                    FriendshipID = Convert.ToInt32(row["FriendshipID"]),
                    UserID = Convert.ToInt32(row["FriendUserID"]),
                    UserName = row["UserName"].ToString(),
                    AvatarUrl = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                    Level = Convert.ToInt32(row["Level"]),
                    FriendSince = row["AcceptDate"] != DBNull.Value ? Convert.ToDateTime(row["AcceptDate"]) : DateTime.Now
                });
            }

            return friends;
        }

        /// <summary>
        /// 取得待處理的好友請求
        /// </summary>
        public static List<FriendRequest> GetPendingRequests(int userId)
        {
            List<FriendRequest> requests = new List<FriendRequest>();

            // 使用正確的欄位名稱：FriendID 是接收者，UserID 是發送者
            string query = @"
                SELECT 
                    F.FriendshipID, F.UserID AS RequesterID, F.RequestDate,
                    U.UserName, U.Avatar, U.Level
                FROM Friendships F
                INNER JOIN Users U ON F.UserID = U.UserID
                WHERE F.FriendID = @UserID AND F.Status = 'Pending'
                ORDER BY F.RequestDate DESC";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                requests.Add(new FriendRequest
                {
                    FriendshipID = Convert.ToInt32(row["FriendshipID"]),
                    RequesterID = Convert.ToInt32(row["RequesterID"]),
                    RequesterName = row["UserName"].ToString(),
                    RequesterAvatar = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                    RequesterLevel = Convert.ToInt32(row["Level"]),
                    RequestDate = Convert.ToDateTime(row["RequestDate"])
                });
            }

            return requests;
        }

        /// <summary>
        /// 刪除好友
        /// </summary>
        public static bool RemoveFriend(int friendshipId, int userId)
        {
            // 使用正確的欄位名稱 UserID 和 FriendID
            string query = @"
                DELETE FROM Friendships 
                WHERE FriendshipID = @FriendshipID 
                  AND (UserID = @UserID OR FriendID = @UserID)";

            SqlParameter[] parameters = {
                new SqlParameter("@FriendshipID", friendshipId),
                new SqlParameter("@UserID", userId)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        #endregion

        #region 聊天室功能

        /// <summary>
        /// 取得聊天室列表
        /// </summary>
        public static List<ChatRoom> GetChatRooms(int userId)
        {
            List<ChatRoom> rooms = new List<ChatRoom>();

            string query = @"
                SELECT 
                    R.RoomID, R.RoomName, R.Description, R.RoomType, R.IconUrl, R.CreatedDate,
                    R.MaxMembers, R.CreatorID,
                    (SELECT COUNT(*) FROM ChatRoomMembers WHERE RoomID = R.RoomID AND IsActive = 1) AS MemberCount,
                    CASE WHEN EXISTS(SELECT 1 FROM ChatRoomMembers WHERE RoomID = R.RoomID AND UserID = @UserID AND IsActive = 1) 
                         THEN 1 ELSE 0 END AS IsMember
                FROM ChatRooms R
                WHERE R.IsActive = 1 AND (R.RoomType = 'Public' OR EXISTS(
                    SELECT 1 FROM ChatRoomMembers WHERE RoomID = R.RoomID AND UserID = @UserID AND IsActive = 1
                ))
                ORDER BY R.RoomType, R.RoomName";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                rooms.Add(new ChatRoom
                {
                    RoomID = Convert.ToInt32(row["RoomID"]),
                    RoomName = row["RoomName"].ToString(),
                    Description = row["Description"] != DBNull.Value ? row["Description"].ToString() : "",
                    RoomType = row["RoomType"].ToString(),
                    IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : "fa-comments",
                    CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                    MaxMembers = Convert.ToInt32(row["MaxMembers"]),
                    MemberCount = Convert.ToInt32(row["MemberCount"]),
                    IsMember = Convert.ToBoolean(row["IsMember"])
                });
            }

            return rooms;
        }

        /// <summary>
        /// 建立聊天室
        /// </summary>
        public static int CreateChatRoom(int creatorId, string roomName, string description, string roomType)
        {
            if (string.IsNullOrWhiteSpace(roomName))
                throw new ArgumentException("聊天室名稱不能為空");

            string query = @"
                INSERT INTO ChatRooms (RoomName, Description, CreatorID, RoomType, CreatedDate)
                VALUES (@RoomName, @Description, @CreatorID, @RoomType, GETDATE());
                
                DECLARE @RoomID INT = SCOPE_IDENTITY();
                
                INSERT INTO ChatRoomMembers (RoomID, UserID, Role, JoinedDate)
                VALUES (@RoomID, @CreatorID, 'Owner', GETDATE());
                
                SELECT @RoomID;";

            SqlParameter[] parameters = {
                new SqlParameter("@RoomName", roomName.Trim()),
                new SqlParameter("@Description", string.IsNullOrEmpty(description) ? (object)DBNull.Value : description.Trim()),
                new SqlParameter("@CreatorID", creatorId),
                new SqlParameter("@RoomType", roomType)
            };

            return Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
        }

        /// <summary>
        /// 加入聊天室
        /// </summary>
        public static bool JoinChatRoom(int roomId, int userId)
        {
            // 檢查是否已是成員
            string checkQuery = "SELECT COUNT(*) FROM ChatRoomMembers WHERE RoomID = @RoomID AND UserID = @UserID";
            SqlParameter[] checkParams = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@UserID", userId)
            };

            if (Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams)) > 0)
            {
                // 已是成員，重新啟用 - 需要創建新的參數陣列
                string updateQuery = "UPDATE ChatRoomMembers SET IsActive = 1 WHERE RoomID = @RoomID AND UserID = @UserID";
                SqlParameter[] updateParams = {
                    new SqlParameter("@RoomID", roomId),
                    new SqlParameter("@UserID", userId)
                };
                return DBHelper.ExecuteNonQuery(updateQuery, updateParams) > 0;
            }

            // 新增成員 - 需要創建新的參數陣列
            string insertQuery = @"
                INSERT INTO ChatRoomMembers (RoomID, UserID, Role, JoinedDate)
                VALUES (@RoomID, @UserID, 'Member', GETDATE())";
            SqlParameter[] insertParams = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@UserID", userId)
            };

            return DBHelper.ExecuteNonQuery(insertQuery, insertParams) > 0;
        }

        /// <summary>
        /// 離開聊天室
        /// </summary>
        public static bool LeaveChatRoom(int roomId, int userId)
        {
            string query = @"
                UPDATE ChatRoomMembers 
                SET IsActive = 0 
                WHERE RoomID = @RoomID AND UserID = @UserID AND Role != 'Owner'";

            SqlParameter[] parameters = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@UserID", userId)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 取得聊天室訊息
        /// </summary>
        public static List<ChatMessage> GetChatMessages(int roomId, int count = 50)
        {
            List<ChatMessage> messages = new List<ChatMessage>();

            string query = @"
                SELECT TOP (@Count)
                    M.ChatMessageID, M.RoomID, M.UserID, M.Content, M.MessageType, M.SentDate,
                    U.UserName, U.Avatar, U.Level
                FROM ChatMessages M
                INNER JOIN Users U ON M.UserID = U.UserID
                WHERE M.RoomID = @RoomID AND M.IsDeleted = 0
                ORDER BY M.SentDate DESC";

            SqlParameter[] parameters = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@Count", count)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                messages.Add(new ChatMessage
                {
                    ChatMessageID = Convert.ToInt32(row["ChatMessageID"]),
                    RoomID = Convert.ToInt32(row["RoomID"]),
                    UserID = Convert.ToInt32(row["UserID"]),
                    UserName = row["UserName"].ToString(),
                    AvatarUrl = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                    UserLevel = Convert.ToInt32(row["Level"]),
                    Content = row["Content"].ToString(),
                    MessageType = row["MessageType"].ToString(),
                    SentDate = Convert.ToDateTime(row["SentDate"])
                });
            }

            messages.Reverse(); // 反轉順序，最新的在最後
            return messages;
        }

        /// <summary>
        /// 發送聊天訊息
        /// </summary>
        public static int SendChatMessage(int roomId, int userId, string content)
        {
            if (string.IsNullOrWhiteSpace(content))
                throw new ArgumentException("訊息內容不能為空");

            // 檢查是否為聊天室成員
            string checkQuery = "SELECT COUNT(*) FROM ChatRoomMembers WHERE RoomID = @RoomID AND UserID = @UserID AND IsActive = 1";
            SqlParameter[] checkParams = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@UserID", userId)
            };

            if (Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams)) == 0)
                throw new InvalidOperationException("您不是此聊天室的成員");

            string query = @"
                INSERT INTO ChatMessages (RoomID, UserID, Content, MessageType, SentDate)
                VALUES (@RoomID, @UserID, @Content, 'Text', GETDATE());
                SELECT SCOPE_IDENTITY();";

            SqlParameter[] parameters = {
                new SqlParameter("@RoomID", roomId),
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Content", content.Trim())
            };

            return Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
        }

        #endregion

        #region 統計功能

        /// <summary>
        /// 取得社交統計
        /// </summary>
        public static SocialStats GetSocialStats(int userId)
        {
            SocialStats stats = new SocialStats();

            // 使用正確的欄位名稱 UserID 和 FriendID
            string query = @"
                SELECT 
                    (SELECT COUNT(*) FROM Friendships 
                     WHERE (UserID = @UserID OR FriendID = @UserID) AND Status = 'Accepted') AS FriendCount,
                    (SELECT COUNT(*) FROM Friendships 
                     WHERE FriendID = @UserID AND Status = 'Pending') AS PendingRequests,
                    (SELECT COUNT(*) FROM ChatRoomMembers 
                     WHERE UserID = @UserID AND IsActive = 1) AS JoinedRooms,
                    (SELECT COUNT(*) FROM MessageBoard 
                     WHERE UserID = @UserID AND IsDeleted = 0) AS PostedMessages";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                stats.FriendCount = Convert.ToInt32(row["FriendCount"]);
                stats.PendingRequests = Convert.ToInt32(row["PendingRequests"]);
                stats.JoinedRooms = Convert.ToInt32(row["JoinedRooms"]);
                stats.PostedMessages = Convert.ToInt32(row["PostedMessages"]);
            }

            return stats;
        }

        #endregion
    }

    #region 資料模型

    public class BoardMessage
    {
        public int MessageID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string AvatarUrl { get; set; }
        public int UserLevel { get; set; }
        public string Content { get; set; }
        public DateTime PostedDate { get; set; }
        public int LikeCount { get; set; }
    }

    public class UserInfo
    {
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string AvatarUrl { get; set; }
        public int Level { get; set; }
    }

    public class FriendInfo
    {
        public int FriendshipID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string AvatarUrl { get; set; }
        public int Level { get; set; }
        public DateTime FriendSince { get; set; }
    }

    public class FriendRequest
    {
        public int FriendshipID { get; set; }
        public int RequesterID { get; set; }
        public string RequesterName { get; set; }
        public string RequesterAvatar { get; set; }
        public int RequesterLevel { get; set; }
        public DateTime RequestDate { get; set; }
    }

    public class ChatRoom
    {
        public int RoomID { get; set; }
        public string RoomName { get; set; }
        public string Description { get; set; }
        public string RoomType { get; set; }
        public string IconUrl { get; set; }
        public DateTime CreatedDate { get; set; }
        public int MaxMembers { get; set; }
        public int MemberCount { get; set; }
        public bool IsMember { get; set; }
    }

    public class ChatMessage
    {
        public int ChatMessageID { get; set; }
        public int RoomID { get; set; }
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string AvatarUrl { get; set; }
        public int UserLevel { get; set; }
        public string Content { get; set; }
        public string MessageType { get; set; }
        public DateTime SentDate { get; set; }
    }

    public class SocialStats
    {
        public int FriendCount { get; set; }
        public int PendingRequests { get; set; }
        public int JoinedRooms { get; set; }
        public int PostedMessages { get; set; }
    }

    #endregion
}
