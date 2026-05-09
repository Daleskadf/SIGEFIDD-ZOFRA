<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DevolverDocumento.aspx.cs" Inherits="ZofraTacna.Presentacion.DevolverDocumento" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Devolver Documento</title>
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
        .doc-banner{background:white;border-radius:12px;padding:18px 24px;margin-bottom:24px;box-shadow:0 1px 4px rgba(0,0,0,.06);display:flex;align-items:center;justify-content:space-between;gap:16px;flex-wrap:wrap;border-left:4px solid #c0392b}
        .doc-banner-left h2{font-size:18px;font-weight:700;color:#1a2a4a}
        .doc-banner-left .codigo{font-size:12px;color:#888;margin-top:2px}
        .badge{padding:4px 12px;border-radius:8px;font-size:11px;font-weight:600}
        .badge-estado{background:#e3f2fd;color:#1565c0}
        .badge-firma{background:#ffe0b2;color:#e65100}
        .btn-volver{padding:9px 20px;border:1.5px solid #c9d0de;border-radius:8px;background:white;color:#1a2a4a;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:6px}
        .btn-volver:hover{background:#f4f6fa}
        .card{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);max-width:600px}
        .card-header{padding:18px 24px;border-bottom:1px solid #fdecea;background:#fff8f8;border-radius:12px 12px 0 0;display:flex;align-items:center;gap:10px}
        .card-header svg{width:20px;height:20px;fill:#c0392b}
        .card-header h3{font-size:15px;font-weight:700;color:#c0392b}
        .card-body{padding:24px}
        .alert{padding:12px 16px;border-radius:8px;font-size:13px;font-weight:600;margin-bottom:16px}
        .alert-err{background:#fdecea;color:#c0392b}
        .field-label{font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:6px;font-weight:600}
        .info-box{background:#f8f9fc;border-radius:8px;padding:14px 16px;margin-bottom:20px;font-size:13px;color:#555;line-height:1.6}
        .info-box strong{color:#1a2a4a}
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<asp:HiddenField ID="hfDocId" runat="server"/>
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
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
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / <a href="BandejaTrabajo.aspx" style="color:#999;text-decoration:none">Bandeja de Trabajo</a> / Devolver Documento</div>
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

            <asp:Panel ID="pnlNoPermitido" runat="server" Visible="false">
                <div class="card">
                    <div class="card-body">
                        <p style="font-size:14px;color:#888;text-align:center;padding:20px 0">Este documento no puede ser devuelto en su estado actual.</p>
                    </div>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlFormDevolver" runat="server" Visible="false">
                <div class="card">
                    <div class="card-header">
                        <svg viewBox="0 0 24 24"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
                        <h3>Devolver al Registrador</h3>
                    </div>
                    <div class="card-body">
                        <div class="info-box">
                            Los revisores y firmantes asignados quedar&aacute;n <strong>inactivos</strong> y el documento volver&aacute; a estado <strong>Observado</strong>. El registrador podr&aacute; corregirlo y reenviarlo.
                        </div>
                        <asp:Literal ID="litMsg" runat="server"/>
                        <label class="field-label">Motivo de la devoluci&oacute;n <span style="color:#c0392b">*</span></label>
                        <asp:TextBox ID="txtMotivo" runat="server" TextMode="MultiLine" Rows="4"
                            style="width:100%;padding:10px 12px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif;resize:vertical;margin-bottom:16px"
                            placeholder="Describa el motivo por el cual se devuelve el documento..."/>
                        <asp:Button ID="btnDevolver" runat="server" Text="Confirmar Devoluci&#243;n"
                            OnClick="btnDevolver_Click"
                            OnClientClick="return confirm('¿Confirma la devolución? Los participantes asignados quedarán inactivos.');"
                            CausesValidation="false"
                            style="padding:11px 28px;background:linear-gradient(90deg,#8b1a1a,#c0392b);color:white;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer"/>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
</body>
</html>
