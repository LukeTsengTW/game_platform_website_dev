<%@ Page Title="我的任務" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyTasks.aspx.cs" Inherits="ForumDev.Tasks.MyTasks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-clipboard-check text-primary"></i> 我的任務
                </h1>
                <p class="lead text-muted">管理您的任務進度，領取豐富獎勵！</p>
            </div>
            <div class="col-auto d-flex gap-2 align-items-start">
                <asp:Button ID="btnClaimAll" runat="server" 
                            Text="?? 領取所有獎勵" 
                            CssClass="btn btn-success btn-lg claim-all-btn"
                            OnClick="btnClaimAll_Click"
                            OnClientClick="return confirm('確定要領取所有已完成任務的獎勵嗎？');"
                            Visible="false" />
                <asp:HyperLink ID="lnkTaskHall" runat="server" NavigateUrl="~/Tasks/TaskList.aspx"
                               CssClass="btn btn-primary">
                    <i class="bi bi-plus-circle"></i> 接取新任務
                </asp:HyperLink>
            </div>
        </div>

        <!-- 任務統計卡片 -->
        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">進行中</h6>
                        <h2 class="mb-0 text-primary">
                            <asp:Label ID="lblInProgressCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">待領取</h6>
                        <h2 class="mb-0 text-success">
                            <asp:Label ID="lblCompletedCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">已領取</h6>
                        <h2 class="mb-0 text-info">
                            <asp:Label ID="lblClaimedCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stats-card shadow">
                    <div class="card-body text-center">
                        <h6 class="card-title text-muted">總完成數</h6>
                        <h2 class="mb-0 text-warning">
                            <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 篩選標籤 -->
        <ul class="nav nav-pills mb-4" role="tablist">
            <li class="nav-item">
                <asp:LinkButton ID="btnShowAll" runat="server" CssClass="nav-link active" 
                                OnClick="btnShowAll_Click">
                    全部
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnShowInProgress" runat="server" CssClass="nav-link" 
                                OnClick="btnShowInProgress_Click">
                    進行中
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnShowCompleted" runat="server" CssClass="nav-link" 
                                OnClick="btnShowCompleted_Click">
                    已完成
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnShowClaimed" runat="server" CssClass="nav-link" 
                                OnClick="btnShowClaimed_Click">
                    已領取
                </asp:LinkButton>
            </li>
        </ul>

        <!-- 訊息顯示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 任務列表 -->
        <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="alert alert-info text-center py-5">
            <i class="bi bi-inbox fs-1"></i>
            <p class="mt-3 mb-2 fs-5">目前沒有任務</p>
            <p class="text-muted">前往任務大廳接取新任務吧！</p>
            <asp:HyperLink ID="lnkGoToTaskHall" runat="server" NavigateUrl="~/Tasks/TaskList.aspx"
                           CssClass="btn btn-primary mt-2">
                前往任務大廳
            </asp:HyperLink>
        </asp:Panel>

        <div class="row row-cols-1 g-4">
            <asp:Repeater ID="rptMyTasks" runat="server" OnItemCommand="rptMyTasks_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card task-detail-card shadow-sm">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <!-- 任務資訊 -->
                                    <div class="col-md-6">
                                        <div class="d-flex align-items-start mb-3">
                                            <div class="task-icon me-3">
                                                <i class="bi bi-trophy-fill text-warning" style="font-size: 2.5rem;"></i>
                                            </div>
                                            <div class="flex-grow-1">
                                                <h5 class="mb-1"><%# Eval("Task.TaskName") %></h5>
                                                <p class="text-muted mb-2"><%# Eval("Task.Description") %></p>
                                                <div class="d-flex gap-2 flex-wrap">
                                                    <span class="badge bg-<%# GetCategoryColor(Eval("Task.Category").ToString()) %>">
                                                        <%# GetCategoryName(Eval("Task.Category").ToString()) %>
                                                    </span>
                                                    <span class="badge bg-<%# GetStatusColor(Eval("Status").ToString()) %>">
                                                        <i class="bi bi-<%# GetStatusIcon(Eval("Status").ToString()) %>"></i>
                                                        <%# GetStatusText(Eval("Status").ToString()) %>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 任務獎勵 -->
                                        <div class="rewards-info">
                                            <small class="text-muted d-block mb-1">任務獎勵：</small>
                                            <div class="d-flex gap-2">
                                                <span class="badge bg-warning text-dark">
                                                    <i class="bi bi-star-fill"></i> <%# Eval("Task.ExpReward") %> EXP
                                                </span>
                                                <span class="badge bg-success">
                                                    <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon-small" /> <%# Eval("Task.PointsReward") %> 積分
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 進度與操作 -->
                                    <div class="col-md-6">
                                        <!-- 進度條 -->
                                        <div class="mb-3">
                                            <div class="d-flex justify-content-between align-items-center mb-2">
                                                <span class="text-muted small">任務進度</span>
                                                <span class="fw-bold text-<%# GetStatusColor(Eval("Status").ToString()) %>">
                                                    <%# Eval("Progress") %>%
                                                </span>
                                            </div>
                                            <div class="progress" style="height: 15px;">
                                                <div class="progress-bar bg-<%# GetStatusColor(Eval("Status").ToString()) %>" 
                                                     role="progressbar" 
                                                     style='width: <%# Eval("Progress") %>%'
                                                     aria-valuenow='<%# Eval("Progress") %>' 
                                                     aria-valuemin="0" 
                                                     aria-valuemax="100">
                                                </div>
                                            </div>
                                        </div>

                                        <!-- 時間資訊 -->
                                        <div class="time-info mb-3">
                                            <small class="text-muted d-block">
                                                <i class="bi bi-clock-fill"></i>
                                                開始時間: <%# Eval("StartedDate", "{0:yyyy/MM/dd HH:mm}") %>
                                            </small>
                                            <%# GetCompletedDateInfo(Eval("CompletedDate")) %>
                                        </div>

                                        <!-- 操作按鈕 -->
                                        <div class="d-grid gap-2">
                                            <!-- 領取獎勵按鈕 (已完成但未領取) -->
                                            <asp:Button ID="btnClaim" runat="server" 
                                                        CommandName="Claim" 
                                                        CommandArgument='<%# Eval("UserTaskID") + "," + Eval("TaskID") %>'
                                                        Text="領取獎勵" 
                                                        CssClass="btn btn-success btn-lg"
                                                        OnClientClick="return confirm('確定要領取此任務的獎勵嗎？');"
                                                        Visible='<%# Eval("Status").ToString() == "Completed" %>' />

                                            <!-- 進行中狀態提示 -->
                                            <%# Eval("Status").ToString() == "InProgress" ? 
                                                "<div class='alert alert-warning mb-0'>" +
                                                "<i class='bi bi-hourglass-split'></i> " +
                                                "<strong>進行中</strong><br/>" +
                                                "<small>系統會自動偵測任務完成條件，完成後請返回領取獎勵</small>" +
                                                "</div>" : "" %>

                                            <!-- 已完成狀態 -->
                                            <%# Eval("Status").ToString() == "Claimed" ? 
                                                "<div class='alert alert-success mb-0'>" +
                                                "<i class='bi bi-check-circle-fill'></i> " +
                                                "<strong>獎勵已領取</strong><br/>" +
                                                "<small>於 " + Eval("ClaimedDate", "{0:yyyy/MM/dd HH:mm}") + " 領取</small>" +
                                                "</div>" : "" %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <style>
        /* 積分圖標樣式 */
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

        /* 統計卡片暗色主題樣式 */
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

        .task-detail-card {
            border: none;
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
        }

        .task-detail-card:hover {
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
        }

        /* 領取所有獎勵按鈕樣式 */
        .claim-all-btn {
            font-weight: bold;
            transition: all 0.3s ease;
            animation: claim-glow 2s ease-in-out infinite;
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
            border: none;
        }

        .claim-all-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 20px rgba(40, 167, 69, 0.5);
            background: linear-gradient(135deg, #20c997 0%, #28a745 100%);
        }

        @keyframes claim-glow {
            0%, 100% {
                box-shadow: 0 0 10px rgba(40, 167, 69, 0.5);
            }
            50% {
                box-shadow: 0 0 25px rgba(40, 167, 69, 0.8);
            }
        }

        .nav-pills .nav-link {
            color: #6c757d;
        }

        .nav-pills .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
    </style>
</asp:Content>
