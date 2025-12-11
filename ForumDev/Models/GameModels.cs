using System;

namespace ForumDev.Models
{
    /// <summary>
    /// 用戶模型
    /// </summary>
    public class User
    {
        public int UserID { get; set; }
        public string UserName { get; set; }
        public string Email { get; set; }
        public string PasswordHash { get; set; }
        public string Avatar { get; set; }
        public int Level { get; set; }
        public int TotalExp { get; set; }
        public int Points { get; set; }
        public string Bio { get; set; }
        public DateTime RegisterDate { get; set; }
        public DateTime? LastLoginDate { get; set; }
        public bool IsActive { get; set; }
    }

    /// <summary>
    /// 任務模型
    /// </summary>
    public class GameTask
    {
        public int TaskID { get; set; }
        public string TaskName { get; set; }
        public string Description { get; set; }
        public string Category { get; set; }
        public string Type { get; set; }
        public int ExpReward { get; set; }
        public int PointsReward { get; set; }
        public int RequiredLevel { get; set; }
        public string RequiredCondition { get; set; }
        public int? MaxCompletions { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public string IconUrl { get; set; }
        public int DisplayOrder { get; set; }
    }

    /// <summary>
    /// 用戶任務模型
    /// </summary>
    public class UserTask
    {
        public int UserTaskID { get; set; }
        public int UserID { get; set; }
        public int TaskID { get; set; }
        public string Status { get; set; }
        public int Progress { get; set; }
        public DateTime? StartedDate { get; set; }
        public DateTime? CompletedDate { get; set; }
        public DateTime? ClaimedDate { get; set; }
        public int CompletionCount { get; set; }
        public GameTask Task { get; set; }
    }

    /// <summary>
    /// 道具模型
    /// </summary>
    public class Item
    {
        public int ItemID { get; set; }
        public string ItemName { get; set; }
        public string Type { get; set; }
        public string Description { get; set; }
        public string IconUrl { get; set; }
        public int Price { get; set; }
        public int? Stock { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public int DisplayOrder { get; set; }
    }

    /// <summary>
    /// 用戶道具模型
    /// </summary>
    public class UserItem
    {
        public int UserItemID { get; set; }
        public int UserID { get; set; }
        public int ItemID { get; set; }
        public int Quantity { get; set; }
        public DateTime ObtainDate { get; set; }
        public Item Item { get; set; }
    }

    /// <summary>
    /// 成就模型
    /// </summary>
    public class Achievement
    {
        public int AchievementID { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Category { get; set; }
        public string Condition { get; set; }
        public string BadgeIcon { get; set; }
        public string Rarity { get; set; }
        public int Points { get; set; }
        public bool IsHidden { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// 用戶成就模型
    /// </summary>
    public class UserAchievement
    {
        public int UserAchievementID { get; set; }
        public int UserID { get; set; }
        public int AchievementID { get; set; }
        public DateTime UnlockedDate { get; set; }
        public Achievement Achievement { get; set; }
    }

    /// <summary>
    /// 抽獎活動模型
    /// </summary>
    public class Lottery
    {
        public int LotteryID { get; set; }
        public string LotteryName { get; set; }
        public string Description { get; set; }
        public string IconUrl { get; set; }
        public int CostPoints { get; set; }
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int? MaxDrawsPerUser { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
        public int DisplayOrder { get; set; }
        public int? AllowedItemID { get; set; }  // 可使用的道具ID（例如：抽獎券）
    }

    /// <summary>
    /// 抽獎獎品模型
    /// </summary>
    public class LotteryPrize
    {
        public int PrizeID { get; set; }
        public int LotteryID { get; set; }
        public string PrizeName { get; set; }
        public string PrizeType { get; set; }  // Points, Item, Experience, Special
        public int PrizeValue { get; set; }
        public string IconUrl { get; set; }
        public string ItemIconUrl { get; set; }  // 道具類型獎品的圖片 URL（從 Items 表獲取）
        public decimal Probability { get; set; }
        public int? Stock { get; set; }
        public int? RemainingStock { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// 抽獎記錄模型
    /// </summary>
    public class LotteryRecord
    {
        public int RecordID { get; set; }
        public int UserID { get; set; }
        public int LotteryID { get; set; }
        public int PrizeID { get; set; }
        public DateTime DrawDate { get; set; }
        public bool IsClaimed { get; set; }
        public DateTime? ClaimedDate { get; set; }
        public LotteryPrize Prize { get; set; }
        public Lottery Lottery { get; set; }
    }

    /// <summary>
    /// 通知模型
    /// </summary>
    public class Notification
    {
        public int NotificationID { get; set; }
        public int UserID { get; set; }
        public string Type { get; set; }
        public string Title { get; set; }
        public string Content { get; set; }
        public bool IsRead { get; set; }
        public DateTime CreatedDate { get; set; }
    }

    /// <summary>
    /// 儀表板統計模型
    /// </summary>
    public class DashboardStats
    {
        public int TotalUsers { get; set; }
        public int ActiveUsers { get; set; }
        public int TotalTasks { get; set; }
        public int CompletedTasks { get; set; }
        public int TotalRewards { get; set; }
    }

    /// <summary>
    /// 用戶統計模型
    /// </summary>
    public class UserStats
    {
        public int UserID { get; set; }
        public int TasksCompleted { get; set; }
        public int AchievementsUnlocked { get; set; }
        public int FriendsCount { get; set; }
        public int UnreadNotifications { get; set; }
    }
}
