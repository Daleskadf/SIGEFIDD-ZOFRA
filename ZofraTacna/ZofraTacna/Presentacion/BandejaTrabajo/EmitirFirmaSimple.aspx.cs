using System;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class EmitirFirmaSimple : Page
    {
        protected int IdDocumentoActual
        {
            get { return ViewState["IdDocumentoActual"] != null ? Convert.ToInt32(ViewState["IdDocumentoActual"]) : 0; }
            set { ViewState["IdDocumentoActual"] = value; }
        }

        protected string TokenActual
        {
            get { return ViewState["TokenActual"] != null ? ViewState["TokenActual"].ToString() : ""; }
            set { ViewState["TokenActual"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["LoginUsuario"] == null) { Response.Redirect("~/Presentacion/InicioSesion/Login.aspx"); return; }

            int idDoc;
            if (!int.TryParse(Request.QueryString["id"], out idDoc) || idDoc <= 0)
            {
                idDoc = 1;
            }

            IdDocumentoActual = idDoc;

            if (!IsPostBack)
            {
                string login = Session["LoginUsuario"].ToString();
                string token = idDoc + "_" + DateTime.Now.Ticks;
                FirmaPeruTokenStore.StoreToken(token, login);
                TokenActual = token;
            }
        }
    }
}
