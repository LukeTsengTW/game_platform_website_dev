<%@ Page Title="社交中心" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Social.aspx.cs" Inherits="ForumDev.Social.Social" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col-md-8">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-people-fill text-primary"></i> 社交中心
                </h1>
                <p class="lead text-muted">與其他玩家交流、結交好友、加入聊天室！</p>
            </div>
            <div class="col-md-4" id="statsPanel" runat="server">
                <div class="card stats-card shadow">
                    <div class="card-body">
                        <div class="row text-center">
                            <div class="col-4">
                                <h4 class="mb-0 text-primary"><asp:Label ID="lblFriendCount" runat="server" Text="0"></asp:Label></h4>
                                <small class="text-muted">好友</small>
                            </div>
                            <div class="col-4">
                                <h4 class="mb-0 text-success"><asp:Label ID="lblRoomCount" runat="server" Text="0"></asp:Label></h4>
                                <small class="text-muted">聊天室</small>
                            </div>
                            <div class="col-4">
                                <h4 class="mb-0 text-warning"><asp:Label ID="lblMessageCount" runat="server" Text="0"></asp:Label></h4>
                                <small class="text-muted">留言</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 訊息提示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 隱藏欄位：記錄當前標籤頁和聊天室狀態 -->
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="board" />
        <asp:HiddenField ID="hfShowChatModal" runat="server" Value="false" />

        <!-- 未登入提示 -->
        <asp:Panel ID="pnlNotLoggedIn" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-person-x fs-1 text-muted"></i>
            <h3 class="mt-3">請先登入</h3>
            <p class="text-muted">登入後即可使用社交功能</p>
            <a href="/Account/Login.aspx" class="btn btn-primary btn-lg">
                <i class="bi bi-box-arrow-in-right"></i> 立即登入
            </a>
        </asp:Panel>

        <!-- 主要內容區 -->
        <asp:Panel ID="pnlMainContent" runat="server">
            <!-- 功能標籤頁 -->
            <ul class="nav nav-tabs nav-tabs-social mb-4" id="socialTabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="board-tab" data-bs-toggle="tab" data-bs-target="#board" type="button" role="tab">
                        <i class="bi bi-chat-left-text-fill"></i> 留言板
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="friends-tab" data-bs-toggle="tab" data-bs-target="#friends" type="button" role="tab">
                        <i class="bi bi-person-heart"></i> 好友
                        <asp:Label ID="lblPendingBadge" runat="server" CssClass="badge bg-danger ms-1" Visible="false"></asp:Label>
                    </button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="chatrooms-tab" data-bs-toggle="tab" data-bs-target="#chatrooms" type="button" role="tab">
                        <i class="bi bi-chat-dots-fill"></i> 聊天室
                    </button>
                </li>
            </ul>

            <div class="tab-content" id="socialTabsContent">
                <!-- ========== 留言板標籤 ========== -->
                <div class="tab-pane fade show active" id="board" role="tabpanel">
                    <!-- 發布留言區 -->
                    <div class="card mb-4 post-card">
                        <div class="card-body">
                            <div class="d-flex">
                                <asp:Image ID="imgCurrentUserAvatar" runat="server" CssClass="avatar-small rounded-circle me-3" />
                                <div class="flex-grow-1">
                                    <asp:TextBox ID="txtNewMessage" runat="server" TextMode="MultiLine" Rows="2"
                                                 CssClass="form-control mb-2" placeholder="分享你的想法..." MaxLength="1000"></asp:TextBox>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <small class="text-muted"><span id="charCount">0</span>/1000</small>
                                        <asp:Button ID="btnPostMessage" runat="server" Text="發布" CssClass="btn btn-primary"
                                                    OnClick="btnPostMessage_Click" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 留言列表 -->
                    <div id="messageList">
                        <asp:Repeater ID="rptMessages" runat="server" OnItemCommand="rptMessages_ItemCommand">
                            <ItemTemplate>
                                <div class="card mb-3 message-card">
                                    <div class="card-body">
                                        <div class="d-flex">
                                            <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt="Avatar" class="avatar-small rounded-circle me-3" />
                                            <div class="flex-grow-1">
                                                <div class="d-flex justify-content-between align-items-start">
                                                    <div>
                                                        <strong><%# Eval("UserName") %></strong>
                                                        <span class="badge bg-primary ms-1">Lv.<%# Eval("UserLevel") %></span>
                                                    </div>
                                                    <small class="text-muted"><%# GetTimeAgo((DateTime)Eval("PostedDate")) %></small>
                                                </div>
                                                <p class="mt-2 mb-2"><%# Server.HtmlEncode(Eval("Content").ToString()) %></p>
                                                <div class="d-flex align-items-center">
                                                    <asp:LinkButton ID="btnLike" runat="server" CommandName="Like" 
                                                                    CommandArgument='<%# Eval("MessageID") %>'
                                                                    CssClass="btn btn-sm btn-outline-danger me-2">
                                                        <i class="bi bi-heart-fill"></i> <%# Eval("LikeCount") %>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="btnDelete" runat="server" CommandName="Delete"
                                                                    CommandArgument='<%# Eval("MessageID") %>'
                                                                    CssClass="btn btn-sm btn-outline-secondary"
                                                                    Visible='<%# IsOwner(Eval("UserID")) %>'
                                                                    OnClientClick="return confirm('確定要刪除此留言嗎？');">
                                                        <i class="bi bi-trash"></i>
                                                    </asp:LinkButton>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoMessages" runat="server" Visible="false" CssClass="text-center py-5">
                            <i class="bi bi-chat-left fs-1 text-muted"></i>
                            <p class="mt-3 text-muted">還沒有留言，成為第一個發言的人吧！</p>
                        </asp:Panel>
                    </div>
                </div>

                <!-- ========== 好友標籤 ========== -->
                <div class="tab-pane fade" id="friends" role="tabpanel">
                    <!-- 搜尋好友 -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-search"></i> 搜尋用戶</h5>
                            <div class="input-group">
                                <asp:TextBox ID="txtSearchUser" runat="server" CssClass="form-control" 
                                             placeholder="輸入用戶名稱..." MaxLength="50"
                                             onkeypress="return handleSearchEnter(event);"></asp:TextBox>
                                <asp:Button ID="btnSearchUser" runat="server" Text="搜尋" CssClass="btn btn-primary"
                                            OnClick="btnSearchUser_Click" />
                            </div>
                        </div>
                    </div>

                    <!-- 搜尋結果 -->
                    <asp:Panel ID="pnlSearchResults" runat="server" Visible="false" CssClass="card mb-4">
                        <div class="card-header">
                            <i class="bi bi-person-lines-fill"></i> 搜尋結果
                        </div>
                        <div class="card-body">
                            <asp:Repeater ID="rptSearchResults" runat="server" OnItemCommand="rptSearchResults_ItemCommand">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center justify-content-between py-2 border-bottom">
                                        <div class="d-flex align-items-center">
                                            <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt="Avatar" class="avatar-small rounded-circle me-3" />
                                            <div>
                                                <strong><%# Eval("UserName") %></strong>
                                                <span class="badge bg-primary ms-1">Lv.<%# Eval("Level") %></span>
                                            </div>
                                        </div>
                                        <asp:LinkButton ID="btnAddFriend" runat="server" CommandName="AddFriend"
                                                        CommandArgument='<%# Eval("UserID") %>'
                                                        CssClass="btn btn-sm btn-success">
                                            <i class="bi bi-person-plus"></i> 加好友
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>

                    <!-- 待處理請求 -->
                    <asp:Panel ID="pnlPendingRequests" runat="server" Visible="false" CssClass="card mb-4">
                        <div class="card-header bg-warning text-dark">
                            <i class="bi bi-person-plus-fill"></i> 待處理的好友請求
                        </div>
                        <div class="card-body">
                            <asp:Repeater ID="rptPendingRequests" runat="server" OnItemCommand="rptPendingRequests_ItemCommand">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center justify-content-between py-2 border-bottom">
                                        <div class="d-flex align-items-center">
                                            <img src='<%# GetAvatarUrl(Eval("RequesterAvatar")) %>' alt="Avatar" class="avatar-small rounded-circle me-3" />
                                            <div>
                                                <strong><%# Eval("RequesterName") %></strong>
                                                <span class="badge bg-primary ms-1">Lv.<%# Eval("RequesterLevel") %></span>
                                                <br /><small class="text-muted"><%# GetTimeAgo((DateTime)Eval("RequestDate")) %></small>
                                            </div>
                                        </div>
                                        <div>
                                            <asp:LinkButton ID="btnAccept" runat="server" CommandName="Accept"
                                                            CommandArgument='<%# Eval("FriendshipID") %>'
                                                            CssClass="btn btn-sm btn-success me-1">
                                                <i class="bi bi-check-lg"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnReject" runat="server" CommandName="Reject"
                                                            CommandArgument='<%# Eval("FriendshipID") %>'
                                                            CssClass="btn btn-sm btn-danger">
                                                <i class="bi bi-x-lg"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </asp:Panel>

                    <!-- 好友列表 -->
                    <div class="card">
                        <div class="card-header">
                            <i class="bi bi-people-fill"></i> 我的好友
                        </div>
                        <div class="card-body">
                            <asp:Repeater ID="rptFriends" runat="server" OnItemCommand="rptFriends_ItemCommand">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center justify-content-between py-2 border-bottom friend-item">
                                        <div class="d-flex align-items-center">
                                            <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt="Avatar" class="avatar-small rounded-circle me-3" />
                                            <div>
                                                <strong><%# Eval("UserName") %></strong>
                                                <span class="badge bg-primary ms-1">Lv.<%# Eval("Level") %></span>
                                                <br /><small class="text-muted">好友 <%# GetTimeAgo((DateTime)Eval("FriendSince")) %></small>
                                            </div>
                                        </div>
                                        <div class="friend-actions">
                                            <asp:LinkButton ID="btnRemoveFriend" runat="server" CommandName="Remove"
                                                            CommandArgument='<%# Eval("FriendshipID") %>'
                                                            CssClass="btn btn-sm btn-outline-danger"
                                                            OnClientClick="return confirm('確定要移除此好友嗎？');">
                                                <i class="bi bi-person-dash"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <asp:Panel ID="pnlNoFriends" runat="server" Visible="false" CssClass="text-center py-4">
                                <i class="bi bi-person-x fs-1 text-muted"></i>
                                <p class="mt-3 text-muted">還沒有好友，快去搜尋並添加好友吧！</p>
                            </asp:Panel>
                        </div>
                    </div>
                </div>

                <!-- ========== 聊天室標籤 ========== -->
                <div class="tab-pane fade" id="chatrooms" role="tabpanel">
                    <!-- 創建聊天室 -->
                    <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title"><i class="bi bi-plus-circle"></i> 創建聊天室</h5>
                            <div class="row g-2">
                                <div class="col-md-5">
                                    <asp:TextBox ID="txtRoomName" runat="server" CssClass="form-control"
                                                 placeholder="聊天室名稱" MaxLength="100"
                                                 onkeypress="return handleCreateRoomEnter(event);"></asp:TextBox>
                                </div>
                                <div class="col-md-4">
                                    <asp:TextBox ID="txtRoomDesc" runat="server" CssClass="form-control"
                                                 placeholder="描述（選填）" MaxLength="500"
                                                 onkeypress="return handleCreateRoomEnter(event);"></asp:TextBox>
                                </div>
                                <div class="col-md-2">
                                    <asp:DropDownList ID="ddlRoomType" runat="server" CssClass="form-select">
                                        <asp:ListItem Value="Public" Text="公開"></asp:ListItem>
                                        <asp:ListItem Value="Private" Text="私人"></asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="col-md-1">
                                    <asp:Button ID="btnCreateRoom" runat="server" Text="創建" CssClass="btn btn-success w-100"
                                                OnClick="btnCreateRoom_Click" />
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 聊天室列表 -->
                    <div class="row row-cols-1 row-cols-md-2 row-cols-lg-3 g-4">
                        <asp:Repeater ID="rptChatRooms" runat="server" OnItemCommand="rptChatRooms_ItemCommand" OnItemDataBound="rptChatRooms_ItemDataBound">
                            <ItemTemplate>
                                <div class="col">
                                    <div class="card h-100 room-card <%# (bool)Eval("IsMember") ? "room-joined" : "" %>">
                                        <div class="card-body">
                                            <div class="d-flex align-items-center mb-2">
                                                <i class="bi bi-chat-dots-fill fa-2x me-2 text-primary"></i>
                                                <div>
                                                    <h5 class="card-title mb-0"><%# Eval("RoomName") %></h5>
                                                    <span class="badge <%# Eval("RoomType").ToString() == "Public" ? "bg-success" : "bg-warning" %>">
                                                        <%# Eval("RoomType").ToString() == "Public" ? "公開" : "私人" %>
                                                    </span>
                                                </div>
                                            </div>
                                            <p class="card-text text-muted small"><%# Eval("Description") %></p>
                                            <div class="d-flex justify-content-between align-items-center">
                                                <small class="text-muted">
                                                    <i class="bi bi-people"></i> <%# Eval("MemberCount") %>/<%# Eval("MaxMembers") %>
                                                </small>
                                                <asp:HiddenField ID="hfRoomId" runat="server" Value='<%# Eval("RoomID") %>' />
                                                <asp:HiddenField ID="hfIsMember" runat="server" Value='<%# Eval("IsMember") %>' />
                                                <%-- 加入按鈕（非成員時顯示） --%>
                                                <asp:Button ID="btnJoinRoom" runat="server" 
                                                            Text="加入"
                                                            OnClick="btnJoinRoom_Click"
                                                            CssClass="btn btn-sm btn-outline-primary"
                                                            Style='<%# (bool)Eval("IsMember") ? "display:none;" : "" %>' />
                                                <%-- 進入按鈕（成員時顯示） --%>
                                                <asp:Button ID="btnEnterRoom" runat="server" 
                                                            Text="進入"
                                                            OnClick="btnEnterRoom_Click"
                                                            CssClass="btn btn-sm btn-primary"
                                                            Style='<%# !(bool)Eval("IsMember") ? "display:none;" : "" %>' />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <asp:Panel ID="pnlNoRooms" runat="server" Visible="false" CssClass="text-center py-5">
                        <i class="bi bi-chat-left-dots fs-1 text-muted"></i>
                        <p class="mt-3 text-muted">還沒有聊天室，創建一個吧！</p>
                    </asp:Panel>
                </div>
            </div>
        </asp:Panel>
    </div>

    <!-- 聊天室對話框 Modal -->
    <div class="modal fade" id="chatModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title">
                        <i class="bi bi-chat-dots-fill"></i> 
                        <asp:Label ID="lblChatRoomName" runat="server"></asp:Label>
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body chat-body" id="chatBody">
                    <asp:Repeater ID="rptChatMessages" runat="server">
                        <ItemTemplate>
                            <div class='chat-message <%# IsCurrentUser(Eval("UserID")) ? "chat-message-self" : "" %>'>
                                <img src='<%# GetAvatarUrl(Eval("AvatarUrl")) %>' alt="Avatar" class="chat-avatar" />
                                <div class="chat-content">
                                    <div class="chat-header">
                                        <strong><%# Eval("UserName") %></strong>
                                        <small class="text-muted"><%# ((DateTime)Eval("SentDate")).ToString("HH:mm") %></small>
                                    </div>
                                    <div class="chat-text"><%# Server.HtmlEncode(Eval("Content").ToString()) %></div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="modal-footer">
                    <asp:HiddenField ID="hfCurrentRoomId" runat="server" />
                    <div class="input-group">
                        <asp:TextBox ID="txtChatMessage" runat="server" CssClass="form-control"
                                     placeholder="輸入訊息..." MaxLength="2000"
                                     onkeypress="return handleChatEnter(event);"></asp:TextBox>
                        <asp:Button ID="btnSendChat" runat="server" Text="發送" CssClass="btn btn-primary"
                                    OnClick="btnSendChat_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        /* ========== 統計卡片 ========== */
        .stats-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%);
        }

        .stats-card h4 {
            text-shadow: 0 0 10px currentColor;
        }

        /* ========== 標籤頁樣式 ========== */
        .nav-tabs-social {
            border-bottom: 2px solid rgba(108, 92, 231, 0.3);
        }

        .nav-tabs-social .nav-link {
            border: none;
            border-bottom: 3px solid transparent;
            color: #a0a0b8;
            padding: 1rem 1.5rem;
            transition: all 0.3s ease;
        }

        .nav-tabs-social .nav-link:hover {
            color: #00cec9;
            border-bottom-color: rgba(0, 206, 201, 0.5);
        }

        .nav-tabs-social .nav-link.active {
            color: #00cec9;
            background: transparent;
            border-bottom-color: #00cec9;
        }

        /* ========== 卡片樣式 ========== */
        .post-card, .message-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
        }

        .message-card {
            transition: all 0.3s ease;
        }

        .message-card:hover {
            border-color: rgba(108, 92, 231, 0.5);
            box-shadow: 0 0 15px rgba(108, 92, 231, 0.2);
        }

        /* ========== 頭像 ========== */
        .avatar-small {
            width: 45px;
            height: 45px;
            object-fit: cover;
            border: 2px solid rgba(108, 92, 231, 0.5);
        }

        /* ========== 好友列表 ========== */
        .friend-item {
            transition: all 0.3s ease;
        }

        .friend-item:hover {
            background: rgba(108, 92, 231, 0.1);
            padding-left: 10px;
        }

        .friend-actions {
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .friend-item:hover .friend-actions {
            opacity: 1;
        }

        /* ========== 聊天室卡片 ========== */
        .room-card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
            transition: all 0.3s ease;
        }

        .room-card:hover {
            transform: translateY(-5px);
            border-color: rgba(108, 92, 231, 0.6);
            box-shadow: 0 10px 25px rgba(108, 92, 231, 0.3);
        }

        .room-joined {
            border-color: rgba(0, 184, 148, 0.5);
        }

        .room-joined:hover {
            border-color: rgba(0, 184, 148, 0.8);
            box-shadow: 0 10px 25px rgba(0, 184, 148, 0.3);
        }

        /* ========== 聊天對話框 ========== */
        .chat-body {
            height: 400px;
            overflow-y: auto;
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
            padding: 15px;
        }

        .chat-message {
            display: flex;
            margin-bottom: 15px;
        }

        .chat-message-self {
            flex-direction: row-reverse;
        }

        .chat-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            margin: 0 10px;
        }

        .chat-content {
            max-width: 70%;
            background: rgba(108, 92, 231, 0.2);
            border-radius: 15px;
            padding: 10px 15px;
        }

        .chat-message-self .chat-content {
            background: rgba(0, 184, 148, 0.2);
        }

        .chat-header {
            font-size: 0.85rem;
            margin-bottom: 5px;
        }

        .chat-text {
            word-wrap: break-word;
        }

        /* ========== 表單樣式 ========== */
        .form-control, .form-select {
            background: rgba(31, 31, 56, 0.8);
            border: 1px solid rgba(108, 92, 231, 0.3);
            color: #e8e8f0;
        }

        .form-control:focus, .form-select:focus {
            background: rgba(31, 31, 56, 0.9);
            border-color: rgba(108, 92, 231, 0.6);
            box-shadow: 0 0 0 0.2rem rgba(108, 92, 231, 0.25);
            color: #e8e8f0;
        }

        .form-control::placeholder {
            color: #6c6c7e;
        }

        /* ========== 按鈕樣式 ========== */
        .btn-primary {
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.8) 0%, rgba(74, 63, 159, 0.8) 100%);
            border: 1px solid rgba(108, 92, 231, 0.5);
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, rgba(108, 92, 231, 1) 0%, rgba(74, 63, 159, 1) 100%);
            border-color: rgba(108, 92, 231, 0.8);
            box-shadow: 0 0 15px rgba(108, 92, 231, 0.4);
        }

        .btn-success {
            background: linear-gradient(135deg, rgba(0, 184, 148, 0.8) 0%, rgba(0, 160, 133, 0.8) 100%);
            border: 1px solid rgba(0, 184, 148, 0.5);
        }

        .btn-success:hover {
            background: linear-gradient(135deg, rgba(0, 184, 148, 1) 0%, rgba(0, 160, 133, 1) 100%);
            box-shadow: 0 0 15px rgba(0, 184, 148, 0.4);
        }

        /* ========== Modal 樣式 ========== */
        .modal-content {
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.98) 0%, rgba(22, 33, 62, 0.98) 100%);
            border: 1px solid rgba(108, 92, 231, 0.3);
        }

        .modal-header.bg-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
        }

        .modal-footer {
            border-top: 1px solid rgba(108, 92, 231, 0.3);
        }
    </style>

    <script>
        // 處理搜尋用戶輸入框的 Enter 鍵
        function handleSearchEnter(event) {
            if (event.keyCode === 13 || event.which === 13) {
                event.preventDefault();
                document.getElementById('<%= btnSearchUser.ClientID %>').click();
                return false;
            }
            return true;
        }
        
        // 處理創建聊天室輸入框的 Enter 鍵
        function handleCreateRoomEnter(event) {
            if (event.keyCode === 13 || event.which === 13) {
                event.preventDefault();
                document.getElementById('<%= btnCreateRoom.ClientID %>').click();
                return false;
            }
            return true;
        }
        
        // 處理聊天訊息輸入框的 Enter 鍵
        function handleChatEnter(event) {
            if (event.keyCode === 13 || event.which === 13) {
                event.preventDefault();
                document.getElementById('<%= btnSendChat.ClientID %>').click();
                return false;
            }
            return true;
        }
        
        // 字數計算
        document.addEventListener('DOMContentLoaded', function() {
            var textarea = document.getElementById('<%= txtNewMessage.ClientID %>');
            var charCount = document.getElementById('charCount');
            
            if (textarea && charCount) {
                textarea.addEventListener('input', function() {
                    charCount.textContent = this.value.length;
                });
            }
            
            // 監聽標籤頁切換事件，更新隱藏欄位
            var tabElements = document.querySelectorAll('button[data-bs-toggle="tab"]');
            tabElements.forEach(function(tabEl) {
                tabEl.addEventListener('shown.bs.tab', function(event) {
                    var tabId = event.target.id.replace('-tab', '');
                    var hiddenField = document.getElementById('<%= hfActiveTab.ClientID %>');
                    if (hiddenField) {
                        hiddenField.value = tabId;
                    }
                });
            });
            
            // 檢查是否需要顯示聊天室 Modal（頁面載入時）
            var hfShowChatModal = document.getElementById('<%= hfShowChatModal.ClientID %>');
            var hfActiveTab = document.getElementById('<%= hfActiveTab.ClientID %>');
            
            if (hfActiveTab && hfActiveTab.value && hfActiveTab.value !== 'board') {
                // 切換到對應的標籤頁
                var tabEl = document.getElementById(hfActiveTab.value + '-tab');
                if (tabEl) {
                    var tab = new bootstrap.Tab(tabEl);
                    tab.show();
                }
            }
            
            if (hfShowChatModal && hfShowChatModal.value === 'true') {
                // 顯示聊天室 Modal
                setTimeout(function() {
                    var chatModal = document.getElementById('chatModal');
                    if (chatModal) {
                        var modal = new bootstrap.Modal(chatModal);
                        modal.show();
                        
                        // 滾動到底部
                        setTimeout(function() {
                            var chatBody = document.getElementById('chatBody');
                            if (chatBody) {
                                chatBody.scrollTop = chatBody.scrollHeight;
                            }
                        }, 200);
                    }
                    // 重置標記
                    hfShowChatModal.value = 'false';
                }, 300);
            }
        });

        // 顯示聊天室 Modal
        function showChatModal() {
            var modal = new bootstrap.Modal(document.getElementById('chatModal'));
            modal.show();
            
            // 滾動到底部
            setTimeout(function() {
                var chatBody = document.getElementById('chatBody');
                if (chatBody) {
                    chatBody.scrollTop = chatBody.scrollHeight;
                }
            }, 100);
        }

        // 設定當前標籤頁
        function setActiveTab(tabId) {
            var hfActiveTab = document.getElementById('<%= hfActiveTab.ClientID %>');
            hfActiveTab.value = tabId;
        }
    </script>
</asp:Content>
