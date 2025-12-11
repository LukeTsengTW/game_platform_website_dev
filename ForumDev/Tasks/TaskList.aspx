<%@ Page Title="任務大廳" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TaskList.aspx.cs" Inherits="ForumDev.Tasks.TaskList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-list-task text-primary"></i> 任務大廳
                </h1>
                <p class="lead text-muted">選擇任務開始挑戰，獲得豐富獎勵！</p>
            </div>
        </div>

        <!-- 篩選器 -->
        <div class="card mb-4 shadow-sm">
            <div class="card-body">
                <div class="row g-3 align-items-end">
                    <div class="col-md-3">
                        <label class="form-label fw-bold">
                            <i class="bi bi-funnel-fill"></i> 任務類別
                        </label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                            <asp:ListItem Value="" Text="所有類別"></asp:ListItem>
                            <asp:ListItem Value="Daily" Text="每日任務"></asp:ListItem>
                            <asp:ListItem Value="Learning" Text="學習挑戰"></asp:ListItem>
                            <asp:ListItem Value="Shopping" Text="購物任務"></asp:ListItem>
                            <asp:ListItem Value="Social" Text="社交任務"></asp:ListItem>
                            <asp:ListItem Value="Event" Text="限時活動"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold">
                            <i class="bi bi-sort-down"></i> 排序方式
                        </label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                            <asp:ListItem Value="default" Text="預設排序"></asp:ListItem>
                            <asp:ListItem Value="exp_desc" Text="經驗值 (高到低)"></asp:ListItem>
                            <asp:ListItem Value="points_desc" Text="積分 (高到低)"></asp:ListItem>
                            <asp:ListItem Value="level_asc" Text="等級需求 (低到高)"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <div class="d-flex gap-2 flex-wrap">
                            <asp:Button ID="btnAcceptAll" runat="server" 
                                        Text="接收所有任務" 
                                        CssClass="btn btn-success accept-all-btn" 
                                        OnClick="btnAcceptAll_Click"
                                        OnClientClick="return confirm('確定要接收所有可用的任務嗎？');" />
                            <asp:Button ID="btnClaimAll" runat="server" 
                                        Text="?? 領取所有獎勵" 
                                        CssClass="btn btn-warning claim-all-btn" 
                                        OnClick="btnClaimAll_Click"
                                        OnClientClick="return confirm('確定要領取所有已完成任務的獎勵嗎？');"
                                        Visible="false" />
                            <asp:Button ID="btnReset" runat="server" Text="重設篩選" 
                                        CssClass="btn btn-outline-secondary" 
                                        OnClick="btnReset_Click" />
                            <asp:HyperLink ID="lnkMyTasks" runat="server" NavigateUrl="~/Tasks/MyTasks.aspx"
                                           CssClass="btn btn-primary ms-auto">
                                <i class="bi bi-clipboard-check"></i> 我的任務
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 任務列表 -->
        <asp:Panel ID="pnlNoTasks" runat="server" Visible="false" CssClass="alert alert-info text-center">
            <i class="bi bi-info-circle-fill fs-1"></i>
            <p class="mt-2 mb-0">目前沒有符合條件的任務</p>
        </asp:Panel>

        <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
            <asp:Repeater ID="rptTasks" runat="server" OnItemCommand="rptTasks_ItemCommand" OnItemDataBound="rptTasks_ItemDataBound">
                <ItemTemplate>
                    <div class="col">
                        <div class="card task-card h-100 shadow-sm">
                            <div class="card-body">
                                <!-- 任務類別標籤 -->
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <span class="badge bg-<%# GetCategoryColor(Eval("Category").ToString()) %>">
                                        <%# GetCategoryName(Eval("Category").ToString()) %>
                                    </span>
                                    <span class="badge bg-light text-dark">
                                        Lv.<%# Eval("RequiredLevel") %>+
                                    </span>
                                </div>

                                <!-- 任務標題與說明 -->
                                <h5 class="card-title">
                                    <i class="bi bi-star-fill text-warning"></i>
                                    <%# Eval("TaskName") %>
                                </h5>
                                <p class="card-text text-muted">
                                    <%# Eval("Description") %>
                                </p>

                                <!-- 獎勵資訊 -->
                                <div class="rewards-section mb-3">
                                    <div class="d-flex gap-2">
                                        <span class="badge bg-warning text-dark">
                                            <i class="bi bi-star-fill"></i> <%# Eval("ExpReward") %> EXP
                                        </span>
                                        <span class="badge bg-success">
                                            <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon-small" /> <%# Eval("PointsReward") %> 積分
                                        </span>
                                    </div>
                                </div>

                                <!-- 任務類型 -->
                                <small class="text-muted d-block mb-3">
                                    <i class="bi bi-clock-fill"></i> 
                                    <%# GetTaskTypeName(Eval("Type").ToString()) %>
                                </small>

                                <!-- 操作按鈕 - 根據任務狀態動態顯示 -->
                                <asp:LinkButton ID="btnStartTask" runat="server" 
                                    CommandName="StartTask" 
                                    CommandArgument='<%# Eval("TaskID") %>'
                                    CssClass="btn btn-primary w-100"
                                    Visible="false">
                                    <i class="bi bi-play-fill"></i> 開始任務
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnClaimReward" runat="server" 
                                    CommandName="ClaimReward" 
                                    CommandArgument='<%# Eval("TaskID") %>'
                                    CssClass="btn btn-success w-100"
                                    OnClientClick="return confirm('確定要領取此任務的獎勵嗎？');"
                                    Visible="false">
                                    <i class="bi bi-gift-fill"></i> 領取獎勵
                                </asp:LinkButton>

                                <asp:HyperLink ID="lnkInProgress" runat="server" 
                                    NavigateUrl="~/Tasks/MyTasks.aspx"
                                    CssClass="btn btn-info w-100"
                                    Visible="false">
                                    <i class="bi bi-hourglass-split"></i> 進行中
                                </asp:HyperLink>

                                <asp:Label ID="lblCompleted" runat="server" 
                                    CssClass="btn btn-secondary w-100 disabled"
                                    Visible="false">
                                    <i class="bi bi-check-circle-fill"></i> 已完成
                                </asp:Label>

                                <asp:HyperLink ID="lnkLoginToStart" runat="server" 
                                    NavigateUrl="~/Account/Login.aspx"
                                    CssClass="btn btn-outline-primary w-100"
                                    Visible="false">
                                    <i class="bi bi-box-arrow-in-right"></i> 登入後開始
                                </asp:HyperLink>
                            </div>

                            <!-- 任務進度條區域 (如果已開始) -->
                            <%# GetTaskProgressBar(Eval("TaskID")) %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="row mt-4">
            <div class="col text-center">
                <asp:Label ID="lblTaskCount" runat="server" CssClass="text-muted"></asp:Label>
            </div>
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
        
        .task-card {
            border: none;
            border-left: 4px solid #667eea;
            transition: all 0.3s ease;
        }

        .task-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
            border-left-color: #764ba2;
        }

        .rewards-section {
            padding: 10px;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 8px;
        }

        /* 接收所有任務按鈕樣式 */
        .accept-all-btn {
            font-weight: bold;
            transition: all 0.3s ease;
            animation: pulse-glow 2s ease-in-out infinite;
        }

        .accept-all-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(40, 167, 69, 0.4);
        }

        /* 領取所有獎勵按鈕樣式 */
        .claim-all-btn {
            font-weight: bold;
            transition: all 0.3s ease;
            animation: claim-glow 2s ease-in-out infinite;
            background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%) !important;
            border: none !important;
            color: #000 !important;
        }

        .claim-all-btn:hover {
            transform: scale(1.05);
            box-shadow: 0 5px 20px rgba(255, 193, 7, 0.5);
            background: linear-gradient(135deg, #ff9800 0%, #ffc107 100%) !important;
        }

        @keyframes pulse-glow {
            0%, 100% {
                box-shadow: 0 0 5px rgba(40, 167, 69, 0.5);
            }
            50% {
                box-shadow: 0 0 15px rgba(40, 167, 69, 0.8);
            }
        }

        @keyframes claim-glow {
            0%, 100% {
                box-shadow: 0 0 10px rgba(255, 193, 7, 0.5);
            }
            50% {
                box-shadow: 0 0 25px rgba(255, 193, 7, 0.8);
            }
        }
    </style>
</asp:Content>
