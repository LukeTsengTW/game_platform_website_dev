<%@ Page Title="我的抽獎記錄" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MyRecords.aspx.cs" Inherits="ForumDev.LotteryPages.MyRecords" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <!-- 頁面標題 -->
        <div class="row mb-4">
            <div class="col">
                <h1 class="display-5 fw-bold">
                    <i class="bi bi-clock-history text-primary"></i> 我的抽獎記錄
                </h1>
                <p class="lead text-muted">查看您的抽獎歷史和待領取獎品</p>
            </div>
            <div class="col-auto">
                <div class="d-flex gap-2">
                    <asp:Button ID="btnClaimAll" runat="server" Text="領取全部獎品" CssClass="btn btn-secondary" OnClick="btnClaimAll_Click" />
                    <asp:HyperLink ID="lnkBackToLottery" runat="server" NavigateUrl="~/LotteryPages/LotteryList.aspx"
                                   CssClass="btn btn-primary">
                        <i class="bi bi-arrow-left"></i> 返回抽獎中心
                    </asp:HyperLink>
                </div>
            </div>
        </div>

        <!-- 篩選標籤 -->
        <ul class="nav nav-pills mb-4" role="tablist">
            <li class="nav-item">
                <asp:LinkButton ID="btnShowAll" runat="server" CssClass="nav-link active" 
                                OnClick="btnShowAll_Click">
                    全部記錄
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnShowUnclaimed" runat="server" CssClass="nav-link" 
                                OnClick="btnShowUnclaimed_Click">
                    待領取
                    <asp:Label ID="lblUnclaimedBadge" runat="server" CssClass="badge bg-danger ms-1" 
                               Visible="false"></asp:Label>
                </asp:LinkButton>
            </li>
            <li class="nav-item">
                <asp:LinkButton ID="btnShowClaimed" runat="server" CssClass="nav-link" 
                                OnClick="btnShowClaimed_Click">
                    已領取
                </asp:LinkButton>
            </li>
        </ul>

        <!-- 消息提示 -->
        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
            <asp:Label ID="lblMessage" runat="server"></asp:Label>
        </asp:Panel>

        <!-- 記錄列表 -->
        <div class="row row-cols-1 g-4">
            <asp:Repeater ID="rptRecords" runat="server" OnItemCommand="rptRecords_ItemCommand">
                <ItemTemplate>
                    <div class="col">
                        <div class="card record-card shadow-sm">
                            <div class="card-body">
                                <div class="row align-items-center">
                                    <!-- 獎品圖示 -->
                                    <div class="col-auto">
                                        <div class="prize-icon-container">
                                            <img src='<%# GetPrizeImageUrl(Eval("Prize.PrizeType").ToString(), Convert.ToInt32(Eval("Prize.PrizeValue")), Eval("Prize.IconUrl").ToString(), Eval("Prize.ItemIconUrl") != null ? Eval("Prize.ItemIconUrl").ToString() : "") %>' 
                                                 alt='<%# Eval("Prize.PrizeName") %>' 
                                                 class="prize-image" 
                                                 onerror="this.src='/Images/Icons/gift.png';" />
                                        </div>
                                    </div>

                                    <!-- 獎品資訊 -->
                                    <div class="col">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <div>
                                                <h5 class="mb-1"><%# Eval("Prize.PrizeName") %></h5>
                                                <p class="text-muted mb-1">
                                                    來自：<%# Eval("Lottery.LotteryName") %>
                                                </p>
                                                <small class="text-muted">
                                                    <i class="bi bi-calendar-fill"></i>
                                                    抽獎時間：<%# Eval("DrawDate", "{0:yyyy/MM/dd HH:mm}") %>
                                                </small>
                                            </div>
                                            <div class="text-end">
                                                <span class="badge bg-<%# GetStatusColor(Eval("IsClaimed")) %> mb-2">
                                                    <%# GetStatusText(Eval("IsClaimed")) %>
                                                </span>
                                                <br />
                                                <span class="badge bg-light text-dark">
                                                    <%# GetPrizeTypeText(Eval("Prize.PrizeType").ToString()) %>
                                                </span>
                                            </div>
                                        </div>

                                        <!-- 獎品價值 -->
                                        <div class="prize-value mb-3">
                                            <span class="text-muted">獎品價值：</span>
                                            <strong class="text-primary">
                                                <%# GetPrizeValueText(Eval("Prize.PrizeType").ToString(), Eval("Prize.PrizeValue")) %>
                                            </strong>
                                        </div>

                                        <!-- 操作按鈕 -->
                                        <div class="d-flex gap-2">
                                            <asp:Button ID="btnClaim" runat="server" 
                                                        CommandName="Claim" 
                                                        CommandArgument='<%# Eval("RecordID") %>'
                                                        Text="領取獎品" 
                                                        CssClass="btn btn-success"
                                                        Visible='<%# !(bool)Eval("IsClaimed") %>'
                                                        OnClientClick="return confirm('確定要領取此獎品嗎？');" />

                                            <%# GetClaimedInfo(Eval("IsClaimed"), Eval("ClaimedDate")) %>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <!-- 空狀態 -->
        <asp:Panel ID="pnlNoRecords" runat="server" Visible="false" CssClass="text-center py-5">
            <i class="bi bi-inbox fs-1 text-muted"></i>
            <p class="mt-3 text-muted fs-5">還沒有抽獎記錄</p>
            <p class="text-muted">前往抽獎中心試試手氣吧！</p>
            <asp:HyperLink ID="lnkGoToLottery" runat="server" NavigateUrl="~/LotteryPages/LotteryList.aspx"
                           CssClass="btn btn-primary mt-2">
                前往抽獎中心
            </asp:HyperLink>
        </asp:Panel>
    </div>

    <style>
        .record-card {
            border: none;
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
        }

        .record-card:hover {
            box-shadow: 0 10px 30px rgba(0,0,0,0.15) !important;
            transform: translateY(-5px);
        }

        .prize-icon-container {
            width: 80px;
            height: 80px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1) 0%, rgba(118, 75, 162, 0.1) 100%);
            border-radius: 15px;
            overflow: hidden;
        }

        .prize-image {
            max-width: 60px;
            max-height: 60px;
            object-fit: contain;
        }

        .text-points {
            color: #ffc107;
        }

        .text-experience {
            color: #17a2b8;
        }

        .text-item {
            color: #28a745;
        }

        .text-special {
            color: #dc3545;
        }

        .prize-value {
            padding: 10px;
            background: rgba(102, 126, 234, 0.05);
            border-radius: 8px;
        }

        .nav-pills .nav-link {
            color: #6c757d;
        }

        .nav-pills .nav-link.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
    </style>
</asp:Content>
