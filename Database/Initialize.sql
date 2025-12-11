-- Database Initialization Script for GamePlatformDB
-- Run this script to set up the database schema and initial data.

-- Create Tables

-- 1. Users Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Users](
        [UserID] [int] IDENTITY(1,1) NOT NULL,
        [UserName] [nvarchar](50) NOT NULL,
        [Email] [nvarchar](100) NOT NULL,
        [PasswordHash] [nvarchar](255) NOT NULL,
        [Avatar] [nvarchar](255) NULL,
        [Level] [int] NOT NULL DEFAULT 1,
        [TotalExp] [int] NOT NULL DEFAULT 0,
        [Points] [int] NOT NULL DEFAULT 0,
        [Bio] [nvarchar](500) NULL,
        [RegisterDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [LastLoginDate] [datetime] NULL,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        CONSTRAINT [PK_Users] PRIMARY KEY CLUSTERED ([UserID] ASC)
    )
END
GO

-- 2. Tasks Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tasks]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Tasks](
        [TaskID] [int] IDENTITY(1,1) NOT NULL,
        [TaskName] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [Category] [nvarchar](50) NOT NULL,
        [Type] [nvarchar](50) NOT NULL,
        [ExpReward] [int] NOT NULL DEFAULT 0,
        [PointsReward] [int] NOT NULL DEFAULT 0,
        [RequiredLevel] [int] NOT NULL DEFAULT 1,
        [RequiredCondition] [nvarchar](255) NULL,
        [MaxCompletions] [int] NULL,
        [StartDate] [datetime] NULL,
        [EndDate] [datetime] NULL,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [IconUrl] [nvarchar](255) NULL,
        [DisplayOrder] [int] NOT NULL DEFAULT 0,
        CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED ([TaskID] ASC)
    )
END
GO

-- 3. UserTasks Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserTasks]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserTasks](
        [UserTaskID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [TaskID] [int] NOT NULL,
        [Status] [nvarchar](50) NOT NULL DEFAULT 'InProgress', -- InProgress, Completed, Claimed
        [Progress] [int] NOT NULL DEFAULT 0,
        [StartedDate] [datetime] NULL,
        [CompletedDate] [datetime] NULL,
        [ClaimedDate] [datetime] NULL,
        [CompletionCount] [int] NOT NULL DEFAULT 0,
        CONSTRAINT [PK_UserTasks] PRIMARY KEY CLUSTERED ([UserTaskID] ASC),
        CONSTRAINT [FK_UserTasks_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID]),
        CONSTRAINT [FK_UserTasks_Tasks] FOREIGN KEY([TaskID]) REFERENCES [dbo].[Tasks] ([TaskID])
    )
END
GO

-- 4. Items Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Items]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Items](
        [ItemID] [int] IDENTITY(1,1) NOT NULL,
        [ItemName] [nvarchar](100) NOT NULL,
        [Type] [nvarchar](50) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [IconUrl] [nvarchar](255) NULL,
        [Price] [int] NOT NULL DEFAULT 0,
        [Stock] [int] NULL,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [DisplayOrder] [int] NOT NULL DEFAULT 0,
        CONSTRAINT [PK_Items] PRIMARY KEY CLUSTERED ([ItemID] ASC)
    )
END
GO

-- 5. UserItems Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserItems]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserItems](
        [UserItemID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [ItemID] [int] NOT NULL,
        [Quantity] [int] NOT NULL DEFAULT 1,
        [ObtainDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_UserItems] PRIMARY KEY CLUSTERED ([UserItemID] ASC),
        CONSTRAINT [FK_UserItems_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID]),
        CONSTRAINT [FK_UserItems_Items] FOREIGN KEY([ItemID]) REFERENCES [dbo].[Items] ([ItemID])
    )
END
GO

-- 6. Achievements Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Achievements]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Achievements](
        [AchievementID] [int] IDENTITY(1,1) NOT NULL,
        [Name] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [Category] [nvarchar](50) NOT NULL,
        [Condition] [nvarchar](255) NULL,
        [BadgeIcon] [nvarchar](255) NULL,
        [Rarity] [nvarchar](50) NOT NULL DEFAULT 'Common',
        [Points] [int] NOT NULL DEFAULT 0,
        [IsHidden] [bit] NOT NULL DEFAULT 0,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_Achievements] PRIMARY KEY CLUSTERED ([AchievementID] ASC)
    )
END
GO

-- 7. UserAchievements Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[UserAchievements]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[UserAchievements](
        [UserAchievementID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [AchievementID] [int] NOT NULL,
        [UnlockDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_UserAchievements] PRIMARY KEY CLUSTERED ([UserAchievementID] ASC),
        CONSTRAINT [FK_UserAchievements_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID]),
        CONSTRAINT [FK_UserAchievements_Achievements] FOREIGN KEY([AchievementID]) REFERENCES [dbo].[Achievements] ([AchievementID])
    )
END
GO

-- 8. Lotteries Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Lotteries]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Lotteries](
        [LotteryID] [int] IDENTITY(1,1) NOT NULL,
        [LotteryName] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [IconUrl] [nvarchar](255) NULL,
        [CostPoints] [int] NOT NULL DEFAULT 0,
        [StartDate] [datetime] NULL,
        [EndDate] [datetime] NULL,
        [MaxDrawsPerUser] [int] NULL,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [DisplayOrder] [int] NOT NULL DEFAULT 0,
        [AllowedItemID] [int] NULL,
        CONSTRAINT [PK_Lotteries] PRIMARY KEY CLUSTERED ([LotteryID] ASC)
    )
END
GO

-- 9. LotteryPrizes Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LotteryPrizes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LotteryPrizes](
        [PrizeID] [int] IDENTITY(1,1) NOT NULL,
        [LotteryID] [int] NOT NULL,
        [PrizeName] [nvarchar](100) NOT NULL,
        [PrizeType] [nvarchar](50) NOT NULL, -- Points, Item, Experience
        [PrizeValue] [int] NOT NULL DEFAULT 0, -- Points amount, ItemID, or Exp amount
        [IconUrl] [nvarchar](255) NULL,
        [Probability] [decimal](18, 2) NOT NULL DEFAULT 0,
        [Stock] [int] NULL,
        [RemainingStock] [int] NULL,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_LotteryPrizes] PRIMARY KEY CLUSTERED ([PrizeID] ASC),
        CONSTRAINT [FK_LotteryPrizes_Lotteries] FOREIGN KEY([LotteryID]) REFERENCES [dbo].[Lotteries] ([LotteryID])
    )
END
GO

-- 10. LotteryRecords Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[LotteryRecords]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[LotteryRecords](
        [RecordID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [LotteryID] [int] NOT NULL,
        [PrizeID] [int] NOT NULL,
        [DrawDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [IsClaimed] [bit] NOT NULL DEFAULT 0,
        [ClaimedDate] [datetime] NULL,
        CONSTRAINT [PK_LotteryRecords] PRIMARY KEY CLUSTERED ([RecordID] ASC),
        CONSTRAINT [FK_LotteryRecords_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID]),
        CONSTRAINT [FK_LotteryRecords_Lotteries] FOREIGN KEY([LotteryID]) REFERENCES [dbo].[Lotteries] ([LotteryID]),
        CONSTRAINT [FK_LotteryRecords_LotteryPrizes] FOREIGN KEY([PrizeID]) REFERENCES [dbo].[LotteryPrizes] ([PrizeID])
    )
END
GO

-- 11. Transactions Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Transactions]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Transactions](
        [TransactionID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [Type] [nvarchar](50) NOT NULL,
        [Amount] [int] NOT NULL,
        [BalanceAfter] [int] NOT NULL,
        [ItemID] [int] NULL,
        [Description] [nvarchar](500) NULL,
        [Timestamp] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_Transactions] PRIMARY KEY CLUSTERED ([TransactionID] ASC),
        CONSTRAINT [FK_Transactions_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 12. Notifications Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Notifications]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Notifications](
        [NotificationID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [Type] [nvarchar](50) NOT NULL,
        [Title] [nvarchar](100) NOT NULL,
        [Content] [nvarchar](500) NOT NULL,
        [IsRead] [bit] NOT NULL DEFAULT 0,
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([NotificationID] ASC),
        CONSTRAINT [FK_Notifications_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 13. Friendships Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Friendships]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[Friendships](
        [FriendshipID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [FriendID] [int] NOT NULL,
        [Status] [nvarchar](50) NOT NULL DEFAULT 'Pending', -- Pending, Accepted, Rejected
        [RequestDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [AcceptDate] [datetime] NULL,
        CONSTRAINT [PK_Friendships] PRIMARY KEY CLUSTERED ([FriendshipID] ASC),
        CONSTRAINT [FK_Friendships_Users_User] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID]),
        CONSTRAINT [FK_Friendships_Users_Friend] FOREIGN KEY([FriendID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 14. MessageBoard Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MessageBoard]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[MessageBoard](
        [MessageID] [int] IDENTITY(1,1) NOT NULL,
        [UserID] [int] NOT NULL,
        [Content] [nvarchar](1000) NOT NULL,
        [PostedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [LikeCount] [int] NOT NULL DEFAULT 0,
        [IsDeleted] [bit] NOT NULL DEFAULT 0,
        CONSTRAINT [PK_MessageBoard] PRIMARY KEY CLUSTERED ([MessageID] ASC),
        CONSTRAINT [FK_MessageBoard_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 15. MessageLikes Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[MessageLikes]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[MessageLikes](
        [LikeID] [int] IDENTITY(1,1) NOT NULL,
        [MessageID] [int] NOT NULL,
        [UserID] [int] NOT NULL,
        [LikedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        CONSTRAINT [PK_MessageLikes] PRIMARY KEY CLUSTERED ([LikeID] ASC),
        CONSTRAINT [FK_MessageLikes_MessageBoard] FOREIGN KEY([MessageID]) REFERENCES [dbo].[MessageBoard] ([MessageID]),
        CONSTRAINT [FK_MessageLikes_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 16. ChatRooms Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatRooms]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ChatRooms](
        [RoomID] [int] IDENTITY(1,1) NOT NULL,
        [RoomName] [nvarchar](100) NOT NULL,
        [Description] [nvarchar](500) NULL,
        [CreatorID] [int] NOT NULL,
        [RoomType] [nvarchar](50) NOT NULL DEFAULT 'Public', -- Public, Private
        [CreatedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [IconUrl] [nvarchar](255) NULL,
        [MaxMembers] [int] NOT NULL DEFAULT 50,
        [IsActive] [bit] NOT NULL DEFAULT 1,
        CONSTRAINT [PK_ChatRooms] PRIMARY KEY CLUSTERED ([RoomID] ASC),
        CONSTRAINT [FK_ChatRooms_Users] FOREIGN KEY([CreatorID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 17. ChatRoomMembers Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatRoomMembers]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ChatRoomMembers](
        [MemberID] [int] IDENTITY(1,1) NOT NULL,
        [RoomID] [int] NOT NULL,
        [UserID] [int] NOT NULL,
        [Role] [nvarchar](50) NOT NULL DEFAULT 'Member', -- Owner, Admin, Member
        [JoinedDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [IsActive] [bit] NOT NULL DEFAULT 1,
        CONSTRAINT [PK_ChatRoomMembers] PRIMARY KEY CLUSTERED ([MemberID] ASC),
        CONSTRAINT [FK_ChatRoomMembers_ChatRooms] FOREIGN KEY([RoomID]) REFERENCES [dbo].[ChatRooms] ([RoomID]),
        CONSTRAINT [FK_ChatRoomMembers_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- 18. ChatMessages Table
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ChatMessages]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[ChatMessages](
        [ChatMessageID] [int] IDENTITY(1,1) NOT NULL,
        [RoomID] [int] NOT NULL,
        [UserID] [int] NOT NULL,
        [Content] [nvarchar](1000) NOT NULL,
        [MessageType] [nvarchar](50) NOT NULL DEFAULT 'Text',
        [SentDate] [datetime] NOT NULL DEFAULT GETDATE(),
        [IsDeleted] [bit] NOT NULL DEFAULT 0,
        CONSTRAINT [PK_ChatMessages] PRIMARY KEY CLUSTERED ([ChatMessageID] ASC),
        CONSTRAINT [FK_ChatMessages_ChatRooms] FOREIGN KEY([RoomID]) REFERENCES [dbo].[ChatRooms] ([RoomID]),
        CONSTRAINT [FK_ChatMessages_Users] FOREIGN KEY([UserID]) REFERENCES [dbo].[Users] ([UserID])
    )
END
GO

-- Insert Seed Data

-- Achievements
IF NOT EXISTS (SELECT * FROM [dbo].[Achievements])
BEGIN
    INSERT INTO [dbo].[Achievements] ([Name], [Description], [Category], [Condition], [BadgeIcon], [Rarity], [Points], [IsHidden]) VALUES
    (N'新手', N'達到等級 10', N'Level', N'ReachLevel:10', N'badge-level-10.png', N'Common', 100, 0),
    (N'老手', N'達到等級 30', N'Level', N'ReachLevel:30', N'badge-level-30.png', N'Uncommon', 300, 0),
    (N'賢者', N'達到等級 50', N'Level', N'ReachLevel:50', N'badge-level-50.png', N'Rare', 500, 0),
    (N'入土者', N'達到等級 100', N'Level', N'ReachLevel:100', N'badge-level-100.png', N'Epic', 1000, 0),
    (N'骨灰級玩家', N'達到等級 200', N'Level', N'ReachLevel:200', N'badge-level-200.png', N'Legendary', 2000, 0),
    (N'啟航者', N'完成 1 個任務', N'Task', N'CompleteTask:1', N'badge-task-1.png', N'Common', 50, 0),
    (N'水手', N'完成 10 個任務', N'Task', N'CompleteTask:10', N'badge-task-10.png', N'Uncommon', 150, 0),
    (N'海盜', N'完成 30 個任務', N'Task', N'CompleteTask:30', N'badge-task-30.png', N'Rare', 300, 0),
    (N'海盜船長', N'完成 50 個任務', N'Task', N'CompleteTask:50', N'badge-task-50.png', N'Epic', 500, 0),
    (N'海上明珠', N'完成 100 個任務', N'Task', N'CompleteTask:100', N'badge-task-100.png', N'Legendary', 1000, 0)
END
GO

-- Tasks
IF NOT EXISTS (SELECT * FROM [dbo].[Tasks])
BEGIN
    INSERT INTO [dbo].[Tasks] ([TaskName], [Description], [Category], [Type], [ExpReward], [PointsReward], [RequiredLevel], [RequiredCondition], [MaxCompletions], [IsActive], [DisplayOrder]) VALUES
    (N'每日簽到', N'每日登入即可獲得獎勵', N'Daily', N'Daily', 50, 10, 1, NULL, 1, 1, 1),
    (N'首次購物', N'在商店購買任意商品', N'OneTime', N'Shopping', 100, 50, 1, NULL, 1, 1, 2),
    (N'購物狂', N'累計購買 5 次商品', N'Achievement', N'Shopping', 300, 150, 1, NULL, 1, 1, 3),
    (N'初心者', N'完成任意一個任務', N'OneTime', N'General', 50, 20, 1, NULL, 1, 1, 4),
    (N'等級起飛', N'達到等級 5', N'OneTime', N'Level', 200, 100, 1, NULL, 1, 1, 5),
    (N'交好友', N'新增 1 位好友', N'Social', N'Social', 100, 50, 1, NULL, 1, 1, 6),
    (N'人氣王', N'擁有 10 位好友', N'Social', N'Social', 500, 250, 1, NULL, 1, 1, 7),
    (N'第一次抽獎', N'參與 1 次抽獎', N'OneTime', N'Lottery', 100, 50, 1, NULL, 1, 1, 8),
    (N'抽抽樂', N'累計抽獎 10 次', N'Achievement', N'Lottery', 300, 150, 1, NULL, 1, 1, 9),
    (N'賭徒', N'累計抽獎 100 次', N'Achievement', N'Lottery', 1000, 500, 1, NULL, 1, 1, 10),
    (N'平台功能導覽', N'瀏覽平台各項功能', N'OneTime', N'Guide', 50, 20, 1, NULL, 1, 1, 11)
END
GO

-- Items
IF NOT EXISTS (SELECT * FROM [dbo].[Items])
BEGIN
    INSERT INTO [dbo].[Items] ([ItemName], [Type], [Description], [IconUrl], [Price], [Stock], [IsActive], [DisplayOrder]) VALUES
    (N'經驗藥水', N'Consumable', N'使用後獲得 500 經驗值', N'potion-exp.png', 100, 999, 1, 1),
    (N'抽獎券', N'Ticket', N'可用於參與抽獎活動', N'ticket-lottery.png', 200, 999, 1, 2),
    (N'改名卡', N'Service', N'修改使用者名稱一次', N'card-rename.png', 500, 999, 1, 3)
END
GO

-- Lotteries
IF NOT EXISTS (SELECT * FROM [dbo].[Lotteries])
BEGIN
    INSERT INTO [dbo].[Lotteries] ([LotteryName], [Description], [IconUrl], [CostPoints], [MaxDrawsPerUser], [IsActive], [DisplayOrder], [AllowedItemID]) VALUES
    (N'幸運轉盤', N'試試你的手氣，贏取大獎！', N'wheel-lucky.png', 100, NULL, 1, 1, 2) -- AllowedItemID 2 is 抽獎券
END
GO

-- Lottery Prizes (Assuming LotteryID 1 exists from above)
IF NOT EXISTS (SELECT * FROM [dbo].[LotteryPrizes])
BEGIN
    DECLARE @LotteryID int = (SELECT TOP 1 LotteryID FROM [dbo].[Lotteries] WHERE LotteryName = N'幸運轉盤')
    
    INSERT INTO [dbo].[LotteryPrizes] ([LotteryID], [PrizeName], [PrizeType], [PrizeValue], [IconUrl], [Probability], [Stock], [IsActive]) VALUES
    (@LotteryID, N'10 積分', N'Points', 10, N'coin-10.png', 40.00, NULL, 1),
    (@LotteryID, N'50 積分', N'Points', 50, N'coin-50.png', 30.00, NULL, 1),
    (@LotteryID, N'100 經驗', N'Experience', 100, N'exp-100.png', 20.00, NULL, 1),
    (@LotteryID, N'抽獎券', N'Item', 2, N'ticket-lottery.png', 9.00, 100, 1), -- ItemID 2 is 抽獎券
    (@LotteryID, N'1000 積分大獎', N'Points', 1000, N'coin-1000.png', 1.00, 10, 1)
END
GO
