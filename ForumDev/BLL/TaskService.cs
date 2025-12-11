using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using ForumDev.DAL;
using ForumDev.Models;

namespace ForumDev.BLL
{
    /// <summary>
    /// 任務服務類別
    /// </summary>
    public class TaskService
    {
        /// <summary>
        /// 取得所有可用任務
        /// </summary>
        public static List<GameTask> GetAvailableTasks(int? userId = null, int? categoryFilter = null)
        {
            List<GameTask> tasks = new List<GameTask>();

            string query = @"
                SELECT TaskID, TaskName, Description, Category, Type, ExpReward, PointsReward,
                       RequiredLevel, RequiredCondition, MaxCompletions, StartDate, EndDate,
                       IsActive, CreatedDate, IconUrl, DisplayOrder
                FROM Tasks
                WHERE IsActive = 1
                    AND (StartDate IS NULL OR StartDate <= GETDATE())
                    AND (EndDate IS NULL OR EndDate >= GETDATE())
                ORDER BY DisplayOrder, TaskID";

            DataTable dt = DBHelper.ExecuteQuery(query);

            foreach (DataRow row in dt.Rows)
            {
                tasks.Add(MapDataRowToTask(row));
            }

            return tasks;
        }

        /// <summary>
        /// 根據任務 ID 取得任務資訊
        /// </summary>
        public static GameTask GetTaskById(int taskId)
        {
            string query = @"
                SELECT TaskID, TaskName, Description, Category, Type, ExpReward, PointsReward,
                       RequiredLevel, RequiredCondition, MaxCompletions, StartDate, EndDate,
                       IsActive, CreatedDate, IconUrl, DisplayOrder
                FROM Tasks
                WHERE TaskID = @TaskID";

            SqlParameter[] parameters = {
                new SqlParameter("@TaskID", taskId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                return MapDataRowToTask(dt.Rows[0]);
            }

            return null;
        }

        /// <summary>
        /// 取得用戶的任務列表
        /// </summary>
        public static List<UserTask> GetUserTasks(int userId, string statusFilter = null)
        {
            List<UserTask> userTasks = new List<UserTask>();

            string query = @"
                SELECT UT.UserTaskID, UT.UserID, UT.TaskID, UT.Status, UT.Progress,
                       UT.StartedDate, UT.CompletedDate, UT.ClaimedDate, UT.CompletionCount,
                       T.TaskName, T.Description, T.Category, T.Type, T.ExpReward, T.PointsReward,
                       T.RequiredLevel, T.IconUrl
                FROM UserTasks UT
                INNER JOIN Tasks T ON UT.TaskID = T.TaskID
                WHERE UT.UserID = @UserID";

            if (!string.IsNullOrEmpty(statusFilter))
            {
                query += " AND UT.Status = @Status";
            }

            query += " ORDER BY UT.StartedDate DESC, T.DisplayOrder";

            List<SqlParameter> parameters = new List<SqlParameter> {
                new SqlParameter("@UserID", userId)
            };

            if (!string.IsNullOrEmpty(statusFilter))
            {
                parameters.Add(new SqlParameter("@Status", statusFilter));
            }

            DataTable dt = DBHelper.ExecuteQuery(query, parameters.ToArray());

            foreach (DataRow row in dt.Rows)
            {
                userTasks.Add(MapDataRowToUserTask(row));
            }

            return userTasks;
        }

        /// <summary>
        /// 開始任務
        /// </summary>
        public static bool StartTask(int userId, int taskId)
        {
            // 檢查用戶是否已開始此任務
            if (IsTaskStarted(userId, taskId))
            {
                throw new Exception("您已經開始此任務");
            }

            // 檢查任務是否存在且可用
            GameTask task = GetTaskById(taskId);
            if (task == null || !task.IsActive)
            {
                throw new Exception("任務不存在或已停用");
            }

            // 檢查任務類型 - 如果是「每日簽到」或其他即時完成的任務，直接完成
            bool isInstantComplete = IsInstantCompleteTask(task);

            string query = @"
                INSERT INTO UserTasks (UserID, TaskID, Status, Progress, StartedDate, CompletedDate, CompletionCount)
                VALUES (@UserID, @TaskID, @Status, @Progress, GETDATE(), @CompletedDate, 0)";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId),
                new SqlParameter("@Status", isInstantComplete ? "Completed" : "InProgress"),
                new SqlParameter("@Progress", isInstantComplete ? 100 : 0),
                new SqlParameter("@CompletedDate", isInstantComplete ? (object)DateTime.Now : DBNull.Value)
            };

            bool success = DBHelper.ExecuteNonQuery(query, parameters) > 0;

            // 如果是即時完成的任務，發送完成通知
            if (success && isInstantComplete)
            {
                AddNotification(userId, "TaskComplete", "任務完成！", 
                    $"您已完成「{task.TaskName}」任務，請前往領取獎勵！");
            }

            return success;
        }

        /// <summary>
        /// 判斷是否為即時完成的任務
        /// </summary>
        private static bool IsInstantCompleteTask(GameTask task)
        {
            // 每日簽到類任務應該立即完成
            if (task.TaskName != null && 
                (task.TaskName.Contains("簽到") || 
                 task.TaskName.Contains("登入") ||
                 task.TaskName == "每日簽到"))
            {
                return true;
            }

            // 可以根據其他條件判斷
            // 例如：Category 為 "Daily" 且 Type 為 "Daily" 的簡單任務
            if (task.Category == "Daily" && task.Type == "Daily" && 
                (task.Description == null || task.Description.Contains("登入即可")))
            {
                return true;
            }

            return false;
        }

        /// <summary>
        /// 更新任務進度
        /// </summary>
        public static bool UpdateTaskProgress(int userId, int taskId, int progress)
        {
            string query = @"
                UPDATE UserTasks
                SET Progress = @Progress,
                    Status = CASE WHEN @Progress >= 100 THEN 'Completed' ELSE 'InProgress' END,
                    CompletedDate = CASE WHEN @Progress >= 100 THEN GETDATE() ELSE CompletedDate END
                WHERE UserID = @UserID AND TaskID = @TaskID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId),
                new SqlParameter("@Progress", progress)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 完成任務（手動標記）
        /// </summary>
        public static bool CompleteTask(int userId, int taskId)
        {
            string query = @"
                UPDATE UserTasks
                SET Status = 'Completed',
                    Progress = 100,
                    CompletedDate = GETDATE()
                WHERE UserID = @UserID AND TaskID = @TaskID AND Status = 'InProgress'";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId)
            };

            return DBHelper.ExecuteNonQuery(query, parameters) > 0;
        }

        /// <summary>
        /// 領取任務獎勵
        /// </summary>
        public static bool ClaimTaskReward(int userId, int taskId)
        {
            // 取得任務資訊
            GameTask task = GetTaskById(taskId);
            if (task == null)
            {
                throw new Exception("任務不存在");
            }

            // 檢查任務狀態
            string queryCheck = @"
                SELECT Status, ClaimedDate 
                FROM UserTasks 
                WHERE UserID = @UserID AND TaskID = @TaskID";

            SqlParameter[] parametersCheck = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId)
            };

            DataTable dt = DBHelper.ExecuteQuery(queryCheck, parametersCheck);
            if (dt.Rows.Count == 0)
            {
                throw new Exception("找不到任務記錄");
            }

            DataRow row = dt.Rows[0];
            string status = row["Status"].ToString();
            bool alreadyClaimed = row["ClaimedDate"] != DBNull.Value;

            if (status != "Completed")
            {
                throw new Exception("任務尚未完成");
            }

            if (alreadyClaimed)
            {
                throw new Exception("獎勵已經領取過");
            }

            // 更新任務狀態
            string queryUpdate = @"
                UPDATE UserTasks
                SET Status = 'Claimed',
                    ClaimedDate = GETDATE(),
                    CompletionCount = CompletionCount + 1
                WHERE UserID = @UserID AND TaskID = @TaskID";

            SqlParameter[] parametersUpdate = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId)
            };

            int result = DBHelper.ExecuteNonQuery(queryUpdate, parametersUpdate);

            if (result > 0)
            {
                // 發放獎勵
                UserService.AddExperience(userId, task.ExpReward);
                UserService.AddPoints(userId, task.PointsReward, "TaskReward", 
                    $"完成任務: {task.TaskName}");

                // 新增通知
                AddNotification(userId, "TaskComplete", "任務完成！", 
                    $"您領取了「{task.TaskName}」並獲得 {task.ExpReward} EXP 和 {task.PointsReward} 積分！");

                // 觸發任務完成追蹤（檢查其他任務）
                try
                {
                    TaskProgressTracker.OnTaskCompleted(userId, taskId);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Task tracking error: {ex.Message}");
                }

                // 觸發成就追蹤（檢查任務成就）
                try
                {
                    AchievementTracker.OnTaskCompleted(userId);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"Achievement tracking error: {ex.Message}");
                }

                return true;
            }

            return false;
        }

        /// <summary>
        /// 取得熱門任務（依完成次數排序）
        /// </summary>
        public static List<GameTask> GetPopularTasks(int topCount = 6)
        {
            List<GameTask> tasks = new List<GameTask>();

            string query = $@"
                SELECT TOP {topCount}
                    T.TaskID, T.TaskName, T.Description, T.Category, T.Type, T.ExpReward, T.PointsReward,
                    T.RequiredLevel, T.RequiredCondition, T.MaxCompletions, T.StartDate, T.EndDate,
                    T.IsActive, T.CreatedDate, T.IconUrl, T.DisplayOrder,
                    COUNT(UT.UserTaskID) AS CompletionCount
                FROM Tasks T
                LEFT JOIN UserTasks UT ON T.TaskID = UT.TaskID AND UT.Status = 'Completed'
                WHERE T.IsActive = 1
                    AND (T.StartDate IS NULL OR T.StartDate <= GETDATE())
                    AND (T.EndDate IS NULL OR T.EndDate >= GETDATE())
                GROUP BY T.TaskID, T.TaskName, T.Description, T.Category, T.Type, T.ExpReward, 
                         T.PointsReward, T.RequiredLevel, T.RequiredCondition, T.MaxCompletions, 
                         T.StartDate, T.EndDate, T.IsActive, T.CreatedDate, T.IconUrl, T.DisplayOrder
                ORDER BY CompletionCount DESC, T.DisplayOrder";

            DataTable dt = DBHelper.ExecuteQuery(query);

            foreach (DataRow row in dt.Rows)
            {
                tasks.Add(MapDataRowToTask(row));
            }

            return tasks;
        }

        #region 私有輔助方法

        private static bool IsTaskStarted(int userId, int taskId)
        {
            string query = "SELECT COUNT(*) FROM UserTasks WHERE UserID = @UserID AND TaskID = @TaskID";
            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@TaskID", taskId)
            };

            int count = Convert.ToInt32(DBHelper.ExecuteScalar(query, parameters));
            return count > 0;
        }

        private static void AddNotification(int userId, string type, string title, string content)
        {
            string query = @"
                INSERT INTO Notifications (UserID, Type, Title, Content, IsRead, CreatedDate)
                VALUES (@UserID, @Type, @Title, @Content, 0, GETDATE())";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@Type", type),
                new SqlParameter("@Title", title),
                new SqlParameter("@Content", content)
            };

            DBHelper.ExecuteNonQuery(query, parameters);
        }

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
                RequiredCondition = row["RequiredCondition"] != DBNull.Value ? 
                    row["RequiredCondition"].ToString() : null,
                MaxCompletions = row["MaxCompletions"] != DBNull.Value ? 
                    (int?)Convert.ToInt32(row["MaxCompletions"]) : null,
                StartDate = row["StartDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["StartDate"]) : null,
                EndDate = row["EndDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["EndDate"]) : null,
                IsActive = Convert.ToBoolean(row["IsActive"]),
                CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : null,
                DisplayOrder = Convert.ToInt32(row["DisplayOrder"])
            };
        }

        private static UserTask MapDataRowToUserTask(DataRow row)
        {
            return new UserTask
            {
                UserTaskID = Convert.ToInt32(row["UserTaskID"]),
                UserID = Convert.ToInt32(row["UserID"]),
                TaskID = Convert.ToInt32(row["TaskID"]),
                Status = row["Status"].ToString(),
                Progress = Convert.ToInt32(row["Progress"]),
                StartedDate = row["StartedDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["StartedDate"]) : null,
                CompletedDate = row["CompletedDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["CompletedDate"]) : null,
                ClaimedDate = row["ClaimedDate"] != DBNull.Value ? 
                    (DateTime?)Convert.ToDateTime(row["ClaimedDate"]) : null,
                CompletionCount = Convert.ToInt32(row["CompletionCount"]),
                Task = new GameTask
                {
                    TaskID = Convert.ToInt32(row["TaskID"]),
                    TaskName = row["TaskName"].ToString(),
                    Description = row["Description"] != DBNull.Value ? row["Description"].ToString() : "",
                    Category = row["Category"].ToString(),
                    Type = row["Type"].ToString(),
                    ExpReward = Convert.ToInt32(row["ExpReward"]),
                    PointsReward = Convert.ToInt32(row["PointsReward"]),
                    RequiredLevel = Convert.ToInt32(row["RequiredLevel"]),
                    IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : null
                }
            };
        }

        #endregion
    }
}
