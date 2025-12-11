<%@ Page Title="通知中心" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notifications.aspx.cs" Inherits="ForumDev.Profile.Notifications" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col-md-6">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-bell-fill text-primary"></i> 通知中心
                </h1>
                <p class="lead text-muted">查看您的最新通知與消息</p>
            </div>
            <div class="col-md-6 text-end">
                <asp:Button ID="btnMarkAllRead" runat="server" 
                            Text="全部標記為已讀" 
                            CssClass="btn btn-outline-primary me-2"
                            OnClick="btnMarkAllRead_Click" />
                <asp:Button ID="btnDeleteAll" runat="server" 
                            Text="刪除全部通知" 
                            CssClass="btn btn-outline-danger"
                            OnClick="btnDeleteAll_Click"
                            OnClientClick="return confirm('確定要刪除所有通知嗎？此操作無法復原。');" />
            </div>
        </div>

        <!-- 統計卡片 -->
        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-envelope-fill fs-1 mb-2 text-primary"></i>
                        <h6 class="card-title text-muted">未讀通知</h6>
                        <h2 class="mb-0 text-primary">
                            <asp:Label ID="lblUnreadCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-envelope-open-fill fs-1 mb-2 text-success"></i>
                        <h6 class="card-title text-muted">已讀通知</h6>
                        <h2 class="mb-0 text-success">
                            <asp:Label ID="lblReadCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card stats-card shadow-sm">
                    <div class="card-body text-center">
                        <i class="bi bi-inbox-fill fs-1 mb-2 text-info"></i>
                        <h6 class="card-title text-muted">總通知數</h6>
                        <h2 class="mb-0 text-info">
                            <asp:Label ID="lblTotalCount" runat="server" Text="0"></asp:Label>
                        </h2>
                    </div>
                </div>
            </div>
        </div>

        <!-- 訊息顯示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 通知篩選 -->
        <ul class="nav nav-pills nav-fill mb-4" role="tablist">
            <li class="nav-item">
                <asp:LinkButton ID="btnAll" runat="server" CssClass="nav-link active" 
                                OnClick="btnAll_Click">
                    <i class="bi bi-grid-fill"></i> 全部通知
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnUnread" runat="server" CssClass="nav-link" 
                                OnClick="btnUnread_Click">
                    <i class="bi bi-envelope-fill"></i> 未讀
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnSystem" runat="server" CssClass="nav-link" 
                                OnClick="btnSystem_Click">
                    <i class="bi bi-gear-fill"></i> 系統通知
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnTask" runat="server" CssClass="nav-link" 
                                OnClick="btnTask_Click">
                    <i class="bi bi-clipboard-check"></i> 任務通知
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnAchievement" runat="server" CssClass="nav-link" 
                                OnClick="btnAchievement_Click">
                    <i class="bi bi-trophy-fill"></i> 成就通知
                </asp:LinkButton>
            </li>
        </ul>

        <!-- 通知列表 -->
        <div class="notification-list">
            <asp:Repeater ID="rptNotifications" runat="server" OnItemCommand="rptNotifications_ItemCommand">
                <ItemTemplate>
                    <div class='card notification-card mb-3 shadow-sm <%# !IsRead(Eval("IsRead")) ? "unread" : "" %>'>
                        <div class="card-body">
                            <div class="d-flex">
                                <!-- 通知圖示 -->
                                <div class="notification-icon me-3">
                                    <div class='icon-circle bg-<%# GetTypeColor(Eval("Type").ToString()) %>'>
                                        <i class="bi bi-<%# GetTypeIcon(Eval("Type").ToString()) %> text-white"></i>
                                    </div>
                                </div>

                                <!-- 通知內容 -->
                                <div class="flex-grow-1">
                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                        <h6 class="mb-0">
                                            <%# Eval("Title") %>
                                            <%# !IsRead(Eval("IsRead")) ? "<span class='badge bg-danger ms-2'>NEW</span>" : "" %>
                                        </h6>
                                        <small class="text-muted">
                                            <%# GetTimeAgo(Eval("CreatedDate")) %>
                                        </small>
                                    </div>
                                    <p class="text-muted mb-2">
                                        <%# Eval("Content") %>
                                    </p>
                                    <div class="notification-actions">
                                        <asp:Button ID="btnMarkRead" runat="server" 
                                                    CommandName="MarkRead" 
                                                    CommandArgument='<%# Eval("NotificationID") %>'
                                                    Text="標記為已讀" 
                                                    CssClass="btn btn-sm btn-outline-primary"
                                                    Visible='<%# !IsRead(Eval("IsRead")) %>' />
                                        
                                        <asp:Button ID="btnDelete" runat="server" 
                                                    CommandName="Delete" 
                                                    CommandArgument='<%# Eval("NotificationID") %>'
                                                    Text="刪除" 
                                                    CssClass="btn btn-sm btn-outline-danger"
                                                    OnClientClick="return confirm('確定要刪除這則通知嗎？');" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlNoNotifications" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted fs-5">目前沒有通知</p>
            <p class="text-muted">當有新活動時，您會在這裡收到通知</p>
        </asp:Panel>
    </div>

    <style>
        .bg-gradient-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        .bg-gradient-success {
            background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
        }

        .bg-gradient-info {
            background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
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

        /* ========== 通知卡片暗色主題樣式 ========== */
        .notification-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            border-left: 4px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
            transition: all 0.3s ease;
        }

        .notification-card:hover {
            border-color: rgba(108, 92, 231, 0.5);
            box-shadow: 0 5px 20px rgba(108, 92, 231, 0.2) !important;
            transform: translateX(5px);
        }

        .notification-card.unread {
            border-left-color: #00cec9;
            background: linear-gradient(135deg, rgba(0, 206, 201, 0.1) 0%, rgba(31, 31, 56, 0.95) 15%, rgba(22, 33, 62, 0.95) 100%);
            box-shadow: 0 0 15px rgba(0, 206, 201, 0.1);
        }

        .notification-card.unread:hover {
            border-left-color: #00cec9;
            box-shadow: 0 5px 25px rgba(0, 206, 201, 0.2) !important;
        }

        .notification-card .card-body {
            color: #e8e8f0;
        }

        .notification-card h6 {
            color: #e8e8f0;
        }

        .notification-card .text-muted {
            color: #a0a0b8 !important;
        }

        .notification-icon {
            flex-shrink: 0;
        }

        .icon-circle {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.2);
        }

        .notification-actions {
            margin-top: 10px;
        }

        .notification-actions .btn {
            margin-right: 5px;
        }

        .notification-actions .btn-outline-primary {
            border-color: rgba(108, 92, 231, 0.5);
            color: #a0a0b8;
        }

        .notification-actions .btn-outline-primary:hover {
            background: rgba(108, 92, 231, 0.3);
            border-color: rgba(108, 92, 231, 0.7);
            color: #e8e8f0;
        }

        .notification-actions .btn-outline-danger {
            border-color: rgba(220, 53, 69, 0.5);
            color: #a0a0b8;
        }

        .notification-actions .btn-outline-danger:hover {
            background: rgba(220, 53, 69, 0.3);
            border-color: rgba(220, 53, 69, 0.7);
            color: #e8e8f0;
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
    </style>
</asp:Content>
