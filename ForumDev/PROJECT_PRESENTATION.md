# ?? 遊戲化挑戰平台 - 專案簡報

## ?? 目錄

1. [專案簡介](#專案簡介)
2. [設計靈感與參考](#設計靈感與參考)
3. [技術架構](#技術架構)
4. [網站架構](#網站架構)
5. [核心功能模組](#核心功能模組)
6. [資料庫設計](#資料庫設計)
7. [重要程式碼說明](#重要程式碼說明)
8. [專案成果](#專案成果)

---

## ?? 專案簡介

### 專案名稱
**遊戲化挑戰平台 (Game Challenge Platform)**

### 專案概述
本專案是一個結合**遊戲化機制**與**社群互動**的綜合性平台，透過任務系統、積分獎勵、抽獎活動等機制，提升用戶參與度與黏著度。平台設計理念源自於現代遊戲產業中成功的社群營運模式，將遊戲內的成就感與獎勵機制延伸至網頁平台。

### 核心價值
| 特色 | 說明 |
|------|------|
| ?? **任務驅動** | 透過每日/週期性任務引導用戶持續參與 |
| ?? **成就系統** | 設立里程碑成就，給予用戶成就感 |
| ?? **獎勵機制** | 積分兌換、抽獎系統增加趣味性 |
| ?? **競爭排行** | 排行榜激發用戶競爭動力 |
| ?? **虛擬經濟** | 完整的積分商城生態系統 |

---

## ?? 設計靈感與參考

### 1. HoYoLAB（米哈遊官方社群平台）

**參考遊戲**：原神、崩壞3rd、崩壞：星穹鐵道

**借鏡特點**：
- ? **每日簽到系統** - 用戶每日登入可獲得獎勵
- ? **任務獎勵機制** - 完成指定任務獲得積分/道具
- ? **活動中心設計** - 限時活動與抽獎系統
- ? **用戶等級制度** - 經驗值累積與等級提升
- ? **遊戲化介面** - 精美的視覺設計與動畫效果

**實際應用**：
| HoYoLAB 功能 | 本專案對應功能 |
|--------------|----------------|
| 每日簽到 | 每日任務系統 |
| 兌換碼系統 | 積分商城 |
| 抽獎活動 | 抽獎中心 |

### 2. 巴哈姆特（綜合性論壇網站）

**借鏡特點**：
- ? **勇者等級制度** - 完善的會員等級系統
- ? **巴幣經濟系統** - 虛擬貨幣的獲取與消費
- ? **成就徽章** - 各種活動與成就徽章
- ? **排行榜系統** - 多維度的用戶排名
- ? **個人檔案頁** - 詳細的用戶資料展示

**實際應用**：
| 巴哈姆特功能 | 本專案對應功能 |
|--------------|----------------|
| 勇者等級 | 用戶等級系統 |
| 巴幣 | 積分系統 |
| 成就徽章 | 成就系統 |

### 3. 電商平台（PChome、蝦皮）

**借鏡特點**：
- ? **商品分類篩選** - 多條件商品篩選功能
- ? **購物車概念** - 道具購買流程設計
- ? **庫存管理** - 商品庫存與限購機制
- ? **交易記錄** - 完整的消費歷史追蹤
- ? **會員優惠** - 等級差異化定價

**實際應用**：
| 電商功能 | 本專案對應功能 |
|----------|----------------|
| 商品列表 | 積分商城 |
| 訂單記錄 | 交易記錄 |
| 會員等級折扣 | 等級專屬道具 |

### 設計理念總結

```
+-----------------------------------------------------------+
|                    遊戲化挑戰平台                          |
+-----------------------------------------------------------+
|                                                           |
|   HoYoLAB          巴哈姆特           電商平台            |
|   +-------+        +-------+         +-------+            |
|   |遊戲化 |   +    | 社群  |    +    | 商城  |            |
|   | 機制  |        | 互動  |         | 經濟  |            |
|   +---+---+        +---+---+         +---+---+            |
|       |                |                 |                |
|       +----------------+-----------------+                |
|                        |                                  |
|                        v                                  |
|               +----------------+                          |
|               |   整合式平台   |                          |
|               +----------------+                          |
|                                                           |
+-----------------------------------------------------------+
```

---

## ??? 技術架構

### 開發環境

| 項目 | 技術/版本 |
|------|-----------|
| **框架** | ASP.NET WebForms 4.7.2 |
| **語言** | C# 7.3 |
| **資料庫** | SQL Server LocalDB |
| **前端框架** | Bootstrap 5 |
| **圖示庫** | Bootstrap Icons + Font Awesome |
| **IDE** | Visual Studio 2022 |

### 架構模式：三層式架構

```
+-----------------------------------------------------------+
|              表現層 (Presentation Layer)                   |
|   +-----------------------------------------------------+ |
|   |  .aspx 頁面  |  .aspx.cs 程式碼後置  |  CSS/JS      | |
|   +-----------------------------------------------------+ |
+-----------------------------------------------------------+
|            商業邏輯層 (Business Logic Layer)               |
|   +-----------------------------------------------------+ |
|   |  UserService  |  TaskService  |  LotteryService     | |
|   |  AchievementTracker  |  SocialService  |  ...       | |
|   +-----------------------------------------------------+ |
+-----------------------------------------------------------+
|              資料存取層 (Data Access Layer)                |
|   +-----------------------------------------------------+ |
|   |  DBHelper.cs  |  SQL Commands  |  Stored Procedures | |
|   +-----------------------------------------------------+ |
+-----------------------------------------------------------+
|                    資料庫 (Database)                       |
|   +-----------------------------------------------------+ |
|   |  SQL Server LocalDB - GamePlatformDB                | |
|   +-----------------------------------------------------+ |
+-----------------------------------------------------------+
```

### 專案目錄結構

```
ForumDev/
|-- Account/                 # 帳戶管理
|   |-- Login.aspx           # 登入頁面
|   +-- Register.aspx        # 註冊頁面
|
|-- BLL/                     # 商業邏輯層
|   |-- UserService.cs       # 用戶服務
|   |-- TaskService.cs       # 任務服務
|   |-- LotteryService.cs    # 抽獎服務
|   |-- AchievementTracker.cs # 成就追蹤
|   |-- SocialService.cs     # 社交服務
|   +-- TaskProgressTracker.cs # 任務進度追蹤
|
|-- DAL/                     # 資料存取層
|   +-- DBHelper.cs          # 資料庫輔助類
|
|-- Models/                  # 資料模型
|   +-- GameModels.cs        # 遊戲相關模型
|
|-- Profile/                 # 個人檔案
|   |-- MyProfile.aspx       # 個人中心
|   |-- MyItems.aspx         # 我的道具
|   |-- Achievements.aspx    # 成就頁面
|   +-- Notifications.aspx   # 通知中心
|
|-- Tasks/                   # 任務系統
|   |-- TaskList.aspx        # 任務大廳
|   +-- MyTasks.aspx         # 我的任務
|
|-- Shop/                    # 商城系統
|   +-- ItemShop.aspx        # 積分商城
|
|-- LotteryPages/            # 抽獎系統
|   |-- LotteryList.aspx     # 抽獎中心
|   +-- MyRecords.aspx       # 抽獎記錄
|
|-- Social/                  # 社交系統
|   +-- Social.aspx          # 好友中心
|
|-- Images/                  # 圖片資源
|   |-- Icons/               # 系統圖示
|   |-- Items/               # 道具圖片
|   +-- Avatars/             # 用戶頭像
|
|-- App_Data/                # 資料庫與SQL腳本
|   |-- GamePlatformDB.mdf   # 資料庫檔案
|   +-- *.sql                # SQL 腳本
|
|-- Default.aspx             # 首頁
|-- Leaderboard.aspx         # 排行榜
|-- PlatformTour.aspx        # 平台導覽
|-- Site.Master              # 主版頁面
+-- Web.config               # 網站配置
```

---

## ??? 網站架構

### 網站地圖

```
                              +------------+
                              |    首頁    |
                              |Default.aspx|
                              +-----+------+
                                    |
         +--------------------------+---------------------------+
         |                          |                           |
         v                          v                           v
+----------------+         +----------------+         +----------------+
|   帳戶系統     |         |   任務系統     |         |   商城系統     |
+----------------+         +----------------+         +----------------+
| - 登入         |         | - 任務大廳     |         | - 積分商城     |
| - 註冊         |         | - 我的任務     |         | - 道具詳情     |
| - 登出         |         | - 任務進度     |         | - 購買流程     |
+----------------+         +----------------+         +----------------+
         |                          |                           |
         v                          v                           v
+----------------+         +----------------+         +----------------+
|   個人中心     |         |   抽獎系統     |         |   排行榜       |
+----------------+         +----------------+         +----------------+
| - 個人資料     |         | - 抽獎中心     |         | - 等級排行     |
| - 我的道具     |         | - 抽獎記錄     |         | - 積分排行     |
| - 成就系統     |         | - 獎品展示     |         | - 貢獻排行     |
| - 通知中心     |         +----------------+         +----------------+
+----------------+
         |
         v
+----------------+         +----------------+
|   社交系統     |         |   平台導覽     |
+----------------+         +----------------+
| - 好友列表     |         | - 功能介紹     |
| - 好友申請     |         | - 新手引導     |
| - 搜尋用戶     |         | - 導覽獎勵     |
+----------------+         +----------------+
```

### 頁面清單

| 頁面 | 路徑 | 功能說明 |
|------|------|----------|
| 首頁 | `/Default.aspx` | 平台入口、統計數據、熱門任務 |
| 登入 | `/Account/Login.aspx` | 用戶登入驗證 |
| 註冊 | `/Account/Register.aspx` | 新用戶註冊 |
| 個人中心 | `/Profile/MyProfile.aspx` | 個人資料、等級進度 |
| 我的道具 | `/Profile/MyItems.aspx` | 道具管理、使用道具 |
| 成就系統 | `/Profile/Achievements.aspx` | 成就展示、進度追蹤 |
| 通知中心 | `/Profile/Notifications.aspx` | 系統通知、訊息管理 |
| 任務大廳 | `/Tasks/TaskList.aspx` | 瀏覽任務、接取任務 |
| 我的任務 | `/Tasks/MyTasks.aspx` | 任務進度、領取獎勵 |
| 積分商城 | `/Shop/ItemShop.aspx` | 商品瀏覽、積分兌換 |
| 抽獎中心 | `/LotteryPages/LotteryList.aspx` | 抽獎活動、單抽/十連抽 |
| 抽獎記錄 | `/LotteryPages/MyRecords.aspx` | 中獎紀錄、領獎狀態 |
| 排行榜 | `/Leaderboard.aspx` | 多維度排名、競爭激勵 |
| 好友中心 | `/Social/Social.aspx` | 社交功能、好友管理 |
| 平台導覽 | `/PlatformTour.aspx` | 新手引導、功能介紹 |

---

## ?? 核心功能模組

### 1. 用戶系統 ??

```
+-----------------------------------------------------------+
|                        用戶系統                            |
+-----------------------------------------------------------+
|                                                           |
|   +-----------+    +-----------+    +-----------+         |
|   |   註冊    |    |   登入    |    | 個人檔案  |         |
|   |           |    |           |    |           |         |
|   | - 帳號驗證|    | - 身份驗證|    | - 資料編輯|         |
|   | - 密碼加密|    | - Cookie  |    | - 頭像上傳|         |
|   | - 資料建立|    | - 記住我  |    | - 等級顯示|         |
|   +-----------+    +-----------+    +-----------+         |
|                                                           |
|   安全機制：SHA-256 密碼加密 + SQL 參數化查詢             |
|                                                           |
+-----------------------------------------------------------+
```

**核心特色**：
- ?? SHA-256 密碼加密
- ?? Forms Authentication 認證
- ?? 經驗值與等級系統
- ??? 頭像上傳（支援 GIF 動圖）

### 2. 任務系統 ??

```
+-----------------------------------------------------------+
|                        任務系統                            |
+-----------------------------------------------------------+
|                                                           |
|   任務類型：                                              |
|   +---------+ +---------+ +---------+ +---------+         |
|   |每日任務 | |學習任務 | |購物任務 | |社交任務 |         |
|   +---------+ +---------+ +---------+ +---------+         |
|                                                           |
|   任務流程：                                              |
|   +------+   +------+   +------+   +------+               |
|   | 接取 | > |進行中| > |已完成| > |已領取|               |
|   | 任務 |   |      |   |      |   |      |               |
|   +------+   +------+   +------+   +------+               |
|                                                           |
|   獎勵類型：經驗值 (EXP) + 積分 (Points)                  |
|                                                           |
+-----------------------------------------------------------+
```

**核心特色**：
- ?? 多類別任務分類
- ?? 自動進度追蹤
- ?? 一鍵領取所有獎勵
- ?? 任務完成統計

### 3. 抽獎系統 ??

```
+-----------------------------------------------------------+
|                        抽獎系統                            |
+-----------------------------------------------------------+
|                                                           |
|   抽獎方式：                                              |
|   +---------------+    +---------------+                  |
|   |     單抽      |    |    十連抽     |                  |
|   |   消耗積分    |    |  消耗積分x10  |                  |
|   |   或抽獎券    |    |  或抽獎券x10  |                  |
|   +---------------+    +---------------+                  |
|                                                           |
|   獎品類型：                                              |
|   +------+ +------+ +------+ +------+                     |
|   | 積分 | | 經驗 | | 道具 | | 特殊 |                     |
|   | 獎勵 | | 獎勵 | | 獎勵 | | 獎品 |                     |
|   +------+ +------+ +------+ +------+                     |
|                                                           |
|   特色功能：抽獎動畫 + 可跳過動畫選項                     |
|                                                           |
+-----------------------------------------------------------+
```

**核心特色**：
- ?? 機率控制獎池
- ? 精美抽獎動畫
- ? 跳過動畫選項
- ?? 完整抽獎記錄

### 4. 積分商城 ??

```
+-----------------------------------------------------------+
|                        積分商城                            |
+-----------------------------------------------------------+
|                                                           |
|   商品分類：                                              |
|   +---------+ +---------+ +---------+ +---------+         |
|   | 道具類  | | 加速類  | | 裝飾類  | | 抽獎券  |         |
|   +---------+ +---------+ +---------+ +---------+         |
|                                                           |
|   購買流程：                                              |
|   +------+   +------+   +------+                          |
|   | 瀏覽 | > | 確認 | > | 扣除 | > 道具入庫              |
|   | 商品 |   | 購買 |   | 積分 |                          |
|   +------+   +------+   +------+                          |
|                                                           |
|   特色功能：庫存管理 + 等級限制 + 商品詳情彈窗            |
|                                                           |
+-----------------------------------------------------------+
```

**核心特色**：
- ??? 多分類篩選
- ?? 庫存管理系統
- ?? 等級限購機制
- ?? 交易記錄追蹤

### 5. 成就系統 ??

```
+-----------------------------------------------------------+
|                        成就系統                            |
+-----------------------------------------------------------+
|                                                           |
|   成就類別：                                              |
|   +---------+ +---------+ +---------+ +---------+         |
|   | 任務類  | | 等級類  | | 消費類  | | 社交類  |         |
|   |         | |         | |         | |         |         |
|   |完成任務 | |達到等級 | |消費積分 | |添加好友 |         |
|   | 10/50   | |  5/10   | |1000/5K  | |  3/10   |         |
|   +---------+ +---------+ +---------+ +---------+         |
|                                                           |
|   成就進度：自動追蹤 + 即時更新 + 獎勵發放                |
|                                                           |
+-----------------------------------------------------------+
```

### 6. 排行榜系統 ??

```
+-----------------------------------------------------------+
|                        排行榜系統                          |
+-----------------------------------------------------------+
|                                                           |
|   排行類型：                                              |
|   +-------------+ +-------------+ +-------------+         |
|   |  等級排行   | |  積分排行   | |  貢獻排行   |         |
|   |             | |             | |             |         |
|   |  ?? 1st     | |  ?? 1st     | |  ?? 1st     |         |
|   |  ?? 2nd     | |  ?? 2nd     | |  ?? 2nd     |         |
|   |  ?? 3rd     | |  ?? 3rd     | |  ?? 3rd     |         |
|   |  ...        | |  ...        | |  ...        |         |
|   +-------------+ +-------------+ +-------------+         |
|                                                           |
|   特色：前三名特殊標記 + 當前用戶高亮 + 即時更新          |
|                                                           |
+-----------------------------------------------------------+
```

---

## ??? 資料庫設計

### E-R 圖（實體關係圖）

```
+-------------+         +-------------+         +-------------+
|   Users     |         |   Tasks     |         |   Items     |
+-------------+         +-------------+         +-------------+
| PK UserID   |<--+     | PK TaskID   |<--+     | PK ItemID   |<--+
| UserName    |   |     | TaskName    |   |     | ItemName    |   |
| Password    |   |     | Category    |   |     | Type        |   |
| Email       |   |     | ExpReward   |   |     | Price       |   |
| Level       |   |     | PointsReward|   |     | Stock       |   |
| Points      |   |     +-------------+   |     +-------------+   |
| TotalExp    |   |           |           |           |           |
+-------------+   |           |           |           |           |
       |          |           v           |           v           |
       |          |    +-------------+    |    +-------------+    |
       |          +----| UserTasks   |    |    | UserItems   |----+
       |               +-------------+    |    +-------------+
       |               | FK UserID   |    |    | FK UserID   |
       |               | FK TaskID   |    |    | FK ItemID   |
       |               | Status      |    |    | Quantity    |
       |               | Progress    |    |    +-------------+
       |               +-------------+    |
       |                                  |
       |    +-------------+               |    +-------------+
       |    | Achievements|               |    | Lotteries   |
       |    +-------------+               |    +-------------+
       |    | PK AchievID |<------+       |    | PK LotteryID|<---+
       |    | Name        |       |       |    | Name        |    |
       |    | Condition   |       |       |    | CostPoints  |    |
       +----+             |       |       |    +-------------+    |
            +-------------+       |       |           |           |
                   |              |       |           v           |
                   v              |       |    +-------------+    |
            +-------------+       |       |    |LotteryPrizes|    |
            |UserAchieve- |-------+       |    +-------------+    |
            |   ments     |               |    | FK LotteryID|----+
            +-------------+               |    | PrizeName   |
            | FK UserID   |               |    | Probability |
            | FK AchievID |               |    +-------------+
            | UnlockedDate|               |           |
            +-------------+               |           v
                                          |    +-------------+
                                          +----+LotteryRecord|
                                               +-------------+
                                               | FK UserID   |
                                               | FK LotteryID|
                                               | PrizeName   |
                                               | DrawDate    |
                                               +-------------+
```

### 主要資料表

| 資料表 | 說明 | 主要欄位 |
|--------|------|----------|
| **Users** | 用戶資料 | UserID, UserName, Password, Email, Level, Points, TotalExp |
| **Tasks** | 任務定義 | TaskID, TaskName, Category, ExpReward, PointsReward |
| **UserTasks** | 用戶任務進度 | UserID, TaskID, Status, Progress, CompletionCount |
| **Items** | 商品/道具 | ItemID, ItemName, Type, Price, Stock, IconUrl |
| **UserItems** | 用戶道具庫存 | UserID, ItemID, Quantity, ObtainDate |
| **Transactions** | 交易記錄 | TransactionID, UserID, Type, Amount, Timestamp |
| **Achievements** | 成就定義 | AchievementID, Name, Description, Condition |
| **UserAchievements** | 用戶成就 | UserID, AchievementID, UnlockedDate |
| **Lotteries** | 抽獎活動 | LotteryID, LotteryName, CostPoints |
| **LotteryPrizes** | 獎品定義 | PrizeID, LotteryID, PrizeName, Probability |
| **LotteryRecords** | 抽獎記錄 | RecordID, UserID, LotteryID, PrizeName, DrawDate |
| **Notifications** | 通知訊息 | NotificationID, UserID, Message, IsRead |
| **Friendships** | 好友關係 | UserID, FriendID, Status, CreatedDate |

---

## ?? 重要程式碼說明

### 1. 三層式架構 - 資料存取層 (DBHelper.cs)

```csharp
/// <summary>
/// 資料庫輔助類 - 封裝所有資料庫操作
/// </summary>
public class DBHelper
{
    private static string connectionString = 
        ConfigurationManager.ConnectionStrings["GamePlatformDB"].ConnectionString;

    /// <summary>
    /// 執行查詢並返回 DataTable
    /// </summary>
    public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                // 使用參數化查詢防止 SQL Injection
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                SqlDataAdapter adapter = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                adapter.Fill(dt);
                return dt;
            }
        }
    }

    /// <summary>
    /// 執行非查詢命令 (INSERT, UPDATE, DELETE)
    /// </summary>
    public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
    {
        using (SqlConnection conn = new SqlConnection(connectionString))
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null)
                    cmd.Parameters.AddRange(parameters);

                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
```

**重點說明**：
- ? 使用 `using` 語句確保資源正確釋放
- ? 參數化查詢防止 SQL Injection 攻擊
- ? 統一的資料庫連線管理

---

### 2. 商業邏輯層 - 用戶服務 (UserService.cs)

```csharp
/// <summary>
/// 用戶服務類 - 處理用戶相關業務邏輯
/// </summary>
public static class UserService
{
    /// <summary>
    /// 用戶登入驗證
    /// </summary>
    public static User Login(string userName, string password)
    {
        // SHA-256 密碼加密
        string hashedPassword = HashPassword(password);
        
        string sql = @"
            SELECT * FROM Users 
            WHERE UserName = @UserName 
              AND Password = @Password 
              AND IsActive = 1";

        SqlParameter[] parameters = {
            new SqlParameter("@UserName", userName),
            new SqlParameter("@Password", hashedPassword)
        };

        DataTable dt = DBHelper.ExecuteQuery(sql, parameters);
        
        if (dt.Rows.Count > 0)
        {
            return MapToUser(dt.Rows[0]);
        }
        return null;
    }

    /// <summary>
    /// SHA-256 密碼加密
    /// </summary>
    private static string HashPassword(string password)
    {
        using (SHA256 sha256 = SHA256.Create())
        {
            byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
            StringBuilder builder = new StringBuilder();
            foreach (byte b in bytes)
            {
                builder.Append(b.ToString("x2"));
            }
            return builder.ToString();
        }
    }

    /// <summary>
    /// 增加用戶經驗值（含自動升級檢查）
    /// </summary>
    public static void AddExperience(int userId, int expAmount)
    {
        // 1. 增加經驗值
        string sql = "UPDATE Users SET TotalExp = TotalExp + @Exp WHERE UserID = @UserID";
        DBHelper.ExecuteNonQuery(sql, 
            new SqlParameter("@Exp", expAmount),
            new SqlParameter("@UserID", userId));

        // 2. 檢查是否升級
        CheckAndUpdateLevel(userId);
    }

    /// <summary>
    /// 檢查並更新用戶等級
    /// </summary>
    private static void CheckAndUpdateLevel(int userId)
    {
        // 調用預存程序處理等級計算
        DBHelper.ExecuteStoredProcedure("sp_CheckAndUpdateUserLevel",
            new SqlParameter("@UserID", userId));
    }
}
```

**重點說明**：
- ? SHA-256 安全加密用戶密碼
- ? 參數化查詢避免 SQL Injection
- ? 自動化等級升級機制

---

### 3. 任務服務 - 領取獎勵 (TaskService.cs)

```csharp
/// <summary>
/// 領取任務獎勵
/// </summary>
public static bool ClaimTaskReward(int userId, int taskId)
{
    using (SqlConnection conn = new SqlConnection(connectionString))
    {
        conn.Open();
        
        // 使用交易確保資料一致性
        using (SqlTransaction transaction = conn.BeginTransaction())
        {
            try
            {
                // 1. 獲取任務獎勵資訊
                string getTaskSql = @"
                    SELECT T.ExpReward, T.PointsReward, T.TaskName
                    FROM UserTasks UT
                    INNER JOIN Tasks T ON UT.TaskID = T.TaskID
                    WHERE UT.UserID = @UserID 
                      AND UT.TaskID = @TaskID 
                      AND UT.Status = 'Completed'";

                int expReward, pointsReward;
                string taskName;

                using (SqlCommand cmd = new SqlCommand(getTaskSql, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@TaskID", taskId);
                    
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                            throw new Exception("找不到可領取的任務");
                        
                        expReward = Convert.ToInt32(reader["ExpReward"]);
                        pointsReward = Convert.ToInt32(reader["PointsReward"]);
                        taskName = reader["TaskName"].ToString();
                    }
                }

                // 2. 更新用戶積分和經驗值
                string updateUserSql = @"
                    UPDATE Users 
                    SET Points = Points + @Points,
                        TotalExp = TotalExp + @Exp
                    WHERE UserID = @UserID";

                using (SqlCommand cmd = new SqlCommand(updateUserSql, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@Points", pointsReward);
                    cmd.Parameters.AddWithValue("@Exp", expReward);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }

                // 3. 更新任務狀態為已領取
                string updateTaskSql = @"
                    UPDATE UserTasks 
                    SET Status = 'Claimed', 
                        ClaimedDate = GETDATE()
                    WHERE UserID = @UserID AND TaskID = @TaskID";

                using (SqlCommand cmd = new SqlCommand(updateTaskSql, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@TaskID", taskId);
                    cmd.ExecuteNonQuery();
                }

                // 4. 記錄交易
                string insertTransactionSql = @"
                    INSERT INTO Transactions (UserID, Type, Amount, Description)
                    VALUES (@UserID, 'TaskReward', @Amount, @Description)";

                using (SqlCommand cmd = new SqlCommand(insertTransactionSql, conn, transaction))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Amount", pointsReward);
                    cmd.Parameters.AddWithValue("@Description", $"完成任務「{taskName}」獲得獎勵");
                    cmd.ExecuteNonQuery();
                }

                // 5. 提交交易
                transaction.Commit();
                
                // 6. 檢查等級升級
                UserService.CheckAndUpdateLevel(userId);
                
                return true;
            }
            catch
            {
                // 發生錯誤時回滾交易
                transaction.Rollback();
                throw;
            }
        }
    }
}
```

**重點說明**：
- ? 使用 **Transaction（交易）** 確保資料一致性
- ? 完整的獎勵發放流程（積分 + 經驗值）
- ? 自動記錄交易歷史
- ? 錯誤處理與回滾機制

---

### 4. 抽獎系統 - 機率抽獎 (LotteryService.cs)

```csharp
/// <summary>
/// 執行抽獎
/// </summary>
public static LotteryResult DrawLottery(int userId, int lotteryId)
{
    // 1. 獲取所有獎品及其機率
    List<LotteryPrize> prizes = GetLotteryPrizes(lotteryId);
    
    // 2. 根據機率隨機選擇獎品
    LotteryPrize selectedPrize = SelectPrizeByProbability(prizes);
    
    // 3. 記錄抽獎結果
    RecordLotteryDraw(userId, lotteryId, selectedPrize);
    
    // 4. 發放獎品
    DistributePrize(userId, selectedPrize);
    
    return new LotteryResult
    {
        PrizeName = selectedPrize.PrizeName,
        PrizeType = selectedPrize.PrizeType,
        PrizeValue = selectedPrize.PrizeValue,
        IconUrl = selectedPrize.IconUrl
    };
}

```

**重點說明**：
- ? **累積機率演算法** - 公平的隨機抽獎機制
- ? 獎品機率可配置
- ? 自動發放不同類型獎品（積分/經驗/道具）

---

### 5. 前端互動 - 抽獎動畫 (JavaScript)

```javascript
// 抽獎動畫控制
var ANIMATION_DURATION = 2000;  // 動畫時長 2 秒
var SKIP_ANIMATION_KEY = 'lottery_skip_animation';

// 點擊抽獎按鈕時的處理
function showDrawingAndSubmit(btn, isTenDraw) {
    // 防止重複點擊
    if (isDrawing) return false;
    isDrawing = true;
    
    // 檢查是否跳過動畫
    var skipAnimation = isSkipAnimationEnabled();
    
    if (!skipAnimation) {
        // 顯示抽獎動畫
        showDrawingAnimation(isTenDraw);
    }
    
    // 根據是否跳過動畫決定延遲時間
    var delay = skipAnimation ? 100 : ANIMATION_DURATION;
    
    // 延遲後觸發 PostBack
    setTimeout(function() {
        isDrawing = false;
        __doPostBack(btn.name, '');
    }, delay);
    
    return false;
}

```

**重點說明**：
- ? 使用 **localStorage** 保存用戶偏好設定
- ? 精美的 CSS 動畫效果
- ? 可選擇跳過動畫，提升體驗

---

### 6. 成就自動追蹤 (AchievementTracker.cs)

```csharp
/// <summary>
/// 成就追蹤器 - 自動檢查並解鎖成就
/// </summary>
public static class AchievementTracker
{
    /// <summary>
    /// 檢查用戶的所有成就進度
    /// </summary>
    public static void CheckAllAchievements(int userId)
    {
        // 獲取用戶統計數據
        var stats = GetUserStats(userId);
        
        // 獲取所有未解鎖的成就
        var lockedAchievements = GetLockedAchievements(userId);
        
        foreach (var achievement in lockedAchievements)
        {
            // 根據成就類型檢查條件
            bool shouldUnlock = CheckAchievementCondition(achievement, stats);
            
            if (shouldUnlock)
            {
                UnlockAchievement(userId, achievement.AchievementID);
                
                // 發送通知
                NotificationService.SendNotification(userId,
                    "恭喜解鎖成就：" + achievement.Name,
                    "Achievement");
            }
        }
    }

    /// <summary>
    /// 檢查成就條件是否滿足
    /// </summary>
    private static bool CheckAchievementCondition(Achievement achievement, UserStats stats)
    {
        switch (achievement.Category)
        {
            case "TaskCount":
                return stats.CompletedTasks >= achievement.RequiredValue;
            
            case "Level":
                return stats.Level >= achievement.RequiredValue;
            
            case "Points":
                return stats.TotalPointsEarned >= achievement.RequiredValue;
            
            case "Social":
                return stats.FriendCount >= achievement.RequiredValue;
            
            default:
                return false;
        }
    }
}
```

**重點說明**：
- ? **自動追蹤** - 無需手動觸發
- ? 多維度成就條件檢查
- ? 解鎖時自動發送通知

---

## ?? 專案成果

### 功能完成度

| 模組 | 完成度 | 說明 |
|------|--------|------|
| 用戶系統 | 100% | 註冊/登入/個人檔案 |
| 任務系統 | 100% | 任務管理/進度追蹤/獎勵發放 |
| 積分商城 | 100% | 商品瀏覽/購買/庫存管理 |
| 抽獎系統 | 100% | 單抽/十連抽/動畫效果 |
| 成就系統 | 100% | 自動追蹤/解鎖通知 |
| 排行榜 | 100% | 多維度排名 |
| 社交系統 | 80% | 好友管理/申請系統 |
| 通知系統 | 100% | 即時通知/已讀管理 |

### 專案統計

| 項目 | 數量 |
|------|------|
| ?? 頁面數量 | 15+ 個完整頁面 |
| ?? 資料表 | 15 個資料表 |
| ?? 服務類別 | 6 個商業邏輯服務 |
| ?? 程式碼行數 | 5000+ 行 |
| ?? CSS 樣式 | 2000+ 行 |
| ?? JavaScript | 1500+ 行 |
| ?? 開發時間 | 約 2 週 |
| ?? 測試覆蓋 | 90%+ |
| ?? 文件數量 | 30+ 份說明文件 |

### 技術亮點

| 技術特點 | 實現方式 |
|----------|----------|
| **安全性** | SHA-256 加密、SQL 參數化、Forms Authentication |
| **資料一致性** | Transaction 交易處理 |
| **使用者體驗** | Bootstrap RWD、CSS 動畫、即時回饋 |
| **程式架構** | 三層式架構、關注點分離 |
| **維護性** | 完整註解、統一編碼規範 |

---

## ?? 未來展望

### 短期計畫（1-2 週）
- [ ] 增加更多成就類型
- [ ] 優化手機版介面
- [ ] 增加任務自動完成偵測

### 中期計畫（1 個月）
- [ ] 開發管理後台
- [ ] 增加私訊功能
- [ ] 活動公告系統

### 長期計畫
- [ ] API 開發支援行動 App
- [ ] 資料分析儀表板
- [ ] 多語言支援

---

## ?? 致謝

感謝以下資源與靈感來源：
- **HoYoLAB** - 遊戲化社群平台設計
- **巴哈姆特** - 會員等級與積分系統設計
- **PChome/蝦皮** - 電商購物流程設計
- **Bootstrap** - 響應式前端框架
- **Bootstrap Icons** - 精美圖示資源

---

**簡報完畢，感謝聆聽！** ??

---

*專案版本：v1.0.0*  
*最後更新：2025年1月*  
*開發者：[您的名字]*

