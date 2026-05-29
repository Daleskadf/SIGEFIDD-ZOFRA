using System;
using System.Windows.Forms;

namespace ZofraFirmaInvoker
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Si no hay argumentos, intentamos registrar el protocolo
            if (args.Length == 0)
            {
                try
                {
                    RegistryHelper.RegisterProtocol();
                    MessageBox.Show("Aplicación configurada correctamente.\nEl protocolo zofrafirma:// ha sido registrado.",
                                    "ZofraFirma", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (UnauthorizedAccessException)
                {
                    MessageBox.Show("Para configurar la aplicación por primera vez, por favor ejecútala como Administrador.",
                                    "Permisos insuficientes", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error al configurar: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                return;
            }

            // Si hay argumentos, viene de la URL zofrafirma://...
            string url = args[0];
            Application.Run(new FormMain(url));
        }
    }
}
