<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionarParticipantes.aspx.cs" Inherits="ZofraTacna.Presentacion.GestionarParticipantes" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Gestionar Participantes</title>
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
        .nav-item-logout{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:white;font-size:13px;cursor:pointer;margin-top:auto;text-decoration:none;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1.5px solid #7d1717;margin-bottom:10px;box-shadow:0 6px 16px rgba(139,26,26,.25)}
        .nav-item-logout:hover{background:linear-gradient(135deg,#a32121,#d44736)}
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden}
        .topbar{background:white;padding:0 28px;height:56px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e8eaf0;flex-shrink:0}
        .breadcrumb{font-size:13px;color:#999}.breadcrumb strong{color:#1a2a4a}
        .topbar-right{display:flex;align-items:center;gap:14px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,#1a2a4a,#8b1a1a);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700}
        .user-info{display:flex;align-items:center;gap:8px}.user-name{font-size:14px;font-weight:600;color:#333}
        .role-badge{background:#eef0f8;color:#1a2a4a;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600}
        .content{flex:1;padding:28px;overflow-y:auto}
        /* DOC INFO BANNER */
        .doc-banner{background:white;border-radius:12px;padding:18px 24px;margin-bottom:20px;box-shadow:0 1px 4px rgba(0,0,0,.06);display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;border-left:4px solid #1a2a4a}
        .doc-banner-left h2{font-size:18px;font-weight:700;color:#1a2a4a}
        .doc-banner-left .codigo{font-size:12px;color:#888;margin-top:2px}
        .badge{padding:4px 12px;border-radius:8px;font-size:11px;font-weight:600}
        .badge-estado{background:#e3f2fd;color:#1565c0}
        .badge-firma{background:#ffe0b2;color:#e65100}
        .btn-volver{padding:9px 20px;border:1.5px solid #c9d0de;border-radius:8px;background:white;color:#1a2a4a;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:6px}
        .btn-volver:hover{background:#f4f6fa}
        /* ALERT */
        .alert{padding:12px 16px;border-radius:8px;font-size:13px;font-weight:600;margin-bottom:16px}
        .alert-ok{background:#e8f5e9;color:#2e7d32}
        .alert-err{background:#fdecea;color:#c0392b}
        /* PANELES LADO A LADO */
        .panels{display:flex;gap:20px;align-items:flex-start;flex-wrap:wrap}
        .panel{flex:1;min-width:320px;background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);overflow:hidden}
        .panel-header{padding:16px 20px;border-bottom:1px solid #eef0f8;display:flex;align-items:center;gap:10px}
        .panel-header h3{font-size:14px;font-weight:700;color:#1a2a4a}
        .panel-header svg{width:18px;height:18px;fill:#1a2a4a}
        .panel-body{padding:16px 20px}
        /* FORM AGREGAR */
        .agregar-form{display:flex;gap:8px;margin-bottom:16px;align-items:center;flex-wrap:wrap}
        .agregar-form select{flex:1;min-width:140px;padding:9px 12px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;color:#333;outline:none;font-family:'Segoe UI',sans-serif;background:white}
        .agregar-form select:focus{border-color:#1a2a4a}
        .btn-agregar-p{padding:9px 18px;border:none;border-radius:8px;background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap}
        .btn-agregar-p:hover{opacity:.9}
        /* LISTA DE PARTICIPANTES */
        .part-item{display:flex;align-items:center;gap:8px;padding:10px 12px;border-radius:8px;background:#f8f9fc;margin-bottom:8px;border-left:3px solid #1a2a4a}
        .part-item.est-obs{border-left-color:#c0392b;background:#fff5f5}
        .part-item.est-ok{border-left-color:#2e7d32;background:#f0faf0}
        .part-login{flex:1;font-size:13px;font-weight:600;color:#1a2a4a;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .part-orden{width:26px;height:26px;border-radius:50%;background:#1a2a4a;color:white;font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .part-actions{display:flex;gap:4px;flex-shrink:0}
        .btn-orden{width:28px;height:28px;border:1.5px solid #dde1f0;border-radius:6px;background:white;color:#1a2a4a;font-size:14px;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0;line-height:1}
        .btn-orden:hover:not(:disabled){background:#eef0f8}
        .btn-orden:disabled{opacity:.35;cursor:not-allowed}
        .btn-eliminar-p{padding:4px 10px;border:1.5px solid #fca5a5;border-radius:6px;background:white;color:#c0392b;font-size:11px;font-weight:600;cursor:pointer;white-space:nowrap}
        .btn-eliminar-p:hover{background:#fff0f0}
        .empty-list{text-align:center;padding:24px;color:#bbb;font-size:13px}
        .divider{border:none;border-top:1px solid #eef0f8;margin:12px 0}
        .form-label{font-size:11px;font-weight:700;letter-spacing:.5px;color:#555;margin-bottom:6px;display:block}
        .required{color:#c0392b}
        .form-input{width:100%;padding:11px 13px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;color:#333;font-family:'Segoe UI',sans-serif;outline:none}
        .form-input:focus{border-color:#1a2a4a}
        textarea.form-input{resize:vertical;min-height:88px}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:18px;margin-bottom:18px}
        .form-group{margin-bottom:18px}
        .plazos-box{border:1.5px solid #e8eaf0;border-radius:12px;padding:18px;margin-bottom:18px}
        .plazos-box.plazos-zona-plazos{background:linear-gradient(165deg,#f2faf5 0%,#e3f2e8 45%,#f7fcf9 100%);border-color:#a8d4b8;box-shadow:0 2px 12px rgba(46,125,50,.08)}
        .plazos-box.plazos-zona-plazos .plazos-sub{color:#2e7d32}
        .plazos-box.plazos-zona-asignacion{background:linear-gradient(165deg,#f4f6ff 0%,#e8ecfc 40%,#fafbff 100%);border-color:#b8c4e8;box-shadow:0 2px 14px rgba(26,42,74,.08)}
        .plazos-box.plazos-zona-asignacion .plazos-sub{color:#3949ab}
        .revisores-wrap{background:linear-gradient(180deg,#ffffff 0%,#f2faf5 100%);border:1.5px solid #c8e6c9;border-radius:12px;padding:14px;min-height:120px}
        .revisores-hint{font-size:11px;color:#4a6b55;margin:10px 0 0;line-height:1.4}
        .revisor-card{display:flex;align-items:center;gap:10px;padding:10px 12px;margin-bottom:8px;background:white;border:1.5px solid #b2dfbc;border-radius:10px;box-shadow:0 2px 8px rgba(46,125,50,.08);transition:box-shadow .15s,border-color .15s}
        .revisor-card:last-child{margin-bottom:0}
        .revisor-card:hover{border-color:#2e7d32;box-shadow:0 4px 14px rgba(46,125,50,.12)}
        .revisor-badge{flex-shrink:0;min-width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#2e7d32,#43a047);color:white;font-size:11px;font-weight:800;border-radius:8px;letter-spacing:.5px}
        .revisor-nombre{flex:1;font-size:13px;font-weight:600;color:#1b5e20;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .revisor-btn-quitar{width:30px;height:36px;border:none;background:transparent;color:#c0392b;font-size:20px;font-weight:bold;cursor:pointer;line-height:1;border-radius:6px;flex-shrink:0;align-self:center}
        .revisor-btn-quitar:hover{background:#fdecea;color:#8b1a1a}
        .firmantes-wrap{background:linear-gradient(180deg,#ffffff 0%,#f4f7fd 100%);border:1.5px solid #dbe3f0;border-radius:12px;padding:14px;min-height:120px}
        .firmantes-hint{font-size:11px;color:#5c6b8a;margin:0 0 10px;line-height:1.4}
        .firmante-card{display:flex;align-items:center;gap:10px;padding:10px 12px;margin-bottom:8px;background:white;border:1.5px solid #e0e7f2;border-radius:10px;box-shadow:0 2px 8px rgba(26,42,74,.06);transition:box-shadow .15s,border-color .15s,transform .1s;cursor:grab}
        .firmante-card:last-child{margin-bottom:0}
        .firmante-card:hover{border-color:#1a2a4a;box-shadow:0 4px 14px rgba(26,42,74,.1)}
        .firmante-card.firmante-dragging{opacity:.65;transform:scale(.99);cursor:grabbing;box-shadow:0 8px 24px rgba(26,42,74,.18)}
        .firmante-card.firmante-drag-over{border-color:#8b1a1a;background:#fff8f8}
        .firmante-handle{flex-shrink:0;width:28px;height:36px;display:flex;align-items:center;justify-content:center;color:#8898b8;font-size:16px;letter-spacing:-2px;user-select:none;border-radius:6px;background:#f0f3fa;cursor:grab}
        .firmante-handle:active{cursor:grabbing}
        .firmante-orden{flex-shrink:0;min-width:28px;height:28px;display:flex;align-items:center;justify-content:center;background:linear-gradient(135deg,#1a2a4a,#2a3f6f);color:white;font-size:12px;font-weight:700;border-radius:8px}
        .firmante-nombre{flex:1;font-size:13px;font-weight:600;color:#1a2a4a;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .firmante-actions{display:flex;flex-direction:column;gap:4px;flex-shrink:0}
        .firmante-btn-flecha{width:30px;height:26px;border:1.5px solid #c5d0e8;background:#f8faff;color:#1a2a4a;border-radius:6px;font-size:12px;cursor:pointer;line-height:1;padding:0;font-weight:700}
        .firmante-btn-flecha:hover:not(:disabled){background:#1a2a4a;color:white;border-color:#1a2a4a}
        .firmante-btn-flecha:disabled{opacity:.35;cursor:not-allowed}
        .firmante-btn-quitar{width:30px;height:56px;border:none;background:transparent;color:#c0392b;font-size:20px;font-weight:bold;cursor:pointer;line-height:1;border-radius:6px}
        .firmante-btn-quitar:hover{background:#fdecea;color:#8b1a1a}
        @keyframes spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
        #dropdownResultadosGp{animation:gpSlideDown .15s ease-out;border-left:1.5px solid #1a2a4a !important;border-right:1.5px solid #1a2a4a !important;border-bottom:1.5px solid #1a2a4a !important}
        @keyframes gpSlideDown{from{opacity:0;transform:translateY(-5px)}to{opacity:1;transform:translateY(0)}}
        .empleado-resultado-item{transition:all .15s ease}
        .plazos-title{font-size:14px;font-weight:600;color:#1a2a4a;margin-bottom:4px}
        .plazos-sub{font-size:12px;color:#3b5bdb;margin-bottom:14px}
        .plazos-hint{font-size:11px;color:#888;margin-top:4px}
        .upload-zone{border:2px dashed #b0b8d0;border-radius:10px;padding:28px;text-align:center;cursor:pointer;background:#fafbff;margin-bottom:12px;position:relative}
        .upload-zone:hover{border-color:#1a2a4a;background:#f0f2ff}
        .upload-zone svg{width:32px;height:32px;fill:#aab;margin-bottom:8px}
        .upload-zone .uz-title{font-size:14px;font-weight:500;color:#555;margin-bottom:4px}
        .upload-zone .uz-sub{font-size:12px;color:#aaa}
        .upload-zone input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer}
        .btn-guardar-doc{padding:11px 26px;border-radius:8px;font-size:14px;font-weight:700;cursor:pointer;border:none;background:linear-gradient(90deg,#1a2a4a,#8b1a1a);color:#fff;box-shadow:0 4px 12px rgba(26,42,74,.2)}
        .btn-guardar-doc:hover{filter:brightness(1.05)}
        .guardar-doc-wrap{margin-top:20px;background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);padding:18px 22px;border:1.5px solid #e8eaf0}
        .guardar-doc-wrap p{font-size:12px;color:#63718f;margin:0 0 14px;line-height:1.5;max-width:920px}
        .guardar-doc-actions{display:flex;justify-content:flex-end;flex-wrap:wrap;gap:12px;align-items:center}
        .doc-ayuda{font-size:11px;color:#888;margin-top:6px;line-height:1.45}
        @media (max-width:720px){.form-row{grid-template-columns:1fr}.gp-grid-participantes{grid-template-columns:1fr !important}}
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" enctype="multipart/form-data" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<asp:HiddenField ID="hfDocId" runat="server"/>
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div>
            <div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div>
        </div>
        <nav class="sidebar-nav" style="display:flex;flex-direction:column;height:100%;">
            <div style="flex:1;overflow-y:auto;">
                <a href="../Default.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>Inicio</a>
                <a href="BandejaTrabajo.aspx" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>Bandeja de Trabajo</a>
                <a href="../GestionDocumentos/CargarDocumento.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>Cargar Documento</a>
                <a href="../GestionDocumentos/MisDocumentos.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>Mis Documentos</a>
                <a href="../GestionRoles/GestionRoles.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>Gesti&oacute;n de Roles</a>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click"/>
        </nav>
    </div>
    <!-- MAIN -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / <a href="BandejaTrabajo.aspx" style="color:#999;text-decoration:none">Bandeja de Trabajo</a> / Gestionar Participantes</div>
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
            <!-- BANNER DEL DOCUMENTO -->
            <div class="doc-banner">
                <div class="doc-banner-left">
                    <h2><asp:Literal ID="litAsunto" runat="server"/></h2>
                    <div class="codigo"><asp:Literal ID="litCodigo" runat="server"/></div>
                </div>
                <div style="display:flex;align-items:center;gap:12px;">
                    <asp:Literal ID="litEstadoBadge" runat="server"/>
                    <a href="BandejaTrabajo.aspx" class="btn-volver">
                        <svg viewBox="0 0 24 24" style="width:14px;height:14px;fill:#1a2a4a"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
                        Volver a Bandeja
                    </a>
                </div>
            </div>

            <!-- MENSAJE -->
            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="alert"/>

            <!-- DATOS DEL DOCUMENTO (alineado a Cargar documento) -->
            <div class="panel" style="margin-bottom:20px">
                <div class="panel-header">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                    <h3>Datos del documento</h3>
                </div>
                <div class="panel-body">
                    <p style="font-size:12px;color:#63718f;margin:-4px 0 16px;line-height:1.45">Edite la misma informaci&oacute;n que al cargar un documento (incluidos los plazos por horas). Los revisores y firmantes se gestionan abajo. Use el bot&oacute;n <strong>Guardar datos del documento</strong> (debajo de esos paneles) cuando haya terminado los cambios; el flujo vuelve a <strong>revisi&oacute;n</strong> desde el inicio.</p>
                    <div class="form-group">
                        <label class="form-label">C&Oacute;DIGO DE DOCUMENTO <span class="required">*</span></label>
                        <asp:TextBox ID="txtEditCodigo" runat="server" CssClass="form-input" MaxLength="50" placeholder="Ej: RS-0001-2026"/>
                        <div class="doc-ayuda">Debe ser &uacute;nico en el sistema. Mismo formato que en &laquo;Cargar documento&raquo;.</div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">ASUNTO <span class="required">*</span></label>
                        <asp:TextBox ID="txtEditAsunto" runat="server" CssClass="form-input" placeholder="Asunto del documento"/>
                    </div>
                    <div class="form-group">
                        <label class="form-label">DESCRIPCI&Oacute;N</label>
                        <asp:TextBox ID="txtEditDescripcion" runat="server" TextMode="MultiLine" CssClass="form-input" placeholder="Descripci&oacute;n opcional"/>
                    </div>
                    <div class="form-row">
                        <div>
                            <label class="form-label">CATEGOR&Iacute;A <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlEditCategoria" runat="server" CssClass="form-input"/>
                        </div>
                        <div>
                            <label class="form-label">PRIORIDAD <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlEditPrioridad" runat="server" CssClass="form-input">
                                <asp:ListItem Value="ALTA">Alta</asp:ListItem>
                                <asp:ListItem Value="MEDIA">Media</asp:ListItem>
                                <asp:ListItem Value="BAJA">Baja</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">&Aacute;REA (UNIDAD ORG&Aacute;NICA) <span class="required">*</span></label>
                        <asp:DropDownList ID="ddlEditArea" runat="server" CssClass="form-input"/>
                    </div>
                    <div class="plazos-box plazos-zona-plazos">
                        <div class="plazos-title">Plazos por etapa (desde este momento)</div>
                        <div class="plazos-sub">Al guardar se recalculan las fechas l&iacute;mite a partir de la hora actual, igual que al registrar un documento nuevo.</div>
                        <div class="form-row" style="margin-bottom:0">
                            <div>
                                <label class="form-label">PLAZO REVISI&Oacute;N (HORAS) <span class="required">*</span></label>
                                <asp:TextBox ID="txtEditHorasRevision" runat="server" CssClass="form-input" Text="24"/>
                                <div class="plazos-hint">Tiempo m&aacute;ximo para la fase de revisi&oacute;n</div>
                            </div>
                            <div>
                                <label class="form-label">PLAZO FIRMA (HORAS) <span class="required">*</span></label>
                                <asp:TextBox ID="txtEditHorasFirma" runat="server" CssClass="form-input" Text="48"/>
                                <div class="plazos-hint">Debe ser mayor o igual que el plazo de revisi&oacute;n</div>
                            </div>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">ARCHIVO PDF</label>
                        <asp:Literal ID="litPdfVigente" runat="server"/>
                        <div class="upload-zone" onclick="document.getElementById('<%= filePdfReemplazo.ClientID %>').click()">
                            <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zm-2 8H7v-2h4v2zm6-4H7v-2h10v2z"/></svg>
                            <div class="uz-title">Opcional: nueva versi&oacute;n PDF</div>
                            <div class="uz-sub">Solo PDF, m&aacute;x. 15 MB. La versi&oacute;n vigente queda archivada.</div>
                            <asp:FileUpload ID="filePdfReemplazo" runat="server" style="display:none" accept=".pdf" onchange="gpMostrarNombrePdf(this)"/>
                        </div>
                        <asp:Label ID="lblNombrePdfSeleccionado" runat="server" style="font-size:13px;color:#2e7d32;display:none"/>
                    </div>
                </div>
            </div>

            <!-- Revisores y firmantes (misma experiencia que Cargar documento) -->
            <div class="plazos-box plazos-zona-asignacion" style="margin-bottom:20px">
                <div class="plazos-title">Asignar revisores y firmantes</div>
                <div class="plazos-sub">Se muestran los ya asignados; puede buscar por nombre o login, reordenar firmas y guardar todo con el bot&oacute;n inferior.</div>
                <div style="margin-bottom:20px;position:relative;">
                    <label class="form-label">BUSCAR EMPLEADO</label>
                    <asp:TextBox ID="txtBuscadorParticipantes" runat="server" CssClass="form-input" placeholder="Escriba nombre o login..." AutoComplete="off"/>
                    <div id="dropdownResultadosGp" style="display:none;position:absolute;top:100%;left:0;right:0;background:white;border:1.5px solid #1a2a4a;border-top:none;border-radius:0 0 8px 8px;max-height:280px;overflow-y:auto;z-index:1000;box-shadow:0 8px 16px rgba(0,0,0,0.1);"></div>
                    <asp:ListBox ID="lstBuscadorParticipantes" runat="server" style="display:none;" SelectionMode="Single"/>
                </div>
                <div class="gp-grid-participantes" style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:20px;">
                    <div style="border:1.5px solid rgba(168,212,184,.85);border-radius:10px;padding:16px;background:rgba(255,255,255,.72);">
                        <div style="font-size:13px;font-weight:700;color:#1b5e20;margin-bottom:12px;">&#10003; REVISORES</div>
                        <div id="listaRevisores" class="revisores-wrap" role="list" aria-label="Lista de revisores"></div>
                        <p class="revisores-hint">Quitar en una columna elimina tambi&eacute;n de la otra, igual que en Cargar documento.</p>
                    </div>
                    <div style="border:1.5px solid rgba(184,196,232,.9);border-radius:10px;padding:16px;background:rgba(255,255,255,.72);">
                        <div style="font-size:13px;font-weight:700;color:#1a2a4a;margin-bottom:12px;">&#128271; FIRMANTES (orden de firma)</div>
                        <p class="firmantes-hint">Arrastre las tarjetas o use &#9650; &#9660;. El n&uacute;mero indica la secuencia de firma.</p>
                        <div id="listaFirmantes" class="firmantes-wrap" role="list" aria-label="Lista de firmantes"></div>
                    </div>
                </div>
                <asp:HiddenField ID="hfParticipantes" runat="server" />
            </div>

            <div class="guardar-doc-wrap">
                <p>Confirme aqu&iacute; los datos del documento, los plazos en horas y el PDF (si aplica), <strong>despu&eacute;s</strong> de revisar revisores, firmantes y el orden de firma. Un solo guardado aplica todo y reinicia el proceso de revisi&oacute;n.</p>
                <div class="guardar-doc-actions">
                    <asp:Button ID="btnGuardarMetadatos" runat="server" Text="Guardar datos del documento" CssClass="btn-guardar-doc" OnClick="btnGuardarMetadatos_Click" OnClientClick="return (typeof window.gpValidarAntesGuardar === 'function' ? window.gpValidarAntesGuardar() : true);" CausesValidation="false"/>
                </div>
            </div>

            <!-- HISTORIAL / FLUJO -->
            <div class="panel" style="margin-top:20px;margin-bottom:28px">
                <div class="panel-header">
                    <svg viewBox="0 0 24 24"><path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
                    <h3>Flujo del Documento</h3>
                </div>
                <div class="panel-body" style="max-height:360px;overflow-y:auto">
                    <div style="position:relative;padding-left:4px">
                        <div style="position:absolute;left:11px;top:6px;bottom:8px;width:2px;background:linear-gradient(180deg,#1a2a4a22,#1a2a4a44)"></div>
                        <asp:Literal ID="litHistorial" runat="server"/>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
<script type="text/javascript">
    function gpMostrarNombrePdf(input) {
        var lbl = document.getElementById('<%= lblNombrePdfSeleccionado.ClientID %>');
        if (!lbl) return;
        if (input.files && input.files.length > 0) {
            var f = input.files[0];
            lbl.textContent = 'Seleccionado: ' + f.name + ' (' + (f.size / (1024 * 1024)).toFixed(2) + ' MB)';
            lbl.style.display = 'block';
        } else {
            lbl.textContent = '';
            lbl.style.display = 'none';
        }
    }
    window.GP_IDS = {
        txt: '<%= txtBuscadorParticipantes.ClientID %>',
        lst: '<%= lstBuscadorParticipantes.ClientID %>',
        hf: '<%= hfParticipantes.ClientID %>',
        dd: 'dropdownResultadosGp'
    };
</script>
<script type="text/javascript" src="<%= ResolveUrl("~/Scripts/gestionarParticipantesAsignacion.js") %>"></script>
</form>
</body>
</html>
