<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VisualizarFirmantes.aspx.cs" Inherits="ZofraTacna.Presentacion.VisualizarFirmantes" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Visualizar Firmantes</title>
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
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden}
        .topbar{background:white;padding:0 28px;height:56px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e8eaf0;flex-shrink:0}
        .breadcrumb{font-size:13px;color:#999}.breadcrumb strong{color:#1a2a4a}
        .topbar-right{display:flex;align-items:center;gap:14px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,#1a2a4a,#8b1a1a);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700}
        .user-info{display:flex;align-items:center;gap:8px}.user-name{font-size:14px;font-weight:600;color:#333}
        .role-badge{background:#eef0f8;color:#1a2a4a;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600}
        .nav-item-logout{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:white;font-size:13px;cursor:pointer;margin-top:auto;text-decoration:none;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1.5px solid #7d1717;margin-bottom:10px;box-shadow:0 6px 16px rgba(139,26,26,.25)}
        .nav-item-logout:hover{background:linear-gradient(135deg,#a32121,#d44736)}
        .btn-logout{padding:6px 16px;border:1.5px solid #ddd;border-radius:6px;background:white;color:#555;font-size:13px;cursor:pointer}
        .content{flex:1;padding:28px;overflow-y:auto}
        .content h1{font-size:24px;color:#1a2a4a;font-weight:700}
        .content .sub{font-size:13px;color:#888;margin-top:2px;margin-bottom:24px}
        /* DOC FIRMANTE CARDS */
        .doc-card{background:white;border-radius:12px;padding:22px 24px;margin-bottom:18px;box-shadow:0 1px 4px rgba(0,0,0,.06)}
        .doc-card-header{display:flex;align-items:flex-start;justify-content:space-between;margin-bottom:14px}
        .doc-nombre{font-size:16px;font-weight:700;color:#1a2a4a}
        .badge{border-radius:10px;padding:3px 10px;font-size:11px;font-weight:600;display:inline-block;flex-shrink:0}
        .badge-pen,.badge-fpar{background:#f5eeff;color:#6b21a8;border:1px solid #d8b4fe}
        .badge-rev{background:#e8f0ff;color:#1a56db;border:1px solid #b3c6ff}
        .badge-fcom{background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9}
        .badge-obs{background:#fff3e0;color:#e65100;border:1px solid #ffcc80}
        .badge-reg{background:#f0f2f8;color:#555;border:1px solid #d0d4e8}
        .orden-label{font-size:12px;font-weight:700;color:#888;text-transform:uppercase;letter-spacing:.4px;margin-bottom:10px}
        .firmante-row{display:flex;align-items:center;gap:12px;padding:8px 0;border-bottom:1px solid #f4f5fa}
        .firmante-row:last-of-type{border-bottom:none}
        .firmante-num{width:32px;height:32px;border-radius:50%;background:linear-gradient(135deg,#1a2a4a,#2a4a8a);color:white;font-size:12px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0}
        .firmante-info{flex:1}
        .firmante-login{font-weight:600;color:#1a2a4a;font-size:13px}
        .firmante-email{color:#aaa;font-size:11px}
        .firmante-status-ok{color:#2e7d32;font-size:13px;font-weight:600;white-space:nowrap}
        .firmante-status-pen{color:#aaa;font-size:13px;font-weight:500;white-space:nowrap}
        /* PROGRESS BAR */
        .progress-wrap{margin:14px 0 16px}
        .progress-label{font-size:12px;color:#888;margin-bottom:6px;font-weight:600}
        .progress-bar-bg{background:#eef0f8;border-radius:6px;height:8px;overflow:hidden}
        .progress-bar-fill{background:linear-gradient(90deg,#1a2a4a,#2a4a8a);height:8px;border-radius:6px;transition:width .3s}
        .progress-text{font-size:12px;color:#888;margin-top:4px}
        .btn-ver{padding:8px 20px;border:1.5px solid #dde1f0;border-radius:7px;background:white;color:#1a2a4a;font-size:13px;font-weight:600;cursor:pointer}
        .empty{text-align:center;padding:60px;color:#aaa;font-size:14px;background:white;border-radius:12px}
    </style>
</head>
<body>
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div>
            <div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div>
        </div>
        <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1; overflow-y: auto;">
                <a href="../../Default.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>Inicio</a>
                <a href="../BandejaTrabajo/BandejaTrabajo.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>Bandeja de Trabajo<span class="nav-badge"><asp:Literal ID="litBadge" runat="server"/></span></a>
                <a href="../GestionDocumentos/CargarDocumento.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>Cargar Documento</a>
                <a href="../GestionDocumentos/MisDocumentos.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>Mis Documentos</a>
                <a href="../GestionRoles/GestionRoles.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>Gesti&oacute;n de Roles</a>
                <a href="VisualizarFirmantes.aspx" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>Visualizar Firmantes</a>
                <a href="#" class="nav-item"><svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg>Estado del Sistema</a>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>
    <!-- MAIN -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Visualizar Firmantes</div>
            <div class="topbar-right">
                <div class="user-info">
                    <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server"/></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span>
                </div>
            </div>
        </div>
        <div class="content">
            <h1>Visualizar Firmantes</h1>
            <p class="sub">Estado de firmas por documento</p>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                <div class="empty">No hay documentos con firmantes asignados.</div>
            </asp:Panel>

            <asp:Repeater ID="rptDocumentos" runat="server">
                <ItemTemplate>
                    <div class="doc-card">
                        <div class="doc-card-header">
                            <div class="doc-nombre"><%# System.Web.HttpUtility.HtmlEncode(Eval("Asunto").ToString()) %></div>
                            <span class='badge <%# Eval("BadgeCss") %>'><%# System.Web.HttpUtility.HtmlEncode(Eval("EstadoDesc").ToString()) %></span>
                        </div>
                        <div class="orden-label">Orden de Firmantes:</div>
                        <%# Eval("FirmantesHtml") %>
                        <div class="progress-wrap">
                            <div class="progress-label">Progreso</div>
                            <div class="progress-bar-bg">
                                <div class="progress-bar-fill" style='width:<%# Eval("PorcentajeStr") %>%'></div>
                            </div>
                            <div class="progress-text"><%# Eval("FirmadosCount") %> / <%# Eval("TotalCount") %> firmantes</div>
                        </div>
                        <button type="button" class="btn-ver">Ver Detalles</button>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>
</form>
</body>
</html>
