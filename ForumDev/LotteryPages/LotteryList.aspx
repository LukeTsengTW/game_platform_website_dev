<%@ Page Title="抽獎中心" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LotteryList.aspx.cs" Inherits="ForumDev.LotteryPages.LotteryList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-gift-fill text-primary"></i> 抽獎中心
                </h1>
                <p class="lead text-muted">試試手氣，贏取豐富獎勵！</p>
            </div>
            <div class="col-md-4 text-end">
                <div class="card bg-gradient-primary text-white shadow">
                    <div class="card-body">
                        <h6 class="mb-1">我的積分</h6>
                        <h2 class="mb-0">
                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" />
                            <asp:Label ID="lblUserPoints" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 統計卡片 -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">參與次數</h6>
                        <h2 class="mb-0 text-success">
                            <asp:Label ID="lblTotalDraws" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">待領取獎品</h6>
                        <h2 class="mb-0 text-warning">
                            <asp:Label ID="lblUnclaimedPrizes" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">累計獲得</h6>
                        <h2 class="mb-0 text-info">
                            <i class="bi bi-trophy-fill"></i>
                            <asp:Label ID="lblTotalValue" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 快速導航 -->
        <div class="row mb-4">
            <div class="col">
                <asp:HyperLink ID="lnkMyRecords" runat="server" NavigateUrl="~/LotteryPages/MyRecords.aspx"
                               CssClass="btn btn-outline-primary me-2">
                    <i class="bi bi-clock-history"></i> 我的抽獎記錄
                </asp:HyperLink>
            </div>
            <div class="col-auto">
                <div class="form-check form-switch">
                    <input class="form-check-input" type="checkbox" id="chkSkipAnimation" onchange="saveAnimationPreference()">
                    <label class="form-check-label text-muted" for="chkSkipAnimation">
                        <i class="bi bi-lightning-fill text-warning"></i> 跳過抽獎動畫
                    </label>
                </div>
            </div>
        </div>

        <!-- 消息提示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 隱藏欄位：標記動畫已播放 -->
        <asp:HiddenField ID="hfAnimationPlayed" runat="server" Value="0" />

        <!-- 抽獎活動列表 -->
        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptLotteries" runat="server" OnItemCommand="rptLotteries_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card lottery-card h-100 shadow-sm">
                            <!-- 卡片頭部 -->
                            <div class="card-header bg-gradient-primary text-white border-0">
                                <div class="text-center py-3">
                                    <i class="fa-solid <%# Eval("IconUrl") %> fa-3x mb-2"></i>
                                    <h4 class="mb-0"><%# Eval("LotteryName") %></h4>
                                </div>
                            </div>

                            <!-- 卡片主體 -->
                            <div class="card-body">
                                <!-- 說明 -->
                                <p class="card-text text-muted mb-3"><%# Eval("Description") %></p>

                                <!-- 消耗積分 -->
                                <div class="cost-section mb-3">
                                    <div class="d-flex justify-content-between align-items-center">
                                        <span class="text-muted">單抽消耗：</span>
                                        <h5 class="mb-0 text-primary">
                                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon-inline" />
                                            <%# Eval("CostPoints") %> 積分
                                        </h5>
                                    </div>
                                    <%# GetTicketOption(Eval("AllowedItemID"), Eval("LotteryID")) %>
                                </div>

                                <%# GetLimitInfo(Eval("MaxDrawsPerUser"), Eval("LotteryID")) %>

                                <!-- 活動時間 -->
                                <small class="text-muted d-block mb-3">
                                    <i class="bi bi-calendar-fill"></i>
                                    <%# GetDateRangeText(Eval("StartDate"), Eval("EndDate")) %>
                                </small>

                                <!-- 操作按鈕 -->
                                <div class="d-grid gap-2">
                                    <!-- 免費單抽按鈕 -->
                                    <asp:LinkButton ID="btnDrawFree" runat="server" 
                                                    CommandName="Draw" 
                                                    CommandArgument='<%# Eval("LotteryID") %>'
                                                    CssClass="btn btn-lottery btn-lottery-free btn-lg"
                                                    OnClientClick="return showDrawingAndSubmit(this, false);"
                                                    Visible='<%# User.Identity.IsAuthenticated && IsFreeLottery(Eval("CostPoints"), Eval("AllowedItemID")) %>'>
                                        <i class="bi bi-gift-fill"></i> 
                                        免費單抽 <span class="badge bg-success ms-1">每日一次</span>
                                    </asp:LinkButton>

                                    <!-- 積分單抽按鈕 -->
                                    <asp:LinkButton ID="btnDraw" runat="server" 
                                                    CommandName="Draw" 
                                                    CommandArgument='<%# Eval("LotteryID") %>'
                                                    CssClass="btn btn-lottery btn-lottery-primary btn-lg"
                                                    OnClientClick="return showDrawingAndSubmit(this, false);"
                                                    Visible='<%# User.Identity.IsAuthenticated && Convert.ToInt32(Eval("CostPoints")) > 0 %>'>
                                        <i class="bi bi-dice-5-fill"></i> 
                                        單抽 <span class="badge bg-dark bg-opacity-50 ms-1"><%# Eval("CostPoints") %> 積分</span>
                                    </asp:LinkButton>

                                    <!-- 積分十連抽按鈅 -->
                                    <asp:LinkButton ID="btnDraw10" runat="server" 
                                                    CommandName="Draw10" 
                                                    CommandArgument='<%# Eval("LotteryID") %>'
                                                    CssClass="btn btn-lottery btn-lottery-warning btn-lg"
                                                    OnClientClick="return showDrawingAndSubmit(this, true);"
                                                    Visible='<%# User.Identity.IsAuthenticated && Convert.ToInt32(Eval("CostPoints")) > 0 %>'>
                                        <i class="bi bi-stars"></i> 
                                        十連抽 <span class="badge bg-dark bg-opacity-50 ms-1"><%# Convert.ToInt32(Eval("CostPoints")) * 10 %> 積分</span>
                                    </asp:LinkButton>

                                    <!-- 抽獎券單抽按鈕 -->
                                    <asp:LinkButton ID="btnDrawWithTicket" runat="server" 
                                                    CommandName="DrawWithTicket" 
                                                    CommandArgument='<%# Eval("LotteryID") %>'
                                                    CssClass="btn btn-lottery btn-lottery-success btn-lg"
                                                    OnClientClick="return showDrawingAndSubmit(this, false);"
                                                    Visible='<%# ShowTicketButton(Eval("AllowedItemID")) %>'>
                                        <img src="/Images/Items/ticket_rmbg.png" alt="抽獎券" class="btn-icon" /> 
                                        使用抽獎券 <span class="badge bg-dark bg-opacity-50 ms-1"><%# GetUserTicketCount(Eval("AllowedItemID")) %> 張</span>
                                    </asp:LinkButton>

                                    <!-- 抽獎券十連抽按鈕 -->
                                    <asp:LinkButton ID="btnDrawWithTicket10" runat="server" 
                                                    CommandName="DrawWithTicket10" 
                                                    CommandArgument='<%# Eval("LotteryID") %>'
                                                    CssClass="btn btn-lottery btn-lottery-info btn-lg"
                                                    OnClientClick="return showDrawingAndSubmit(this, true);"
                                                    Visible='<%# ShowTicket10Button(Eval("AllowedItemID")) %>'>
                                        <img src="/Images/Items/ticket_rmbg.png" alt="抽獎券" class="btn-icon" /> 
                                        抽獎券十連抽 <span class="badge bg-dark bg-opacity-50 ms-1">需 10 張</span>
                                    </asp:LinkButton>

                                    <!-- 購買抽獎券按鈕 -->
                                    <asp:HyperLink ID="lnkBuyTicket" runat="server" 
                                                   NavigateUrl="~/Shop/ItemShop.aspx"
                                                   CssClass="btn btn-outline-secondary"
                                                   Visible='<%# ShowBuyTicketButton(Eval("AllowedItemID")) %>'>
                                        <i class="bi bi-cart3"></i> 購買抽獎券
                                    </asp:HyperLink>

                                    <!-- 登入按鈕 -->
                                    <asp:HyperLink ID="lnkLogin" runat="server" 
                                                   NavigateUrl="~/Account/Login.aspx"
                                                   CssClass="btn btn-outline-primary"
                                                   Visible='<%# !User.Identity.IsAuthenticated %>'>
                                        <i class="bi bi-box-arrow-in-right"></i> 登入後抽獎
                                    </asp:HyperLink>
                                </div>
                            </div>

                            <!-- 卡片底部 - 獎品預覽 -->
                            <div class="card-footer bg-light">
                                <small class="text-muted">
                                    <i class="bi bi-gift"></i> 查看獎品池
                                    <a href="#" onclick="showPrizes(<%# Eval("LotteryID") %>); return false;" class="text-primary">
                                        點擊查看
                                    </a>
                                </small>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlNoLotteries" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted fs-5">目前沒有進行中的抽獎活動</p>
            <p class="text-muted">請稍後再來看看！</p>
        </asp:Panel>
    </div>

    <!-- 獎品池 Modal -->
    <div class="modal fade" id="prizePoolModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-gradient-primary text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-gift-fill"></i> <span id="modalLotteryName">獎品池</span>
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="prizePoolContent">
                        <div class="text-center py-5">
                            <div class="spinner-border text-primary" role="status">
                                <span class="visually-hidden">載入中...</span>
                            </div>
                            <p class="mt-3 text-muted">正在載入獎品資訊...</p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">關閉</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 抽獎結果 Modal -->
    <div class="modal fade" id="resultModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header border-0 bg-gradient-success text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-trophy-fill"></i> 抽獎結果
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body text-center py-5">
                    <div id="prizeResult">
                        <!-- 動態填充抽獎結果 -->
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">關閉</button>
                    <a href="/LotteryPages/MyRecords.aspx" class="btn btn-primary">查看記錄</a>
                </div>
            </div>
        </div>
    </div>

    <!-- 抽獎動畫 Modal -->
    <div class="modal fade" id="drawingModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static" data-bs-keyboard="false">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content bg-dark text-white border-0">
                <div class="modal-body text-center py-5">
                    <div class="drawing-animation">
                        <div class="lottery-box">
                            <i class="bi bi-gift-fill gift-icon"></i>
                        </div>
                        <div class="sparkles">
                            <span></span><span></span><span></span>
                            <span></span><span></span><span></span>
                        </div>
                    </div>
                    <h3 class="mt-4 drawing-text">抽獎中...</h3>
                    <p class="text-muted" id="drawingProgress">正在揭曉結果</p>
                </div>
            </div>
        </div>
    </div>

    <!-- 十連抽結果 Modal -->
    <div class="modal fade" id="result10Modal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header border-0 bg-gradient-warning text-dark">
                    <h5 class="modal-title">
                        <i class="bi bi-stars"></i> 十連抽結果
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="prize10Result" class="row row-cols-2 row-cols-md-5 g-3">
                        <!-- 動態填充十連抽結果 -->
                    </div>
                    <div id="prize10Summary" class="alert alert-info mt-3 mb-0">
                        <!-- 統計摘要 -->
                    </div>
                </div>
                <div class="modal-footer border-0">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">關閉</button>
                    <a href="/LotteryPages/MyRecords.aspx" class="btn btn-primary">查看記錄</a>
                </div>
            </div>
        </div>
    </div>

    <style>
        /* 金幣圖標樣式 */
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

        /* 按鈕內圖標樣式 */
        .btn-icon {
            width: 22px;
            height: 22px;
            vertical-align: middle;
            margin-right: 5px;
        }

        /* 抽獎券圖標樣式 */
        .ticket-icon-inline {
            width: 22px;
            height: 22px;
            vertical-align: middle;
            margin-right: 5px;
        }

        /* ========== 抽獎按鈕暗色主題樣式 ========== */
        .btn-lottery {
            border: 1px solid rgba(255, 255, 255, 0.1);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
            color: #e8e8f0;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .btn-lottery::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transition: left 0.5s ease;
        }

        .btn-lottery:hover::before {
            left: 100%;
        }

        .btn-lottery:hover {
            transform: translateY(-2px);
            color: #fff;
        }

        /* 免費單抽按鈕 - 粉紅色主題 */
        .btn-lottery-free {
            border-color: rgba(232, 67, 147, 0.5);
            box-shadow: 0 0 15px rgba(232, 67, 147, 0.2);
        }

        .btn-lottery-free:hover {
            border-color: rgba(232, 67, 147, 0.8);
            box-shadow: 0 0 25px rgba(232, 67, 147, 0.4);
            background: linear-gradient(135deg, rgba(232, 67, 147, 0.3) 0%, rgba(200, 55, 130, 0.3) 100%);
        }

        .btn-lottery-free i {
            color: #e84393;
            text-shadow: 0 0 10px rgba(232, 67, 147, 0.5);
            animation: pulse-gift 1.5s ease-in-out infinite;
        }

        @keyframes pulse-gift {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.2); }
        }

        /* 單抽按鈕 - 紫色主題 */
        .btn-lottery-primary {
            border-color: rgba(108, 92, 231, 0.5);
            box-shadow: 0 0 15px rgba(108, 92, 231, 0.2);
        }

        .btn-lottery-primary:hover {
            border-color: rgba(108, 92, 231, 0.8);
            box-shadow: 0 0 25px rgba(108, 92, 231, 0.4);
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.3) 0%, rgba(74, 63, 159, 0.3) 100%);
        }

        .btn-lottery-primary i {
            color: #6c5ce7;
            text-shadow: 0 0 10px rgba(108, 92, 231, 0.5);
        }

        /* 十連抽按鈕 - 金色主題 */
        .btn-lottery-warning {
            border-color: rgba(243, 156, 18, 0.5);
            box-shadow: 0 0 15px rgba(243, 156, 18, 0.2);
        }

        .btn-lottery-warning:hover {
            border-color: rgba(243, 156, 18, 0.8);
            box-shadow: 0 0 25px rgba(243, 156, 18, 0.4);
            background: linear-gradient(135deg, rgba(243, 156, 18, 0.3) 0%, rgba(230, 126, 34, 0.3) 100%);
        }

        .btn-lottery-warning i {
            color: #f39c12;
            text-shadow: 0 0 10px rgba(243, 156, 18, 0.5);
        }

        /* 抽獎券單抽按鈕 - 綠色主題 */
        .btn-lottery-success {
            border-color: rgba(0, 184, 148, 0.5);
            box-shadow: 0 0 15px rgba(0, 184, 148, 0.2);
        }

        .btn-lottery-success:hover {
            border-color: rgba(0, 184, 148, 0.8);
            box-shadow: 0 0 25px rgba(0, 184, 148, 0.4);
            background: linear-gradient(135deg, rgba(0, 184, 148, 0.3) 0%, rgba(0, 160, 133, 0.3) 100%);
        }

        .btn-lottery-success .btn-icon {
            filter: drop-shadow(0 0 5px rgba(0, 184, 148, 0.5));
        }

        /* 抽獎券十連抽按鈕 - 青色主題 */
        .btn-lottery-info {
            border-color: rgba(0, 206, 201, 0.5);
            box-shadow: 0 0 15px rgba(0, 206, 201, 0.2);
        }

        .btn-lottery-info:hover {
            border-color: rgba(0, 206, 201, 0.8);
            box-shadow: 0 0 25px rgba(0, 206, 201, 0.4);
            background: linear-gradient(135deg, rgba(0, 206, 201, 0.3) 0%, rgba(0, 180, 175, 0.3) 100%);
        }

        .btn-lottery-info .btn-icon {
            filter: drop-shadow(0 0 5px rgba(0, 206, 201, 0.5));
        }

        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .bg-gradient-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .bg-gradient-info {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
        }

        .bg-gradient-warning {
            background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
        }

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

        .lottery-card {
            border: none;
            transition: all 0.3s ease;
            overflow: hidden;
        }

        .lottery-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.2) !important;
        }

        .cost-section {
            padding: 15px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 10px;
        }

        .lottery-card .card-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .prize-card {
            border: none;
            border-left: 4px solid #667eea;
            transition: all 0.3s ease;
        }

        .prize-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.15);
        }

        .pulse-animation {
            animation: pulse 1s infinite;
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.1);
            }
        }

        /* ========== 抽獎動畫樣式 ========== */
        .drawing-animation {
            position: relative;
            width: 150px;
            height: 150px;
            margin: 0 auto;
        }

        .lottery-box {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: shake 0.3s ease-in-out infinite;
        }

        .gift-icon {
            font-size: 80px;
            color: #ffc107;
            filter: drop-shadow(0 0 20px rgba(255, 193, 7, 0.8));
            animation: glow 0.5s ease-in-out infinite alternate;
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0) rotate(0deg); }
            25% { transform: translateX(-8px) rotate(-8deg); }
            75% { transform: translateX(8px) rotate(8deg); }
        }

        @keyframes glow {
            from { 
                filter: drop-shadow(0 0 20px rgba(255, 193, 7, 0.5));
                transform: scale(1);
            }
            to { 
                filter: drop-shadow(0 0 40px rgba(255, 193, 7, 1));
                transform: scale(1.1);
            }
        }

        .sparkles {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }

        .sparkles span {
            position: absolute;
            width: 12px;
            height: 12px;
            background: radial-gradient(circle, #ffc107 0%, rgba(255, 215, 0, 0) 70%);
            border-radius: 50%;
            animation: sparkle 1s ease-in-out infinite;
        }

        .sparkles span:nth-child(1) { top: 5%; left: 5%; animation-delay: 0s; }
        .sparkles span:nth-child(2) { top: 15%; right: 10%; animation-delay: 0.15s; }
        .sparkles span:nth-child(3) { bottom: 15%; left: 10%; animation-delay: 0.3s; }
        .sparkles span:nth-child(4) { bottom: 5%; right: 5%; animation-delay: 0.45s; }
        .sparkles span:nth-child(5) { top: 50%; left: -5%; animation-delay: 0.6s; }
        .sparkles span:nth-child(6) { top: 50%; right: -5%; animation-delay: 0.75s; }

        @keyframes sparkle {
            0%, 100% { transform: scale(0); opacity: 0; }
            50% { transform: scale(1.5); opacity: 1; }
        }

        .drawing-text {
            animation: pulse-text 0.8s ease-in-out infinite;
        }

        @keyframes pulse-text {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }

        /* 十連抽結果卡片 */
        .prize-10-card {
            transition: all 0.3s ease;
            animation: card-appear 0.5s ease-out forwards;
            opacity: 0;
            border: 2px solid transparent;
        }

        .prize-10-card:hover {
            transform: scale(1.05);
            border-color: #667eea;
        }

        .prize-10-card.rare {
            background: linear-gradient(135deg, #fff3cd 0%, #ffeeba 100%);
            border-color: #ffc107;
        }

        .prize-10-card.epic {
            background: linear-gradient(135deg, #d4edda 0%, #c3e6cb 100%);
            border-color: #28a745;
        }

        .prize-10-card.legendary {
            background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
            border-color: #dc3545;
            animation: card-appear 0.5s forwards, legendary-glow 1s 0.5s infinite alternate;
        }

        @keyframes card-appear {
            0% { transform: scale(0) rotateY(180deg); opacity: 0; }
            100% { transform: scale(1) rotateY(0deg); opacity: 1; }
        }

        @keyframes legendary-glow {
            from { box-shadow: 0 0 10px rgba(220, 53, 69, 0.5); }
            to { box-shadow: 0 0 25px rgba(220, 53, 69, 0.8); }
        }
    </style>

    <script>
        // 動畫持續時間（毫秒）
        var ANIMATION_DURATION = 2000;
        var SKIP_ANIMATION_KEY = 'lottery_skip_animation';
        var isDrawing = false;

        // 頁面載入時檢查動畫偏好設定
        document.addEventListener('DOMContentLoaded', function() {
            // 載入動畫偏好設定（優先執行）
            loadAnimationPreference();
            
            var animationField = document.getElementById('<%= hfAnimationPlayed.ClientID %>');
            if (animationField && animationField.value === '1') {
                // 動畫已在前端播放，PostBack 已完成，顯示動畫（短暫）然後後端會觸發結果顯示
                if (!isSkipAnimationEnabled()) {
                    showDrawingAnimation(false);
                }
            }
        });

        // 檢查是否啟用跳過動畫
        function isSkipAnimationEnabled() {
            var checkbox = document.getElementById('chkSkipAnimation');
            return checkbox && checkbox.checked;
        }

        // 儲存動畫偏好設定到 localStorage
        function saveAnimationPreference() {
            var checkbox = document.getElementById('chkSkipAnimation');
            if (checkbox) {
                localStorage.setItem(SKIP_ANIMATION_KEY, checkbox.checked ? '1' : '0');
                console.log('動畫偏好已儲存：跳過動畫 = ' + checkbox.checked);
            }
        }

        // 載入動畫偏好設定從 localStorage
        function loadAnimationPreference() {
            try {
                var saved = localStorage.getItem(SKIP_ANIMATION_KEY);
                var checkbox = document.getElementById('chkSkipAnimation');
                if (checkbox) {
                    if (saved === '1') {
                        checkbox.checked = true;
                    } else {
                        checkbox.checked = false;
                    }
                    console.log('動畫偏好已載入：跳過動畫 = ' + checkbox.checked);
                }
            } catch (e) {
                console.error('載入動畫偏好時發生錯誤：', e);
            }
        }

        // 點擊抽獎按鈕時：先顯示動畫，設置標記，再觸發 PostBack
        function showDrawingAndSubmit(btn, isTenDraw) {
            // 防止重複點擊
            if (isDrawing) return false;
            isDrawing = true;
            
            // 設置隱藏欄位，標記動畫將播放
            var animationField = document.getElementById('<%= hfAnimationPlayed.ClientID %>');
            if (animationField) {
                animationField.value = '1';
            }
            
            // 檢查是否跳過動畫
            var skipAnimation = isSkipAnimationEnabled();
            
            if (!skipAnimation) {
                // 顯示抽獎動畫
                showDrawingAnimation(isTenDraw);
            }
            
            // 獲取按鈕的 href 屬性（ASP.NET LinkButton 會生成 javascript:__doPostBack(...)）
            var href = btn.getAttribute('href');
            
            // 根據是否跳過動畫決定延遲時間
            var delay = skipAnimation ? 100 : ANIMATION_DURATION;
            
            // 延遲後觸發 PostBack
            setTimeout(function() {
                isDrawing = false;
                if (href && href.indexOf('__doPostBack') !== -1) {
                    // 直接執行 href 中的 JavaScript
                    eval(href.replace('javascript:', ''));
                }
            }, delay);
            
            // 阻止默認的表單提交
            return false;
        }

        function showPrizes(lotteryId) {
            // 顯示獎品池 Modal
            var modal = new bootstrap.Modal(document.getElementById('prizePoolModal'));
            modal.show();

            // 使用 AJAX 載入獎品資料
            fetch('LotteryList.aspx/GetPrizePool', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ lotteryId: lotteryId })
            })
            .then(response => response.json())
            .then(data => {
                if (data.d) {
                    var result = JSON.parse(data.d);
                    displayPrizePool(result.lotteryName, result.prizes);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('prizePoolContent').innerHTML = '<div class="alert alert-danger"><i class="bi bi-exclamation-circle-fill"></i> 載入獎品資訊失敗</div>';
            });
        }

        function displayPrizePool(lotteryName, prizes) {
            document.getElementById('modalLotteryName').textContent = lotteryName + ' - 獎品池';

            var html = '<div class="row row-cols-1 row-cols-md-2 g-3">';

            prizes.forEach(function(prize) {
                var stockInfo = '';
                if (prize.Stock !== null) {
                    var stockPercent = (prize.RemainingStock / prize.Stock) * 100;
                    var stockClass = stockPercent > 50 ? 'success' : stockPercent > 20 ? 'warning' : 'danger';
                    stockInfo = '<div class="mb-2"><small class="text-muted">庫存</small><div class="progress" style="height:20px"><div class="progress-bar bg-' + stockClass + '" style="width:' + stockPercent + '%">' + prize.RemainingStock + '/' + prize.Stock + '</div></div></div>';
                } else {
                    stockInfo = '<small class="text-success"><i class="bi bi-infinity"></i> 無限供應</small>';
                }

                var prizeColor = getPrizeColorClass(prize.PrizeType);
                var prizeTypeText = getPrizeTypeText(prize.PrizeType);
                var prizeValueText = getPrizeValueText(prize.PrizeType, prize.PrizeValue);

                html += '<div class="col"><div class="card h-100 prize-card"><div class="card-body"><div class="text-center mb-3"><i class="fa-solid ' + prize.IconUrl + ' fa-3x ' + prizeColor + '"></i></div><h6 class="card-title text-center">' + prize.PrizeName + '</h6><p class="text-center text-muted mb-2">' + prizeValueText + '</p><div class="d-flex justify-content-between align-items-center mb-2"><span class="badge bg-light text-dark">' + prizeTypeText + '</span><span class="badge bg-primary">' + prize.Probability + '%</span></div>' + stockInfo + '</div></div></div>';
            });

            html += '</div>';
            html += '<div class="alert alert-info mt-4 mb-0"><i class="bi bi-info-circle-fill"></i> <strong>抽獎說明：</strong>每個獎品的中獎機率已標示於右上角。</div>';

            document.getElementById('prizePoolContent').innerHTML = html;
        }

        function getPrizeColorClass(prizeType) {
            switch (prizeType) {
                case 'Points': return 'text-warning';
                case 'Experience': return 'text-info';
                case 'Item': return 'text-success';
                case 'Special': return 'text-danger';
                default: return 'text-secondary';
            }
        }

        function getPrizeTypeText(prizeType) {
            switch (prizeType) {
                case 'Points': return '積分獎勵';
                case 'Experience': return '經驗獎勵';
                case 'Item': return '道具獎勵';
                case 'Special': return '特殊獎勵';
                default: return '其他';
            }
        }

        function getPrizeValueText(prizeType, value) {
            switch (prizeType) {
                case 'Points': return value.toLocaleString() + ' 積分';
                case 'Experience': return value.toLocaleString() + ' 經驗值';
                case 'Item': return '道具 x1';
                case 'Special': return '特殊獎品';
                default: return '-';
            }
        }

        // 顯示抽獎動畫
        function showDrawingAnimation(isTenDraw) {
            var drawingModal = new bootstrap.Modal(document.getElementById('drawingModal'));
            var progressText = document.getElementById('drawingProgress');
            
            if (isTenDraw) {
                progressText.textContent = '十連抽進行中...';
            } else {
                progressText.textContent = '正在揭曉結果...';
            }
            
            drawingModal.show();
        }

        // 隱藏抽獎動畫
        function hideDrawingAnimation() {
            var drawingModalEl = document.getElementById('drawingModal');
            var drawingModal = bootstrap.Modal.getInstance(drawingModalEl);
            if (drawingModal) {
                drawingModal.hide();
            }
            // 清除動畫標記
            var animationField = document.getElementById('<%= hfAnimationPlayed.ClientID %>');
            if (animationField) {
                animationField.value = '0';
            }
        }

        // 顯示單抽結果（由後端調用）
        function showResultAfterPostback(prizeName, prizeIcon, prizeType) {
            var skipAnimation = isSkipAnimationEnabled();
            
            if (skipAnimation) {
                showResult(prizeName, prizeIcon, prizeType);
            } else {
                setTimeout(function() {
                    hideDrawingAnimation();
                    setTimeout(function() {
                        showResult(prizeName, prizeIcon, prizeType);
                    }, 300);
                }, 500);
            }
        }

        // 顯示十連抽結果（由後端調用）
        function showResult10AfterPostback(prizesJson) {
            var skipAnimation = isSkipAnimationEnabled();
            
            if (skipAnimation) {
                showResult10(prizesJson);
            } else {
                setTimeout(function() {
                    hideDrawingAnimation();
                    setTimeout(function() {
                        showResult10(prizesJson);
                    }, 300);
                }, 500);
            }
        }

        // 顯示單抽結果
        function showResult(prizeName, prizeIcon, prizeType) {
            var prizeColor = getPrizeColorClass(prizeType);
            var resultHtml = '<div class="prize-animation mb-4"><i class="fa-solid ' + prizeIcon + ' fa-5x ' + prizeColor + ' mb-3 pulse-animation"></i></div><h3 class="text-success mb-3"><i class="bi bi-emoji-laughing-fill text-warning"></i> 恭喜中獎！</h3><h4 class="mb-3">' + prizeName + '</h4><p class="text-muted">獎品已記錄，請前往「我的抽獎記錄」領取</p>';
            
            document.getElementById('prizeResult').innerHTML = resultHtml;
            
            var modal = new bootstrap.Modal(document.getElementById('resultModal'));
            modal.show();
        }

        // 顯示十連抽結果
        function showResult10(prizesJson) {
            var results = typeof prizesJson === 'string' ? JSON.parse(prizesJson) : prizesJson;
            var container = document.getElementById('prize10Result');
            container.innerHTML = '';

            var totalPoints = 0, totalExp = 0, itemCount = 0, specialCount = 0;

            results.forEach(function(result, index) {
                var prizeColor = getPrizeColorClass(result.PrizeType);
                var prizeValueText = getPrizeValueText(result.PrizeType, result.PrizeValue);

                if (result.PrizeType === 'Points') totalPoints += result.PrizeValue;
                if (result.PrizeType === 'Experience') totalExp += result.PrizeValue;
                if (result.PrizeType === 'Item') itemCount++;
                if (result.PrizeType === 'Special') specialCount++;

                var cardClass = '';
                if (result.PrizeType === 'Special') cardClass = 'legendary';
                else if (result.PrizeType === 'Item') cardClass = 'epic';
                else if (result.PrizeValue >= 100) cardClass = 'rare';

                var html = '<div class="col"><div class="card h-100 prize-10-card ' + cardClass + '" style="animation-delay:' + (index * 0.1) + 's"><div class="card-body text-center p-2"><i class="fa-solid ' + result.IconUrl + ' fa-2x ' + prizeColor + ' mb-2"></i><h6 class="card-title small mb-1">' + result.PrizeName + '</h6><small class="text-muted">' + prizeValueText + '</small></div></div></div>';

                container.insertAdjacentHTML('beforeend', html);
            });

            var stats = [];
            if (totalPoints > 0) stats.push('積分 +' + totalPoints.toLocaleString());
            if (totalExp > 0) stats.push('經驗 +' + totalExp.toLocaleString());
            if (itemCount > 0) stats.push('道具 x' + itemCount);
            if (specialCount > 0) stats.push('特殊 x' + specialCount);

            var summary = '<i class="bi bi-bar-chart-fill"></i> <strong>本次統計：</strong>' + stats.join('、');
            document.getElementById('prize10Summary').innerHTML = summary;

            var modal = new bootstrap.Modal(document.getElementById('result10Modal'));
            modal.show();
        }
    </script>
</asp:Content>
