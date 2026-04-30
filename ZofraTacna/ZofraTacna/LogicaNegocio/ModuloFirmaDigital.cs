using ZofraTacna.Datos;
using ZofraTacna.Models;

namespace ZofraTacna.LogicaNegocio
{
    public class ModuloFirmaDigital
    {
        private readonly RepositorioDocumentos _repoDoc = new RepositorioDocumentos();

        public bool RegistrarFirma(int idParticipante, string hashFirma)
        {
            var firma = new FirmaDetalle
            {
                IdParticipante   = idParticipante,
                FirmaDigitalHash = hashFirma
            };
            return _repoDoc.InsertarFirma(firma);
        }
    }
}
