<%@ Page Title="登入" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ForumDev.Account.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="card shadow-lg">
                    <div class="card-body p-5">
                        <div class="text-center mb-4">
                            <i class="bi bi-person-circle" style="font-size: 4rem; color: #667eea;"></i>
                            <h2 class="mt-3">歡迎回來</h2>
                            <p class="text-muted">登入您的帳號開始挑戰</p>
                        </div>

                        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-danger" role="alert">
                            <i class="bi bi-exclamation-circle-fill"></i>
                            <asp:Label ID="lblMessage" runat="server"></asp:Label>
                        </asp:Panel>

                        <div class="mb-3">
                            <label for="txtUserName" class="form-label">
                                <i class="bi bi-person-fill"></i> 用戶名稱
                            </label>
                            <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control form-control-lg" 
                                         placeholder="請輸入用戶名稱" required></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvUserName" runat="server" 
                                ControlToValidate="txtUserName" 
                                ErrorMessage="請輸入用戶名稱" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-3">
                            <label for="txtPassword" class="form-label">
                                <i class="bi bi-lock-fill"></i> 密碼
                            </label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" 
                                         CssClass="form-control form-control-lg" 
                                         placeholder="請輸入密碼" required></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                                ControlToValidate="txtPassword" 
                                ErrorMessage="請輸入密碼" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-3 form-check">
                            <asp:CheckBox ID="chkRememberMe" runat="server" CssClass="form-check-input" />
                            <label class="form-check-label" for="chkRememberMe">
                                記住我
                            </label>
                        </div>

                        <div class="d-grid gap-2 mb-3">
                            <asp:Button ID="btnLogin" runat="server" Text="登入" 
                                        CssClass="btn btn-primary btn-lg" 
                                        OnClick="btnLogin_Click" />
                        </div>

                        <hr />

                        <div class="text-center">
                            <p class="mb-2">還沒有帳號？</p>
                            <asp:HyperLink ID="lnkRegister" runat="server" 
                                           NavigateUrl="~/Account/Register.aspx" 
                                           CssClass="btn btn-outline-primary">
                                <i class="bi bi-person-plus-fill"></i> 立即註冊
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <style>
        .card {
            border: 1px solid rgba(108, 92, 231, 0.3);
            border-radius: 15px;
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.95) 0%, rgba(22, 33, 62, 0.95) 100%);
        }

        .card-body {
            color: #e8e8f0;
        }

        .form-label {
            color: #a0a0b8;
        }

        .form-control {
            background: rgba(31, 31, 56, 0.8);
            border: 1px solid rgba(108, 92, 231, 0.3);
            color: #e8e8f0;
        }

        .form-control::placeholder {
            color: #6c6c7e;
        }

        .form-control:focus {
            background: rgba(31, 31, 56, 0.9);
            border-color: rgba(108, 92, 231, 0.6);
            box-shadow: 0 0 0 0.2rem rgba(108, 92, 231, 0.25);
            color: #e8e8f0;
        }

        .text-muted {
            color: #a0a0b8 !important;
        }

        .form-check-label {
            color: #a0a0b8;
        }

        /* 登入按鈕暗色主題 */
        .btn-primary {
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.4) 0%, rgba(74, 63, 159, 0.4) 100%);
            border: 1px solid rgba(108, 92, 231, 0.5);
            color: #e8e8f0;
            transition: all 0.3s ease;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            background: linear-gradient(135deg, rgba(108, 92, 231, 0.6) 0%, rgba(74, 63, 159, 0.6) 100%);
            border-color: rgba(108, 92, 231, 0.8);
            box-shadow: 0 5px 20px rgba(108, 92, 231, 0.4);
            color: #fff;
        }

        .btn-outline-primary {
            border-color: rgba(108, 92, 231, 0.5);
            color: #a0a0b8;
        }

        .btn-outline-primary:hover {
            background: rgba(108, 92, 231, 0.3);
            border-color: rgba(108, 92, 231, 0.7);
            color: #e8e8f0;
        }

        hr {
            border-color: rgba(108, 92, 231, 0.3);
        }

        /* 測試帳號卡片暗色主題 */
        .bg-light {
            background: linear-gradient(135deg, rgba(31, 31, 56, 0.9) 0%, rgba(22, 33, 62, 0.9) 100%) !important;
            border: 1px solid rgba(108, 92, 231, 0.3) !important;
        }

        .bg-light .card-title {
            color: #00cec9;
        }

        .bg-light .card-text {
            color: #a0a0b8;
        }

        .bg-light strong {
            color: #e8e8f0;
        }
    </style>
</asp:Content>
