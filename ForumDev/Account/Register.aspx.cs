using System;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using ForumDev.BLL;

namespace ForumDev.Account
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 如果已登入，導向首頁
            if (User.Identity.IsAuthenticated)
            {
                Response.Redirect("~/Default.aspx");
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid)
                return;

            try
            {
                string userName = txtUserName.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text;

                // 註冊用戶
                bool success = UserService.Register(userName, email, password);

                if (success)
                {
                    ShowSuccess("註冊成功！正在跳轉到登入頁面...");
                    
                    // 延遲2秒後跳轉
                    Response.AddHeader("REFRESH", "2;URL=Login.aspx");
                }
                else
                {
                    ShowError("註冊失敗，請稍後再試");
                }
            }
            catch (Exception ex)
            {
                ShowError(ex.Message);
            }
        }

        protected void cvAgree_ServerValidate(object source, ServerValidateEventArgs args)
        {
            args.IsValid = chkAgree.Checked;
        }

        private void ShowError(string message)
        {
            lblMessage.Text = "<i class='bi bi-exclamation-circle-fill'></i> " + message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-danger";
        }

        private void ShowSuccess(string message)
        {
            lblMessage.Text = "<i class='bi bi-check-circle-fill'></i> " + message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "alert alert-success";
        }
    }
}
