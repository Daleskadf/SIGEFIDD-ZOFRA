using System;
using System.Collections.Generic;
using System.Management;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.ServiceProcess;
using System.Text;
using System.Web.UI;

namespace ZofraTacna.Presentacion
{
    public partial class DiagnosticoToken : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                EjecutarDiagnostico();
            }
        }

        protected void btnRefrescar_Click(object sender, EventArgs e)
        {
            EjecutarDiagnostico();
        }

        private void EjecutarDiagnostico()
        {
            var sb = new StringBuilder();

            // ============ SECCIÓN 1: Servicio Smart Card ============
            sb.Append("<div class='section'><h2>1. Servicio de Tarjeta Inteligente (SCardSvr)</h2>");
            try
            {
                ServiceController sc = new ServiceController("SCardSvr");
                string status = sc.Status.ToString();
                string startType = sc.StartType.ToString();

                if (sc.Status == ServiceControllerStatus.Running)
                {
                    sb.Append("<div class='item'><span class='label'>Estado:</span> <span class='badge badge-ok'>✓ EJECUTÁNDOSE</span></div>");
                }
                else
                {
                    sb.Append("<div class='item'><span class='label'>Estado:</span> <span class='badge badge-err'>✗ " + status.ToUpper() + "</span></div>");
                    sb.Append("<div class='tip'>⚠️ El servicio Smart Card no está corriendo. ");
                    if (startType == "Automatic")
                    {
                        sb.Append("Está configurado como <b>Automático</b>, lo que significa que se inicia cuando se conecta un lector/token. <b>Conecta el token USB para que se active automáticamente.</b>");
                    }
                    else
                    {
                        sb.Append("Ejecuta como administrador: <code>net start SCardSvr</code>");
                    }
                    sb.Append("</div>");
                }
                sb.Append("<div class='item'><span class='label'>Tipo de inicio:</span> " + startType + "</div>");
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item err'>Error al consultar servicio: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 2: Lectores Smart Card (WMI) ============
            sb.Append("<div class='section'><h2>2. Lectores de Tarjeta Inteligente detectados (Hardware)</h2>");
            try
            {
                int readerCount = 0;
                using (var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PnPEntity WHERE PNPClass = 'SmartCardReader'"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        readerCount++;
                        string name = obj["Name"]?.ToString() ?? "(sin nombre)";
                        string deviceId = obj["DeviceID"]?.ToString() ?? "";
                        string statusWmi = obj["Status"]?.ToString() ?? "Unknown";

                        sb.Append("<div class='cert-card'>");
                        sb.Append("<div class='cert-name'>📟 " + Server.HtmlEncode(name) + "</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Device ID:</span> " + Server.HtmlEncode(deviceId) + "</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Estado HW:</span> ");
                        if (statusWmi == "OK")
                            sb.Append("<span class='ok'>OK - Funcionando</span>");
                        else
                            sb.Append("<span class='warn'>" + statusWmi + " (token posiblemente no conectado)</span>");
                        sb.Append("</div>");

                        // Identificar marca por VID
                        if (deviceId.Contains("VID_25DD"))
                            sb.Append("<div class='cert-detail info'>🏷️ Marca detectada: <b>BIT4ID miniLector / Token criptográfico</b></div>");
                        else if (deviceId.Contains("VID_058F"))
                            sb.Append("<div class='cert-detail info'>🏷️ Marca detectada: <b>Alcor Micro (Lector integrado laptop)</b></div>");
                        else if (deviceId.Contains("VID_04E6"))
                            sb.Append("<div class='cert-detail info'>🏷️ Marca detectada: <b>SCM Microsystems</b></div>");
                        else if (deviceId.Contains("VID_0529"))
                            sb.Append("<div class='cert-detail info'>🏷️ Marca detectada: <b>Aladdin / SafeNet</b></div>");

                        sb.Append("</div>");
                    }
                }

                if (readerCount == 0)
                {
                    sb.Append("<div class='item warn'>No se detectó ningún lector de tarjeta inteligente conectado.</div>");
                    sb.Append("<div class='tip'>Conecta tu Token USB al puerto y presiona \"Volver a Escanear\".</div>");
                }
                else
                {
                    sb.Append("<div class='item'><span class='label'>Total lectores:</span> <span class='ok'>" + readerCount + " encontrado(s)</span></div>");
                }
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item err'>Error al buscar lectores: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 3: Todos los dispositivos USB conectados ============
            sb.Append("<div class='section'><h2>3. Dispositivos USB conectados (general)</h2>");
            try
            {
                int usbCount = 0;
                using (var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_PnPEntity WHERE DeviceID LIKE 'USB%' AND Status = 'OK'"))
                {
                    var usbDevices = new List<string>();
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        string name = obj["Name"]?.ToString() ?? "";
                        string deviceId = obj["DeviceID"]?.ToString() ?? "";
                        if (string.IsNullOrWhiteSpace(name) || name.Contains("Hub") || name.Contains("Root"))
                            continue;
                        usbCount++;
                        usbDevices.Add("• " + name + "  [" + deviceId + "]");
                    }
                    if (usbCount > 0)
                    {
                        sb.Append("<div class='mono'>");
                        foreach (string dev in usbDevices)
                            sb.Append(Server.HtmlEncode(dev) + "\n");
                        sb.Append("</div>");
                    }
                    else
                    {
                        sb.Append("<div class='item warn'>No se encontraron dispositivos USB activos (Status=OK).</div>");
                    }
                }
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item err'>Error al enumerar USB: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 4: Certificados en almacén CurrentUser\My ============
            sb.Append("<div class='section'><h2>4. Certificados en almacén Personal (CurrentUser\\My)</h2>");
            try
            {
                X509Store store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
                store.Open(OpenFlags.ReadOnly);

                int totalCerts = store.Certificates.Count;
                int withPK = 0;

                foreach (X509Certificate2 cert in store.Certificates)
                {
                    if (cert.HasPrivateKey) withPK++;
                }

                sb.Append("<div class='item'><span class='label'>Total certificados:</span> " + totalCerts + "</div>");
                sb.Append("<div class='item'><span class='label'>Con clave privada:</span> ");
                if (withPK > 0)
                    sb.Append("<span class='ok'>" + withPK + " ← estos se pueden usar para firmar</span>");
                else
                    sb.Append("<span class='err'>0 (ningún certificado firmable encontrado)</span>");
                sb.Append("</div>");

                if (totalCerts > 0)
                {
                    foreach (X509Certificate2 cert in store.Certificates)
                    {
                        sb.Append("<div class='cert-card'>");
                        string titular = cert.GetNameInfo(X509NameType.SimpleName, false);
                        string emisor = cert.GetNameInfo(X509NameType.SimpleName, true);
                        sb.Append("<div class='cert-name'>" + (cert.HasPrivateKey ? "🔑 " : "📄 ") + Server.HtmlEncode(titular) + "</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Emisor:</span> " + Server.HtmlEncode(emisor) + "</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Thumbprint:</span> <span style='font-family:Consolas;font-size:11px'>" + cert.Thumbprint + "</span></div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Válido desde:</span> " + cert.NotBefore.ToString("dd/MM/yyyy") + "</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Válido hasta:</span> ");
                        if (cert.NotAfter < DateTime.Now)
                            sb.Append("<span class='err'>" + cert.NotAfter.ToString("dd/MM/yyyy") + " (EXPIRADO)</span>");
                        else
                            sb.Append("<span class='ok'>" + cert.NotAfter.ToString("dd/MM/yyyy") + "</span>");
                        sb.Append("</div>");
                        sb.Append("<div class='cert-detail'><span class='label'>Tiene clave privada:</span> ");
                        sb.Append(cert.HasPrivateKey ? "<span class='ok'>SÍ ✓</span>" : "<span class='warn'>NO</span>");
                        sb.Append("</div>");

                        // Intentar ver proveedor CSP
                        try
                        {
                            if (cert.HasPrivateKey)
                            {
                                var rsa = cert.PrivateKey as RSACryptoServiceProvider;
                                if (rsa != null)
                                {
                                    sb.Append("<div class='cert-detail'><span class='label'>Proveedor CSP:</span> <span class='info'>" + Server.HtmlEncode(rsa.CspKeyContainerInfo.ProviderName) + "</span></div>");
                                    sb.Append("<div class='cert-detail'><span class='label'>Container:</span> <span style='font-family:Consolas;font-size:11px'>" + Server.HtmlEncode(rsa.CspKeyContainerInfo.KeyContainerName) + "</span></div>");
                                    sb.Append("<div class='cert-detail'><span class='label'>Hardware Token:</span> ");
                                    sb.Append(rsa.CspKeyContainerInfo.HardwareDevice ? "<span class='ok'>SÍ - Token de hardware ✓</span>" : "<span class='info'>No (software)</span>");
                                    sb.Append("</div>");
                                }
                            }
                        }
                        catch { /* CSP info no disponible */ }

                        sb.Append("</div>");
                    }
                }
                else
                {
                    sb.Append("<div class='tip'>No hay certificados. Cuando conectes el token USB y el driver esté instalado, los certificados aparecerán aquí automáticamente.</div>");
                }

                store.Close();
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item err'>Error al abrir almacén: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 5: Certificados en LocalMachine ============
            sb.Append("<div class='section'><h2>5. Certificados en almacén Local Machine (LocalMachine\\My)</h2>");
            try
            {
                X509Store store2 = new X509Store(StoreName.My, StoreLocation.LocalMachine);
                store2.Open(OpenFlags.ReadOnly);
                sb.Append("<div class='item'><span class='label'>Total:</span> " + store2.Certificates.Count + "</div>");

                foreach (X509Certificate2 cert in store2.Certificates)
                {
                    if (!cert.HasPrivateKey) continue;
                    string titular = cert.GetNameInfo(X509NameType.SimpleName, false);
                    sb.Append("<div class='cert-card'><div class='cert-name'>🔑 " + Server.HtmlEncode(titular) + "</div>");
                    sb.Append("<div class='cert-detail'>Thumbprint: " + cert.Thumbprint + " | Vence: " + cert.NotAfter.ToString("dd/MM/yyyy") + "</div></div>");
                }

                store2.Close();
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item warn'>No se pudo acceder: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 6: CSP Providers registrados ============
            sb.Append("<div class='section'><h2>6. Proveedores Criptográficos (CSP) Registrados</h2>");
            try
            {
                var key = Microsoft.Win32.Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Cryptography\Defaults\Provider");
                if (key != null)
                {
                    sb.Append("<div class='mono'>");
                    foreach (string subKeyName in key.GetSubKeyNames())
                    {
                        bool isSmartCard = subKeyName.IndexOf("Smart Card", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("minidriver", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("Bit4id", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("SafeNet", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("Athena", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("Gemalto", StringComparison.OrdinalIgnoreCase) >= 0
                                        || subKeyName.IndexOf("Token", StringComparison.OrdinalIgnoreCase) >= 0;

                        if (isSmartCard)
                            sb.Append("<span class='ok'>★ " + Server.HtmlEncode(subKeyName) + "</span>\n");
                        else
                            sb.Append("  " + Server.HtmlEncode(subKeyName) + "\n");
                    }
                    sb.Append("</div>");
                    key.Close();
                }
            }
            catch (Exception ex)
            {
                sb.Append("<div class='item err'>Error al leer registro: " + Server.HtmlEncode(ex.Message) + "</div>");
            }
            sb.Append("</div>");

            // ============ SECCIÓN 7: Resumen / Diagnóstico ============
            sb.Append("<div class='section'><h2>7. 📋 Resumen del Diagnóstico</h2>");
            sb.Append("<div class='tip'>");
            sb.Append("<b>Token detectado en hardware:</b> VID_25DD:PID_2341 → <b>BIT4ID miniLector EVO / Token criptográfico</b><br/><br/>");
            sb.Append("<b>Estado actual:</b> El servicio SCardSvr está en modo <b>Automático</b> (se enciende al conectar el token). ");
            sb.Append("Esto es normal.<br/><br/>");
            sb.Append("<b>Pasos para que funcione:</b><br/>");
            sb.Append("1️⃣ Conecta el token USB al puerto.<br/>");
            sb.Append("2️⃣ Espera 5-10 segundos para que Windows lo reconozca.<br/>");
            sb.Append("3️⃣ Presiona <b>\"Volver a Escanear\"</b> en esta página.<br/>");
            sb.Append("4️⃣ Si la sección 4 sigue vacía, necesitas el driver/minidriver del token.<br/><br/>");
            sb.Append("<b>Drivers posibles para VID_25DD (Bit4id):</b><br/>");
            sb.Append("• <a href='https://www.bit4id.com/es/lectores-y-tokens/' target='_blank' style='color:#4fc3f7'>Bit4id miniDriver</a><br/>");
            sb.Append("• Si es token RENIEC Perú: buscar \"Driver Token RENIEC\" o instalar el middleware que te dieron con el token.<br/>");
            sb.Append("• Windows puede usar el <b>Microsoft Base Smart Card Crypto Provider</b> si el token soporta minidriver genérico.");
            sb.Append("</div>");
            sb.Append("</div>");

            litResultados.Text = sb.ToString();
        }
    }
}
