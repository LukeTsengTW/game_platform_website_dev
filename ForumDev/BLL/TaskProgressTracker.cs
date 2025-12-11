using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ForumDev.DAL;
using ForumDev.Models;

namespace ForumDev.BLL
{
    /// <summary>
    /// 任務進度自動追蹤服務
    /// </summary>
    public class TaskProgressTracker
    {
        /// <summary>
        /// 當用戶購買商品時檢查相關任務
        /// </summary>
        public static void OnItemPurchased(int userId, int itemId, int quantity)
        {
            try
            {
                // 檢查「首次購物」任務
                CheckSimpleTask(userId, "首次購物");
                
                // 檢查「購物狂」任務（累計購買次數）
                CheckShoppingSpreeTask(userId);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnItemPurchased: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶完成任務時檢查相關任務
        /// </summary>
        public static void OnTaskCompleted(int userId, int taskId)
        {
            try
            {
                // 檢查「完成一個任務」或「初心者」任務
                CheckSimpleTask(userId, "完成");
                CheckSimpleTask(userId, "初心者");
                
                System.Diagnostics.Debug.WriteLine($"Task completed tracking for user {userId}, task {taskId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnTaskCompleted: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶登入時檢查相關任務
        /// </summary>
        public static void OnUserLogin(int userId)
        {
            try
            {
                // 檢查登入相關任務
                System.Diagnostics.Debug.WriteLine($"Login tracking for user {userId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnUserLogin: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶升級時檢查相關任務
        /// </summary>
        public static void OnUserLevelUp(int userId, int newLevel)
        {
            try
            {
                // 檢查「等級起飛」任務（達到指定等級）
                CheckLevelUpTask(userId, newLevel);
                
                System.Diagnostics.Debug.WriteLine($"Level up tracking for user {userId}, new level: {newLevel}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnUserLevelUp: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶成功添加好友時檢查相關任務
        /// </summary>
        public static void OnFriendAdded(int userId)
        {
            try
            {
                // 檢查「交好友」任務（新增第一個好友）
                CheckFirstFriendTask(userId);
                
                // 檢查「人氣王」任務（擁有10個好友）
                CheckPopularityTask(userId);
                
                System.Diagnostics.Debug.WriteLine($"Friend added tracking for user {userId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnFriendAdded: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶進行抽獎時檢查相關任務
        /// </summary>
        public static void OnLotteryDrawn(int userId, int drawCount = 1)
        {
            try
            {
                // 檢查「第一次抽獎」任務（抽獎1次）
                CheckFirstLotteryTask(userId);
                
                // 檢查「抽抽樂」任務（抽獎10次）
                CheckLotteryFunTask(userId);
                
                // 檢查「賭徒」任務（抽獎100次）
                CheckGamblerTask(userId);
                
                System.Diagnostics.Debug.WriteLine($"Lottery drawn tracking for user {userId}, draw count: {drawCount}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnLotteryDrawn: {ex.Message}");
            }
        }

        /// <summary>
        /// 當用戶訪問平台功能時（用於導覽任務）
        /// </summary>
        public static void OnFeatureVisited(int userId, string featureName)
        {
            try
            {
                // 檢查平台功能導覽任務
                CheckSimpleTask(userId, "導覽");
                CheckSimpleTask(userId, "平台功能");
                
                System.Diagnostics.Debug.WriteLine($"Feature visited: {featureName} by user {userId}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in OnFeatureVisited: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「購物狂」任務（需要累計購買5次）
        /// </summary>
        private static void CheckShoppingSpreeTask(int userId)
        {
            try
            {
                // 找到「購物狂」任務
                GameTask task = FindTaskByName("購物狂");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶購買次數
                int purchaseCount = GetUserPurchaseCount(userId);
                int requiredCount = 5; // 需要購買5次

                // 計算進度百分比
                int progress = Math.Min(100, (purchaseCount * 100) / requiredCount);

                // 更新進度
                if (progress >= 100)
                {
                    // 任務完成
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"購物狂任務完成！用戶 {userId} 已購買 {purchaseCount} 次");
                }
                else if (progress > userTask.Progress)
                {
                    // 更新進度
                    TaskService.UpdateTaskProgress(userId, task.TaskID, progress);
                    System.Diagnostics.Debug.WriteLine($"購物狂任務進度更新：{progress}%（{purchaseCount}/{requiredCount}）");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckShoppingSpreeTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「等級起飛」任務（需要達到指定等級）
        /// </summary>
        private static void CheckLevelUpTask(int userId, int currentLevel)
        {
            try
            {
                // 找到「等級起飛」任務
                GameTask task = FindTaskByName("等級起飛");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                int requiredLevel = 5; // 需要達到5級

                // 計算進度百分比
                int progress = Math.Min(100, (currentLevel * 100) / requiredLevel);

                // 檢查是否達成
                if (currentLevel >= requiredLevel)
                {
                    // 任務完成
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"等級起飛任務完成！用戶 {userId} 已達到 {currentLevel} 級");
                }
                else if (progress > userTask.Progress)
                {
                    // 更新進度
                    TaskService.UpdateTaskProgress(userId, task.TaskID, progress);
                    System.Diagnostics.Debug.WriteLine($"等級起飛任務進度更新：{progress}%（等級 {currentLevel}/{requiredLevel}）");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckLevelUpTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「交好友」任務（新增第一個好友）
        /// </summary>
        private static void CheckFirstFriendTask(int userId)
        {
            try
            {
                // 找到「交好友」任務
                GameTask task = FindTaskByName("交好友");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶好友數量
                int friendCount = GetUserFriendCount(userId);

                // 只要有一個好友就完成
                if (friendCount >= 1)
                {
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"交好友任務完成！用戶 {userId} 已有 {friendCount} 個好友");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckFirstFriendTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「人氣王」任務（擁有10個好友）
        /// </summary>
        private static void CheckPopularityTask(int userId)
        {
            try
            {
                // 找到「人氣王」任務
                GameTask task = FindTaskByName("人氣王");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶好友數量
                int friendCount = GetUserFriendCount(userId);
                int requiredFriends = 10;

                // 計算進度百分比
                int progress = Math.Min(100, (friendCount * 100) / requiredFriends);

                // 檢查是否達成
                if (friendCount >= requiredFriends)
                {
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"人氣王任務完成！用戶 {userId} 已有 {friendCount} 個好友");
                }
                else if (progress > userTask.Progress)
                {
                    // 更新進度
                    TaskService.UpdateTaskProgress(userId, task.TaskID, progress);
                    System.Diagnostics.Debug.WriteLine($"人氣王任務進度更新：{progress}%（{friendCount}/{requiredFriends} 好友）");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckPopularityTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「第一次抽獎」任務（抽獎1次）
        /// </summary>
        private static void CheckFirstLotteryTask(int userId)
        {
            try
            {
                // 找到「第一次抽獎」任務
                GameTask task = FindTaskByName("第一次抽獎");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶抽獎次數
                int drawCount = GetUserLotteryDrawCount(userId);

                // 只要有一次抽獎就完成
                if (drawCount >= 1)
                {
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"第一次抽獎任務完成！用戶 {userId} 已抽獎 {drawCount} 次");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckFirstLotteryTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「抽抽樂」任務（抽獎10次）
        /// </summary>
        private static void CheckLotteryFunTask(int userId)
        {
            try
            {
                // 找到「抽抽樂」任務
                GameTask task = FindTaskByName("抽抽樂");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶抽獎次數
                int drawCount = GetUserLotteryDrawCount(userId);
                int requiredDraws = 10;

                // 計算進度百分比
                int progress = Math.Min(100, (drawCount * 100) / requiredDraws);

                // 檢查是否達成
                if (drawCount >= requiredDraws)
                {
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"抽抽樂任務完成！用戶 {userId} 已抽獎 {drawCount} 次");
                }
                else if (progress > userTask.Progress)
                {
                    // 更新進度
                    TaskService.UpdateTaskProgress(userId, task.TaskID, progress);
                    System.Diagnostics.Debug.WriteLine($"抽抽樂任務進度更新：{progress}%（{drawCount}/{requiredDraws} 次）");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckLotteryFunTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查「賭徒」任務（抽獎100次）
        /// </summary>
        private static void CheckGamblerTask(int userId)
        {
            try
            {
                // 找到「賭徒」任務
                GameTask task = FindTaskByName("賭徒");
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 取得用戶抽獎次數
                int drawCount = GetUserLotteryDrawCount(userId);
                int requiredDraws = 100;

                // 計算進度百分比
                int progress = Math.Min(100, (drawCount * 100) / requiredDraws);

                // 檢查是否達成
                if (drawCount >= requiredDraws)
                {
                    TaskService.CompleteTask(userId, task.TaskID);
                    System.Diagnostics.Debug.WriteLine($"賭徒任務完成！用戶 {userId} 已抽獎 {drawCount} 次");
                }
                else if (progress > userTask.Progress)
                {
                    // 更新進度
                    TaskService.UpdateTaskProgress(userId, task.TaskID, progress);
                    System.Diagnostics.Debug.WriteLine($"賭徒任務進度更新：{progress}%（{drawCount}/{requiredDraws} 次）");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckGamblerTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 取得用戶的好友數量
        /// </summary>
        private static int GetUserFriendCount(int userId)
        {
            try
            {
                // 計算已接受的好友關係數量（雙向）
                string query = @"
                    SELECT COUNT(*) 
                    FROM Friendships 
                    WHERE (UserID = @UserID OR FriendID = @UserID) 
                      AND Status = 'Accepted'";
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
        /// 取得用戶的抽獎次數
        /// </summary>
        private static int GetUserLotteryDrawCount(int userId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM LotteryRecords WHERE UserID = @UserID";
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
        /// 取得用戶的購買次數（從交易記錄計算）
        /// </summary>
        private static int GetUserPurchaseCount(int userId)
        {
            try
            {
                // 計算 Purchase 類型的交易筆數
                string query = "SELECT COUNT(*) FROM Transactions WHERE UserID = @UserID AND Type = 'Purchase'";
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
        /// 檢查簡單任務（自動完成）
        /// </summary>
        private static void CheckSimpleTask(int userId, string taskNameKeyword)
        {
            try
            {
                // 找到對應的任務
                GameTask task = FindTaskByName(taskNameKeyword);
                if (task == null) return;

                // 檢查用戶是否已開始此任務
                UserTask userTask = GetUserTask(userId, task.TaskID);
                if (userTask == null || userTask.Status != "InProgress") return;

                // 檢查任務條件
                bool isCompleted = CheckTaskCondition(userId, task);
                if (isCompleted)
                {
                    // 自動完成任務
                    TaskService.CompleteTask(userId, task.TaskID);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in CheckSimpleTask: {ex.Message}");
            }
        }

        /// <summary>
        /// 檢查任務完成條件
        /// </summary>
        private static bool CheckTaskCondition(int userId, GameTask task)
        {
            try
            {
                // 根據任務名稱判斷條件
                if (task.TaskName.Contains("首次購物"))
                {
                    return HasPurchasedAnyItem(userId);
                }
                
                // 檢查「完成一個任務」或「初心者」任務
                if (task.TaskName.Contains("完成") || task.TaskName.Contains("初心者"))
                {
                    return HasCompletedAnyTask(userId);
                }

                // 檢查「平台功能導覽」任務（需要手動在PlatformTour頁面完成）
                if (task.TaskName.Contains("導覽") || task.TaskName.Contains("平台功能"))
                {
                    return false;
                }

                // 檢查「購物狂」任務
                if (task.TaskName.Contains("購物狂"))
                {
                    return GetUserPurchaseCount(userId) >= 5;
                }

                // 檢查「等級起飛」任務
                if (task.TaskName.Contains("等級起飛"))
                {
                    int userLevel = GetUserLevel(userId);
                    return userLevel >= 5;
                }

                // 檢查「交好友」任務
                if (task.TaskName.Contains("交好友"))
                {
                    int friendCount = GetUserFriendCount(userId);
                    return friendCount >= 1;
                }

                // 檢查「人氣王」任務
                if (task.TaskName.Contains("人氣王"))
                {
                    int friendCount = GetUserFriendCount(userId);
                    return friendCount >= 10;
                }

                // 檢查「第一次抽獎」任務
                if (task.TaskName.Contains("第一次抽獎"))
                {
                    int drawCount = GetUserLotteryDrawCount(userId);
                    return drawCount >= 1;
                }

                // 檢查「抽抽樂」任務
                if (task.TaskName.Contains("抽抽樂"))
                {
                    int drawCount = GetUserLotteryDrawCount(userId);
                    return drawCount >= 10;
                }

                // 檢查「賭徒」任務
                if (task.TaskName.Contains("賭徒"))
                {
                    int drawCount = GetUserLotteryDrawCount(userId);
                    return drawCount >= 100;
                }
                
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error checking task condition: {ex.Message}");
            }
            return false;
        }

        /// <summary>
        /// 取得用戶等級
        /// </summary>
        private static int GetUserLevel(int userId)
        {
            try
            {
                string query = "SELECT Level FROM Users WHERE UserID = @UserID";
                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId)
                };
                object result = DBHelper.ExecuteScalar(query, parameters);
                return result != null ? Convert.ToInt32(result) : 0;
            }
            catch
            {
                return 0;
            }
        }

        /// <summary>
        /// 根據任務名稱查找任務
        /// </summary>
        private static GameTask FindTaskByName(string taskName)
        {
            try
            {
                string query = "SELECT * FROM Tasks WHERE TaskName LIKE @TaskName AND IsActive = 1";
                SqlParameter[] parameters = {
                    new SqlParameter("@TaskName", "%" + taskName + "%")
                };

                DataTable dt = DBHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    return MapDataRowToTask(dt.Rows[0]);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error finding task: {ex.Message}");
            }
            return null;
        }

        /// <summary>
        /// 獲取用戶的任務狀態
        /// </summary>
        private static UserTask GetUserTask(int userId, int taskId)
        {
            try
            {
                string query = @"
                    SELECT UT.*, T.TaskName
                    FROM UserTasks UT
                    INNER JOIN Tasks T ON UT.TaskID = T.TaskID
                    WHERE UT.UserID = @UserID AND UT.TaskID = @TaskID";

                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@TaskID", taskId)
                };

                DataTable dt = DBHelper.ExecuteQuery(query, parameters);
                if (dt.Rows.Count > 0)
                {
                    DataRow row = dt.Rows[0];
                    return new UserTask
                    {
                        UserTaskID = Convert.ToInt32(row["UserTaskID"]),
                        UserID = Convert.ToInt32(row["UserID"]),
                        TaskID = Convert.ToInt32(row["TaskID"]),
                        Status = row["Status"].ToString(),
                        Progress = Convert.ToInt32(row["Progress"])
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting user task: {ex.Message}");
            }
            return null;
        }

        /// <summary>
        /// 檢查用戶是否購買過任何商品
        /// </summary>
        private static bool HasPurchasedAnyItem(int userId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM UserItems WHERE UserID = @UserID";
                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId)
                };
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
                return count > 0;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 檢查用戶是否完成過任何任務（已領取獎勵）
        /// </summary>
        private static bool HasCompletedAnyTask(int userId)
        {
            try
            {
                string query = "SELECT COUNT(*) FROM UserTasks WHERE UserID = @UserID AND Status = 'Claimed'";
                SqlParameter[] parameters = {
                    new SqlParameter("@UserID", userId)
                };
                int count = Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
                return count > 0;
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// 映射 DataRow 到 GameTask
        /// </summary>
        private static GameTask MapDataRowToTask(DataRow row)
        {
            return new GameTask
            {
                TaskID = Convert.ToInt32(row["TaskID"]),
                TaskName = row["TaskName"].ToString(),
                Description = row["Description"] != DBNull.Value ? row["Description"].ToString() : "",
                Category = row["Category"].ToString(),
                Type = row["Type"].ToString(),
                ExpReward = Convert.ToInt32(row["ExpReward"]),
                PointsReward = Convert.ToInt32(row["PointsReward"]),
                RequiredLevel = Convert.ToInt32(row["RequiredLevel"]),
                IsActive = Convert.ToBoolean(row["IsActive"])
            };
        }
    }
}
