using System.Configuration;
using System.Net;
using System.Net.Mail;

namespace ZofraTacna.ServiciosExternos
{
    public class ServicioSMTP
    {
        public void Enviar(string destinatario, string asunto, string cuerpo)
        {
            string host  = ConfigurationManager.AppSettings["SMTP_Host"]  ?? "smtp.gmail.com";
            int    port  = int.Parse(ConfigurationManager.AppSettings["SMTP_Port"] ?? "587");
            string user  = ConfigurationManager.AppSettings["SMTP_User"]  ?? "";
            string pass  = ConfigurationManager.AppSettings["SMTP_Pass"]  ?? "";

            using (var cliente = new SmtpClient(host, port))
            {
                cliente.EnableSsl   = true;
                cliente.Credentials = new NetworkCredential(user, pass);

                var msg = new MailMessage
                {
                    From    = new MailAddress(user, "SIGEFIDD-ZOFRA"),
                    Subject = asunto,
                    Body    = cuerpo,
                    IsBodyHtml = false
                };
                msg.To.Add(destinatario);
                cliente.Send(msg);
            }
        }
    }
}
