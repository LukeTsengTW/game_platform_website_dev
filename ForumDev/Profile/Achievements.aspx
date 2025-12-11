<%@ Page Title="我的成就" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Achievements.aspx.cs" Inherits="ForumDev.Profile.Achievements" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col text-center">
                <h1 class="display-4 fw-bold">
                    <i class="bi bi-trophy-fill text-warning"></i> 我的成就
                </h1>
                <p class="lead text-muted">收集成就，展現您的實力！</p>
            </div>
        </div>

        <!-- 成就統計卡片 -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-trophy-fill fs-1 mb-2 text-warning"></i>
                        <h6 class="card-title text-muted">已解鎖成就</h6>
                        <h2 class="mb-0 text-warning">
                            <asp:Label ID="lblUnlockedCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-lock-fill fs-1 mb-2 text-info"></i>
                        <h6 class="card-title text-muted">未解鎖成就</h6>
                        <h2 class="mb-0 text-info">
                            <asp:Label ID="lblLockedCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-percent fs-1 mb-2 text-success"></i>
                        <h6 class="card-title text-muted">完成度</h6>
                        <h2 class="mb-0 text-success">
                            <asp:Label ID="lblCompletionRate" runat="server" Text="0"></asp:Label>%
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-coin fs-1 mb-2 text-primary"></i>
                        <h6 class="card-title text-muted">成就積分</h6>
                        <h2 class="mb-0 text-primary">
                            <asp:Label ID="lblTotalPoints" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 成就進度條 -->
        <div class="card mb-4 shadow-sm">
            <div class="card-body">
                <div class="d-flex justify-content-between mb-2">
                    <span class="fw-bold">總體進度</span>
                    <span class="text-muted">
                        <asp:Label ID="lblProgressText" runat="server"></asp:Label>
                    </span>
                </div>
                <div class="progress" style="height: 30px;">
                    <div class="progress-bar progress-bar-striped progress-bar-animated bg-warning" 
                         role="progressbar" 
                         style="width: 0%" 
                         id="achievementProgress" 
                         runat="server">
                    </div>
                </div>
            </div>
        </div>

        <!-- 成就分類標籤 -->
        <ul class="nav nav-pills nav-fill mb-4" role="tablist">
            <li class="nav-item">
                <asp:LinkButton ID="btnAll" runat="server" CssClass="nav-link active" 
                                OnClick="btnAll_Click">
                    <i class="bi bi-grid-fill"></i> 全部
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnTask" runat="server" CssClass="nav-link" 
                                OnClick="btnTask_Click">
                    <i class="bi bi-clipboard-check"></i> 任務成就
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnLevel" runat="server" CssClass="nav-link" 
                                OnClick="btnLevel_Click">
                    <i class="bi bi-star-fill"></i> 等級成就
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnSocial" runat="server" CssClass="nav-link" 
                                OnClick="btnSocial_Click">
                    <i class="bi bi-people-fill"></i> 社交成就
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnSpecial" runat="server" CssClass="nav-link" 
                                OnClick="btnSpecial_Click">
                    <i class="bi bi-gem"></i> 特殊成就
                </asp:LinkButton>
            </li>
        </ul>

        <!-- 成就列表 -->
        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptAchievements" runat="server">
                <ItemTemplate>
                    <div class="col">
                        <div class='card achievement-card h-100 shadow-sm <%# IsUnlocked(Eval("IsUnlocked")) ? "unlocked" : "locked" %>'>
                            <!-- 稀有度標記 -->
                            <div class="rarity-badge <%# GetRarityClass(Eval("Achievement.Rarity").ToString()) %>">
                                <%# GetRarityText(Eval("Achievement.Rarity").ToString()) %>
                            </div>

                            <div class="card-body text-center">
                                <!-- 成就圖標 -->
                                <div class="achievement-icon mb-3 <%# !IsUnlocked(Eval("IsUnlocked")) ? "grayscale" : "" %>">
                                    <span style="font-size: 5rem;">
                                        <%# Eval("Achievement.BadgeIcon") ?? "??" %>
                                    </span>
                                </div>

                                <!-- 成就名稱 -->
                                <h5 class="card-title">
                                    <%# Eval("Achievement.Name") %>
                                </h5>

                                <!-- 成就描述 -->
                                <p class="card-text text-muted">
                                    <%# Eval("Achievement.Description") %>
                                </p>

                                <!-- 成就積分 -->
                                <div class="achievement-points mb-3">
                                    <i class="bi bi-coin text-warning"></i>
                                    +<%# Eval("Achievement.Points") %> 積分
                                </div>

                                <!-- 解鎖狀態 -->
                                <div class="unlock-status">
                                    <%# GetUnlockStatus(Eval("IsUnlocked"), Eval("UnlockedDate")) %>
                                </div>
                            </div>

                            <!-- 鎖定遮罩 -->
                            <div class='lock-overlay <%# !IsUnlocked(Eval("IsUnlocked")) ? "" : "d-none" %>'>
                                <i class="bi bi-lock-fill"></i>
                                <p class="mt-2 mb-0">尚未解鎖</p>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlNoAchievements" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted fs-5">目前沒有可用的成就</p>
        </asp:Panel>
    </div>

    <style>
        .bg-gradient-warning {
            background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
        }

        .bg-gradient-info {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
        }

        .bg-gradient-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        /* ========== 統計卡片暗色主題樣式 ========== */
        .stats-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .stats-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(108, 92, 231, 0.3);
            border-color: rgba(108, 92, 231, 0.5);
        }

        .stats-card .card-title {
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .stats-card h2 {
            font-size: 2.5rem;
            font-weight: bold;
            text-shadow: 0 0 10px currentColor;
        }

        .stats-card .fs-1 {
            text-shadow: 0 0 15px currentColor;
        }

        /* ========== 分頁籤暗色主題樣式 ========== */
        .nav-pills .nav-link {
            color: #a0a0b8;
            font-weight: 500;
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
            border: 1px solid rgba(108, 92, 231, 0.3);
            margin: 0 3px;
            transition: all 0.3s ease;
        }

        .nav-pills .nav-link:hover {
            color: #e8e8f0;
            border-color: rgba(108, 92, 231, 0.5);
            box-shadow: 0 0 15px rgba(108, 92, 231, 0.3);
        }

        .nav-pills .nav-link.active {
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.4) 0%, rgba(74, 63, 159, 0.4) 100%);
            border-color: rgba(108, 92, 231, 0.6);
            color: #00cec9;
            box-shadow: 0 0 20px rgba(108, 92, 231, 0.3), inset 0 0 15px rgba(108, 92, 231, 0.2);
            text-shadow: 0 0 10px rgba(0, 206, 201, 0.5);
        }

        .achievement-card {
            border: none;
            position: relative;
            overflow: hidden;
            transition: all 0.3s ease;
        }

        .achievement-card.unlocked {
            border: 2px solid #ffc107;
            background: linear-gradient(135deg, rgba(255, 193, 7, 0.05) 0%, rgba(255, 152, 0, 0.05) 100%);
        }

        .achievement-card.locked {
            opacity: 0.7;
        }

        .achievement-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
        }

        .achievement-icon.grayscale {
            filter: grayscale(100%);
            opacity: 0.5;
        }

        .rarity-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: bold;
            z-index: 10;
        }

        .rarity-common {
            background: #6c757d;
            color: white;
        }

        .rarity-rare {
            background: #0d6efd;
            color: white;
        }

        .rarity-epic {
            background: #6f42c1;
            color: white;
        }

        .rarity-legendary {
            background: linear-gradient(135deg, #ff6b6b, #feca57);
            color: white;
            animation: glow 2s ease-in-out infinite;
        }

        @keyframes glow {
            0%, 100% { box-shadow: 0 0 10px rgba(255, 107, 107, 0.5); }
            50% { box-shadow: 0 0 20px rgba(254, 202, 87, 0.8); }
        }

        .lock-overlay {
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.6);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
        }

        .unlock-status {
            padding: 8px;
            border-radius: 20px;
            font-weight: bold;
        }
    </style>
</asp:Content>
