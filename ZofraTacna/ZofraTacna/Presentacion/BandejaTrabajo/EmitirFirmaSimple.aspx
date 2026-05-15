<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmitirFirmaSimple.aspx.cs" Inherits="ZofraTacna.Presentacion.EmitirFirmaSimple" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Firma Perú Simple</title>
    <script src="https://apps.firmaperu.gob.pe/web/clienteweb/firmaperu.min.js"></script>
    <style>
        body { font-family: Arial, sans-serif; padding: 40px; max-width: 800px; margin: 0 auto; }
        h1 { color: #1a2a4a; }
        .btn-firmar { background: #8b1a1a; color: white; border: none; padding: 15px 30px; font-size: 16px; border-radius: 8px; cursor: pointer; margin: 20px 0; }
        .info { background: #e8ecf7; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .log { background: #f5f5f5; padding: 15px; border-radius: 8px; font-family: monospace; font-size: 12px; max-height: 300px; overflow-y: auto; }
    </style>
</head>
<body>
    <h1>Firma Perú - Integración Simple</h1>
    
    <div class="info">
        <p><strong>Documento ID:</strong> <%= IdDocumentoActual %></p>
        <p><strong>Token:</strong> <%= TokenActual %></p>
        <p><strong>URL Parametros:</strong> <span id="spanUrl"></span></p>
    </div>
    
    <button class="btn-firmar" onclick="iniciarFirma()">Firmar Documento</button>
    
    <div class="log" id="log"></div>
    
    <script>
        var idDoc = <%= IdDocumentoActual %>;
        var token = '<%= TokenActual %>';
        var urlParams = '<%= new Uri(Request.Url, ResolveUrl("~/Presentacion/BandejaTrabajo/FirmaPeruParametros.ashx")).AbsoluteUri %>';
        
        document.getElementById('spanUrl').textContent = urlParams;
        
        function log(msg) {
            var el = document.getElementById('log');
            el.innerHTML += '[' + new Date().toLocaleTimeString() + '] ' + msg + '<br>';
            el.scrollTop = el.scrollHeight;
            console.log(msg);
        }
        
        function signatureInit() {
            log('signatureInit() llamado');
        }
        
        function signatureOk() {
            log('signatureOk() llamado - ¡Firma completada!');
            alert('¡Firma completada exitosamente!');
        }
        
        function signatureCancel() {
            log('signatureCancel() llamado');
            alert('Firma cancelada.');
        }
        
        function iniciarFirma() {
            log('=== Iniciando firma ===');
            
            var paramObj = {
                param_url: urlParams,
                param_token: token,
                document_extension: 'pdf'
            };
            
            log('Parametros objeto: ' + JSON.stringify(paramObj));
            
            var json = JSON.stringify(paramObj);
            log('JSON: ' + json);
            
            var base64 = btoa(unescape(encodeURIComponent(json)));
            log('Base64: ' + base64);
            
            log('Llamando a startSignature(48596, ...)');
            
            try {
                startSignature(48596, base64);
                log('startSignature llamado exitosamente');
            } catch (e) {
                log('ERROR: ' + e.message);
                alert('Error: ' + e.message);
            }
        }
    </script>
</body>
</html>
