<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DiagnosticoToken.aspx.cs" Inherits="ZofraTacna.Presentacion.DiagnosticoToken" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <title>Diagnóstico de Token USB</title>
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family:'Segoe UI',sans-serif; background:#0f1923; color:#e0e6ed; padding:30px; }
        h1 { color:#4fc3f7; margin-bottom:8px; font-size:24px; }
        .subtitle { color:#78909c; font-size:13px; margin-bottom:24px; }
        .section { background:#1a2a3a; border:1px solid #263d50; border-radius:10px; padding:18px 20px; margin-bottom:16px; }
        .section h2 { font-size:15px; color:#4fc3f7; margin-bottom:12px; padding-bottom:8px; border-bottom:1px solid #263d50; }
        .ok { color:#66bb6a; font-weight:700; }
        .warn { color:#ffa726; font-weight:700; }
        .err { color:#ef5350; font-weight:700; }
        .info { color:#90caf9; }
        .mono { font-family:Consolas,'Courier New',monospace; font-size:12px; background:#0d1520; padding:12px; border-radius:6px; white-space:pre-wrap; word-break:break-all; line-height:1.7; margin-top:8px; border:1px solid #1e3348; }
        .item { padding:6px 0; border-bottom:1px solid #1e3348; font-size:13px; }
        .item:last-child { border-bottom:none; }
        .label { color:#78909c; display:inline-block; min-width:180px; }
        .badge { display:inline-block; padding:2px 8px; border-radius:4px; font-size:11px; font-weight:700; }
        .badge-ok { background:#1b5e20; color:#a5d6a7; }
        .badge-err { background:#b71c1c; color:#ef9a9a; }
        .badge-warn { background:#e65100; color:#ffcc80; }
        .btn-refresh { background:linear-gradient(135deg,#1565c0,#0d47a1); color:white; border:none; padding:12px 24px; border-radius:8px; font-size:14px; font-weight:700; cursor:pointer; margin-top:16px; }
        .btn-refresh:hover { background:linear-gradient(135deg,#1976d2,#1565c0); }
        .tip { background:#263d50; border-left:4px solid #4fc3f7; padding:12px 16px; border-radius:0 8px 8px 0; margin-top:12px; font-size:12px; line-height:1.6; }
        .cert-card { background:#0d1520; border:1px solid #1e3348; border-radius:8px; padding:14px; margin-bottom:10px; }
        .cert-card .cert-name { color:#4fc3f7; font-weight:700; font-size:13px; margin-bottom:6px; }
        .cert-card .cert-detail { font-size:12px; color:#90a4ae; margin:2px 0; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h1>🔍 Diagnóstico de Token USB / Smart Card</h1>
        <p class="subtitle">Esta página verifica si tu token USB es detectado por el servidor y si sus certificados son accesibles.</p>
        
        <asp:Button ID="btnRefrescar" runat="server" Text="🔄 Volver a Escanear" CssClass="btn-refresh" OnClick="btnRefrescar_Click" />
        
        <div style="margin-top:20px;">
            <asp:Literal ID="litResultados" runat="server" />
        </div>
    </form>
</body>
</html>
