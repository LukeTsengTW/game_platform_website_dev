using System;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using ForumDev.BLL;
using ForumDev.Models;

namespace ForumDev.Account
{
    public partial class Login : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 如果已登入，導向首頁
            if (User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Default.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                string userName = txtUserName.Text.Trim();
                string password = txtPassword.Text;

                // 驗證用戶
                User user = UserService.Login(userName, password);

                if (user != null)
                {
                    // 建立 Forms Authentication Ticket
                    FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                        1,                                      // 版本
                        user.UserName,                          // 用戶名稱
                        DateTime.Now,                           // 發行時間
                        DateTime.Now.AddMinutes(60),           // 過期時間
                        chkRememberMe.Checked,                 // 是否持久
                        user.UserID.ToString(),                // 用戶資料
                        FormsAuthentication.FormsCookiePath);  // Cookie 路徑

                    // 加密票證
                    string encryptedTicket = FormsAuthentication.Encrypt(ticket);

                    // 建立 Cookie
                    HttpCookie cookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket);
                    if (chkRememberMe.Checked)
                    {
                        cookie.Expires = DateTime.Now.AddDays(30);
                    }
                    Response.Cookies.Add(cookie);

                    // 觸發登入任務追蹤
                    try
                    {
                        TaskProgressTracker.OnUserLogin(user.UserID);
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Task tracking error: {ex.Message}");
                    }

                    // 導向回原本要前往的頁面或首頁
                    string returnUrl = Request.QueryString["ReturnUrl"];
                    if (!string.IsNullOrEmpty(returnUrl))
                    {
                        Response.Redirect(returnUrl);
                    }
                    else
                    {
                        Response.Redirect("~/Default.aspx");
                    }
                }
                else
                {
                    ShowError("用戶名稱或密碼錯誤");
                }
            }
            catch (Exception ex)
            {
                ShowError("登入失敗: " + ex.Message);
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-danger";
        }
    }
}
