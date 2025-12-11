using System;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using ForumDev.DAL;
using ForumDev.Models;

namespace ForumDev.BLL
{
    /// <summary>
    /// 用戶服務類別
    /// </summary>
    public class UserService
    {
        /// <summary>
        /// 用戶登入
        /// </summary>
        public static User Login(string userName, string password)
        {
            string passwordHash = HashPassword(password);
            
            string query = @"
                SELECT UserID, UserName, Email, Avatar, Level, TotalExp, Points, 
                       Bio, RegisterDate, LastLoginDate, IsActive
                FROM Users
                WHERE UserName = @UserName AND PasswordHash = @PasswordHash AND IsActive = 1";

            SqlParameter[] parameters = {
                new SqlParameter("@UserName", userName),
                new SqlParameter("@PasswordHash", passwordHash)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                User user = MapDataRowToUser(row);

                // 更新最後登入時間
                UpdateLastLoginDate(user.UserID);

                return user;
            }

            return null;
        }

        /// <summary>
        /// 用戶註冊
        /// </summary>
        public static bool Register(string userName, string email, string password)
        {
            // 檢查用戶名是否已存在
            if (IsUserNameExists(userName))
            {
                throw new Exception("用戶名稱已存在");
            }

            // 檢查 Email 是否已存在
            if (IsEmailExists(email))
            {
                throw new Exception("Email 已被註冊");
            }

            string passwordHash = HashPassword(password);
            string defaultAvatar = "~/Images/default-avatar.png";
            
            string query = @"
                INSERT INTO Users (UserName, Email, PasswordHash, Avatar, Level, TotalExp, Points, RegisterDate, IsActive)
                VALUES (@UserName, @Email, @PasswordHash, @Avatar, 1, 0, 100, GETDATE(), 1)";

            SqlParameter[] parameters = {
                new SqlParameter("@UserName", userName),
                new SqlParameter("@Email", email),
                new SqlParameter("@PasswordHash", passwordHash),
                new SqlParameter("@Avatar", defaultAvatar)
            };

            int result = DBHelper.ExecuteNonQuery(query, parameters);
            return result > 0;
        }

        /// <summary>
        /// 根據用戶 ID 取得用戶資訊
        /// </summary>
        public static User GetUserById(int userId)
        {
            string query = @"
                SELECT UserID, UserName, Email, Avatar, Level, TotalExp, Points, 
                       Bio, RegisterDate, LastLoginDate, IsActive
                FROM Users
                WHERE UserID = @UserID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                return MapDataRowToUser(dt.Rows[0]);
            }

            return null;
        }

        /// <summary>
        /// 根據用戶名稱取得用戶資訊
        /// </summary>
        public static User GetUserByUserName(string userName)
        {
            string query = @"
                SELECT UserID, UserName, Email, Avatar, Level, TotalExp, Points, 
                       Bio, RegisterDate, LastLoginDate, IsActive
                FROM Users
                WHERE UserName = @UserName";

            SqlParameter[] parameters = {
                new SqlParameter("@UserName", userName)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                return MapDataRowToUser(dt.Rows[0]);
            }

            return null;
        }

        /// <summary>
        /// 更新用戶經驗值
        /// </summary>
        public static bool AddExperience(int userId, int exp)
        {
            // 先取得升級前的等級
            int oldLevel = GetUserLevel(userId);

            string query = @"
                UPDATE Users 
                SET TotalExp = TotalExp + @Exp
                WHERE UserID = @UserID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Exp", exp)
            };

            int result = DBHelper.ExecuteNonQuery(query, parameters);

            if (result > 0)
            {
                // 檢查並更新等級
                DBHelper.ExecuteStoredProcedure("sp_CheckAndUpdateUserLevel",
                    new SqlParameter("@UserID", userId));

                // 取得升級後的等級
                int newLevel = GetUserLevel(userId);

                // 如果升級了，觸發任務追蹤和成就追蹤
                if (newLevel > oldLevel)
                {
                    try
                    {
                        TaskProgressTracker.OnUserLevelUp(userId, newLevel);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Task tracking error on level up: {ex.Message}");
                    }

                    // 檢查等級成就
                    try
                    {
                        AchievementTracker.OnLevelChanged(userId, newLevel);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Achievement tracking error on level up: {ex.Message}");
                    }
                }
            }

            return result > 0;
        }

        /// <summary>
        /// 更新用戶經驗值（不觸發成就檢查，用於成就獎勵發放）
        /// </summary>
        public static bool AddExperienceWithoutAchievementCheck(int userId, int exp)
        {
            // 先取得升級前的等級
            int oldLevel = GetUserLevel(userId);

            string query = @"
                UPDATE Users 
                SET TotalExp = TotalExp + @Exp
                WHERE UserID = @UserID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Exp", exp)
            };

            int result = DBHelper.ExecuteNonQuery(query, parameters);

            if (result > 0)
            {
                // 檢查並更新等級
                DBHelper.ExecuteStoredProcedure("sp_CheckAndUpdateUserLevel",
                    new SqlParameter("@UserID", userId));

                // 取得升級後的等級
                int newLevel = GetUserLevel(userId);

                // 如果升級了，只觸發任務追蹤（不觸發成就追蹤避免無限循環）
                if (newLevel > oldLevel)
                {
                    try
                    {
                        TaskProgressTracker.OnUserLevelUp(userId, newLevel);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Task tracking error on level up: {ex.Message}");
                    }
                }
            }

            return result > 0;
        }

        /// <summary>
        /// 更新用戶積分
        /// </summary>
        public static bool AddPoints(int userId, int points, string transactionType, string description)
        {
            // 取得當前積分
            string queryBalance = "SELECT Points FROM Users WHERE UserID = @UserID";
            object currentPoints = DBHelper.ExecuteScalar(queryBalance, new SqlParameter("@UserID", userId));
            int newBalance = Convert.ToInt32(currentPoints) + points;

            // 檢查是否會導致負積分
            if (newBalance < 0)
            {
                throw new Exception("積分不足");
            }

            // 更新積分
            string queryUpdate = @"
                UPDATE Users 
                SET Points = Points + @Points
                WHERE UserID = @UserID";

            SqlParameter[] parametersUpdate = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Points", points)
            };

            int result = DBHelper.ExecuteNonQuery(queryUpdate, parametersUpdate);

            if (result > 0)
            {
                // 記錄交易
                LogTransaction(userId, transactionType, points, newBalance, null, description);
            }

            return result > 0;
        }

        /// <summary>
        /// 更新用戶個人資料
        /// </summary>
        public static bool UpdateProfile(int userId, string avatar, string bio)
        {
            string query = @"
                UPDATE Users 
                SET Avatar = @Avatar, Bio = @Bio
                WHERE UserID = @UserID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Avatar", avatar ?? (object)DBNull.Value),
                new SqlParameter("@Bio", bio ?? (object)DBNull.Value)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 取得用戶統計資訊
        /// </summary>
        public static UserStats GetUserStats(int userId)
        {
            UserStats stats = new UserStats { UserID = userId };

            // 完成的任務數
            string queryTasks = "SELECT COUNT(*) FROM UserTasks WHERE UserID = @UserID AND Status = 'Completed'";
            stats.TasksCompleted = Convert.ToInt32(
                DBHelper.ExecuteScalar(queryTasks, new SqlParameter("@UserID", userId)));

            // 解鎖的成就數
            string queryAchievements = "SELECT COUNT(*) FROM UserAchievements WHERE UserID = @UserID";
            stats.AchievementsUnlocked = Convert.ToInt32(
                DBHelper.ExecuteScalar(queryAchievements, new SqlParameter("@UserID", userId)));

            // 好友數
            string queryFriends = "SELECT COUNT(*) FROM Friendships WHERE UserID = @UserID AND Status = 'Accepted'";
            stats.FriendsCount = Convert.ToInt32(
                DBHelper.ExecuteScalar(queryFriends, new SqlParameter("@UserID", userId)));

            // 未讀通知數
            string queryNotifications = "SELECT COUNT(*) FROM Notifications WHERE UserID = @UserID AND IsRead = 0";
            stats.UnreadNotifications = Convert.ToInt32(
                DBHelper.ExecuteScalar(queryNotifications, new SqlParameter("@UserID", userId)));

            return stats;
        }

        #region 私有輔助方法

        private static bool IsUserNameExists(string userName)
        {
            string query = "SELECT COUNT(*) FROM Users WHERE UserName = @UserName";
            int count = Convert.ToInt32(DBHelper.ExecuteScalar(query, 
                new SqlParameter("@UserName", userName)));
            return count > 0;
        }

        private static bool IsEmailExists(string email)
        {
            string query = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
            int count = Convert.ToInt32(DBHelper.ExecuteScalar(query, 
                new SqlParameter("@Email", email)));
            return count > 0;
        }

        private static void UpdateLastLoginDate(int userId)
        {
            string query = "UPDATE Users SET LastLoginDate = GETDATE() WHERE UserID = @UserID";
            DBHelper.ExecuteNonQuery(query, new SqlParameter("@UserID", userId));
        }

        private static void LogTransaction(int userId, string type, int amount, int balanceAfter, 
            int? itemId, string description)
        {
            string query = @"
                INSERT INTO Transactions (UserID, Type, Amount, BalanceAfter, ItemID, Description, Timestamp)
                VALUES (@UserID, @Type, @Amount, @BalanceAfter, @ItemID, @Description, GETDATE())";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Type", type),
                new SqlParameter("@Amount", amount),
                new SqlParameter("@BalanceAfter", balanceAfter),
                new SqlParameter("@ItemID", itemId.HasValue ? (object)itemId.Value : DBNull.Value),
                new SqlParameter("@Description", description ?? (object)DBNull.Value)
            };

            DBHelper.ExecuteNonQuery(query, parameters);
        }

        private static User MapDataRowToUser(DataRow row)
        {
            return new User
            {
                UserID = Convert.ToInt32(row["UserID"]),
                UserName = row["UserName"].ToString(),
                Email = row["Email"].ToString(),
                Avatar = row["Avatar"] != DBNull.Value ? row["Avatar"].ToString() : null,
                Level = Convert.ToInt32(row["Level"]),
                TotalExp = Convert.ToInt32(row["TotalExp"]),
                Points = Convert.ToInt32(row["Points"]),
                Bio = row["Bio"] != DBNull.Value ? row["Bio"].ToString() : null,
                RegisterDate = Convert.ToDateTime(row["RegisterDate"]),
                LastLoginDate = row["LastLoginDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["LastLoginDate"]) : null,
                IsActive = Convert.ToBoolean(row["IsActive"])
            };
        }

        private static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("X2"));
                }
                return builder.ToString();
            }
        }

        /// <summary>
        /// 取得用戶等級
        /// </summary>
        private static int GetUserLevel(int userId)
        {
            try
            {
                string query = "SELECT Level FROM Users WHERE UserID = @UserID";
                object result = DBHelper.ExecuteScalar(query, new SqlParameter("@UserID", userId));
                return result != null ? Convert.ToInt32(result) : 0;
            }
            catch
            {
                return 0;
            }
        }

        #endregion
    }
}
