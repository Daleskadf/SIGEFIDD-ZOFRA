<%@ Page Language="C#" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Prueba Handlers Firma Perú</title>
    <style>
        body { font-family: 'Segoe UI', Arial; padding: 20px; background: #f5f5f5; }
        .container { max-width: 900px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #1a2a4a; margin-bottom: 20px; }
        .test-section { margin-bottom: 30px; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px; }
        .test-section h3 { color: #8b1a1a; margin-top: 0; }
        .btn { padding: 12px 24px; background: #8b1a1a; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 14px; margin-right: 10px; }
        .btn:hover { background: #a32121; }
        .result { margin-top: 15px; padding: 15px; background: #f8f9fa; border-radius: 6px; font-family: Consolas, monospace; font-size: 12px; white-space: pre-wrap; word-break: break-all; }
        .success { color: #2e7d32; }
        .error { color: #c0392b; }
        .info { color: #1565c0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Prueba de Handlers Firma Perú</h1>

        <div class="test-section">
            <h3>1. Probar FirmaPeruParametros.ashx (GET)</h3>
            <p>Prueba con un token simple:</p>
            <button class="btn" onclick="probarParametros()">Probar Handler</button>
            <div id="result-parametros" class="result"></div>
        </div>

        <div class="test-section">
            <h3>2. Probar FirmaPeruDocumento.ashx</h3>
            <p>Nota: Necesita un idDoc válido en la URL:</p>
            <a href="FirmaPeruDocumento.ashx?idDoc=1" target="_blank" class="btn">Abrir PDF de prueba (idDoc=1)</a>
            <div class="result info">Si el handler funciona, deberías ver un PDF o un mensaje de error.</div>
        </div>

        <div class="test-section">
            <h3>3. URLs de prueba</h3>
            <div class="result info" id="urls-info"></div>
        </div>
    </div>

    <script>
        // Mostrar URLs actuales
        document.getElementById('urls-info').textContent = 
            'URL actual: ' + window.location.href + '\n' +
            'Base URL: ' + window.location.protocol + '//' + window.location.host + '\n' +
            'Path: ' + window.location.pathname;

        function probarParametros() {
            var resultDiv = document.getElementById('result-parametros');
            resultDiv.textContent = 'Cargando...';
            resultDiv.className = 'result info';

            var token = '1_' + Date.now() + '_usuario';
            var url = 'FirmaPeruParametros.ashx?token=' + encodeURIComponent(token);

            console.log('Probando URL:', url);

            fetch(url, {
                method: 'GET',
                credentials: 'same-origin'
            })
            .then(function(response) {
                console.log('Response status:', response.status);
                return response.text().then(function(text) {
                    if (response.ok) {
                        resultDiv.textContent = '✅ Éxito!\n\nStatus: ' + response.status + '\n\nRespuesta:\n' + text;
                        resultDiv.className = 'result success';
                    } else {
                        resultDiv.textContent = '❌ Error!\n\nStatus: ' + response.status + '\n\nRespuesta:\n' + text;
                        resultDiv.className = 'result error';
                    }
                });
            })
            .catch(function(err) {
                console.error('Error:', err);
                resultDiv.textContent = '❌ Error de red:\n' + err.message;
                resultDiv.className = 'result error';
            });
        }
    </script>
</body>
</html>
