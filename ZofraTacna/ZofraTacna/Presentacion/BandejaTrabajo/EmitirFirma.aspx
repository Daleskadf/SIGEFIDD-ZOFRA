<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EmitirFirma.aspx.cs" Inherits="ZofraTacna.Presentacion.EmitirFirma, ZofraTacna" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1"/>
    <title>SIGEFIDD-ZOFRA | Emitir firma</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
    <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        var jqFirmaPeru = jQuery.noConflict(true);
    </script>
    <script src="https://apps.firmaperu.gob.pe/web/clienteweb/firmaperu.min.js"></script>
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
        #firma-peru-overlay{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:9999;display:flex;align-items:center;justify-content:center;display:none;}
        #firma-peru-modal{background:white;padding:30px;border-radius:16px;text-align:center;max-width:500px;box-shadow:0 20px 60px rgba(0,0,0,0.3);}
        #firma-peru-modal h3{margin:0 0 15px 0;color:#1a2a4a;}
        #firma-peru-modal p{margin:0 0 20px 0;color:#666;}
        .spinner{width:40px;height:40px;border:4px solid #e8eaf0;border-top:4px solid #8b1a1a;border-radius:50%;animation:spin 1s linear infinite;margin:0 auto 20px auto;}
        @keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}
        .modal-opciones-firma { position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.6); z-index:9000; display:flex; align-items:center; justify-content:center; display:none; }
        .modal-opciones-content { background:white; padding:25px; border-radius:12px; width:460px; max-width:90%; box-shadow:0 15px 40px rgba(0,0,0,0.2); max-height: 90vh; overflow-y: auto; }
        .modal-opciones-content h3 { margin-top:0; color:#1a2a4a; font-size:18px; border-bottom:1px solid #eef0f8; padding-bottom:10px; margin-bottom:15px; }
        .form-group { margin-bottom:15px; }
        .form-group label { display:block; font-size:13px; font-weight:600; color:#555; margin-bottom:6px; }
        .form-select { width:100%; padding:10px; font-size:14px; border:1px solid #ccc; border-radius:6px; background:#fff; }
        .panel-opcion { display:none; margin-top:15px; padding:15px; background:#f9fafc; border-radius:8px; border:1px solid #eef0f8; }
        .panel-opcion.active { display:block; }
        .btn-accion { display:inline-block; background:linear-gradient(135deg,#1a2a4a,#2a3f6f); color:#fff; border:none; padding:10px 16px; border-radius:6px; font-size:13px; font-weight:700; cursor:pointer; width:100%; text-align:center; box-shadow:0 4px 10px rgba(26,42,74,.2); }
        .btn-accion:hover { background:linear-gradient(135deg,#2a3f6f,#1a2a4a); }
        .btn-secundario { display:inline-block; background:#e8ecf7; color:#1a2a4a; border:none; padding:8px 12px; border-radius:6px; font-size:12px; font-weight:600; cursor:pointer; margin-top:10px; }
        .btn-cerrar-modal { float:right; background:none; border:none; font-size:20px; cursor:pointer; color:#999; }
        .mensaje-error { color:#c0392b; font-size:12px; margin-top:10px; font-weight:600; }
        
        /* Modal Éxito */
        .modal-exito-overlay{display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.6);z-index:9000;align-items:center;justify-content:center}
        .modal-exito-box{background:#fff;border-radius:16px;width:min(400px,92vw);box-shadow:0 24px 64px rgba(0,0,0,.35);overflow:hidden;text-align:center}
        .modal-exito-head{background:linear-gradient(135deg,#2e7d32,#43a047);padding:28px 24px 20px}
        .modal-exito-icon{width:56px;height:56px;background:rgba(255,255,255,.2);border-radius:50%;display:inline-flex;align-items:center;justify-content:center;margin-bottom:12px}
        .modal-exito-icon svg{width:30px;height:30px;fill:#fff}
        .modal-exito-title{color:#fff;font-size:17px;font-weight:700;margin:0}
        .modal-exito-body{padding:20px 24px 24px}
        .modal-exito-msg{font-size:13px;color:#555;margin-bottom:16px;line-height:1.5}
        .modal-exito-bar-wrap{background:#e8f5e9;border-radius:8px;height:6px;overflow:hidden}
        .modal-exito-bar{height:100%;background:linear-gradient(90deg,#2e7d32,#43a047);width:100%;border-radius:8px;transition:width linear}
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
                    <div class="pdf-head">Vista del Documento: <span id="nombreArchivoPdf"><asp:Literal ID="litNombreArchivoTitulo" runat="server"/></span></div>
                    <div class="pdf-frame-wrap">
                        <div class="pdf-float-actions">
                            <button type="button" id="btnLanzarFirma" class="btn-firma" onclick="abrirModalOpcionesFirma()">&#9998; Firmar con Firma Per&uacute;</button>
                        </div>
                        <asp:Panel ID="pnlSinPdf" runat="server" Visible="false" CssClass="pdf-empty">No hay PDF almacenado para este tr&aacute;mite.</asp:Panel>
                        <iframe runat="server" id="ifrPdf" visible="false" title="Visor PDF"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<div id="addComponent"></div>
<div id="modalOpcionesFirma" class="modal-opciones-firma">
    <div class="modal-opciones-content">
        <button type="button" class="btn-cerrar-modal" onclick="cerrarModalOpcionesFirma()">&times;</button>
        <h3>Opciones de Firma</h3>
        <div class="form-group">
            <label>Seleccione el método de firma:</label>
            <select id="ddlMetodoFirma" class="form-select" onchange="cambiarMetodoFirma()">
                <option value="firmaperu">DNIe v3</option>
                <option value="usb">Token USB</option>
            </select>
        </div>
        
        <div id="panelDnie" class="panel-opcion active">
            <h4 style="font-size:13px; color:#1a2a4a; margin-bottom:8px; border-bottom:1px solid #eef0f8; padding-bottom:4px; font-weight:700;">Opción A: Firma Oficial PCM (Automática)</h4>
            <p style="font-size:12px; color:#666; margin-bottom:10px;">Requiere tener el Agente Web de Firma Perú ejecutándose en esta PC.</p>
            <button type="button" class="btn-accion" style="margin-bottom:18px;" onclick="ejecutarFirmaDnie()">Iniciar Firma Perú (Agente Web)</button>
            
            <h4 style="font-size:13px; color:#1a2a4a; margin-bottom:8px; border-bottom:1px solid #eef0f8; padding-bottom:4px; font-weight:700;">Opción B: Aplicación Local (Semiautomática - AHK)</h4>
            <p style="font-size:12px; color:#666; margin-bottom:12px;">Se descargará el PDF en tu carpeta de Descargas y se ejecutará el script de AutoHotkey para cargarlo automáticamente.</p>
            
            <div style="display:flex; flex-direction:column; gap:8px; margin-bottom:12px;">
                <button type="button" class="btn-accion" style="background: linear-gradient(135deg, #1565C0, #1E88E5);" onclick="iniciarFirmaSemiautomatica('firmaperu')">
                    &#128190; 1. Descargar y abrir en Firma Perú (AHK)
                </button>
                <button type="button" class="btn-accion" style="background: linear-gradient(135deg, #2E7D32, #43A047);" onclick="iniciarFirmaSemiautomatica('refirma')">
                    &#128190; 2. Descargar y abrir en ReFirma (AHK)
                </button>
            </div>
            
            <!-- Zona de Subida Manual para AHK -->
            <div id="seccionSubirFirmado" style="border: 2px dashed #cfd8ef; border-radius: 8px; padding: 12px; background: #fafafb; display: none; margin-top: 15px;">
                <h4 style="font-size: 12px; color: #1a2a4a; margin-top:0; margin-bottom: 6px; font-weight:700;">&#8593; Subir PDF Firmado</h4>
                <p style="font-size: 11px; color: #555; margin-bottom: 8px; line-height:1.3;">
                    Una vez firmado el PDF en la aplicación de escritorio y guardado en tu carpeta de descargas, selecciónalo aquí para completar el trámite:
                </p>
                <input type="file" id="fileFirmado" accept=".pdf" class="form-select" style="font-size: 12px; padding: 4px; margin-bottom: 8px; background: #fff;" onchange="actualizarBotonVisualizar()" />
                <button type="button" id="btnVisualizarFirmado" class="btn-accion" style="background: linear-gradient(135deg, #1565c0, #0d47a1); font-size:12px; padding:8px 12px; margin-bottom: 8px; display: none;" onclick="visualizarPdfFirmadoLocal()">
                    &#128065; Visualizar PDF Seleccionado
                </button>
                <button type="button" class="btn-accion" style="background: linear-gradient(135deg,#c0392b,#8b1a1a); font-size:12px; padding:8px 12px;" onclick="subirPdfFirmadoManual()">
                    Completar Firma y Guardar
                </button>
                <div id="msgUploadError" class="mensaje-error" style="display: none; margin-top: 6px; font-size:11px;"></div>
                <div id="msgUploadSuccess" style="display: none; margin-top: 6px; font-size:11px; color: #2e7d32; font-weight:bold;">Subiendo archivo...</div>
            </div>
        </div>
        
        <div id="panelUsb" class="panel-opcion">
            <p style="font-size:13px; color:#666; margin-bottom:10px;">Seleccione su certificado local (asegúrese de tener el token USB conectado):</p>
            <div style="margin-bottom:10px;">
                <asp:DropDownList ID="ddlCertificados" runat="server" CssClass="form-select" />
            </div>
            <asp:Button ID="btnRefrescar" runat="server" Text="Refrescar Certificados" CssClass="btn-secundario" OnClick="btnRefrescar_Click" />
            <div style="margin-top:15px;">
                <asp:Button ID="btnFirmarUsb" runat="server" Text="Firmar con Token USB" CssClass="btn-accion" OnClick="btnFirmarUsb_Click" />
            </div>
            <asp:Label ID="lblErrorUsb" runat="server" CssClass="mensaje-error" />
        </div>
    </div>
</div>
<div id="firma-peru-overlay">
    <div id="firma-peru-modal">
        <div class="spinner"></div>
        <h3>Proceso de Firma Digital</h3>
        <p id="firma-peru-mensaje">Iniciando Firma Perú...</p>
    </div>
</div>
<!-- Modal Éxito Firma -->
<div id="modalExitoFirma" class="modal-exito-overlay" aria-hidden="true">
    <div class="modal-exito-box">
        <div class="modal-exito-head">
            <div class="modal-exito-icon">
                <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
            </div>
            <p class="modal-exito-title">Documento firmado correctamente.</p>
        </div>
        <div class="modal-exito-body">
            <p class="modal-exito-msg">Redirigiendo al Historial en unos segundos&hellip;</p>
            <div class="modal-exito-bar-wrap">
                <div id="barraExitoFirma" class="modal-exito-bar" style="width: 0%;"></div>
            </div>
        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
<script>
var idDocumentoActual = <%= IdDocumentoActual %>;
var baseUrlNgrok = ''; // Pon aquí tu URL de ngrok, ej: 'https://abc123.ngrok.io' (sin barra al final)
var urlParametros = baseUrlNgrok 
    ? baseUrlNgrok + '/Presentacion/BandejaTrabajo/FirmaPeruParametros.ashx?token=<%= TokenActual %>'
    : '<%= new Uri(Request.Url, ResolveUrl("~/Presentacion/BandejaTrabajo/FirmaPeruParametros.ashx?token=")).AbsoluteUri %>' + '<%= TokenActual %>';

function signatureInit() {
    console.log('signatureInit OK');
}

function signatureOk() {
    console.log('signatureOk OK');
    mostrarExitoYRedirigir();
}

function signatureCancel() {
    console.log('signatureCancel');
    alert('Firma cancelada.');
}

function iniciarFirmaDigital() {
    console.log('Iniciando firma para documento:', idDocumentoActual);
    console.log('URL:', urlParametros);
    
    var paramObj = {
        param_url: urlParametros,
        param_token: '<%= TokenActual %>',
        document_extension: 'pdf'
    };
    
    console.log('Parametros:', paramObj);
    
    var json = JSON.stringify(paramObj);
    console.log('JSON:', json);
    
    var base64 = btoa(unescape(encodeURIComponent(json)));
    console.log('Base64:', base64);
    
    try {
        startSignature(48596, base64);
        console.log('startSignature llamado OK');
    } catch (e) {
        console.error('Error:', e);
        alert('Error: ' + e.message);
    }
}

function mostrarExitoYRedirigir() {
    var modal = document.getElementById('modalExitoFirma');
    var barra = document.getElementById('barraExitoFirma');
    if (modal && barra) {
        modal.style.display = 'flex';
        // Iniciar animación de la barra
        setTimeout(function () {
            barra.style.width = '100%';
            barra.style.transition = 'width 2.5s linear';
        }, 50);

        // Redirigir después de 2.5 segundos
        setTimeout(function () {
            window.location.href = '../GestionDocumentos/Historial.aspx';
        }, 2500);
    } else {
        window.location.href = '../GestionDocumentos/Historial.aspx';
    }
}

function abrirModalOpcionesFirma() {
    document.getElementById('modalOpcionesFirma').style.display = 'flex';
    cambiarMetodoFirma();
}

function cerrarModalOpcionesFirma() {
    document.getElementById('modalOpcionesFirma').style.display = 'none';
}

function cambiarMetodoFirma() {
    var ddl = document.getElementById('ddlMetodoFirma');
    var val = ddl.value;
    document.getElementById('panelDnie').classList.remove('active');
    document.getElementById('panelUsb').classList.remove('active');
    
    if(val === 'usb') {
        document.getElementById('panelUsb').classList.add('active');
    } else {
        document.getElementById('panelDnie').classList.add('active');
    }
}

function ejecutarFirmaDnie() {
    cerrarModalOpcionesFirma();
    iniciarFirmaDigital();
}

// Si hay error desde servidor y necesitamos mostrar el modal (opcional, para UX)
function mostrarModalPorError() {
    var errorLabel = document.getElementById('<%= lblErrorUsb.ClientID %>');
    if(errorLabel && errorLabel.innerText.trim() !== "") {
        document.getElementById('ddlMetodoFirma').value = 'usb';
        abrirModalOpcionesFirma();
    }
}

// Flujo Semiautomático con AHK (Firma Perú / ReFirma)
function iniciarFirmaSemiautomatica(protocolo) {
    var spanEl = document.getElementById('nombreArchivoPdf');
    var filename = (spanEl ? spanEl.innerText : '').trim();
    if (!filename || filename === '(sin archivo)') {
        filename = 'documento_' + idDocumentoActual + '.pdf';
    }
    
    // 1. Descargar el archivo PDF
    var downloadUrl = '<%= ResolveUrl("~/Presentacion/BandejaTrabajo/ServirPdf.ashx?idDoc=") %>' + idDocumentoActual;
    var link = document.createElement('a');
    link.href = downloadUrl;
    link.download = filename;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    
    // 2. Mostrar la sección de subida de archivo firmado
    var seccion = document.getElementById('seccionSubirFirmado');
    if (seccion) {
        seccion.style.display = 'block';
    }
    
    // 3. Ejecutar el protocolo para el script de AHK (esperar 1 segundo para iniciar la descarga antes de redirigir)
    setTimeout(function() {
        window.location.href = protocolo + '://' + encodeURIComponent(filename);
    }, 1000);
}

// Subir PDF Firmado Manualmente desde flujo AHK
function subirPdfFirmadoManual() {
    var fileInput = document.getElementById('fileFirmado');
    var msgError = document.getElementById('msgUploadError');
    var msgSuccess = document.getElementById('msgUploadSuccess');
    
    if (msgError) msgError.style.display = 'none';
    if (msgSuccess) msgSuccess.style.display = 'none';
    
    if (!fileInput || fileInput.files.length === 0) {
        if (msgError) {
            msgError.innerText = 'Por favor, seleccione el archivo PDF firmado localmente.';
            msgError.style.display = 'block';
        }
        return;
    }
    
    var file = fileInput.files[0];
    if (file.type !== 'application/pdf' && !file.name.toLowerCase().endsWith('.pdf')) {
        if (msgError) {
            msgError.innerText = 'El archivo debe ser un documento PDF.';
            msgError.style.display = 'block';
        }
        return;
    }
    
    if (msgSuccess) {
        msgSuccess.innerText = 'Subiendo y procesando firma, por favor espere...';
        msgSuccess.style.display = 'block';
    }
    
    var formData = new FormData();
    formData.append('file', file);
    
    var uploadUrl = '<%= ResolveUrl("~/Presentacion/BandejaTrabajo/FirmaPeruSubir.ashx?token=") %>' + '<%= TokenActual %>';
    
    fetch(uploadUrl, {
        method: 'POST',
        body: formData
    })
    .then(function(response) {
        if (response.ok) {
            return response.text();
        } else {
            return response.text().then(function(text) {
                throw new Error(text || 'Error en la subida del servidor.');
            });
        }
    })
    .then(function(text) {
        if (text.trim() === 'OK') {
            if (msgSuccess) msgSuccess.style.display = 'none';
            cerrarModalOpcionesFirma();
            mostrarExitoYRedirigir();
        } else {
            throw new Error(text);
        }
    })
    .catch(function(err) {
        if (msgSuccess) msgSuccess.style.display = 'none';
        if (msgError) {
            msgError.innerText = 'Error: ' + err.message;
            msgError.style.display = 'block';
        }
    });
}

function actualizarBotonVisualizar() {
    var fileInput = document.getElementById('fileFirmado');
    var btnVisualizar = document.getElementById('btnVisualizarFirmado');
    if (fileInput && btnVisualizar) {
        if (fileInput.files.length > 0) {
            btnVisualizar.style.display = 'inline-block';
        } else {
            btnVisualizar.style.display = 'none';
        }
    }
}

function visualizarPdfFirmadoLocal() {
    var fileInput = document.getElementById('fileFirmado');
    var msgError = document.getElementById('msgUploadError');
    if (msgError) msgError.style.display = 'none';
    
    if (!fileInput || fileInput.files.length === 0) {
        if (msgError) {
            msgError.innerText = 'Por favor, seleccione primero el archivo PDF firmado.';
            msgError.style.display = 'block';
        }
        return;
    }
    
    var file = fileInput.files[0];
    if (file.type !== 'application/pdf' && !file.name.toLowerCase().endsWith('.pdf')) {
        if (msgError) {
            msgError.innerText = 'El archivo debe ser un documento PDF.';
            msgError.style.display = 'block';
        }
        return;
    }
    
    try {
        var fileURL = URL.createObjectURL(file);
        window.open(fileURL, '_blank');
    } catch (e) {
        console.error(e);
        if (msgError) {
            msgError.innerText = 'No se pudo visualizar el PDF: ' + e.message;
            msgError.style.display = 'block';
        }
    }
}

window.onload = function() {
    mostrarModalPorError();
};
</script>
</body>
</html>
