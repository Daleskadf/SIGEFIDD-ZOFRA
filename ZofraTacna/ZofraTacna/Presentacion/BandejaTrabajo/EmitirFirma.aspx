<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmitirFirma.aspx.cs" Inherits="ZofraTacna.Presentacion.EmitirFirma, ZofraTacna" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Emitir firma</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
    <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}html,body{width:100%;height:100%;overflow:hidden}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;display:flex;height:100vh}
        .sidebar{width:230px;min-width:230px;background:#1a2a4a;display:flex;flex-direction:column;height:100vh}.sidebar-logo{padding:20px 18px 16px;border-bottom:1px solid rgba(255,255,255,.08);display:flex;align-items:center;gap:10px}.logo-icon{width:36px;height:36px;background:linear-gradient(135deg,#2a3f6f,#8b1a1a);border-radius:8px;display:flex;align-items:center;justify-content:center}.logo-icon svg{width:20px;height:20px;fill:white}.logo-text .top{color:white;font-size:13px;font-weight:700;letter-spacing:1px}.logo-text .top span{color:#c0392b}.logo-text .bot{color:rgba(255,255,255,.4);font-size:9px;letter-spacing:1px}
        .sidebar-nav{padding:16px 10px;flex:1;overflow-y:auto;display:flex;flex-direction:column}.nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,.6);font-size:13px;margin-bottom:2px;text-decoration:none}.nav-item:hover{background:rgba(255,255,255,.07);color:white}.nav-item.active{background:linear-gradient(90deg,#2a3f6f,#8b1a1a);color:white}.nav-item svg{width:17px;height:17px;fill:currentColor;flex-shrink:0}.nav-badge{margin-left:auto;background:#c0392b;color:white;border-radius:10px;font-size:10px;padding:1px 6px;font-weight:600}.nav-item-logout{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:white;font-size:13px;cursor:pointer;margin-top:auto;text-decoration:none;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1.5px solid #7d1717;margin-bottom:10px;box-shadow:0 6px 16px rgba(139,26,26,.25)}
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}.topbar{background:white;padding:0 28px;height:56px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e8eaf0;flex-shrink:0}.breadcrumb{font-size:13px;color:#999}.breadcrumb strong{color:#1a2a4a}.topbar-right{display:flex;align-items:center;gap:14px}.user-avatar{width:34px;height:34px;background:linear-gradient(135deg,#1a2a4a,#8b1a1a);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700}.user-info{display:flex;align-items:center;gap:8px}.user-name{font-size:14px;font-weight:600;color:#333}.role-badge{background:#eef0f8;color:#1a2a4a;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600}
        .content{flex:1;padding:24px 28px;overflow:auto}.content h1{font-size:22px;color:#1a2a4a;font-weight:700}.content .sub{font-size:13px;color:#63718f;margin-top:4px;margin-bottom:18px}.content-head{display:flex;justify-content:space-between;align-items:flex-start;gap:14px;margin-bottom:14px}.sub .doc-code{display:inline-block;background:#e8ecf7;color:#1a2a4a;border:1px solid #cfd8ef;border-radius:999px;padding:2px 10px;font-weight:700;margin-right:6px}
        .link-volver{display:inline-flex;align-items:center;justify-content:center;font-size:12px;color:#fff;padding:10px 16px;border-radius:10px;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1px solid #7d1717;text-decoration:none;font-weight:700}
        .emitir-wrap{display:flex;gap:20px;align-items:stretch;min-height:min(720px,calc(100vh - 200px))}.emitir-left{width:min(380px,34vw);min-width:280px;flex-shrink:0;display:flex;flex-direction:column;gap:14px}.emitir-right{flex:1;min-width:0;display:flex;flex-direction:column;background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);overflow:hidden}
        .card-panel{background:white;border-radius:12px;padding:16px 18px;box-shadow:0 1px 4px rgba(0,0,0,.06)}.panel-title{font-size:12px;font-weight:700;color:#1a2a4a;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;padding-bottom:8px;border-bottom:1px solid #eef0f8}.det-grid{display:flex;flex-direction:column;gap:10px}.det-row{display:flex;flex-direction:column;gap:3px;font-size:12px}.det-row .lbl{color:#888;font-size:11px;text-transform:uppercase;letter-spacing:.3px}.det-row .val{color:#333;font-weight:600;word-break:break-word}.det-row .val.mono{font-family:Consolas,'Segoe UI',monospace;font-size:12px;font-weight:500}
        .tiempo-ok{color:#2e7d32;font-weight:700}.tiempo-vencido{color:#c0392b;font-weight:700}.tl-wrap{position:relative;padding-left:4px}.tl-line{position:absolute;left:11px;top:6px;bottom:8px;width:2px;background:linear-gradient(180deg,#1a2a4a22,#1a2a4a44)}.tl-item{position:relative;padding-left:26px;padding-bottom:16px;font-size:12px}.tl-item:last-child{padding-bottom:4px}.tl-dot{position:absolute;left:5px;top:3px;width:12px;height:12px;border-radius:50%;background:#1a2a4a;border:2px solid #fff;box-shadow:0 0 0 1px #dde1f0}.tl-reg .tl-dot{background:#1a2a4a}.tl-estado .tl-dot{background:#5c6bc0}.tl-aprob .tl-dot{background:#2e7d32}.tl-obs .tl-dot{background:#e65100}.tl-time{color:#888;font-size:11px;margin-bottom:4px}.tl-title{font-weight:700;color:#1a2a4a;margin-bottom:4px}.tl-detail{color:#555;line-height:1.45}
        .pdf-head{padding:14px 18px;border-bottom:1px solid #eef0f8;font-size:14px;font-weight:700;color:#1a2a4a;background:#fafbfd}.pdf-frame-wrap{flex:1;min-height:420px;background:#3a3a42;position:relative}.pdf-frame-wrap iframe{display:block;width:100%;height:100%;min-height:420px;border:none}.pdf-empty{display:flex;align-items:center;justify-content:center;height:100%;min-height:320px;color:#aaa;font-size:14px;padding:24px;text-align:center}
        .pdf-float-actions{position:absolute;bottom:18px;right:18px;display:flex;z-index:8}.btn-firma{border:none;border-radius:12px;padding:13px 18px;font-size:13px;font-weight:700;color:#fff;cursor:pointer;box-shadow:0 10px 24px rgba(0,0,0,.3);background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1px solid #7d1717}
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <div class="sidebar">
        <div class="sidebar-logo"><div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div><div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div></div>
        <nav class="sidebar-nav" style="display:flex;flex-direction:column;height:100%;"><div style="flex:1;overflow-y:auto;"><asp:Literal ID="litSidebarNav" runat="server"/></div><asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" /></nav>
    </div>
    <div class="main">
        <div class="topbar"><div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Bandeja de Trabajo / Emitir firma</div><div class="topbar-right"><div class="zfn-bell-wrap"><button type="button" class="zfn-bell-btn" id="zfnBellBtn" aria-label="Notificaciones" aria-expanded="false" aria-controls="zfnBellPanel"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg><span class="zfn-bell-badge" id="zfnBellBadge"></span></button><div id="zfnBellPanel" class="zfn-bell-panel" role="dialog" aria-hidden="true"><div class="zfn-bell-panel-head">Alertas de documentos</div><div class="zfn-bell-panel-body" id="zfnBellPanelBody"></div></div></div><div class="user-info"><div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div><span class="user-name"><asp:Literal ID="litNombre" runat="server"/></span><span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span></div></div></div>
        <div class="content">
            <div class="content-head"><div><h1>Emitir firma</h1><p class="sub"><asp:Literal ID="litSubtituloDoc" runat="server"/></p></div><a class="link-volver" href="BandejaTrabajo.aspx">&larr; Volver a Bandeja de Trabajo</a></div>
            <div class="emitir-wrap">
                <div class="emitir-left">
                    <div class="card-panel"><div class="panel-title">Detalles del documento</div><div class="det-grid"><asp:Literal ID="litDetallesDoc" runat="server"/></div></div>
                    <div class="card-panel" style="flex:1;min-height:200px;display:flex;flex-direction:column"><div class="panel-title">Flujo del documento</div><div class="tl-wrap" style="flex:1;overflow-y:auto;max-height:480px"><div class="tl-line" aria-hidden="true"></div><asp:Literal ID="litLineaTiempo" runat="server"/></div></div>
                </div>
                <div class="emitir-right">
                    <div class="pdf-head">Vista del Documento: <span><asp:Literal ID="litNombreArchivoTitulo" runat="server"/></span></div>
                    <div class="pdf-frame-wrap">
                        <div class="pdf-float-actions"><asp:Button ID="btnEmitirFirma" runat="server" Text="Emitir Firma" CssClass="btn-firma" OnClick="btnEmitirFirma_Click" /></div>
                        <asp:Panel ID="pnlSinPdf" runat="server" Visible="false" CssClass="pdf-empty">No hay PDF almacenado para este tr&aacute;mite.</asp:Panel>
                        <iframe runat="server" id="ifrPdf" visible="false" title="Visor PDF"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
</body>
</html>
