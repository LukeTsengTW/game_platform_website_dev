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
    /// 抽獎服務 - 完整版
    /// </summary>
    public class LotteryService
    {
        /// <summary>
        /// 獲取所有可用的抽獎活動
        /// </summary>
        public static List<Models.Lottery> GetAvailableLotteries()
        {
            var lotteries = new List<Models.Lottery>();

            string query = @"
                SELECT LotteryID, LotteryName, Description, IconUrl, CostPoints, 
                       StartDate, EndDate, MaxDrawsPerUser, IsActive, CreatedDate, DisplayOrder, AllowedItemID
                FROM Lotteries
                WHERE IsActive = 1
                    AND (StartDate IS NULL OR StartDate <= GETDATE())
                    AND (EndDate IS NULL OR EndDate >= GETDATE())
                ORDER BY DisplayOrder, LotteryID";

            DataTable dt = DBHelper.ExecuteQuery(query);

            foreach (DataRow row in dt.Rows)
            {
                lotteries.Add(new Models.Lottery
                {
                    LotteryID = Convert.ToInt32(row["LotteryID"]),
                    LotteryName = row["LotteryName"].ToString(),
                    Description = row["Description"] != DBNull.Value ? row["Description"].ToString() : "",
                    IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : "",
                    CostPoints = Convert.ToInt32(row["CostPoints"]),
                    StartDate = row["StartDate"] != DBNull.Value ?
                        (DateTime?)Convert.ToDateTime(row["StartDate"]) : null,
                    EndDate = row["EndDate"] != DBNull.Value ?
                        (DateTime?)Convert.ToDateTime(row["EndDate"]) : null,
                    MaxDrawsPerUser = row["MaxDrawsPerUser"] != DBNull.Value ?
                        (int?)Convert.ToInt32(row["MaxDrawsPerUser"]) : null,
                    IsActive = Convert.ToBoolean(row["IsActive"]),
                    CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                    DisplayOrder = Convert.ToInt32(row["DisplayOrder"]),
                    AllowedItemID = row["AllowedItemID"] != DBNull.Value ?
                        (int?)Convert.ToInt32(row["AllowedItemID"]) : null
                });
            }

            return lotteries;
        }

        /// <summary>
        /// 根據 ID 獲取抽獎活動
        /// </summary>
        public static Models.Lottery GetLotteryById(int lotteryId)
        {
            string query = @"
                SELECT LotteryID, LotteryName, Description, IconUrl, CostPoints, 
                       StartDate, EndDate, MaxDrawsPerUser, IsActive, CreatedDate, DisplayOrder, AllowedItemID
                FROM Lotteries
                WHERE LotteryID = @LotteryID";

            SqlParameter[] parameters = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                return new Models.Lottery
                {
                    LotteryID = Convert.ToInt32(row["LotteryID"]),
                    LotteryName = row["LotteryName"].ToString(),
                    Description = row["Description"] != DBNull.Value ? row["Description"].ToString() : "",
                    IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : "",
                    CostPoints = Convert.ToInt32(row["CostPoints"]),
                    StartDate = row["StartDate"] != DBNull.Value ?
                        (DateTime?)Convert.ToDateTime(row["StartDate"]) : null,
                    EndDate = row["EndDate"] != DBNull.Value ?
                        (DateTime?)Convert.ToDateTime(row["EndDate"]) : null,
                    MaxDrawsPerUser = row["MaxDrawsPerUser"] != DBNull.Value ?
                        (int?)Convert.ToInt32(row["MaxDrawsPerUser"]) : null,
                    IsActive = Convert.ToBoolean(row["IsActive"]),
                    CreatedDate = Convert.ToDateTime(row["CreatedDate"]),
                    DisplayOrder = Convert.ToInt32(row["DisplayOrder"]),
                    AllowedItemID = row["AllowedItemID"] != DBNull.Value ?
                        (int?)Convert.ToInt32(row["AllowedItemID"]) : null
                };
            }

            return null;
        }

        /// <summary>
        /// 獲取用戶的抽獎記錄
        /// </summary>
        public static List<LotteryRecord> GetUserLotteryRecords(int userId, bool onlyUnclaimed = false)
        {
            List<LotteryRecord> records = new List<LotteryRecord>();

            // 查詢時加入 Items 表的 LEFT JOIN 來獲取道具類型獎品的圖片
            string query = @"
                SELECT 
                    LR.RecordID, LR.UserID, LR.LotteryID, LR.PrizeID, LR.DrawDate, LR.IsClaimed, LR.ClaimedDate,
                    L.LotteryName, L.IconUrl AS LotteryIcon,
                    LP.PrizeName, LP.PrizeType, LP.PrizeValue, LP.IconUrl AS PrizeIcon,
                    I.IconUrl AS ItemIconUrl
                FROM LotteryRecords LR
                INNER JOIN Lotteries L ON LR.LotteryID = L.LotteryID
                INNER JOIN LotteryPrizes LP ON LR.PrizeID = LP.PrizeID
                LEFT JOIN Items I ON LP.PrizeType = 'Item' AND LP.PrizeValue = I.ItemID
                WHERE LR.UserID = @UserID";

            if (onlyUnclaimed)
            {
                query += " AND LR.IsClaimed = 0";
            }

            query += " ORDER BY LR.DrawDate DESC";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                records.Add(new LotteryRecord
                {
                    RecordID = Convert.ToInt32(row["RecordID"]),
                    UserID = Convert.ToInt32(row["UserID"]),
                    LotteryID = Convert.ToInt32(row["LotteryID"]),
                    PrizeID = Convert.ToInt32(row["PrizeID"]),
                    DrawDate = Convert.ToDateTime(row["DrawDate"]),
                    IsClaimed = Convert.ToBoolean(row["IsClaimed"]),
                    ClaimedDate = row["ClaimedDate"] != DBNull.Value ?
                        (DateTime?)Convert.ToDateTime(row["ClaimedDate"]) : null,
                    Prize = new LotteryPrize
                    {
                        PrizeID = Convert.ToInt32(row["PrizeID"]),
                        PrizeName = row["PrizeName"].ToString(),
                        PrizeType = row["PrizeType"].ToString(),
                        PrizeValue = Convert.ToInt32(row["PrizeValue"]),
                        IconUrl = row["PrizeIcon"].ToString(),
                        ItemIconUrl = row["ItemIconUrl"] != DBNull.Value ? row["ItemIconUrl"].ToString() : null
                    },
                    Lottery = new Models.Lottery
                    {
                        LotteryID = Convert.ToInt32(row["LotteryID"]),
                        LotteryName = row["LotteryName"].ToString(),
                        IconUrl = row["LotteryIcon"].ToString()
                    }
                });
            }

            return records;
        }

        /// <summary>
        /// 執行抽獎（簡化版）
        /// </summary>
        public static LotteryPrize DrawLottery(int userId, int lotteryId, bool useTicket = false)
        {
            // 1. 檢查抽獎活動
            string lotteryQuery = @"
                SELECT LotteryID, LotteryName, CostPoints, MaxDrawsPerUser, IsActive, AllowedItemID
                FROM Lotteries
                WHERE LotteryID = @LotteryID AND IsActive = 1";

            SqlParameter[] lotteryParams = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable lotteryDt = DBHelper.ExecuteQuery(lotteryQuery, lotteryParams);
            if (lotteryDt.Rows.Count == 0)
            {
                throw new Exception("抽獎活動不存在或已結束");
            }

            DataRow lotteryRow = lotteryDt.Rows[0];
            int costPoints = Convert.ToInt32(lotteryRow["CostPoints"]);
            object maxDrawsObj = lotteryRow["MaxDrawsPerUser"];
            object allowedItemObj = lotteryRow["AllowedItemID"];

            // 2. 檢查是否可以使用抽獎券
            if (useTicket)
            {
                if (allowedItemObj == DBNull.Value)
                {
                    throw new Exception("此抽獎活動不支援使用抽獎券");
                }

                int allowedItemId = Convert.ToInt32(allowedItemObj);

                // 檢查用戶是否有抽獎券
                string checkTicket = @"
                    SELECT Quantity 
                    FROM UserItems 
                    WHERE UserID = @UserID AND ItemID = @ItemID";

                SqlParameter[] ticketCheckParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@ItemID", allowedItemId)
                };

                DataTable ticketDt = DBHelper.ExecuteQuery(checkTicket, ticketCheckParams);
                if (ticketDt.Rows.Count == 0 || Convert.ToInt32(ticketDt.Rows[0]["Quantity"]) < 1)
                {
                    throw new Exception("您沒有抽獎券！請前往商店購買或使用積分抽獎。");
                }

                // 扣除抽獎券（創建新的參數）
                string useTicketQuery = @"
                    UPDATE UserItems 
                    SET Quantity = Quantity - 1 
                    WHERE UserID = @UserID AND ItemID = @ItemID";

                SqlParameter[] ticketUpdateParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@ItemID", allowedItemId)
                };

                DBHelper.ExecuteNonQuery(useTicketQuery, ticketUpdateParams);

                // 記錄交易
                string recordTransaction = @"
                    INSERT INTO Transactions (UserID, Type, Amount, BalanceAfter, Description, Timestamp)
                    VALUES (@UserID, 'ItemUsed', 0, (SELECT Points FROM Users WHERE UserID = @UserID), 
                            '使用抽獎券: ' + @LotteryName, GETDATE())";

                SqlParameter[] transParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@LotteryName", lotteryRow["LotteryName"].ToString())
                };

                DBHelper.ExecuteNonQuery(recordTransaction, transParams);
            }
            else
            {
                // 使用積分抽獎
                // 2. 檢查用戶積分
                User user = UserService.GetUserById(userId);
                if (user.Points < costPoints)
                {
                    throw new Exception($"積分不足！需要 {costPoints} 積分");
                }

                // 6. 扣除積分
                if (costPoints > 0)
                {
                    UserService.AddPoints(userId, -costPoints, "Lottery", 
                        $"參與抽獎: {lotteryRow["LotteryName"]}");
                }
            }

            // 3. 檢查抽獎次數
            if (maxDrawsObj != DBNull.Value)
            {
                int maxDraws = Convert.ToInt32(maxDrawsObj);
                string countQuery = "SELECT COUNT(*) FROM LotteryRecords WHERE UserID = @UserID AND LotteryID = @LotteryID";
                SqlParameter[] countParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@LotteryID", lotteryId)
                };
                int drawCount = Convert.ToInt32(DBHelper.ExecuteScalar(countQuery, countParams));
                
                if (drawCount >= maxDraws)
                {
                    throw new Exception($"已達到最大抽獎次數（{maxDraws} 次）");
                }
            }

            // 4. 獲取獎品列表
            string prizesQuery = @"
                SELECT PrizeID, PrizeName, PrizeType, PrizeValue, IconUrl, Probability, RemainingStock
                FROM LotteryPrizes
                WHERE LotteryID = @LotteryID AND IsActive = 1
                    AND (RemainingStock IS NULL OR RemainingStock > 0)
                ORDER BY Probability DESC";

            SqlParameter[] prizesParams = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable prizesDt = DBHelper.ExecuteQuery(prizesQuery, prizesParams);
            if (prizesDt.Rows.Count == 0)
            {
                throw new Exception("暫無可抽獎品");
            }

            // 5. 隨機抽取獎品
            Random random = new Random();
            double randomValue = random.NextDouble() * 100;
            double cumulative = 0;
            DataRow selectedPrize = null;

            foreach (DataRow row in prizesDt.Rows)
            {
                cumulative += Convert.ToDouble(row["Probability"]);
                if (randomValue <= cumulative)
                {
                    selectedPrize = row;
                    break;
                }
            }

            if (selectedPrize == null)
            {
                selectedPrize = prizesDt.Rows[0]; // 保底
            }

            int prizeId = Convert.ToInt32(selectedPrize["PrizeID"]);

            // 7. 更新庫存
            if (selectedPrize["RemainingStock"] != DBNull.Value)
            {
                string updateStock = "UPDATE LotteryPrizes SET RemainingStock = RemainingStock - 1 WHERE PrizeID = @PrizeID";
                SqlParameter[] stockParams = { new SqlParameter("@PrizeID", prizeId) };
                DBHelper.ExecuteNonQuery(updateStock, stockParams);
            }

            // 8. 記錄抽獎
            string insertRecord = @"
                INSERT INTO LotteryRecords (UserID, LotteryID, PrizeID, DrawDate, IsClaimed)
                VALUES (@UserID, @LotteryID, @PrizeID, GETDATE(), 0)";

            SqlParameter[] recordParams = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@LotteryID", lotteryId),
                new SqlParameter("@PrizeID", prizeId)
            };

            DBHelper.ExecuteNonQuery(insertRecord, recordParams);

            // 9. 追蹤抽獎任務進度
            try
            {
                TaskProgressTracker.OnLotteryDrawn(userId, 1);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error tracking lottery task: {ex.Message}");
            }

            // 10. 返回獎品
            return new LotteryPrize
            {
                PrizeID = prizeId,
                PrizeName = selectedPrize["PrizeName"].ToString(),
                PrizeType = selectedPrize["PrizeType"].ToString(),
                PrizeValue = Convert.ToInt32(selectedPrize["PrizeValue"]),
                IconUrl = selectedPrize["IconUrl"].ToString()
            };
        }

        /// <summary>
        /// 執行十連抽
        /// </summary>
        public static List<LotteryPrize> DrawLottery10(int userId, int lotteryId, bool useTicket = false)
        {
            List<LotteryPrize> results = new List<LotteryPrize>();

            // 1. 檢查抽獎活動
            string lotteryQuery = @"
                SELECT LotteryID, LotteryName, CostPoints, MaxDrawsPerUser, IsActive, AllowedItemID
                FROM Lotteries
                WHERE LotteryID = @LotteryID AND IsActive = 1";

            SqlParameter[] lotteryParams = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable lotteryDt = DBHelper.ExecuteQuery(lotteryQuery, lotteryParams);
            if (lotteryDt.Rows.Count == 0)
            {
                throw new Exception("抽獎活動不存在或已結束");
            }

            DataRow lotteryRow = lotteryDt.Rows[0];
            int costPoints = Convert.ToInt32(lotteryRow["CostPoints"]);
            object maxDrawsObj = lotteryRow["MaxDrawsPerUser"];
            object allowedItemObj = lotteryRow["AllowedItemID"];
            int totalCost = costPoints * 10;

            // 2. 檢查抽獎次數限制
            if (maxDrawsObj != DBNull.Value)
            {
                int maxDraws = Convert.ToInt32(maxDrawsObj);
                string countQuery = "SELECT COUNT(*) FROM LotteryRecords WHERE UserID = @UserID AND LotteryID = @LotteryID";
                SqlParameter[] countParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@LotteryID", lotteryId)
                };
                int drawCount = Convert.ToInt32(DBHelper.ExecuteScalar(countQuery, countParams));
                
                if (drawCount + 10 > maxDraws)
                {
                    int remaining = maxDraws - drawCount;
                    throw new Exception($"剩餘抽獎次數不足！還能抽 {remaining} 次");
                }
            }

            // 3. 檢查並扣除費用
            if (useTicket)
            {
                if (allowedItemObj == DBNull.Value)
                {
                    throw new Exception("此抽獎活動不支援使用抽獎券");
                }

                int allowedItemId = Convert.ToInt32(allowedItemObj);

                // 檢查用戶是否有足夠的抽獎券
                string checkTicket = @"
                    SELECT Quantity 
                    FROM UserItems 
                    WHERE UserID = @UserID AND ItemID = @ItemID";

                SqlParameter[] ticketCheckParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@ItemID", allowedItemId)
                };

                DataTable ticketDt = DBHelper.ExecuteQuery(checkTicket, ticketCheckParams);
                if (ticketDt.Rows.Count == 0 || Convert.ToInt32(ticketDt.Rows[0]["Quantity"]) < 10)
                {
                    throw new Exception("抽獎券不足！十連抽需要 10 張抽獎券。");
                }

                // 扣除 10 張抽獎券
                string useTicketQuery = @"
                    UPDATE UserItems 
                    SET Quantity = Quantity - 10 
                    WHERE UserID = @UserID AND ItemID = @ItemID";

                SqlParameter[] ticketUpdateParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@ItemID", allowedItemId)
                };

                DBHelper.ExecuteNonQuery(useTicketQuery, ticketUpdateParams);

                // 記錄交易
                string recordTransaction = @"
                    INSERT INTO Transactions (UserID, Type, Amount, BalanceAfter, Description, Timestamp)
                    VALUES (@UserID, 'ItemUsed', 0, (SELECT Points FROM Users WHERE UserID = @UserID), 
                            '使用抽獎券十連抽: ' + @LotteryName, GETDATE())";

                SqlParameter[] transParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@LotteryName", lotteryRow["LotteryName"].ToString())
                };

                DBHelper.ExecuteNonQuery(recordTransaction, transParams);
            }
            else
            {
                // 使用積分抽獎
                User user = UserService.GetUserById(userId);
                if (user.Points < totalCost)
                {
                    throw new Exception($"積分不足！十連抽需要 {totalCost} 積分");
                }

                // 扣除積分
                if (totalCost > 0)
                {
                    UserService.AddPoints(userId, -totalCost, "Lottery", 
                        $"十連抽: {lotteryRow["LotteryName"]}");
                }
            }

            // 4. 獲取獎品列表
            string prizesQuery = @"
                SELECT PrizeID, PrizeName, PrizeType, PrizeValue, IconUrl, Probability, RemainingStock
                FROM LotteryPrizes
                WHERE LotteryID = @LotteryID AND IsActive = 1
                    AND (RemainingStock IS NULL OR RemainingStock > 0)
                ORDER BY Probability DESC";

            SqlParameter[] prizesParams = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable prizesDt = DBHelper.ExecuteQuery(prizesQuery, prizesParams);
            if (prizesDt.Rows.Count == 0)
            {
                throw new Exception("暫無可抽獎品");
            }

            // 5. 執行 10 次抽獎
            Random random = new Random();
            for (int i = 0; i < 10; i++)
            {
                double randomValue = random.NextDouble() * 100;
                double cumulative = 0;
                DataRow selectedPrize = null;

                foreach (DataRow row in prizesDt.Rows)
                {
                    cumulative += Convert.ToDouble(row["Probability"]);
                    if (randomValue <= cumulative)
                    {
                        selectedPrize = row;
                        break;
                    }
                }

                if (selectedPrize == null)
                {
                    selectedPrize = prizesDt.Rows[0]; // 保底
                }

                int prizeId = Convert.ToInt32(selectedPrize["PrizeID"]);

                // 更新庫存
                if (selectedPrize["RemainingStock"] != DBNull.Value)
                {
                    string updateStock = "UPDATE LotteryPrizes SET RemainingStock = RemainingStock - 1 WHERE PrizeID = @PrizeID";
                    SqlParameter[] stockParams = { new SqlParameter("@PrizeID", prizeId) };
                    DBHelper.ExecuteNonQuery(updateStock, stockParams);
                }

                // 記錄抽獎
                string insertRecord = @"
                    INSERT INTO LotteryRecords (UserID, LotteryID, PrizeID, DrawDate, IsClaimed)
                    VALUES (@UserID, @LotteryID, @PrizeID, GETDATE(), 0)";

                SqlParameter[] recordParams = {
                    new SqlParameter("@UserID", userId),
                    new SqlParameter("@LotteryID", lotteryId),
                    new SqlParameter("@PrizeID", prizeId)
                };

                DBHelper.ExecuteNonQuery(insertRecord, recordParams);

                // 添加到結果列表
                results.Add(new LotteryPrize
                {
                    PrizeID = prizeId,
                    PrizeName = selectedPrize["PrizeName"].ToString(),
                    PrizeType = selectedPrize["PrizeType"].ToString(),
                    PrizeValue = Convert.ToInt32(selectedPrize["PrizeValue"]),
                    IconUrl = selectedPrize["IconUrl"].ToString()
                });
            }

            // 6. 追蹤抽獎任務進度（十連抽算10次）
            try
            {
                TaskProgressTracker.OnLotteryDrawn(userId, 10);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error tracking lottery task: {ex.Message}");
            }

            return results;
        }

        /// <summary>
        /// 獲取抽獎活動的所有獎品
        /// </summary>
        public static List<LotteryPrize> GetLotteryPrizes(int lotteryId)
        {
            List<LotteryPrize> prizes = new List<LotteryPrize>();

            string query = @"
                SELECT PrizeID, LotteryID, PrizeName, PrizeType, PrizeValue, 
                       IconUrl, Probability, Stock, RemainingStock, IsActive, CreatedDate
                FROM LotteryPrizes
                WHERE LotteryID = @LotteryID AND IsActive = 1
                ORDER BY Probability DESC, PrizeID";

            SqlParameter[] parameters = {
                new SqlParameter("@LotteryID", lotteryId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);

            foreach (DataRow row in dt.Rows)
            {
                prizes.Add(new LotteryPrize
                {
                    PrizeID = Convert.ToInt32(row["PrizeID"]),
                    LotteryID = Convert.ToInt32(row["LotteryID"]),
                    PrizeName = row["PrizeName"].ToString(),
                    PrizeType = row["PrizeType"].ToString(),
                    PrizeValue = Convert.ToInt32(row["PrizeValue"]),
                    IconUrl = row["IconUrl"] != DBNull.Value ? row["IconUrl"].ToString() : "",
                    Probability = Convert.ToDecimal(row["Probability"]),
                    Stock = row["Stock"] != DBNull.Value ? (int?)Convert.ToInt32(row["Stock"]) : null,
                    RemainingStock = row["RemainingStock"] != DBNull.Value ? 
                        (int?)Convert.ToInt32(row["RemainingStock"]) : null,
                    IsActive = Convert.ToBoolean(row["IsActive"]),
                    CreatedDate = Convert.ToDateTime(row["CreatedDate"])
                });
            }

            return prizes;
        }

        /// <summary>
        /// 領取獎品
        /// </summary>
        public static bool ClaimPrize(int userId, int recordId)
        {
            // 1. 檢查記錄
            string checkQuery = @"
                SELECT LR.RecordID, LR.IsClaimed, LP.PrizeType, LP.PrizeValue, LP.PrizeName
                FROM LotteryRecords LR
                INNER JOIN LotteryPrizes LP ON LR.PrizeID = LP.PrizeID
                WHERE LR.RecordID = @RecordID AND LR.UserID = @UserID";

            SqlParameter[] checkParams = {
                new SqlParameter("@RecordID", recordId),
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(checkQuery, checkParams);
            if (dt.Rows.Count == 0)
            {
                throw new Exception("找不到抽獎記錄");
            }

            DataRow record = dt.Rows[0];
            if (Convert.ToBoolean(record["IsClaimed"]))
            {
                throw new Exception("獎品已經領取過了");
            }

            string prizeType = record["PrizeType"].ToString();
            int prizeValue = Convert.ToInt32(record["PrizeValue"]);
            string prizeName = record["PrizeName"].ToString();

            // 2. 發放獎品
            switch (prizeType)
            {
                case "Points":
                    UserService.AddPoints(userId, prizeValue, "LotteryPrize", $"抽獎獎品: {prizeName}");
                    break;

                case "Experience":
                    UserService.AddExperience(userId, prizeValue);
                    break;

                case "Item":
                    // 添加道具
                    string addItem = @"
                        IF EXISTS (SELECT 1 FROM UserItems WHERE UserID = @UserID AND ItemID = @ItemID)
                            UPDATE UserItems SET Quantity = Quantity + 1 WHERE UserID = @UserID AND ItemID = @ItemID
                        ELSE
                            INSERT INTO UserItems (UserID, ItemID, Quantity, ObtainDate)
                            VALUES (@UserID, @ItemID, 1, GETDATE())";

                    SqlParameter[] itemParams = {
                        new SqlParameter("@UserID", userId),
                        new SqlParameter("@ItemID", prizeValue)
                    };
                    DBHelper.ExecuteNonQuery(addItem, itemParams);
                    break;
            }

            // 3. 更新領取狀態
            string updateQuery = @"
                UPDATE LotteryRecords
                SET IsClaimed = 1, ClaimedDate = GETDATE()
                WHERE RecordID = @RecordID";

            SqlParameter[] updateParams = {
                new SqlParameter("@RecordID", recordId)
            };

            int result = DBHelper.ExecuteNonQuery(updateQuery, updateParams);
            return result > 0;
        }

        /// <summary>
        /// 批次領取使用者所有未領取的抽獎獎品，回傳實際領取數量
        /// </summary>
        public static int ClaimAllUnclaimed(int userId)
        {
            // 取得未領取的記錄
            string query = @"
                SELECT LR.RecordID
                FROM LotteryRecords LR
                WHERE LR.UserID = @UserID AND LR.IsClaimed = 0
                ORDER BY LR.DrawDate";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId)
            };

            DataTable dt = DBHelper.ExecuteQuery(query, parameters);
            int successCount = 0;

            foreach (DataRow row in dt.Rows)
            {
                int recordId = Convert.ToInt32(row["RecordID"]);
                try
                {
                    if (ClaimPrize(userId, recordId))
                    {
                        successCount++;
                    }
                }
                catch
                {
                    // 單筆失敗忽略，持續處理其他項目
                }
            }

            return successCount;
        }

        /// <summary>
        /// 獲取用戶擁有的道具數量
        /// </summary>
        public static int GetUserItemQuantity(int userId, int itemId)
        {
            string query = @"
                SELECT ISNULL(Quantity, 0) AS Quantity
                FROM UserItems
                WHERE UserID = @UserID AND ItemID = @ItemID";

            SqlParameter[] parameters = {
                new SqlParameter("@UserID", userId),
                new SqlParameter("@ItemID", itemId)
            };

            object result = DBHelper.ExecuteScalar(query, parameters);
            return result != null ? Convert.ToInt32(result) : 0;
        }
    }
}
