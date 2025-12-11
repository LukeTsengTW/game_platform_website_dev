<%@ Page Title="首頁" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ForumDev._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <main>
        <!-- Hero section -->
        <section class="hero-section text-center py-5 text-white">
            <div class="container">
                <h1 class="display-4 fw-bold mb-3">暗魂的神諭：遊戲活動平台</h1>
                <p class="lead mb-4">完成任務 • 累積經驗 • 解鎖成就 • 獲得獎勵</p>
                <div class="d-flex justify-content-center gap-3 flex-wrap">
                    <asp:HyperLink ID="lnkStartNow" runat="server" NavigateUrl="~/Account/Register.aspx" 
                        CssClass="btn btn-light btn-lg px-5" Visible="true">立即開始</asp:HyperLink>
                    <asp:HyperLink ID="lnkMyTasks" runat="server" NavigateUrl="~/Tasks/MyTasks.aspx" 
                        CssClass="btn btn-outline-light btn-lg px-5" Visible="false">我的任務</asp:HyperLink>
                    <asp:HyperLink ID="lnkPlatformTour" runat="server" NavigateUrl="~/PlatformTour.aspx" 
                        CssClass="btn btn-warning btn-lg px-5 tour-cta" Visible="false">
                        <i class="bi bi-compass-fill"></i> 開始平台導覽
                    </asp:HyperLink>
                </div>
            </div>
        </section>

        <!-- 用戶資訊界面（登入後才看得到） -->
        <asp:Panel ID="pnlUserInfo" runat="server" Visible="false" CssClass="user-info-panel bg-light py-4">
            <div class="container">
                <div class="row">
                    <div class="col-md-3 text-center">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h3 class="text-primary mb-0">
                                    <asp:Label ID="lblLevel" runat="server" Text="1"></asp:Label>
                                </h3>
                                <small class="text-muted">等級</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h3 class="text-success mb-0">
                                    <asp:Label ID="lblPoints" runat="server" Text="0"></asp:Label>
                                </h3>
                                <small class="text-muted">積分</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h3 class="text-warning mb-0">
                                    <asp:Label ID="lblExp" runat="server" Text="0"></asp:Label>
                                </h3>
                                <small class="text-muted">經驗值</small>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="card shadow-sm">
                            <div class="card-body">
                                <h3 class="text-info mb-0">
                                    <asp:Label ID="lblTasksCompleted" runat="server" Text="0"></asp:Label>
                                </h3>
                                <small class="text-muted">完成任務</small>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- 新手導覽（給那些比較低等的玩家） -->
                <asp:Panel ID="pnlTourTip" runat="server" Visible="false" CssClass="mt-4">
                    <div class="alert alert-warning alert-dismissible fade show tour-tip-banner" role="alert">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-compass-fill fs-3 me-3"></i>
                            <div class="flex-grow-1">
                                <h5 class="alert-heading mb-1">
                                    <i class="bi bi-lightbulb-fill"></i> 歡迎新手
                                </h5>
                                <p class="mb-2">還不熟悉平台功能嗎？讓我帶你快速了解所有功能！完成導覽還能獲得 <strong>100 EXP + 200 積分</strong>！</p>
                                <asp:HyperLink ID="lnkTourBanner" runat="server" NavigateUrl="~/PlatformTour.aspx" 
                                    CssClass="btn btn-warning btn-sm">
                                    <i class="bi bi-arrow-right-circle"></i> 開始平台導覽
                                </asp:HyperLink>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </asp:Panel>

        <section class="features-section py-5">
            <div class="container">
                <h2 class="text-center mb-5">🌟 這個平台有什麼特色？</h2>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">📋</span>
                                </div>
                                <h4 class="card-title">多樣化任務</h4>
                                <p class="card-text">每日簽到、社交任務、購物任務等豐富任務類型，讓你在遊戲中成長。</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">⬆️</span>
                                </div>
                                <h4 class="card-title">等級系統</h4>
                                <p class="card-text">完成任務獲得經驗值，成為神諭世界最強的王者！</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">🎁</span>
                                </div>
                                <h4 class="card-title">積分商城</h4>
                                <p class="card-text">累積積分兌換實體商品、優惠券、加速卡等豐富獎勵，好禮不斷！</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">🏆</span>
                                </div>
                                <h4 class="card-title">成就系統</h4>
                                <p class="card-text">解鎖各種稀有成就，還能拿到積分跟經驗值，還不快農起來？</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">📊</span>
                                </div>
                                <h4 class="card-title">排行榜</h4>
                                <p class="card-text">與全球玩家競爭，查看即時排名，挑戰榜首寶座，成為最強王者。</p>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm hover-lift">
                            <div class="card-body text-center">
                                <div class="feature-icon mb-3">
                                    <span style="font-size: 3rem;">🎰</span>
                                </div>
                                <h4 class="card-title">抽獎活動</h4>
                                <p class="card-text">使用積分或抽獎券參加豪華抽獎，有機會獲得遊戲道具和神秘禮物！</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="tasks-preview py-5 bg-light">
            <div class="container">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h2>🔥 熱門任務</h2>
                    <asp:HyperLink ID="lnkViewAllTasks" runat="server" NavigateUrl="~/Tasks/TaskList.aspx" 
                        CssClass="btn btn-primary">查看全部</asp:HyperLink>
                </div>
                
                <asp:Repeater ID="rptPopularTasks" runat="server">
                    <HeaderTemplate>
                        <div class="row g-4">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="col-md-6 col-lg-4">
                            <div class="card task-card shadow-sm h-100">
                                <div class="card-body">
                                    <div class="d-flex align-items-start mb-3">
                                        <div class="task-icon me-3">
                                            <span style="font-size: 2rem;">✨</span>
                                        </div>
                                        <div class="flex-grow-1">
                                            <h5 class="card-title mb-1"><%# Eval("TaskName") %></h5>
                                            <small class="text-muted"><%# Eval("Category") %></small>
                                        </div>
                                    </div>
                                    <p class="card-text"><%# Eval("Description") %></p>
                                    <div class="task-rewards d-flex gap-3 mt-3">
                                        <span class="badge bg-warning text-dark">
                                            <i class="bi bi-star-fill"></i> <%# Eval("ExpReward") %> EXP
                                        </span>
                                        <span class="badge bg-success">
                                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" /> <%# Eval("PointsReward") %> 積分
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </section>

        <section class="getting-started py-5">
            <div class="container">
                <h2 class="text-center mb-5">🚀 快速開始</h2>
                <div class="row g-4">
                    <div class="col-md-3 text-center">
                        <div class="step-number bg-primary text-white rounded-circle mx-auto mb-3 
                                    d-flex align-items-center justify-content-center" 
                             style="width: 60px; height: 60px;">
                            <h3 class="mb-0">1</h3>
                        </div>
                        <h5>註冊帳號</h5>
                        <p class="text-muted">馬上下載並註冊《暗魂的神諭》，立即獲得100積分新手禮包</p>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="step-number bg-primary text-white rounded-circle mx-auto mb-3 
                                    d-flex align-items-center justify-content-center" 
                             style="width: 60px; height: 60px;">
                            <h3 class="mb-0">2</h3>
                        </div>
                        <h5>選擇任務</h5>
                        <p class="text-muted">瀏覽任務列表，選擇感興趣的任務開始挑戰</p>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="step-number bg-primary text-white rounded-circle mx-auto mb-3 
                                    d-flex align-items-center justify-content-center" 
                             style="width: 60px; height: 60px;">
                            <h3 class="mb-0">3</h3>
                        </div>
                        <h5>完成任務</h5>
                        <p class="text-muted">按照任務要求完成挑戰，獲得經驗值和積分</p>
                    </div>
                    <div class="col-md-3 text-center">
                        <div class="step-number bg-primary text-white rounded-circle mx-auto mb-3 
                                    d-flex align-items-center justify-content-center" 
                             style="width: 60px; height: 60px;">
                            <h3 class="mb-0">4</h3>
                        </div>
                        <h5>兌換獎勵</h5>
                        <p class="text-muted">使用積分兌換喜歡的商品和優惠券</p>
                    </div>
                </div>
            </div>
        </section>

        <section class="stats-section py-5 bg-dark text-white">
            <div class="container">
                <div class="row text-center">
                    <div class="col-md-3">
                        <h2 class="display-4 fw-bold mb-2">
                            <asp:Label ID="lblTotalUsers" runat="server" Text="0"></asp:Label>+
                        </h2>
                        <p class="lead">活躍用戶</p>
                    </div>
                    <div class="col-md-3">
                        <h2 class="display-4 fw-bold mb-2">
                            <asp:Label ID="lblTotalTasks" runat="server" Text="0"></asp:Label>+
                        </h2>
                        <p class="lead">任務總數</p>
                    </div>
                    <div class="col-md-3">
                        <h2 class="display-4 fw-bold mb-2">
                            <asp:Label ID="lblCompletedTasks" runat="server" Text="0"></asp:Label>+
                        </h2>
                        <p class="lead">完成次數</p>
                    </div>
                    <div class="col-md-3">
                        <h2 class="display-4 fw-bold mb-2">
                            <asp:Label ID="lblTotalRewards" runat="server" Text="0"></asp:Label>+
                        </h2>
                        <p class="lead">獎勵發放</p>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <style>
        .coin-icon {
            width: 24px;
            height: 24px;
            vertical-align: middle;
            margin-right: 5px;
        }

        .coin-icon-small {
            width: 18px;
            height: 18px;
            vertical-align: middle;
            margin-right: 3px;
        }

        .coin-icon-inline {
            width: 20px;
            height: 20px;
            vertical-align: middle;
            margin-right: 3px;
        }

        .coin-icon-large {
            width: 32px;
            height: 32px;
            vertical-align: middle;
            margin-right: 8px;
        }
        
        .hero-section {
            background: transparent;
            min-height: 400px;
            display: flex;
            align-items: center;
            position: relative;
            overflow: hidden;
            border-bottom: 1px solid rgba(108, 92, 231, 0.2);
        }

        /* 微弱神秘光暈效果 */
        .hero-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: 
                radial-gradient(circle at 50% 50%, rgba(108, 92, 231, 0.08) 0%, transparent 50%);
            pointer-events: none;
        }

        .hero-section .container {
            position: relative;
            z-index: 1;
        }

        .hero-section h1 {
            color: #00cec9;
            text-shadow: 
                0 0 10px rgba(0, 206, 201, 0.5),
                0 0 20px rgba(0, 206, 201, 0.3),
                0 0 40px rgba(0, 206, 201, 0.2);
            animation: neon-flicker 3s ease-in-out infinite;
        }

        @keyframes neon-flicker {
            0%, 100% {
                text-shadow: 
                    0 0 10px rgba(0, 206, 201, 0.5),
                    0 0 20px rgba(0, 206, 201, 0.3),
                    0 0 40px rgba(0, 206, 201, 0.2);
            }
            50% {
                text-shadow: 
                    0 0 5px rgba(0, 206, 201, 0.4),
                    0 0 15px rgba(0, 206, 201, 0.2),
                    0 0 30px rgba(0, 206, 201, 0.15);
            }
            92% {
                text-shadow: 
                    0 0 10px rgba(0, 206, 201, 0.5),
                    0 0 20px rgba(0, 206, 201, 0.3),
                    0 0 40px rgba(0, 206, 201, 0.2);
            }
            93% {
                text-shadow: none;
            }
            94% {
                text-shadow: 
                    0 0 10px rgba(0, 206, 201, 0.5),
                    0 0 20px rgba(0, 206, 201, 0.3),
                    0 0 40px rgba(0, 206, 201, 0.2);
            }
        }

        .hero-section .lead {
            color: #a0a0b8;
            text-shadow: 0 0 10px rgba(108, 92, 231, 0.3);
            letter-spacing: 2px;
        }

        .hero-section .btn-light {
            background: linear-gradient(135deg, #6c5ce7, #4a3f9f);
            border: none;
            color: #fff;
            font-weight: bold;
            box-shadow: 
                0 0 20px rgba(108, 92, 231, 0.5),
                inset 0 0 10px rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .hero-section .btn-light:hover {
            background: linear-gradient(135deg, #7c6cf7, #6c5ce7);
            box-shadow: 
                0 0 30px rgba(108, 92, 231, 0.7),
                0 0 60px rgba(108, 92, 231, 0.3),
                inset 0 0 15px rgba(255, 255, 255, 0.2);
            transform: translateY(-3px) scale(1.02);
            color: #fff;
        }

        .hero-section .btn-outline-light {
            border: 2px solid #6c5ce7;
            color: #6c5ce7;
            background: transparent;
            box-shadow: 0 0 15px rgba(108, 92, 231, 0.3);
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .hero-section .btn-outline-light:hover {
            background: rgba(108, 92, 231, 0.15);
            border-color: #00cec9;
            color: #00cec9;
            box-shadow: 
                0 0 25px rgba(108, 92, 231, 0.5),
                inset 0 0 20px rgba(108, 92, 231, 0.1);
            transform: translateY(-3px);
        }

        .hero-section .btn-warning {
            background: linear-gradient(135deg, #f39c12, #e67e22);
            border: none;
            color: #1a1a2e;
            font-weight: bold;
            box-shadow: 0 0 20px rgba(243, 156, 18, 0.5);
        }

        .hero-section .btn-warning:hover {
            background: linear-gradient(135deg, #f1c40f, #f39c12);
            box-shadow: 
                0 0 30px rgba(243, 156, 18, 0.7),
                0 0 60px rgba(243, 156, 18, 0.3);
            transform: translateY(-3px) scale(1.02);
        }

        .tour-cta {
            animation: neon-bounce 2s ease-in-out infinite;
        }

        .tour-cta:hover {
            animation: none;
        }

        @keyframes neon-bounce {
            0%, 100% {
                transform: translateY(0);
                box-shadow: 0 0 20px rgba(243, 156, 18, 0.5);
            }
            50% {
                transform: translateY(-10px);
                box-shadow: 0 0 40px rgba(243, 156, 18, 0.8);
            }
        }

        .tour-tip-banner {
            border-left: 5px solid #f39c12;
            background: linear-gradient(to right, rgba(243, 156, 18, 0.1), transparent);
            animation: slideDown 0.5s ease-out;
        }

        @keyframes slideDown {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .tour-tip-banner .btn-warning {
            animation: pulse-button 2s ease-in-out infinite;
        }

        @keyframes pulse-button {
            0%, 100% {
                box-shadow: 0 0 0 0 rgba(243, 156, 18, 0.7);
            }
            50% {
                box-shadow: 0 0 0 10px rgba(243, 156, 18, 0);
            }
        }

        .hover-lift {
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        .hover-lift:hover {
            transform: translateY(-10px);
            box-shadow: 0 10px 30px rgba(108, 92, 231, 0.2) !important;
        }

        .task-card {
            transition: all 0.3s ease;
            border-left: 4px solid #6c5ce7;
        }

        .task-card:hover {
            border-left-color: #00cec9;
            box-shadow: 0 0 20px rgba(108, 92, 231, 0.2);
        }

        .user-info-panel .card {
            border: none;
            transition: all 0.3s ease;
        }

        .user-info-panel .card:hover {
            transform: scale(1.05);
            box-shadow: 0 0 20px rgba(108, 92, 231, 0.2);
        }

        .stats-section {
            background: transparent !important;
            border-top: 1px solid rgba(108, 92, 231, 0.2);
            border-bottom: 1px solid rgba(108, 92, 231, 0.2);
        }

        .stats-section h2 {
            color: #00cec9;
            text-shadow: 0 0 20px rgba(0, 206, 201, 0.5);
        }

        .stats-section .lead {
            color: #a0a0b8;
        }

        /* 快速開始步驟圓圈 */
        .step-number {
            background: linear-gradient(135deg, #6c5ce7, #4a3f9f) !important;
            box-shadow: 0 0 20px rgba(108, 92, 231, 0.4);
        }

        /* 功能區塊標題 */
        .features-section h2 {
            color: #00cec9;
            text-shadow: 0 0 10px rgba(0, 206, 201, 0.3);
        }

        /* 快速開始區塊 */
        .getting-started h2 {
            color: #00cec9;
            text-shadow: 0 0 10px rgba(0, 206, 201, 0.3);
        }

        .getting-started h5 {
            color: #e8e8f0;
        }

        /* 熱門任務區塊 */
        .tasks-preview h2 {
            color: #00cec9;
            text-shadow: 0 0 10px rgba(0, 206, 201, 0.3);
        }
    </style>

</asp:Content>
