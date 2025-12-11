<%@ Page Title="註冊" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="ForumDev.Account.Register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5 mb-5">
        <div class="row justify-content-center">
            <div class="col-md-7 col-lg-6">
                <div class="card shadow-lg">
                    <div class="card-body p-5">
                        <div class="text-center mb-4">
                            <i class="bi bi-person-plus-fill" style="font-size: 4rem; color: #667eea;"></i>
                            <h2 class="mt-3">加入我們</h2>
                            <p class="text-muted">建立帳號開始您的挑戰之旅</p>
                        </div>

                        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert" role="alert">
                            <asp:Label ID="lblMessage" runat="server"></asp:Label>
                        </asp:Panel>

                        <div class="mb-3">
                            <label for="txtUserName" class="form-label">
                                <i class="bi bi-person-fill"></i> 用戶名稱 <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtUserName" runat="server" CssClass="form-control form-control-lg" 
                                         placeholder="4-20個字元" MaxLength="50"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvUserName" runat="server" 
                                ControlToValidate="txtUserName" 
                                ErrorMessage="請輸入用戶名稱" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                            <asp:RegularExpressionValidator ID="revUserName" runat="server"
                                ControlToValidate="txtUserName"
                                ValidationExpression="^[a-zA-Z0-9\u4e00-\u9fa5]{4,20}$"
                                ErrorMessage="用戶名稱必須為4-20個字元，只能包含英文、數字或中文"
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-3">
                            <label for="txtEmail" class="form-label">
                                <i class="bi bi-envelope-fill"></i> Email <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" 
                                         CssClass="form-control form-control-lg" 
                                         placeholder="your@email.com"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" 
                                ControlToValidate="txtEmail" 
                                ErrorMessage="請輸入 Email" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server"
                                ControlToValidate="txtEmail"
                                ValidationExpression="^\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*$"
                                ErrorMessage="Email 格式不正確"
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-3">
                            <label for="txtPassword" class="form-label">
                                <i class="bi bi-lock-fill"></i> 密碼 <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" 
                                         CssClass="form-control form-control-lg" 
                                         placeholder="至少6個字元"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvPassword" runat="server" 
                                ControlToValidate="txtPassword" 
                                ErrorMessage="請輸入密碼" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                            <asp:RegularExpressionValidator ID="revPassword" runat="server"
                                ControlToValidate="txtPassword"
                                ValidationExpression="^.{6,}$"
                                ErrorMessage="密碼至少需要6個字元"
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-3">
                            <label for="txtConfirmPassword" class="form-label">
                                <i class="bi bi-lock-fill"></i> 確認密碼 <span class="text-danger">*</span>
                            </label>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" 
                                         CssClass="form-control form-control-lg" 
                                         placeholder="再次輸入密碼"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" 
                                ControlToValidate="txtConfirmPassword" 
                                ErrorMessage="請再次輸入密碼" 
                                Display="Dynamic"
                                CssClass="text-danger small" />
                            <asp:CompareValidator ID="cvPassword" runat="server"
                                ControlToValidate="txtConfirmPassword"
                                ControlToCompare="txtPassword"
                                ErrorMessage="兩次輸入的密碼不一致"
                                Display="Dynamic"
                                CssClass="text-danger small" />
                        </div>

                        <div class="mb-4">
                            <div class="form-check">
                                <asp:CheckBox ID="chkAgree" runat="server" CssClass="form-check-input" />
                                <label class="form-check-label" for="chkAgree">
                                    我同意 <a href="#" class="text-primary">使用條款</a> 和 <a href="#" class="text-primary">隱私政策</a>
                                </label>
                            </div>
                            <asp:CustomValidator ID="cvAgree" runat="server"
                                ErrorMessage="請同意使用條款和隱私政策"
                                OnServerValidate="cvAgree_ServerValidate"
                                Display="Dynamic"
                                CssClass="text-danger small d-block mt-1" />
                        </div>

                        <div class="d-grid gap-2 mb-3">
                            <asp:Button ID="btnRegister" runat="server" Text="註冊" 
                                        CssClass="btn btn-primary btn-lg" 
                                        OnClick="btnRegister_Click" />
                        </div>

                        <hr />

                        <div class="text-center">
                            <p class="mb-2">已經有帳號了？</p>
                            <asp:HyperLink ID="lnkLogin" runat="server" 
                                           NavigateUrl="~/Account/Login.aspx" 
                                           CssClass="btn btn-outline-primary">
                                <i class="bi bi-box-arrow-in-right"></i> 立即登入
                            </asp:HyperLink>
                        </div>
                    </div>
                </div>

                <!-- 註冊福利提示 -->
                <div class="card mt-3 bg-gradient-info text-white">
                    <div class="card-body">
                        <h6 class="card-title"><i class="bi bi-gift-fill"></i> 新手福利</h6>
                        <ul class="mb-0 ps-3">
                            <li>註冊即送 <strong>100 積分</strong></li>
                            <li>完成新手任務再送 <strong>100 EXP</strong></li>
                            <li>立即解鎖「新手上路」成就</li>
                        </ul>
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

        .form-check-label a {
            color: #00cec9;
        }

        /* 註冊按鈕暗色主題 */
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

        /* 新手福利卡片暗色主題 */
        .bg-gradient-info {
            background: linear-gradient(135deg, rgba(0, 206, 201, 0.15) 0%, rgba(31, 31, 56, 0.95) 100%) !important;
            border: 1px solid rgba(0, 206, 201, 0.3) !important;
        }

        .bg-gradient-info .card-title {
            color: #00cec9;
            text-shadow: 0 0 10px rgba(0, 206, 201, 0.5);
        }

        .bg-gradient-info ul li {
            color: #a0a0b8;
        }

        .bg-gradient-info strong {
            color: #00cec9;
        }
    </style>
</asp:Content>
