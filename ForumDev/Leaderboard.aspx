<%@ Page Title="排行榜" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Leaderboard.aspx.cs" Inherits="ForumDev.Leaderboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col text-center">
                <h1 class="display-4 fw-bold">
                    <i class="bi bi-trophy-fill text-warning"></i> 排行榜
                </h1>
                <p class="lead text-muted">看看誰是最強的王者！</p>
            </div>
        </div>

        <!-- 排行榜類型選擇 -->
        <ul class="nav nav-pills nav-fill mb-4" role="tablist">
            <li class="nav-item">
                <asp:LinkButton ID="btnLevel" runat="server" CssClass="nav-link active" 
                                OnClick="btnLevel_Click">
                    <i class="bi bi-star-fill"></i> 等級榜
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnPoints" runat="server" CssClass="nav-link" 
                                OnClick="btnPoints_Click">
                    <img src="/Images/Icons/coin_rmbg.png" alt="積分" class="coin-icon" /> 積分榜
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnTasks" runat="server" CssClass="nav-link" 
                                OnClick="btnTasks_Click">
                    <i class="bi bi-clipboard-check"></i> 任務榜
                </asp:LinkButton>
            </li>
        </ul>

        <!-- 當前用戶排名卡片 -->
        <asp:Panel ID="pnlUserRank" runat="server" Visible="false" CssClass="card bg-gradient-primary text-white mb-4 shadow">
            <div class="card-body">
                <div class="row align-items-center">
                    <div class="col-auto">
                        <div class="rank-badge">
                            <i class="bi bi-person-circle" style="font-size: 3rem;"></i>
                        </div>
                    </div>
                    <div class="col">
                        <h5 class="mb-1">您的排名</h5>
                        <p class="mb-0">
                            <strong>第 <asp:Label ID="lblUserRank" runat="server"></asp:Label> 名</strong> · 
                            <asp:Label ID="lblUserScore" runat="server"></asp:Label>
                        </p>
                    </div>
                    <div class="col-auto text-end">
                        <h2 class="mb-0">#<asp:Label ID="lblUserRankNumber" runat="server"></asp:Label></h2>
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- 排行榜列表 -->
        <div class="card shadow">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead class="table-light">
                            <tr>
                                <th width="80" class="text-center">排名</th>
                                <th>用戶</th>
                                <th width="120" class="text-center">等級</th>
                                <th width="150" class="text-end">
                                    <asp:Label ID="lblScoreColumn" runat="server"></asp:Label>
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptLeaderboard" runat="server">
                                <ItemTemplate>
                                    <tr class='<%# GetRowClass(Container.ItemIndex) %>'>
                                        <td class="text-center">
                                            <div class='<%# GetRankBadgeClass(Container.ItemIndex + 1) %>'>
                                                <%# GetRankDisplay(Container.ItemIndex + 1) %>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="d-flex align-items-center">
                                                <div class="avatar-sm me-2">
                                                    <img src='<%# GetAvatar(Eval("Avatar")) %>' 
                                                         class="rounded-circle" 
                                                         width="40" 
                                                         height="40"
                                                         alt="Avatar" />
                                                </div>
                                                <div>
                                                    <strong><%# Eval("UserName") %></strong>
                                                    <%# IsCurrentUser(Eval("UserName").ToString()) %>
                                                </div>
                                            </div>
                                        </td>
                                        <td class="text-center">
                                            <span class="badge bg-primary">Lv.<%# Eval("Level") %></span>
                                        </td>
                                        <td class="text-end">
                                            <strong class="fs-5"><%# FormatScore(Eval("Score")) %></strong>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted">目前暫無排行榜數據</p>
        </asp:Panel>

        <!-- 更新時間 -->
        <div class="text-center text-muted mt-3">
            <small>
                <i class="bi bi-clock-fill"></i>
                最後更新: <asp:Label ID="lblUpdateTime" runat="server"></asp:Label>
            </small>
        </div>
    </div>

    <style>
        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        /* ========== 分頁籤暗色主題樣式 ========== */
        .nav-pills .nav-link {
            color: #a0a0b8;
            font-weight: 500;
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
            border: 1px solid rgba(108, 92, 231, 0.3);
            margin: 0 5px;
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

        .rank-badge {
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: rgba(255,255,255,0.2);
        }

        .rank-gold {
            background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
            color: white;
            font-weight: bold;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 1.1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .rank-silver {
            background: linear-gradient(135deg, #C0C0C0 0%, #A9A9A9 100%);
            color: white;
            font-weight: bold;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 1.1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .rank-bronze {
            background: linear-gradient(135deg, #CD7F32 0%, #8B4513 100%);
            color: white;
            font-weight: bold;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 1.1rem;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }

        .rank-normal {
            font-size: 1.1rem;
            font-weight: 600;
            color: #a0a0b8;
        }

        .row-highlight {
            background-color: rgba(102, 126, 234, 0.1);
        }

        /* ========== 表格暗色主題樣式 ========== */
        .table {
            color: #e8e8f0;
        }

        .table thead.table-light th {
            background: rgba(31, 31, 56, 0.9);
            color: #00cec9;
            border-color: rgba(108, 92, 231, 0.3);
        }

        .table tbody tr {
            transition: all 0.3s ease;
            border-color: rgba(108, 92, 231, 0.2);
        }

        .table tbody tr:hover {
            background-color: rgba(108, 92, 231, 0.15) !important;
            color: #e8e8f0 !important;
            transform: scale(1.01);
        }

        .table tbody tr:hover td {
            color: #e8e8f0 !important;
        }

        .table tbody tr:hover strong {
            color: #fff !important;
        }

        .coin-icon {
            width: 20px;
            height: 20px;
            vertical-align: middle;
            margin-right: 3px;
            display: inline-block;
        }

        .coin-icon-small {
            width: 16px;
            height: 16px;
            vertical-align: middle;
            margin-right: 2px;
            display: inline-block;
        }

        .coin-icon-inline {
            width: 18px;
            height: 18px;
            vertical-align: middle;
            margin-right: 2px;
            display: inline-block;
        }

        .nav-pills .nav-link .coin-icon {
            width: 18px;
            height: 18px;
        }
    </style>
</asp:Content>
