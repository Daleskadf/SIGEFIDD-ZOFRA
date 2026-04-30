using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloAuditoria
    {
        private readonly RepositorioAuditoria _repo = new RepositorioAuditoria();

        public void RegistrarCambioEstado(int idDocumento, int? idEstadoAnterior, int idEstadoNuevo, string loginAccion, string detalle)
        {
            var historial = new HistorialDocumento
            {
                IdDocumento        = idDocumento,
                IdEstadoAnterior   = idEstadoAnterior,
                IdEstadoNuevo      = idEstadoNuevo,
                LoginUsuarioAccion = loginAccion,
                DetalleAccion      = detalle
            };
            _repo.InsertarHistorial(historial);
        }

        public void RegistrarError(string capa, string mensaje, string stackTrace, string login)
        {
            _repo.InsertarLogError(capa, mensaje, stackTrace, login);
        }
    }
}
