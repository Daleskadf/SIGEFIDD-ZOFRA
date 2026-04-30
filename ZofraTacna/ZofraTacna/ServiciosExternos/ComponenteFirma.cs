namespace ZofraTacna.ServiciosExternos
{
    /// <summary>
    /// Wrapper del componente Java ReFirma / Firma Peru.
    /// Pendiente de integracion con el componente real.
    /// </summary>
    public class ComponenteFirma
    {
        public ResultadoFirma FirmarDocumento(string rutaPDF, string certificado)
        {
            // TODO: invocar componente Java via proceso externo o WebService
            return new ResultadoFirma { Exitoso = false, Mensaje = "Componente no integrado aun." };
        }

        public bool ValidarFirma(string rutaPDFFirmado)
        {
            // TODO: validar firma digital con ReFirma/Firma Peru
            return false;
        }
    }

    public class ResultadoFirma
    {
        public bool   Exitoso  { get; set; }
        public string Mensaje  { get; set; }
        public string HashFirma { get; set; }
    }
}
