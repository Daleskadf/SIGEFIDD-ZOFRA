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
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<asp:HiddenField ID="hfDocId" runat="server"/>
<asp:HiddenField ID="hfReasignarId" runat="server"/>
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

            <!-- PANELES -->
            <div class="panels">

                <!-- PANEL REVISORES -->
                <div class="panel">
                    <div class="panel-header">
                        <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                        <h3>Revisores Asignados</h3>
                    </div>
                    <div class="panel-body">
                        <!-- Agregar revisor -->
                        <div class="agregar-form">
                            <asp:DropDownList ID="ddlRevisor" runat="server" CssClass="agregar-form select"/>
                            <asp:Button ID="btnAgregarRevisor" runat="server" Text="+ Agregar" CssClass="btn-agregar-p" OnClick="btnAgregarRevisor_Click" CausesValidation="false"/>
                        </div>
                        <hr class="divider"/>
                        <!-- Lista actual -->
                        <asp:Panel ID="pnlRevisoresVacio" runat="server" Visible="false">
                            <div class="empty-list">Sin revisores asignados</div>
                        </asp:Panel>
                        <asp:Repeater ID="rptRevisores" runat="server" OnItemCommand="rptRevisores_ItemCommand">
                            <ItemTemplate>
                                <div class='part-item <%# Eval("EstadoCss") %>'>
                                    <span class="part-login"><%# System.Web.HttpUtility.HtmlEncode(Eval("Login").ToString()) %></span>
                                    <div class="part-actions">
                                        <asp:LinkButton runat="server" CommandName="Reasignar" CommandArgument='<%# Eval("IdParticipante") + "|" + Eval("Login") %>' CssClass="btn-orden" title="Reasignar" style="width:auto;padding:4px 8px;font-size:11px;font-weight:600;color:#1a2a4a">&#8635; Reasignar</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IdParticipante") %>' CssClass="btn-eliminar-p" OnClientClick="return confirm('¿Eliminar este revisor?')">Eliminar</asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlReasignar" runat="server" Visible="false">
                            <hr class="divider"/>
                            <div style="background:#f0f4ff;border:1.5px solid #c5d0f0;border-radius:8px;padding:14px;margin-top:8px">
                                <p style="font-size:12px;font-weight:700;color:#1a2a4a;margin-bottom:8px">&#8635; Reasignar revisor: <asp:Literal ID="litReasignarLogin" runat="server"/></p>
                                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap">
                                    <asp:DropDownList ID="ddlReasignarNuevo" runat="server" style="flex:1;min-width:140px;padding:9px 12px;border:1.5px solid #c5d0f0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif;background:white"/>
                                    <asp:Button ID="btnConfirmarReasignacion" runat="server" Text="Confirmar" OnClick="btnConfirmarReasignacion_Click" CausesValidation="false"
                                        style="padding:9px 16px;border:none;border-radius:8px;background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;font-size:13px;font-weight:600;cursor:pointer"/>
                                    <asp:LinkButton runat="server" OnClick="btnCancelarReasignacion_Click" CausesValidation="false"
                                        style="font-size:12px;color:#888;cursor:pointer;text-decoration:underline">Cancelar</asp:LinkButton>
                                </div>
                            </div>
                        </asp:Panel>
                    </div>
                </div>

                <!-- PANEL FIRMANTES -->
                <div class="panel">
                    <div class="panel-header">
                        <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z"/></svg>
                        <h3>Firmantes y Orden de Firma</h3>
                    </div>
                    <div class="panel-body">
                        <!-- Agregar firmante -->
                        <div class="agregar-form">
                            <asp:DropDownList ID="ddlFirmante" runat="server" CssClass="agregar-form select"/>
                            <asp:Button ID="btnAgregarFirmante" runat="server" Text="+ Agregar" CssClass="btn-agregar-p" OnClick="btnAgregarFirmante_Click" CausesValidation="false"/>
                        </div>
                        <hr class="divider"/>
                        <!-- Lista actual con orden -->
                        <asp:Panel ID="pnlFirmantesVacio" runat="server" Visible="false">
                            <div class="empty-list">Sin firmantes asignados</div>
                        </asp:Panel>
                        <asp:Repeater ID="rptFirmantes" runat="server" OnItemCommand="rptFirmantes_ItemCommand">
                            <ItemTemplate>
                                <div class="part-item">
                                    <span class="part-orden"><%# Eval("Orden") %></span>
                                    <span class="part-login"><%# System.Web.HttpUtility.HtmlEncode(Eval("Login").ToString()) %></span>
                                    <div class="part-actions">
                                        <asp:LinkButton runat="server" CommandName="Subir" CommandArgument='<%# Eval("IdParticipante") %>' CssClass="btn-orden" title="Subir orden" Enabled='<%# (bool)Eval("PuedeSubir") %>'>&#8593;</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="Bajar" CommandArgument='<%# Eval("IdParticipante") %>' CssClass="btn-orden" title="Bajar orden" Enabled='<%# (bool)Eval("PuedeBajar") %>'>&#8595;</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IdParticipante") %>' CssClass="btn-eliminar-p" OnClientClick="return confirm('¿Eliminar este firmante?')">Eliminar</asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

            </div>

            <!-- AMPLIAR PLAZO -->
            <div class="panel" style="margin-top:20px">
                <div class="panel-header">
                    <svg viewBox="0 0 24 24"><path d="M17 12h-5v5h5v-5zM16 1v2H8V1H6v2H5c-1.11 0-1.99.9-1.99 2L3 19c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2h-1V1h-2zm3 18H5V8h14v11z"/></svg>
                    <h3>Ampliar Plazo de Revisi&oacute;n</h3>
                </div>
                <div class="panel-body">
                    <asp:Literal ID="litPlazosActuales" runat="server"/>
                    <asp:Literal ID="litMsgAmpliacion" runat="server"/>
                    <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:12px">
                        <div style="flex:1;min-width:200px">
                            <label style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:4px">Nueva fecha l&iacute;m. revisi&oacute;n</label>
                            <asp:TextBox ID="txtNuevaFechaRevision" runat="server" TextMode="DateTimeLocal"
                                style="width:100%;padding:8px 10px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif"/>
                        </div>
                        <div style="flex:1;min-width:200px">
                            <label style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:4px">Nueva fecha l&iacute;m. aprobaci&oacute;n / firma</label>
                            <asp:TextBox ID="txtNuevaFechaAprobacion" runat="server" TextMode="DateTimeLocal"
                                style="width:100%;padding:8px 10px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif"/>
                        </div>
                    </div>
                    <div style="margin-bottom:12px">
                        <label style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:4px">Motivo de la ampliaci&oacute;n</label>
                        <asp:TextBox ID="txtMotivoAmpliacion" runat="server" TextMode="MultiLine" Rows="2"
                            style="width:100%;padding:10px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif;resize:vertical"
                            placeholder="Motivo de la ampliaci&oacute;n..."/>
                    </div>
                    <asp:Button ID="btnAmpliarPlazo" runat="server" Text="Confirmar Ampliaci&#243;n"
                        OnClick="btnAmpliarPlazo_Click"
                        OnClientClick="return confirm('¿Confirma la ampliación de plazos?');"
                        CausesValidation="false"
                        style="padding:10px 24px;background:linear-gradient(90deg,#1a6b9a,#2196f3);color:white;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer"/>
                </div>
            </div>

            <!-- EDITAR METADATOS -->
            <div class="panel" style="margin-top:20px">
                <div class="panel-header">
                    <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a1 1 0 0 0 0-1.41l-2.34-2.34a1 1 0 0 0-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>
                    <h3>Editar Metadatos del Documento</h3>
                </div>
                <div class="panel-body">
                    <asp:Literal ID="litMsgMetadatos" runat="server"/>
                    <div style="display:flex;gap:16px;flex-wrap:wrap;margin-bottom:12px">
                        <div style="flex:2;min-width:240px">
                            <label style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:4px">Asunto</label>
                            <asp:TextBox ID="txtEditAsunto" runat="server"
                                style="width:100%;padding:8px 10px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif"/>
                        </div>
                        <div style="flex:1;min-width:160px">
                            <label style="font-size:11px;color:#888;text-transform:uppercase;letter-spacing:.3px;display:block;margin-bottom:4px">Prioridad</label>
                            <asp:DropDownList ID="ddlEditPrioridad" runat="server"
                                style="width:100%;padding:8px 10px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;font-family:'Segoe UI',sans-serif;background:white">
                                <asp:ListItem Value="ALTA">Alta</asp:ListItem>
                                <asp:ListItem Value="MEDIA">Media</asp:ListItem>
                                <asp:ListItem Value="BAJA">Baja</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <asp:Button ID="btnGuardarMetadatos" runat="server" Text="Guardar Cambios"
                        OnClick="btnGuardarMetadatos_Click" CausesValidation="false"
                        style="padding:10px 24px;background:linear-gradient(90deg,#2e7d32,#43a047);color:white;border:none;border-radius:8px;font-size:13px;font-weight:700;cursor:pointer"/>
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
</form>
</body>
</html>
