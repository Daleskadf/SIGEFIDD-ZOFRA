<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmitirRevision.aspx.cs" Inherits="ZofraTacna.Presentacion.EmitirRevision, ZofraTacna" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Emitir revisi&oacute;n</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
    <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}html,body{width:100%;height:100%;overflow:hidden}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;display:flex;height:100vh}
        .sidebar{width:230px;min-width:230px;background:#1a2a4a;display:flex;flex-direction:column;height:100vh}
        .sidebar-logo{padding:20px 18px 16px;border-bottom:1px solid rgba(255,255,255,.08);display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:linear-gradient(135deg,#2a3f6f,#8b1a1a);border-radius:8px;display:flex;align-items:center;justify-content:center}
        .logo-icon svg{width:20px;height:20px;fill:white}
        .logo-text .top{color:white;font-size:13px;font-weight:700;letter-spacing:1px}
        .logo-text .top span{color:#c0392b}.logo-text .bot{color:rgba(255,255,255,.4);font-size:9px;letter-spacing:1px}
        .sidebar-nav{padding:16px 10px;flex:1;overflow-y:auto;display:flex;flex-direction:column}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,.6);font-size:13px;margin-bottom:2px;text-decoration:none}
        .nav-item:hover{background:rgba(255,255,255,.07);color:white}.nav-item.active{background:linear-gradient(90deg,#2a3f6f,#8b1a1a);color:white}
        .nav-item svg{width:17px;height:17px;fill:currentColor;flex-shrink:0}
        .nav-badge{margin-left:auto;background:#c0392b;color:white;border-radius:10px;font-size:10px;padding:1px 6px;font-weight:600}
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden;min-width:0}
        .topbar{background:white;padding:0 28px;height:56px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e8eaf0;flex-shrink:0}
        .breadcrumb{font-size:13px;color:#999}.breadcrumb strong{color:#1a2a4a}
        .topbar-right{display:flex;align-items:center;gap:14px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,#1a2a4a,#8b1a1a);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700}
        .user-info{display:flex;align-items:center;gap:8px}.user-name{font-size:14px;font-weight:600;color:#333}
        .role-badge{background:#eef0f8;color:#1a2a4a;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600}
        .nav-item-logout{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:white;font-size:13px;cursor:pointer;margin-top:auto;text-decoration:none;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1.5px solid #7d1717;margin-bottom:10px;box-shadow:0 6px 16px rgba(139,26,26,.25)}
        .nav-item-logout:hover{background:linear-gradient(135deg,#a32121,#d44736)}
        .content{flex:1;padding:24px 28px;overflow:auto}
        .content h1{font-size:22px;color:#1a2a4a;font-weight:700}
        .content .sub{font-size:13px;color:#63718f;margin-top:4px;margin-bottom:18px}
        .content-head{display:flex;justify-content:space-between;align-items:flex-start;gap:14px;margin-bottom:14px}
        .sub .doc-code{display:inline-block;background:#e8ecf7;color:#1a2a4a;border:1px solid #cfd8ef;border-radius:999px;padding:2px 10px;font-weight:700;margin-right:6px}
        .link-volver{display:inline-flex;align-items:center;justify-content:center;font-size:12px;color:#fff;padding:10px 16px;border-radius:10px;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1px solid #7d1717;text-decoration:none;font-weight:700;box-shadow:0 6px 16px rgba(139,26,26,.25);white-space:nowrap}
        .link-volver:hover{background:linear-gradient(135deg,#a32121,#d44736)}
        .emitir-wrap{display:flex;gap:20px;align-items:stretch;min-height:min(720px,calc(100vh - 200px))}
        .emitir-left{width:min(380px,34vw);min-width:280px;flex-shrink:0;display:flex;flex-direction:column;gap:14px}
        .emitir-right{flex:1;min-width:0;display:flex;flex-direction:column;background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);overflow:hidden}
        .card-panel{background:white;border-radius:12px;padding:16px 18px;box-shadow:0 1px 4px rgba(0,0,0,.06)}
        .panel-title{font-size:12px;font-weight:700;color:#1a2a4a;text-transform:uppercase;letter-spacing:.5px;margin-bottom:12px;padding-bottom:8px;border-bottom:1px solid #eef0f8}
        .det-grid{display:flex;flex-direction:column;gap:10px}
        .det-row{display:flex;flex-direction:column;gap:3px;font-size:12px}
        .det-row .lbl{color:#888;font-size:11px;text-transform:uppercase;letter-spacing:.3px}
        .det-row .val{color:#333;font-weight:600;word-break:break-word}
        .det-row .val.mono{font-family:Consolas,'Segoe UI',monospace;font-size:12px;font-weight:500}
        .tiempo-ok{color:#2e7d32;font-weight:700}
        .tiempo-vencido{color:#c0392b;font-weight:700}
        /* Linea de tiempo */
        .tl-wrap{position:relative;padding-left:4px}
        .tl-line{position:absolute;left:11px;top:6px;bottom:8px;width:2px;background:linear-gradient(180deg,#1a2a4a22,#1a2a4a44)}
        .tl-item{position:relative;padding-left:26px;padding-bottom:16px;font-size:12px}
        .tl-item:last-child{padding-bottom:4px}
        .tl-dot{position:absolute;left:5px;top:3px;width:12px;height:12px;border-radius:50%;background:#1a2a4a;border:2px solid #fff;box-shadow:0 0 0 1px #dde1f0}
        .tl-reg .tl-dot{background:#1a2a4a}.tl-estado .tl-dot{background:#5c6bc0}.tl-aprob .tl-dot{background:#2e7d32}.tl-obs .tl-dot{background:#e65100}
        .tl-time{color:#888;font-size:11px;margin-bottom:4px}
        .tl-title{font-weight:700;color:#1a2a4a;margin-bottom:4px}
        .tl-detail{color:#555;line-height:1.45}
        .pdf-head{padding:14px 18px;border-bottom:1px solid #eef0f8;font-size:14px;font-weight:700;color:#1a2a4a;background:#fafbfd}
        .pdf-head span{color:#2a3f6f}
        .pdf-frame-wrap{flex:1;min-height:420px;background:#3a3a42;position:relative}
        .pdf-frame-wrap iframe{display:block;width:100%;height:100%;min-height:420px;border:none}
        .pdf-float-actions{position:absolute;bottom:18px;right:18px;display:flex;flex-direction:column;gap:12px;z-index:8}
        .pdf-float-btn{border:none;border-radius:12px;padding:13px 18px;font-size:13px;font-weight:700;color:#fff;cursor:pointer;box-shadow:0 10px 24px rgba(0,0,0,.3);backdrop-filter:blur(2px);transition:transform .15s ease,opacity .2s ease;min-width:204px;letter-spacing:.2px}
        .pdf-float-btn:hover{transform:translateY(-1px)}
        .btn-conformidad{background:linear-gradient(135deg,#2a3f6f,#1a2a4a);border:1px solid #17243f}
        .btn-observacion{background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1px solid #7d1717}
        .pdf-empty{display:flex;align-items:center;justify-content:center;height:100%;min-height:320px;color:#aaa;font-size:14px;padding:24px;text-align:center}
        .alert-msg{margin-bottom:12px;padding:10px 12px;border-radius:8px;font-size:12px;font-weight:600}
        .alert-ok{background:#e8f5e9;color:#1b5e20;border:1px solid #c8e6c9}
        .alert-err{background:#ffebee;color:#8b1a1a;border:1px solid #ffcdd2}
        .modal-overlay{position:fixed;inset:0;background:rgba(15,24,43,.45);display:none;align-items:center;justify-content:center;z-index:999}
        .modal-box{width:min(460px,92vw);background:#fff;border-radius:14px;box-shadow:0 22px 40px rgba(0,0,0,.28);overflow:hidden}
        .modal-head{padding:14px 16px;background:linear-gradient(135deg,#1a2a4a,#2a3f6f);color:#fff;font-weight:700;font-size:14px}
        .modal-body{padding:18px 16px;color:#444;font-size:13px;line-height:1.5}
        .modal-actions{padding:0 16px 16px;display:flex;justify-content:flex-end;gap:10px}
        .btn-modal{border:none;border-radius:9px;padding:9px 14px;font-size:12px;font-weight:700;cursor:pointer}
        .btn-modal-cancel{background:#eceff6;color:#3f4a64}
        .btn-modal-ok{background:linear-gradient(135deg,#2a3f6f,#1a2a4a);color:#fff}
        .obs-text{width:100%;min-height:120px;resize:vertical;border:1.5px solid #d3daea;border-radius:10px;padding:10px 12px;font-size:13px;color:#2e3445;outline:none}
        .obs-text:focus{border-color:#1a2a4a;box-shadow:0 0 0 3px rgba(26,42,74,.12)}
        .obs-help{font-size:12px;color:#7a849b;margin-top:8px}
        @media (max-width:1024px){.emitir-wrap{flex-direction:column}.emitir-left{width:100%;min-width:0}.pdf-frame-wrap{min-height:50vh}.content-head{flex-direction:column}.link-volver{align-self:flex-end}}
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div>
            <div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div>
        </div>
        <nav class="sidebar-nav" style="display:flex;flex-direction:column;height:100%;">
            <div style="flex:1;overflow-y:auto;">
                <asp:Literal ID="litSidebarNav" runat="server"/>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Bandeja de Trabajo / Emitir revisi&oacute;n</div>
            <div class="topbar-right">
                <div class="zfn-bell-wrap">
                    <button type="button" class="zfn-bell-btn" id="zfnBellBtn" aria-label="Notificaciones" aria-expanded="false" aria-controls="zfnBellPanel">
                        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z"/></svg>
                        <span class="zfn-bell-badge" id="zfnBellBadge"></span>
                    </button>
                    <div id="zfnBellPanel" class="zfn-bell-panel" role="dialog" aria-hidden="true">
                        <div class="zfn-bell-panel-head">Alertas de documentos</div>
                        <div class="zfn-bell-panel-body" id="zfnBellPanelBody"></div>
                    </div>
                </div>
                <div class="user-info">
                    <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server"/></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span>
                </div>
            </div>
        </div>
        <div class="content">
            <asp:Panel ID="pnlMensajeOk" runat="server" Visible="false" CssClass="alert-msg alert-ok"><asp:Literal ID="litMensajeOk" runat="server" /></asp:Panel>
            <asp:Panel ID="pnlMensajeError" runat="server" Visible="false" CssClass="alert-msg alert-err"><asp:Literal ID="litMensajeError" runat="server" /></asp:Panel>
            <div class="content-head">
                <div>
                    <h1>Emitir revisi&oacute;n</h1>
                    <p class="sub"><asp:Literal ID="litSubtituloDoc" runat="server"/></p>
                </div>
                <a class="link-volver" href="BandejaTrabajo.aspx">&larr; Volver a Bandeja de Trabajo</a>
            </div>
            <div class="emitir-wrap">
                <div class="emitir-left">
                    <div class="card-panel">
                        <div class="panel-title">Detalles del documento</div>
                        <div class="det-grid"><asp:Literal ID="litDetallesDoc" runat="server"/></div>
                    </div>
                    <div class="card-panel" style="flex:1;min-height:200px;display:flex;flex-direction:column">
                        <div class="panel-title">Flujo del documento</div>
                        <div class="tl-wrap" style="flex:1;overflow-y:auto;max-height:480px">
                            <div class="tl-line" aria-hidden="true"></div>
                            <asp:Literal ID="litLineaTiempo" runat="server"/>
                        </div>
                    </div>
                </div>
                <div class="emitir-right">
                    <div class="pdf-head">Vista del Documento: <span><asp:Literal ID="litNombreArchivoTitulo" runat="server"/></span></div>
                    <div class="pdf-frame-wrap">
                        <div class="pdf-float-actions" style="<%= ModoBloqueado ? "display:none;" : "" %>">
                            <button class="pdf-float-btn btn-conformidad" type="button" onclick="mostrarConfirmacionConformidad()">Emitir Conformidad</button>
                            <button class="pdf-float-btn btn-observacion" type="button" onclick="mostrarModalObservacion()">Emitir Observaci&oacute;n</button>
                        </div>
                        <asp:Panel ID="pnlSinPdf" runat="server" Visible="false" CssClass="pdf-empty">No hay PDF almacenado para este tr&aacute;mite.</asp:Panel>
                        <iframe runat="server" id="ifrPdf" visible="false" title="Visor PDF"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<asp:Button ID="btnEmitirConformidad" runat="server" style="display:none" OnClick="btnEmitirConformidad_Click" UseSubmitBehavior="false" />
<asp:Button ID="btnEnviarObservacion" runat="server" style="display:none" OnClick="btnEmitirObservacion_Click" UseSubmitBehavior="false" />
<div id="modalConformidad" class="modal-overlay" aria-hidden="true">
    <div class="modal-box">
        <div class="modal-head">Confirmar conformidad</div>
        <div class="modal-body">
            &iquest;Est&aacute;s conforme con la revisi&oacute;n del documento?<br />
            Esta acci&oacute;n guardar&aacute; tu conformidad y continuar&aacute; el flujo del documento.
        </div>
        <div class="modal-actions">
            <button type="button" class="btn-modal btn-modal-cancel" onclick="cerrarModalConformidad()">No</button>
            <button type="button" class="btn-modal btn-modal-ok" onclick="confirmarConformidad()">S&iacute;, conforme</button>
        </div>
    </div>
</div>
<div id="modalObservacion" class="modal-overlay" aria-hidden="true">
    <div class="modal-box">
        <div class="modal-head">Emitir observaci&oacute;n</div>
        <div class="modal-body">
            Ingrese las observaciones encontradas en el documento.
            <asp:TextBox ID="txtObservaciones" runat="server" CssClass="obs-text" TextMode="MultiLine" />
            <div class="obs-help">El comentario es obligatorio para enviar observaciones.</div>
        </div>
        <div class="modal-actions">
            <button type="button" class="btn-modal btn-modal-cancel" onclick="cerrarModalObservacion()">Cancelar</button>
            <button type="button" class="btn-modal btn-modal-ok" onclick="enviarObservacion()">Enviar Observaciones</button>
        </div>
    </div>
</div>
<div id="modalBloqueoRevision" class="modal-overlay" aria-hidden="true" style="<%= ModoBloqueado ? "display:flex;" : "display:none;" %>">
    <div class="modal-box">
        <div class="modal-head">Documento en edición</div>
        <div class="modal-body"><%= System.Web.HttpUtility.HtmlEncode(MensajeBloqueo) %>.</div>
        <div class="modal-actions">
            <button type="button" class="btn-modal btn-modal-ok" onclick="window.location.href='BandejaTrabajo.aspx'">Ok</button>
        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
<script type="text/javascript">
    var emRevIdDocumento = parseInt('<%= Request.QueryString["id"] ?? "0" %>', 10) || 0;
    var emRevToken = '<%= LockToken %>';
    var emRevBloqueado = '<%= ModoBloqueado ? "1" : "0" %>' === '1';
    var emRevHeartbeat = null;
    function mostrarConfirmacionConformidad() {
        var modal = document.getElementById('modalConformidad');
        if (!modal) return;
        modal.style.display = 'flex';
    }
    function cerrarModalConformidad() {
        var modal = document.getElementById('modalConformidad');
        if (!modal) return;
        modal.style.display = 'none';
    }
    function confirmarConformidad() {
        cerrarModalConformidad();
        var btn = document.getElementById('<%= btnEmitirConformidad.ClientID %>');
        if (btn) btn.click();
    }
    function mostrarModalObservacion() {
        var modal = document.getElementById('modalObservacion');
        if (!modal) return;
        modal.style.display = 'flex';
    }
    function cerrarModalObservacion() {
        var modal = document.getElementById('modalObservacion');
        if (!modal) return;
        modal.style.display = 'none';
    }
    function enviarObservacion() {
        var txt = document.getElementById('<%= txtObservaciones.ClientID %>');
        if (!txt || !txt.value || !txt.value.trim()) {
            alert('Debe ingresar las observaciones encontradas en el documento.');
            if (txt) txt.focus();
            return;
        }
        cerrarModalObservacion();
        var btn = document.getElementById('<%= btnEnviarObservacion.ClientID %>');
        if (btn) btn.click();
    }
    window.addEventListener('click', function (e) {
        var modal = document.getElementById('modalConformidad');
        if (modal && e.target === modal) cerrarModalConformidad();
        var modalObs = document.getElementById('modalObservacion');
        if (modalObs && e.target === modalObs) cerrarModalObservacion();
    });

    function emRevEnviarBloqueo(accion) {
        if (emRevBloqueado || !emRevIdDocumento || !emRevToken) return;
        var url = '<%= ResolveUrl("~/Presentacion/BloqueoFlujo.ashx") %>'
            + '?accion=' + encodeURIComponent(accion)
            + '&idDocumento=' + encodeURIComponent(emRevIdDocumento)
            + '&tipo=REV_EDIT'
            + '&token=' + encodeURIComponent(emRevToken);
        try { fetch(url, { method: 'GET', credentials: 'same-origin', keepalive: accion === 'release' }); } catch (e) { }
    }

    window.addEventListener('load', function () {
        if (!emRevBloqueado) {
            emRevEnviarBloqueo('touch');
            emRevHeartbeat = setInterval(function () { emRevEnviarBloqueo('touch'); }, 15000);
        }
    });

    window.addEventListener('beforeunload', function () {
        if (emRevHeartbeat) {
            clearInterval(emRevHeartbeat);
            emRevHeartbeat = null;
        }
        emRevEnviarBloqueo('release');
    });
</script>
</body>
</html>
