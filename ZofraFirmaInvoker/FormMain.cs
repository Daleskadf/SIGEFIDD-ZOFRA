using System;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using System.Windows.Forms;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.security;
using Org.BouncyCastle.Security;

namespace ZofraFirmaInvoker
{
    public partial class FormMain : Form
    {
        private string _url;
        private string _uploadUrl = null;
        private bool _completed = false;
        
        public FormMain(string url)
        {
            InitializeComponent();
            _url = url;
            this.Load += FormMain_Load;
            this.FormClosing += FormMain_FormClosing;
        }

        private void FormMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (!_completed && !string.IsNullOrEmpty(_uploadUrl))
            {
                _completed = true;
                NotificarErrorServidor(_uploadUrl, "cancelado");
            }
        }

        private async void FormMain_Load(object sender, EventArgs e)
        {
            try
            {
                lblStatus.Text = "Iniciando proceso de firma...";
                progressBar.Value = 10;
                
                // 1. Parsear URL zofratacna://[base64_json]
                string base64Json = _url.Replace("zofratacna://", "").Trim('/');
                string jsonString = System.Text.Encoding.UTF8.GetString(Convert.FromBase64String(base64Json));
                var payload = Newtonsoft.Json.JsonConvert.DeserializeObject<dynamic>(jsonString);
                
                string downloadUrl = payload.documentToSign;
                _uploadUrl = payload.uploadDocumentSigned;
                string logoUrl = payload.logoUrl;
                string token = payload.token;

                string pageStr = payload.page ?? "1";
                string xStr = payload.x ?? "0";
                string yStr = payload.y ?? "0";
                string wStr = payload.w ?? "0";
                string hStr = payload.h ?? "0";

                lblStatus.Text = "Descargando documento...";
                progressBar.Value = 30;
                
                // 2. Descargar PDF original e Imagen Logo
                byte[] pdfBytes = await DescargarPdf(downloadUrl);
                if (pdfBytes == null || pdfBytes.Length == 0)
                    throw new Exception("No se pudo descargar el documento original.");
                    
                byte[] logoBytes = null;
                try {
                    if (!string.IsNullOrEmpty(logoUrl))
                        logoBytes = await DescargarPdf(logoUrl); // Reutilizamos DescargarPdf para la imagen
                } catch { }

                lblStatus.Text = "Seleccione su certificado DNIe...";
                progressBar.Value = 50;

                // 3. Seleccionar Certificado de DNIe
                X509Certificate2 cert = SeleccionarCertificado();
                if (cert == null)
                {
                    lblStatus.Text = "Firma cancelada por el usuario.";
                    btnCerrar.Visible = true;
                    _completed = true;
                    NotificarErrorServidor(_uploadUrl, "cancelado");
                    return;
                }
                
                string titular = GetCommonName(cert.Subject);

                lblStatus.Text = "Firmando documento localmente...";
                progressBar.Value = 70;

                // 4. Firmar el PDF
                byte[] pdfFirmado = FirmarPdf(pdfBytes, cert, titular, pageStr, xStr, yStr, wStr, hStr, logoBytes);

                lblStatus.Text = "Subiendo documento firmado al servidor...";
                progressBar.Value = 90;

                // 5. Subir PDF firmado
                bool subidaOk = await SubirPdf(_uploadUrl, pdfFirmado);
                if (!subidaOk)
                    throw new Exception("Error al subir el documento firmado.");

                lblStatus.Text = "¡Firma realizada con éxito!";
                lblStatus.ForeColor = Color.MediumSeaGreen;
                progressBar.Value = 100;
                btnCerrar.Visible = true;
                _completed = true;
            }
            catch (Exception ex)
            {
                lblStatus.Text = "Error: " + ex.Message;
                lblStatus.ForeColor = Color.Salmon;
                btnCerrar.Visible = true;
                _completed = true;
                if (!string.IsNullOrEmpty(_uploadUrl))
                {
                    NotificarErrorServidor(_uploadUrl, "error:" + ex.Message);
                }
            }
        }

        private void NotificarErrorServidor(string uploadUrl, string status)
        {
            if (string.IsNullOrEmpty(uploadUrl)) return;
            try
            {
                int idx = uploadUrl.IndexOf("FirmaPeruSubir.ashx", StringComparison.OrdinalIgnoreCase);
                string verifyUrl = idx >= 0 
                    ? uploadUrl.Substring(0, idx) + "VerificarEstadoFirma.ashx" + uploadUrl.Substring(idx + "FirmaPeruSubir.ashx".Length)
                    : uploadUrl.Replace("FirmaPeruSubir.ashx", "VerificarEstadoFirma.ashx");

                string actionParam = status == "cancelado" ? "cancel" : "error";
                string url = verifyUrl + "&action=" + actionParam;
                if (actionParam == "error")
                {
                    string errMsg = Uri.EscapeDataString(status.Replace("error:", ""));
                    url += "&error=" + errMsg;
                }

                // Deshabilitar la verificación de certificado SSL (para entornos locales, auto-firmados o Azure)
                System.Net.ServicePointManager.ServerCertificateValidationCallback = (sender, cert, chain, errors) => true;

                var request = (System.Net.HttpWebRequest)System.Net.WebRequest.Create(url);
                request.Method = "GET";
                request.Timeout = 10000; // 10 segundos
                using (var response = (System.Net.HttpWebResponse)request.GetResponse())
                {
                    using (var reader = new System.IO.StreamReader(response.GetResponseStream()))
                    {
                        reader.ReadToEnd(); // Consumir respuesta
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Error al notificar al servidor: " + ex.Message);
            }
        }

        private async Task<byte[]> DescargarPdf(string downloadUrl)
        {
            var handler = new HttpClientHandler();
            handler.ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => { return true; };
            using (HttpClient client = new HttpClient(handler))
            {
                var response = await client.GetAsync(downloadUrl);
                response.EnsureSuccessStatusCode();
                return await response.Content.ReadAsByteArrayAsync();
            }
        }

        private async Task<bool> SubirPdf(string uploadUrl, byte[] fileBytes)
        {
            var handler = new HttpClientHandler();
            handler.ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => { return true; };
            using (HttpClient client = new HttpClient(handler))
            {
                var form = new MultipartFormDataContent();
                form.Add(new ByteArrayContent(fileBytes, 0, fileBytes.Length), "file", "documento.pdf");

                var response = await client.PostAsync(uploadUrl, form);
                return response.IsSuccessStatusCode;
            }
        }

        private X509Certificate2 SeleccionarCertificado()
        {
            X509Store store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadOnly);
            try
            {
                X509Certificate2Collection validCerts = store.Certificates.Find(X509FindType.FindByTimeValid, DateTime.Now, false);
                X509Certificate2Collection selected = X509Certificate2UI.SelectFromCollection(
                    validCerts,
                    "Firma Digital",
                    "Seleccione el certificado de su DNI electrónico:",
                    X509SelectionFlag.SingleSelection);

                if (selected.Count > 0)
                    return selected[0];
            }
            finally
            {
                store.Close();
            }
            return null;
        }

        private byte[] FirmarPdf(byte[] inputBytes, X509Certificate2 cert, string titular, string strPage, string strX, string strY, string strW, string strH, byte[] logoBytes)
        {
            using (PdfReader reader = new PdfReader(inputBytes))
            using (MemoryStream outputStream = new MemoryStream())
            {
                PdfStamper stamper = PdfStamper.CreateSignature(reader, outputStream, '\0', null, true); // Append mode
                PdfSignatureAppearance appearance = stamper.SignatureAppearance;
                
                string prefijoFirma = "Firma_DNIe_";
                appearance.Reason = "Firma Oficial ZOFRATACNA (DNIe)";
                appearance.Location = "Tacna, Perú";
                appearance.SignatureCreator = titular;
                
                // Matemática de Posicionamiento copiada de EmitirFirma.aspx.cs
                int pageNum = 1;
                float llx = 36f, lly = 36f, urx = 270f, ury = 100f; // Default
                
                if (int.TryParse(strPage, out int p) && p > 0 && p <= reader.NumberOfPages)
                    pageNum = p;
                    
                if (float.TryParse(strX, NumberStyles.Float, CultureInfo.InvariantCulture, out float relX) && relX >= 0)
                {
                    float relY = float.Parse(strY, CultureInfo.InvariantCulture);
                    float relW = float.Parse(strW, CultureInfo.InvariantCulture);
                    float relH = float.Parse(strH, CultureInfo.InvariantCulture);
                    iTextSharp.text.Rectangle pageSize = reader.GetPageSize(pageNum);
                    
                    int rotation = reader.GetPageRotation(pageNum);
                    if (rotation == 90 || rotation == 270)
                    {
                        pageSize = new iTextSharp.text.Rectangle(pageSize.Height, pageSize.Width);
                    }
                    float pdfX = relX * pageSize.Width;
                    float pdfY = (1 - relY - relH) * pageSize.Height;
                    float pdfW = relW * pageSize.Width;
                    float pdfH = relH * pageSize.Height;
                    llx = pdfX;
                    lly = pdfY;
                    urx = pdfX + pdfW;
                    ury = pdfY + pdfH;
                }

                string fechaFirma = DateTime.Now.ToString("dd/MM/yyyy HH:mm:sszzz");
                string textoFirma = $"Firmado digitalmente por:\n{titular}\nMotivo: Soy el autor del documento\nFecha: {fechaFirma}";
                appearance.Layer2Text = textoFirma;
                
                if (logoBytes != null && logoBytes.Length > 0)
                {
                    try
                    {
                        iTextSharp.text.Image sigImage = iTextSharp.text.Image.GetInstance(logoBytes);
                        appearance.SignatureGraphic = sigImage;
                        appearance.SignatureRenderingMode = PdfSignatureAppearance.RenderingMode.GRAPHIC_AND_DESCRIPTION;
                    }
                    catch { } // Si la imagen es inválida, usar firma de texto simple
                }

                appearance.SetVisibleSignature(new iTextSharp.text.Rectangle(llx, lly, urx, ury), pageNum, prefijoFirma + DateTime.Now.Ticks);

                iTextSharp.text.pdf.security.IExternalSignature externalSignature;
                string oidValue = cert.PublicKey.Oid.Value;

                if (oidValue == "1.2.840.10045.2.1") // ECC (DNIe v3 usually)
                {
                    externalSignature = new ModernCngSignature(cert, "SHA-256");
                }
                else
                {
                    externalSignature = new LegacySmartCardSignature(cert, "SHA-256");
                }
                MakeSignature.SignDetached(appearance, externalSignature,
                    new Org.BouncyCastle.X509.X509Certificate[] { DotNetUtilities.FromX509Certificate(cert) },
                    null, null, null, 0, CryptoStandard.CMS);

                return outputStream.ToArray();
            }
        }
        
        private string GetCommonName(string subject)
        {
            var parts = subject.Split(',');
            foreach (var part in parts)
            {
                var kv = part.Trim().Split('=');
                if (kv.Length == 2 && kv[0] == "CN")
                {
                    return kv[1];
                }
            }
            return subject;
        }

        private void btnCerrar_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        private void FormMain_Load_1(object sender, EventArgs e)
        {

        }
    }

    public class LegacySmartCardSignature : iTextSharp.text.pdf.security.IExternalSignature
    {
        private X509Certificate2 _cert;
        private string _hashAlgorithm;

        public LegacySmartCardSignature(X509Certificate2 cert, string hashAlgorithm)
        {
            _cert = cert;
            _hashAlgorithm = hashAlgorithm;
        }

        public string GetEncryptionAlgorithm() { return "RSA"; }
        public string GetHashAlgorithm() { return _hashAlgorithm; }

        public byte[] Sign(byte[] message)
        {
            try
            {
                using (System.Security.Cryptography.RSA rsa = _cert.GetRSAPrivateKey())
                {
                    if (rsa != null)
                    {
                        string netHashName = _hashAlgorithm.Replace("-", "");
                        return rsa.SignData(message, new System.Security.Cryptography.HashAlgorithmName(netHashName), System.Security.Cryptography.RSASignaturePadding.Pkcs1);
                    }
                }
            }
            catch { }

            System.Security.Cryptography.RSACryptoServiceProvider rsaCsp = null;
            try { rsaCsp = _cert.PrivateKey as System.Security.Cryptography.RSACryptoServiceProvider; }
            catch (Exception ex) { throw new Exception("Fallo al acceder a la llave privada (CAPI): " + ex.Message); }

            if (rsaCsp == null) throw new Exception("No se pudo obtener la llave privada RSA.");

            try
            {
                System.Security.Cryptography.CspParameters csp = new System.Security.Cryptography.CspParameters(1, "Microsoft Base Smart Card Crypto Provider");
                csp.KeyContainerName = rsaCsp.CspKeyContainerInfo.KeyContainerName;
                csp.Flags = System.Security.Cryptography.CspProviderFlags.UseExistingKey;

                using (System.Security.Cryptography.RSACryptoServiceProvider rsaNative = new System.Security.Cryptography.RSACryptoServiceProvider(csp))
                {
                    string oid = System.Security.Cryptography.CryptoConfig.MapNameToOID(_hashAlgorithm.Replace("-", ""));
                    return rsaNative.SignData(message, oid);
                }
            }
            catch
            {
                string oid = System.Security.Cryptography.CryptoConfig.MapNameToOID(_hashAlgorithm.Replace("-", ""));
                return rsaCsp.SignData(message, oid);
            }
        }
    }

    public class ModernCngSignature : iTextSharp.text.pdf.security.IExternalSignature
    {
        private X509Certificate2 _cert;
        private string _hashAlgorithm;

        public ModernCngSignature(X509Certificate2 cert, string hashAlgorithm)
        {
            _cert = cert;
            _hashAlgorithm = hashAlgorithm;
        }

        public string GetEncryptionAlgorithm() { return "ECDSA"; }
        public string GetHashAlgorithm() { return _hashAlgorithm; }

        public byte[] Sign(byte[] message)
        {
            string netHashName = _hashAlgorithm.Replace("-", ""); 
            using (System.Security.Cryptography.ECDsa ecdsa = _cert.GetECDsaPrivateKey())
            {
                if (ecdsa == null) throw new Exception("No se pudo obtener la llave privada ECDSA (CNG).");
                System.Security.Cryptography.HashAlgorithmName hashName = new System.Security.Cryptography.HashAlgorithmName(netHashName);
                byte[] signature = ecdsa.SignData(message, hashName);
                return ConvertP1363ToDer(signature);
            }
        }

        private byte[] ConvertP1363ToDer(byte[] p1363Signature)
        {
            int halfLength = p1363Signature.Length / 2;
            byte[] r = new byte[halfLength];
            byte[] s = new byte[halfLength];
            Array.Copy(p1363Signature, 0, r, 0, halfLength);
            Array.Copy(p1363Signature, halfLength, s, 0, halfLength);

            Org.BouncyCastle.Math.BigInteger rBig = new Org.BouncyCastle.Math.BigInteger(1, r);
            Org.BouncyCastle.Math.BigInteger sBig = new Org.BouncyCastle.Math.BigInteger(1, s);
            
            Org.BouncyCastle.Asn1.DerSequence seq = new Org.BouncyCastle.Asn1.DerSequence(
                new Org.BouncyCastle.Asn1.DerInteger(rBig),
                new Org.BouncyCastle.Asn1.DerInteger(sBig)
            );
            return seq.GetDerEncoded();
        }
    }
}
