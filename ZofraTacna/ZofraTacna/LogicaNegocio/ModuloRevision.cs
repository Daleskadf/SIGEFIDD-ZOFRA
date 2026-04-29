using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloRevision
    {
        private readonly RepositorioDocumentos _repoDoc = new RepositorioDocumentos();

        public bool RegistrarRevision(int idParticipante, string comentario, bool esObservacion)
        {
            var revision = new RevisionDetalle
            {
                IdParticipante = idParticipante,
                Comentario     = comentario,
                EsObservacion  = esObservacion
            };
            return _repoDoc.InsertarRevision(revision);
        }
    }
}
