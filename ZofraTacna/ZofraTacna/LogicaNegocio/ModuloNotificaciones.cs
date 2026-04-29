using ZofraTacna.ServiciosExternos;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloNotificaciones
    {
        private readonly ServicioSMTP _smtp = new ServicioSMTP();

        public void NotificarAsignacion(string destinatario, string asuntoDoc)
        {
            string cuerpo = $"Se le ha asignado el documento: {asuntoDoc}. Ingrese al sistema para revisarlo.";
            _smtp.Enviar(destinatario, "Nuevo documento asignado - SIGEFIDD-ZOFRA", cuerpo);
        }

        public void NotificarVencimiento(string destinatario, string asuntoDoc)
        {
            string cuerpo = $"El plazo del documento '{asuntoDoc}' esta por vencer. Por favor tome accion.";
            _smtp.Enviar(destinatario, "Alerta de plazo - SIGEFIDD-ZOFRA", cuerpo);
        }
    }
}
