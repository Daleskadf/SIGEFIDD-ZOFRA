<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionRoles.aspx.cs" Inherits="ZofraTacna.Presentacion.GestionRoles" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Gesti&oacute;n de Roles</title>
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
        /* HEADER ROW */
        .page-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}
        .page-header h1{font-size:24px;color:#1a2a4a;font-weight:700}
        .page-header .sub{font-size:13px;color:#888;margin-top:2px}
        .btn-agregar{padding:9px 20px;border:none;border-radius:8px;background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;font-size:13px;font-weight:600;cursor:pointer;white-space:nowrap}
        /* STAT CARDS */
        .stat-cards{display:flex;gap:16px;margin-bottom:24px;flex-wrap:wrap}
        .stat-card{background:white;border-radius:12px;padding:20px 24px;flex:1;min-width:160px;box-shadow:0 1px 4px rgba(0,0,0,.06);display:flex;flex-direction:column;gap:4px}
        .stat-label{font-size:12px;color:#888;font-weight:600;text-transform:uppercase;letter-spacing:.4px}
        .stat-value{font-size:32px;font-weight:700;color:#1a2a4a}
        .stat-icon{margin-bottom:8px}
        /* TABLE */
        .tbl-wrap{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);overflow:hidden}
        table{width:100%;border-collapse:collapse}
        thead tr{background:#f8f9fc}
        thead th{padding:12px 16px;font-size:11px;font-weight:700;color:#888;text-transform:uppercase;letter-spacing:.5px;text-align:left;border-bottom:1px solid #eef0f8}
        tbody tr{border-bottom:1px solid #f4f5fa}
        tbody tr:last-child{border-bottom:none}
        tbody tr:hover{background:#fafbff}
        tbody td{padding:13px 16px;font-size:13px;color:#444;vertical-align:middle}
        .user-row-name{font-weight:600;color:#1a2a4a;font-size:14px}
        .user-row-email{color:#888;font-size:12px}
        .badge{border-radius:10px;padding:3px 10px;font-size:11px;font-weight:600;display:inline-block}
        .badge-rev{background:white;color:#555;border:1.5px solid #aaa}
        .badge-fir{background:white;color:#6b21a8;border:1.5px solid #a855f7}
        .badge-adm{background:white;color:#1a56db;border:1.5px solid #3b82f6}
        .badge-reg{background:white;color:#2e7d32;border:1.5px solid #4caf50}
        .btn-editar{padding:5px 14px;border:1.5px solid #dde1f0;border-radius:6px;background:white;color:#1a2a4a;font-size:12px;cursor:pointer;margin-right:6px;font-weight:600;text-decoration:none;display:inline-block}
        .btn-eliminar{padding:5px 14px;border:1.5px solid #fca5a5;border-radius:6px;background:white;color:#c0392b;font-size:12px;cursor:pointer;font-weight:600;text-decoration:none;display:inline-block}
        .empty{text-align:center;padding:60px;color:#aaa;font-size:14px}
        /* FILTER BAR */
        .filter-bar{display:flex;gap:10px;margin-bottom:16px;align-items:center;flex-wrap:wrap}
        .filter-bar input{flex:1;min-width:180px;padding:9px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;color:#333;outline:none;font-family:'Segoe UI',sans-serif}
        .filter-bar input:focus{border-color:#1a2a4a}
        .filter-bar select{padding:9px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:13px;color:#333;outline:none;font-family:'Segoe UI',sans-serif;background:white}
        .filter-bar select:focus{border-color:#1a2a4a}
        .btn-limpiar-filtro{padding:9px 16px;border:1.5px solid #ddd;border-radius:8px;background:white;color:#555;font-size:13px;cursor:pointer;white-space:nowrap}
        .btn-limpiar-filtro:hover{background:#f4f4f4}
        .filter-count{font-size:12px;color:#888;margin-left:auto;white-space:nowrap}
        /* FORM PANEL UC-006 */
        .fup{background:white;border-radius:12px;border-left:4px solid #1a2a4a;box-shadow:0 2px 8px rgba(0,0,0,.08);padding:20px 24px;margin-bottom:20px}
        .fup-title{font-size:15px;font-weight:700;color:#1a2a4a;margin-bottom:16px}
        .fup-row{display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:14px}
        .fup label{display:block;font-size:11px;font-weight:700;letter-spacing:1px;color:#555;margin-bottom:6px}
        .fup-input{width:100%;padding:11px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;color:#333;outline:none;font-family:'Segoe UI',sans-serif}
        .fup-input:focus{border-color:#1a2a4a}
        .fup-input[readonly]{background:#f8f9fc;color:#888}
        .fup-actions{display:flex;gap:10px;margin-top:6px}
        .fup-btn-save{padding:10px 24px;background:linear-gradient(90deg,#1a2a4a,#8b1a1a);color:white;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer}
        .fup-btn-cancel{padding:10px 20px;background:white;color:#555;border:1.5px solid #ddd;border-radius:8px;font-size:14px;cursor:pointer}
        .fup-msg-ok{display:block;margin-bottom:10px;padding:10px 14px;background:#e8f5e9;color:#2e7d32;border-radius:8px;font-size:13px;font-weight:600}
        .fup-msg-err{display:block;margin-bottom:10px;padding:10px 14px;background:#fdecea;color:#c0392b;border-radius:8px;font-size:13px;font-weight:600}
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
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
                <a href="../Default.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>Inicio</a>
                <a href="../BandejaTrabajo/BandejaTrabajo.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>Bandeja de Trabajo<span class="nav-badge"><asp:Literal ID="litBadge" runat="server"/></span></a>
                <a href="../GestionDocumentos/CargarDocumento.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>Cargar Documento</a>
                <a href="../GestionDocumentos/MisDocumentos.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>Mis Documentos</a>
                <a href="GestionRoles.aspx" class="nav-item active"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>Gesti&oacute;n de Roles</a>
                <a href="../VisualizarFirmantes/VisualizarFirmantes.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>Visualizar Firmantes</a>
                <a href="../GestionAuditoria/GestionAuditoria.aspx" class="nav-item"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.53c-.26-.81-1-1.4-1.9-1.4h-1v-3c0-.55-.45-1-1-1h-6v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.4z"/></svg>Auditoría</a>
                <a href="#" class="nav-item"><svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg>Estado del Sistema</a>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>
    <!-- MAIN -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Gesti&oacute;n de Roles</div>
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
            <div class="page-header">
                <div>
                    <h1>Gesti&oacute;n de Roles</h1>
                    <div class="sub">Administrar usuarios, revisores y firmantes</div>
                </div>
                <asp:Button ID="btnAgregarUsuario" runat="server" Text="+ Agregar Usuario" CssClass="btn-agregar" OnClick="btnAgregarUsuario_Click" CausesValidation="false"/>
            </div>

            <!-- FORMULARIO USUARIO (UC-006) -->
            <asp:Panel ID="pnlFormulario" runat="server" Visible="false" CssClass="fup">
                <div class="fup-title"><asp:Literal ID="litFormTitulo" runat="server">Agregar Usuario</asp:Literal></div>
                <asp:HiddenField ID="hfIdUsuario" runat="server" Value="0"/>
                <div class="fup-row">
                    <div>
                        <label>LOGIN USUARIO *</label>
                        <asp:TextBox ID="txtLoginNuevo" runat="server" CssClass="fup-input" placeholder="ej: jperez"/>
                    </div>
                    <div>
                        <label>ROL *</label>
                        <asp:DropDownList ID="ddlRolNuevo" runat="server" CssClass="fup-input"/>
                    </div>
                </div>
                <asp:Label ID="lblMensajeForm" runat="server" Visible="false"/>
                <div class="fup-actions">
                    <asp:Button ID="btnGuardarUsuario" runat="server" Text="Guardar" CssClass="fup-btn-save" OnClick="btnGuardarUsuario_Click"/>
                    <asp:Button ID="btnCancelarFormulario" runat="server" Text="Cancelar" CssClass="fup-btn-cancel" OnClick="btnCancelarFormulario_Click" CausesValidation="false"/>
                </div>
            </asp:Panel>

            <!-- STAT CARDS -->
            <div class="stat-cards">
                <div class="stat-card">
                    <div class="stat-label">Revisores</div>
                    <div class="stat-value"><asp:Literal ID="litCntRev" runat="server">0</asp:Literal></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Firmantes</div>
                    <div class="stat-value"><asp:Literal ID="litCntFir" runat="server">0</asp:Literal></div>
                </div>
                <div class="stat-card">
                    <div class="stat-label">Administradores</div>
                    <div class="stat-value"><asp:Literal ID="litCntAdm" runat="server">0</asp:Literal></div>
                </div>
            </div>

            <!-- FILTER BAR -->
            <div class="filter-bar">
                <input type="text" id="filterTexto" placeholder="Buscar por login o email..." oninput="filtrarTabla()"/>
                <select id="filterRol" onchange="filtrarTabla()">
                    <option value="">Todos los roles</option>
                    <option value="adm">Administrador</option>
                    <option value="rev">Revisor</option>
                    <option value="fir">Firmante</option>
                    <option value="reg">Registrador</option>
                </select>
                <button class="btn-limpiar-filtro" type="button" onclick="limpiarFiltro()">Limpiar</button>
                <span class="filter-count" id="filterCount"></span>
            </div>

            <!-- TABLE -->
            <div class="tbl-wrap">
                <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                    <div class="empty">No hay usuarios registrados.</div>
                </asp:Panel>
                <asp:Panel ID="pnlTable" runat="server">
                    <table id="tblUsuarios">
                        <thead>
                            <tr>
                                <th>NOMBRE</th>
                                <th>EMAIL</th>
                                <th>ROL</th>
                                <th>ACCIONES</th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptUsuarios" runat="server" OnItemCommand="rptUsuarios_ItemCommand">
                                <ItemTemplate>
                                    <tr data-login="<%# Eval("LoginUsuario").ToString().ToLower() %>" data-email="<%# Eval("Email").ToString().ToLower() %>" data-rol="<%# Eval("RolCodigo").ToString().ToLower() %>">
                                        <td>
                                            <div class="user-row-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginUsuario").ToString()) %></div>
                                        </td>
                                        <td>
                                            <div class="user-row-email"><%# System.Web.HttpUtility.HtmlEncode(Eval("Email").ToString()) %></div>
                                        </td>
                                        <td>
                                            <span class='badge <%# Eval("BadgeCss") %>'><%# System.Web.HttpUtility.HtmlEncode(Eval("Rol").ToString()) %></span>
                                        </td>
                                        <td>
                                            <asp:LinkButton runat="server" CommandName="Editar" CommandArgument='<%# Eval("IdUsuario") %>' CssClass="btn-editar">Editar</asp:LinkButton>
                                            <asp:LinkButton runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IdUsuario") %>' CssClass="btn-eliminar" OnClientClick="return confirm('¿Eliminar este usuario?')">Eliminar</asp:LinkButton>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </asp:Panel>
            </div>
        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
<script>
    function filtrarTabla() {
        var texto = document.getElementById('filterTexto').value.toLowerCase().trim();
        var rol   = document.getElementById('filterRol').value.toLowerCase();
        var filas = document.querySelectorAll('#tblUsuarios tbody tr');
        var visibles = 0;
        filas.forEach(function(tr) {
            var login = tr.getAttribute('data-login') || '';
            var email = tr.getAttribute('data-email') || '';
            var trRol = tr.getAttribute('data-rol') || '';
            var okTexto = !texto || login.indexOf(texto) >= 0 || email.indexOf(texto) >= 0;
            var okRol   = !rol   || trRol === rol;
            if (okTexto && okRol) { tr.style.display = ''; visibles++; }
            else                  { tr.style.display = 'none'; }
        });
        var total = filas.length;
        var cnt = document.getElementById('filterCount');
        if (cnt) cnt.textContent = (texto || rol) ? 'Mostrando ' + visibles + ' de ' + total : '';
    }
    function limpiarFiltro() {
        document.getElementById('filterTexto').value = '';
        document.getElementById('filterRol').value   = '';
        filtrarTabla();
    }
</script>
</body>
</html>
