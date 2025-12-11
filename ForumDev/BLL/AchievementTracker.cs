using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ForumDev.DAL;
using ForumDev.Models;

namespace ForumDev.BLL
{
    /// <summary>
    /// 成就追蹤器 - 自動檢查並解鎖成就
    /// </summary>
    public static class AchievementTracker
    {
        // 成就經驗獎勵對照表（任務成就才有經驗獎勵）
        private static readonly Dictionary<string, int> TaskAchievementExpRewards = new Dictionary<string, int>
        {
            { "啟航者", 300 },
            { "水手", 1200 },
            { "海盜", 3600 },
            { "海盜船長", 7200 },
            { "海上明珠", 36000 }
        };

        /// <summary>
        /// 當用戶等級改變時檢查等級成就
        /// </summary>
        public static void OnLevelChanged(int userId, int newLevel)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"AchievementTracker: Checking level achievements for user {userId}, level {newLevel}");

                // 檢查各等級成就
                if (newLevel >= 10) TryUnlockAchievement(userId, "新手", "ReachLevel:10");
                if (newLevel >= 30) TryUnlockAchievement(userId, "老手", "ReachLevel:30");
                if (newLevel >= 50) TryUnlockAchievement(userId, "賢者", "ReachLevel:50");
                if (newLevel >= 100) TryUnlockAchievement(userId, "入土者", "ReachLevel:100");
                if (newLevel >= 200) TryUnlockAchievement(userId, "骨灰級玩家", "ReachLevel:200");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnLevelChanged: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶完成任務時檢查任務成就
        /// </summary>
        public static void OnTaskCompleted(int userId)
        {
            try
            {
                // 取得用戶已完成的任務數量（已領取獎勵的任務）
                int completedCount = GetCompletedTaskCount(userId);
                System.Diagnostics.Debug.WriteLine($"AchievementTracker: Checking task achievements for user {userId}, completed {completedCount} tasks");

                // 檢查各任務成就
                if (completedCount >= 1) TryUnlockAchievement(userId, "啟航者", "CompleteTask:1");
                if (completedCount >= 10) TryUnlockAchievement(userId, "水手", "CompleteTask:10");
                if (completedCount >= 30) TryUnlockAchievement(userId, "海盜", "CompleteTask:30");
                if (completedCount >= 50) TryUnlockAchievement(userId, "海盜船長", "CompleteTask:50");
                if (completedCount >= 100) TryUnlockAchievement(userId, "海上明珠", "CompleteTask:100");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnTaskCompleted: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查並解鎖指定成就
        /// </summary>
        private static void TryUnlockAchievement(int userId, string achievementName, string condition)
        {
            try
            {
                // 查找成就
                string findQuery = @"
                    SELECT AchievementID, Name, Points, Category
                    FROM Achievements 
                    WHERE Name = @Name OR Condition = @Condition";

                SqlParameter[] findParams = {
                    new SqlParameter("@Name", achievementName),
                    new SqlParameter("@Condition", condition)
                };

                DataTable dt = DBHelper.ExecuteQuery(findQuery, findParams);
                if (dt.Rows.Count == 0)
                {
                    System.Diagnostics.Debug.WriteLine($"Achievement not found: {achievementName}");
                    return;
                }

                int achievementId = Convert.ToInt32(dt.Rows[0]["AchievementID"]);
                string name = dt.Rows[0]["Name"].ToString();
                int points = Convert.ToInt32(dt.Rows[0]["Points"]);
                string category = dt.Rows[0]["Category"].ToString();

                // 檢查是否已解鎖
                string checkQuery = @"
                    SELECT COUNT(*) FROM UserAchievements 
                    WHERE UserID = @UserID AND AchievementID = @AchievementID";

                SqlParameter[] checkParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@AchievementID", achievementId)
                };

                int exists = Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, checkParams));
                if (exists > 0)
                {
                    // 已解鎖，跳過
                    return;
                }

                // 解鎖成就
                string unlockQuery = @"
                    INSERT INTO UserAchievements (UserID, AchievementID, UnlockDate)
                    VALUES (@UserID, @AchievementID, GETDATE())";

                SqlParameter[] unlockParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@AchievementID", achievementId)
                };

                DBHelper.ExecuteNonQuery(unlockQuery, unlockParams);
                System.Diagnostics.Debug.WriteLine($"Achievement unlocked: {name} for user {userId}");

                // 發放積分獎勵
                if (points > 0)
                {
                    UserService.AddPoints(userId, points, "Achievement", $"成就獎勵：{name}");
                }

                // 發放經驗獎勵（僅任務成就有經驗獎勵）
                if (category == "Task" && TaskAchievementExpRewards.ContainsKey(name))
                {
                    int expReward = TaskAchievementExpRewards[name];
                    UserService.AddExperienceWithoutAchievementCheck(userId, expReward);
                }

                // 發送通知
                SendAchievementNotification(userId, name, points);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error unlocking achievement {achievementName}: {ex.Message}");
            }
        }

        /// <summary>
        /// 取得用戶已完成的任務數量
        /// </summary>
        private static int GetCompletedTaskCount(int userId)
        {
            try
            {
                // 計算已領取獎勵的任務數量
                string query = @"
                    SELECT COUNT(*) FROM UserTasks 
                    WHERE UserID = @UserID AND Status = 'Claimed'";

                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId)
                };

                return Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
            }
            catch
            {
                return 0;
            }
        }

        /// <summary>
        /// 發送成就解鎖通知
        /// </summary>
        private static void SendAchievementNotification(int userId, string achievementName, int points)
        {
            try
            {
                string query = @"
                    INSERT INTO Notifications (UserID, Type, Title, Content, IsRead, CreatedDate)
                    VALUES (@UserID, 'Achievement', @Title, @Content, 0, GETDATE())";

                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@Title", "?? 成就解鎖！"),
                    new SqlParameter("@Content", $"恭喜您獲得成就「{achievementName}」！獲得 {points} 積分獎勵。")
                };

                DBHelper.ExecuteNonQuery(query, parameters);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error sending achievement notification: {ex.Message}");
            }
        }

        /// <summary>
        /// 手動檢查用戶的所有成就（用於頁面載入時）
        /// </summary>
        public static void CheckAllAchievements(int userId)
        {
            try
            {
                // 取得用戶資訊
                User user = UserService.GetUserById(userId);
                if (user == null) return;

                // 檢查等級成就
                OnLevelChanged(userId, user.Level);

                // 檢查任務成就
                OnTaskCompleted(userId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckAllAchievements: {ex.Message}");
            }
        }
    }
}
