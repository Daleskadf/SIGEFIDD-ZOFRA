<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BandejaTrabajo.aspx.cs" Inherits="ZofraTacna.Presentacion.BandejaTrabajo" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Bandeja de Trabajo</title>
    <style>
        *{margin:0;padding:0;box-sizing:border-box}html,body{width:100%;height:100%;overflow:hidden}
        body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;display:flex;height:100vh}
        .sidebar{width:230px;min-width:230px;background:#1a2a4a;display:flex;flex-direction:column;height:100vh}
        .sidebar-logo{padding:20px 18px 16px;border-bottom:1px solid rgba(255,255,255,.08);display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:linear-gradient(135deg,#2a3f6f,#8b1a1a);border-radius:8px;display:flex;align-items:center;justify-content:center}
        .logo-icon svg{width:20px;height:20px;fill:white}
        .logo-text .top{color:white;font-size:13px;font-weight:700;letter-spacing:1px}
        .logo-text .top span{color:#c0392b}.logo-text .bot{color:rgba(255,255,255,.4);font-size:9px;letter-spacing:1px}
        .sidebar-nav{padding:16px 10px;flex:1;overflow-y:auto}
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
        .btn-logout{padding:6px 16px;border:1.5px solid #ddd;border-radius:6px;background:white;color:#555;font-size:13px;cursor:pointer}
        .content{flex:1;padding:28px;overflow-y:auto}
        .content h1{font-size:24px;color:#1a2a4a;font-weight:700}
        .content .sub{font-size:13px;color:#888;margin-top:2px;margin-bottom:24px}
        /* DOC CARDS */
        .doc-card{background:white;border-radius:12px;padding:20px 24px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,.06)}
        .doc-card-header{display:flex;align-items:center;gap:10px;margin-bottom:6px}
        .doc-title{font-size:16px;font-weight:600;color:#1a2a4a}
        .badge{border-radius:10px;padding:2px 10px;font-size:11px;font-weight:600}
        .badge-alta{background:#ffeef0;color:#c0392b;border:1px solid #f5c6cb}
        .badge-media{background:#fff8e1;color:#f59f00;border:1px solid #ffe082}
        .badge-baja{background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9}
        .badge-estado{background:#f0f2f8;color:#555;border:1px solid #d0d4e8;border-radius:10px;padding:2px 10px;font-size:11px;font-weight:500}
        .badge-firma{background:#f5eeff;color:#6b21a8;border:1px solid #d8b4fe;border-radius:10px;padding:2px 10px;font-size:11px;font-weight:500}
        .doc-desc{font-size:13px;color:#666;margin-bottom:10px}
        .doc-meta{display:flex;align-items:center;gap:18px;font-size:12px;color:#999;margin-bottom:16px}
        .doc-meta svg{width:13px;height:13px;fill:#bbb;margin-right:3px;vertical-align:middle}
        .doc-actions{display:flex;gap:10px}
        .btn-detalle{padding:8px 18px;border:1.5px solid #ddd;border-radius:7px;background:white;color:#555;font-size:13px;cursor:pointer}
        .btn-revision{padding:8px 18px;border:none;border-radius:7px;background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;font-size:13px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:6px}
        .btn-firma{padding:8px 18px;border:none;border-radius:7px;background:linear-gradient(90deg,#5b21b6,#8b1a1a);color:white;font-size:13px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:6px}
        .empty{text-align:center;padding:60px;color:#aaa;font-size:14px;background:white;border-radius:12px}
    </style>
</head>
<body>
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div>
            <div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div>
        </div>
        <nav class="sidebar-nav">
            <asp:Literal ID="litSidebarNav" runat="server"/>
        </nav>
    </div>
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Bandeja de Trabajo</div>
            <div class="topbar-right">
                <div class="user-info">
                    <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server"/></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span>
                </div>
                <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesion" CssClass="btn-logout" OnClick="btnCerrarSesion_Click"/>
            </div>
        </div>
        <div class="content">
            <h1>Bandeja de Trabajo</h1>
            <p class="sub">Documentos pendientes de acci&oacute;n</p>
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                <div class="empty">No hay documentos pendientes en la bandeja.</div>
            </asp:Panel>
            <asp:Repeater ID="rptDocs" runat="server">
                <ItemTemplate>
                    <div class="doc-card">
                        <div class="doc-card-header">
                            <span class="doc-title"><%# Eval("Asunto") %></span>
                            <span class='badge badge-<%# Eval("PrioridadCss") %>'><%# Eval("Prioridad") %></span>
                            <span class='<%# Eval("EstadoBadgeCss") %>'><%# Eval("EstadoDesc") %></span>
                        </div>
                        <div class="doc-desc"><%# Eval("AreaResponsable") %></div>
                        <div class="doc-meta">
                            <span><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16h14V8l-6-6z"/></svg><%# Eval("NombreArchivo") %></span>
                            <span><svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg><%# Eval("AreaCategoria") %></span>
                            <span><svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg><%# Eval("Registrador") %></span>
                            <span><svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg><%# Eval("FechaCreacionStr") %></span>
                        </div>
                        <div class="doc-actions">
                            <button class="btn-detalle" type="button">Ver Detalles</button>
                            <%# (string)Eval("EstadoCodigo") == "PEN" || (string)Eval("EstadoCodigo") == "FPAR"
                                ? "<button class='btn-firma' type='button'><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>Firmar Documento</button>"
                                : "<button class='btn-revision' type='button'><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>Emitir Revisi&oacute;n</button>" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>
</form>
</body>
</html>
