<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Historial.aspx.cs"
    Inherits="ZofraTacna.Presentacion.Historial" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta charset="utf-8" />
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>SIGEFIDD-ZOFRA | Historial</title>
        <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
        <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box
            }

            html,
            body {
                width: 100%;
                height: 100%;
                overflow: hidden
            }

            body {
                font-family: 'Segoe UI', sans-serif;
                background: #f0f2f5;
                display: flex;
                height: 100vh
            }

            .sidebar {
                width: 230px;
                min-width: 230px;
                background: #1a2a4a;
                display: flex;
                flex-direction: column;
                height: 100vh
            }

            .sidebar-logo {
                padding: 20px 18px 16px;
                border-bottom: 1px solid rgba(255, 255, 255, .08);
                display: flex;
                align-items: center;
                gap: 10px
            }

            .logo-icon {
                width: 36px;
                height: 36px;
                background: linear-gradient(135deg, #2a3f6f, #8b1a1a);
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center
            }

            .logo-icon svg {
                width: 20px;
                height: 20px;
                fill: white
            }

            .logo-text .top {
                color: white;
                font-size: 13px;
                font-weight: 700;
                letter-spacing: 1px
            }

            .logo-text .top span {
                color: #c0392b
            }

            .logo-text .bot {
                color: rgba(255, 255, 255, .4);
                font-size: 9px;
                letter-spacing: 1px
            }

            .sidebar-nav {
                padding: 16px 10px;
                flex: 1;
                overflow-y: auto;
                display: flex;
                flex-direction: column
            }

            .nav-item {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 12px;
                border-radius: 8px;
                color: rgba(255, 255, 255, .6);
                font-size: 13px;
                margin-bottom: 2px;
                text-decoration: none
            }

            .nav-item:hover {
                background: rgba(255, 255, 255, .07);
                color: white
            }

            .nav-item.active {
                background: linear-gradient(90deg, #2a3f6f, #8b1a1a);
                color: white
            }

            .nav-item svg {
                width: 17px;
                height: 17px;
                fill: currentColor;
                flex-shrink: 0
            }

            .nav-badge {
                margin-left: auto;
                background: #c0392b;
                color: white;
                border-radius: 10px;
                font-size: 10px;
                padding: 1px 6px;
                font-weight: 600
            }

            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
                overflow: hidden
            }

            .topbar {
                background: white;
                padding: 0 28px;
                height: 56px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid #e8eaf0;
                flex-shrink: 0
            }

            .breadcrumb {
                font-size: 13px;
                color: #999
            }

            .breadcrumb strong {
                color: #1a2a4a
            }

            .topbar-right {
                display: flex;
                align-items: center;
                gap: 14px
            }

            .user-avatar {
                width: 34px;
                height: 34px;
                background: linear-gradient(135deg, #1a2a4a, #8b1a1a);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-size: 12px;
                font-weight: 700
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 8px
            }

            .user-name {
                font-size: 14px;
                font-weight: 600;
                color: #333
            }

            .role-badge {
                background: #eef0f8;
                color: #1a2a4a;
                border-radius: 12px;
                padding: 2px 10px;
                font-size: 11px;
                font-weight: 600
            }

            .nav-item-logout {
                display: flex;
                align-items: center;
                gap: 10px;
                padding: 10px 12px;
                border-radius: 8px;
                color: white;
                font-size: 13px;
                cursor: pointer;
                margin-top: auto;
                text-decoration: none;
                background: linear-gradient(135deg, #8b1a1a, #c0392b);
                border: 1.5px solid #7d1717;
                margin-bottom: 10px;
                box-shadow: 0 6px 16px rgba(139, 26, 26, .25)
            }

            .nav-item-logout:hover {
                background: linear-gradient(135deg, #a32121, #d44736)
            }

            .btn-logout {
                padding: 6px 16px;
                border: 1.5px solid #ddd;
                border-radius: 6px;
                background: white;
                color: #555;
                font-size: 13px;
                cursor: pointer
            }

            .content {
                flex: 1;
                padding: 28px;
                overflow-y: auto
            }

            .content h1 {
                font-size: 24px;
                color: #1a2a4a;
                font-weight: 700
            }

            .content .sub {
                font-size: 13px;
                color: #888;
                margin-top: 2px;
                margin-bottom: 20px
            }

            .filter-tabs {
                display: flex;
                gap: 6px;
                margin-bottom: 20px;
                flex-wrap: wrap
            }

            .tab-btn {
                padding: 7px 18px;
                border-radius: 20px;
                border: 1.5px solid #dde1f0;
                background: white;
                color: #555;
                font-size: 13px;
                cursor: pointer;
                text-decoration: none;
                font-family: 'Segoe UI', sans-serif;
                font-weight: 500;
                display: inline-block
            }

            .tab-btn:hover {
                background: #f0f2f8;
                color: #1a2a4a
            }

            .tab-btn.tab-active {
                background: linear-gradient(90deg, #1a2a4a, #2a4a8a);
                color: white;
                border-color: transparent
            }

            /* SEARCH BOX */
            .search-box {
                display: flex;
                align-items: center;
                background: white;
                border: 1.5px solid #dde1f0;
                border-radius: 20px;
                padding: 5px 14px;
                min-width: 260px;
                transition: all .2s;
            }

            .search-box:focus-within {
                border-color: #1a2a4a;
                box-shadow: 0 0 0 3px rgba(26, 42, 74, .1);
            }

            .search-input {
                border: none;
                outline: none;
                font-family: 'Segoe UI', sans-serif;
                font-size: 13px;
                width: 100%;
                color: #333;
            }

            .search-input::placeholder {
                color: #aaa;
            }

            .tbl-wrap {
                background: white;
                border-radius: 12px;
                box-shadow: 0 1px 4px rgba(0, 0, 0, .06);
                overflow: hidden
            }

            table {
                width: 100%;
                border-collapse: collapse
            }

            thead tr {
                background: #f8f9fc
            }

            thead th {
                padding: 12px 16px;
                font-size: 11px;
                font-weight: 700;
                color: #888;
                text-transform: uppercase;
                letter-spacing: .5px;
                text-align: left;
                border-bottom: 1px solid #eef0f8
            }

            tbody tr {
                border-bottom: 1px solid #f4f5fa
            }

            tbody tr:last-child {
                border-bottom: none
            }

            tbody tr:hover {
                background: #fafbff
            }

            tbody td {
                padding: 13px 16px;
                font-size: 13px;
                color: #444;
                vertical-align: middle
            }

            .doc-asunto {
                font-weight: 600;
                color: #1a2a4a;
                font-size: 14px
            }

            .doc-archivo {
                color: #aaa;
                font-size: 11px;
                margin-top: 2px
            }

            .badge {
                border-radius: 10px;
                padding: 3px 10px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block
            }

            .badge-pen,
            .badge-fpar {
                background: #f5eeff;
                color: #6b21a8;
                border: 1px solid #d8b4fe
            }

            .badge-rev {
                background: #e8f0ff;
                color: #1a56db;
                border: 1px solid #b3c6ff
            }

            .badge-fcom {
                background: #e8f5e9;
                color: #2e7d32;
                border: 1px solid #c8e6c9
            }

            .badge-obs {
                background: #fff3e0;
                color: #e65100;
                border: 1px solid #ffcc80
            }

            .badge-reg {
                background: #f0f2f8;
                color: #555;
                border: 1px solid #d0d4e8
            }

            .plazo-vencido {
                background: #fdecea;
                color: #c0392b;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block
            }

            .plazo-warn {
                background: #fff8e1;
                color: #b45309;
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                font-weight: 600;
                display: inline-block
            }

            .plazo-ok {
                color: #888;
                font-size: 11px
            }

            .btn-editar-doc {
                border: none;
                border-radius: 9px;
                padding: 9px 14px;
                cursor: pointer;
                font-size: 12px;
                font-weight: 700;
                color: #fff;
                background: linear-gradient(135deg, #2a3f6f, #1a2a4a);
                box-shadow: 0 6px 16px rgba(26, 42, 74, .22)
            }

            .btn-editar-doc:hover {
                background: linear-gradient(135deg, #355287, #243a62)
            }

            .btn-icon {
                background: none;
                border: 1.5px solid #dde1f0;
                border-radius: 6px;
                width: 34px;
                height: 34px;
                cursor: pointer;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                color: #666;
                transition: all 0.2s;
            }

            .btn-icon:hover {
                background: #f0f2f8;
                color: #1a2a4a;
                border-color: #c4cada;
            }

            .btn-icon svg {
                width: 17px;
                height: 17px;
                fill: currentColor;
            }

            .btn-icon.btn-ver-pdf:hover {
                color: #2a3f6f;
                background: #e8ecf5;
                border-color: #aebce0;
            }

            .btn-icon.btn-descargar-pdf:hover {
                color: #8b1a1a;
                background: #f5e8e8;
                border-color: #e0aeae;
            }

            .btn-icon.btn-ver-flujo:hover {
                color: #10b981;
                background: #ecfdf5;
                border-color: #a7f3d0;
            }

            .modal-visor {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background-color: rgba(0, 0, 0, 0.6);
                align-items: center;
                justify-content: center;
                backdrop-filter: blur(3px);
            }

            .modal-visor-content {
                background-color: #f8f9fa;
                border-radius: 12px;
                width: 85%;
                max-width: 1000px;
                height: 85vh;
                display: flex;
                flex-direction: column;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
                overflow: hidden;
            }

            .modal-visor-header {
                padding: 15px 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-bottom: 1px solid #e1e4ee;
                background: white;
            }

            .modal-visor-header h3 {
                margin: 0;
                font-size: 16px;
                color: #1a2a4a;
                font-weight: 600;
            }

            .btn-cerrar-modal {
                background: none;
                border: none;
                font-size: 24px;
                color: #888;
                cursor: pointer;
                line-height: 1;
                padding: 0;
                margin-top: -4px;
                transition: color 0.2s;
            }

            .btn-cerrar-modal:hover {
                color: #c0392b;
            }

            .modal-visor-body {
                flex: 1;
                padding: 0;
                background: #525659;
            }

            .modal-visor-body iframe {
                width: 100%;
                height: 100%;
                border: none;
            }

            /* TIMELINE STYLES */
            .timeline-wrapper {
                position: relative;
                padding-left: 24px;
                margin-top: 10px;
                overflow-y: auto;
                max-height: 400px;
            }

            .timeline-wrapper::-webkit-scrollbar {
                width: 6px
            }

            .timeline-wrapper::-webkit-scrollbar-track {
                background: #f1f5f9;
                border-radius: 4px
            }

            .timeline-wrapper::-webkit-scrollbar-thumb {
                background: #cbd5e1;
                border-radius: 4px
            }

            .timeline-wrapper::before {
                content: '';
                position: absolute;
                left: 5px;
                top: 8px;
                bottom: 8px;
                width: 2px;
                background: #e2e8f0
            }

            .timeline-node {
                position: relative;
                margin-bottom: 24px
            }

            .timeline-node:last-child {
                margin-bottom: 0
            }

            .timeline-dot {
                position: absolute;
                left: -24px;
                top: 4px;
                width: 10px;
                height: 10px;
                border-radius: 50%;
                background: #64748b;
                border: 2.5px solid #ffffff;
                box-shadow: 0 0 0 2px #e2e8f0;
            }

            .timeline-dot.blue {
                background: #3b82f6;
                box-shadow: 0 0 0 2px rgba(59, 130, 246, .3)
            }

            .timeline-dot.green {
                background: #10b981;
                box-shadow: 0 0 0 2px rgba(16, 185, 129, .3)
            }

            .timeline-dot.red {
                background: #ef4444;
                box-shadow: 0 0 0 2px rgba(239, 68, 68, .3)
            }

            .timeline-dot.yellow {
                background: #f59e0b;
                box-shadow: 0 0 0 2px rgba(245, 158, 11, .3)
            }

            .timeline-card {
                background: #f8fafc;
                border-radius: 10px;
                padding: 12px 16px;
                border: 1px solid #f1f5f9;
            }

            .timeline-meta-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 6px;
                flex-wrap: wrap;
                gap: 6px
            }

            .timeline-action-title {
                font-size: 13.5px;
                font-weight: 700;
                color: #1e293b
            }

            .timeline-timestamp {
                font-size: 11px;
                font-weight: 600;
                color: #64748b;
                font-family: 'JetBrains Mono', monospace
            }

            .timeline-card-body {
                font-size: 12.5px;
                color: #475569;
                line-height: 1.4
            }
        </style>
    </head>

    <body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
        <form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
            <div style="display:flex;width:100%;height:100vh;overflow:hidden;">
                <div class="sidebar">
                    <div class="sidebar-logo">
                        <div class="logo-icon"><svg viewBox="0 0 24 24">
                                <path
                                    d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z" />
                            </svg></div>
                        <div class="logo-text">
                            <div class="top">SIGEFIDD<span>-ZOFRA</span></div>
                            <div class="bot">ZONA FRANCA DE TACNA</div>
                        </div>
                    </div>
                    <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
                        <div style="flex: 1; overflow-y: auto;">
                            <asp:Literal ID="litSidebarNav" runat="server" />
                        </div>
                        <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout"
                            OnClick="btnCerrarSesion_Click" />
                    </nav>
                </div>
                <div class="main">
                    <div class="topbar">
                        <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Historial</div>
                        <div class="topbar-right">
                            <div class="zfn-bell-wrap">
                                <button type="button" class="zfn-bell-btn" id="zfnBellBtn" aria-label="Notificaciones"
                                    aria-expanded="false" aria-controls="zfnBellPanel">
                                    <svg viewBox="0 0 24 24" aria-hidden="true">
                                        <path
                                            d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.64-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.63 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2z" />
                                    </svg>
                                    <span class="zfn-bell-badge" id="zfnBellBadge"></span>
                                </button>
                                <div id="zfnBellPanel" class="zfn-bell-panel" role="dialog" aria-hidden="true">
                                    <div class="zfn-bell-panel-head">Alertas de documentos</div>
                                    <div class="zfn-bell-panel-body" id="zfnBellPanelBody"></div>
                                </div>
                            </div>
                            <div class="user-info">
                                <div class="user-avatar">
                                    <asp:Literal ID="litAvatar" runat="server" />
                                </div>
                                <span class="user-name">
                                    <asp:Literal ID="litNombre" runat="server" />
                                </span>
                                <span class="role-badge">
                                    <asp:Literal ID="litRol" runat="server" />
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="content">
                        <h1>Historial de Documentos</h1>
                        <p class="sub">Documentos revisados y en proceso</p>
                        <div
                            style="display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;flex-wrap:wrap;gap:12px;">
                            <div class="filter-tabs" style="margin-bottom:0;">
                                <asp:LinkButton ID="lbTodos" runat="server" OnClick="lbTodos_Click" CssClass="tab-btn">
                                    Todos</asp:LinkButton>
                                <asp:LinkButton ID="lbPendiente" runat="server" OnClick="lbPendiente_Click"
                                    CssClass="tab-btn">Pendiente</asp:LinkButton>
                                <asp:LinkButton ID="lbRevision" runat="server" OnClick="lbRevision_Click"
                                    CssClass="tab-btn">Revisi&oacute;n</asp:LinkButton>
                                <asp:LinkButton ID="lbFirma" runat="server" OnClick="lbFirma_Click" CssClass="tab-btn">
                                    Firma</asp:LinkButton>
                                <asp:LinkButton ID="lbCompletado" runat="server" OnClick="lbCompletado_Click"
                                    CssClass="tab-btn">Completado</asp:LinkButton>
                            </div>
                            <div class="search-box">
                                <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:#aaa;margin-right:8px;">
                                    <path
                                        d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z" />
                                </svg>
                                <input type="text" id="txtBuscarDoc" onkeyup="filtrarTablaDocs()"
                                    placeholder="Buscar por código o título..." class="search-input"
                                    autocomplete="off" />
                            </div>
                        </div>
                        <div class="tbl-wrap">
                            <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                                <div class="empty">No hay documentos para mostrar.</div>
                            </asp:Panel>
                            <asp:Panel ID="pnlTable" runat="server">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>C&Oacute;DIGO</th>
                                            <th>T&Iacute;TULO</th>
                                            <th>CATEGOR&Iacute;A</th>
                                            <th>ESTADO</th>
                                            <th>PLAZOS</th>
                                            <th>FECHA</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <asp:Repeater ID="rptDocs" runat="server">
                                            <ItemTemplate>
                                                <tr class="doc-row">
                                                    <td>
                                                        <div style="font-weight:700;color:#1a2a4a;font-size:13px">
                                                            <%# System.Web.HttpUtility.HtmlEncode(Eval("CodigoDocumento").ToString())
                                                                %>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="doc-asunto">
                                                            <%# System.Web.HttpUtility.HtmlEncode(Eval("Asunto").ToString())
                                                                %>
                                                        </div>
                                                        <div class="doc-archivo">
                                                            <%# System.Web.HttpUtility.HtmlEncode(Eval("NombreArchivo").ToString())
                                                                %>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <%# System.Web.HttpUtility.HtmlEncode(Eval("AreaCategoria").ToString())
                                                            %>
                                                    </td>
                                                    <td><span class='badge <%# Eval("BadgeCss") %>'>
                                                            <%# Eval("EstadoDesc") %>
                                                        </span></td>
                                                    <td>
                                                        <%# Eval("PlazosHtml") %>
                                                    </td>
                                                    <td>
                                                        <%# Eval("FechaStr") %>
                                                    </td>
                                                    <td>
                                                        <div style="display:flex; gap:6px;">
                                                            <button type="button" class="btn-icon btn-ver-pdf" title="Ver documento PDF" onclick="abrirModalVisor(<%# Eval("IdDocumento") %>)">
                                                                <svg viewBox='0 0 24 24'><path d='M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z' /></svg>
                                                            </button>
                                                            <button type="button" class="btn-icon btn-descargar-pdf" title="Descargar documento PDF" onclick="window.location.href='../BandejaTrabajo/ServirPdf.ashx?idDoc=<%# Eval("IdDocumento") %>&descargar=1'">
                                                                <svg viewBox='0 0 24 24'><path d='M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z' /></svg>
                                                            </button>
                                                            <button type="button" class="btn-icon btn-ver-flujo" title="Ver flujo de estados" onclick="abrirModalFlujo(<%# Eval("IdDocumento") %>)">
                                                                <svg viewBox="0 0 24 24"><path d="M23 8c0 1.1-.9 2-2 2-.18 0-.35-.02-.51-.07l-3.56 3.55c.05.16.07.34.07.52 0 1.1-.9 2-2 2s-2-.9-2-2c0-.18.02-.36.07-.52l-2.55-2.55c-.16.05-.34.07-.52.07s-.36-.02-.52-.07l-4.55 4.56c.05.16.07.33.07.51 0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2c.18 0 .35.02.51.07l4.56-4.55C8.02 9.36 8 9.18 8 9c0-1.1.9-2 2-2s2 .9 2 2c0 .18-.02.36-.07.52l2.55 2.55c.16-.05.34-.07.52-.07s.36.02.52.07l3.55-3.56C19.02 8.35 19 8.18 19 8c0-1.1.9-2 2-2s2 .9 2 2c0 .18-.02.36-.07.52l2.55 2.55c.16-.05.34-.07.52-.07s.36.02.52.07l3.55-3.56C19.02 8.35 19 8.18 19 8c0-1.1.9-2 2-2s2 .9 2 2z" /></svg>
                                                            </button>
                                                        </div>
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
            <div id="modalVisorPdf" class="modal-visor">
                <div class="modal-visor-content">
                    <div class="modal-visor-header">
                        <h3>Visor de Documento</h3>
                        <button type="button" class="btn-cerrar-modal" onclick="cerrarModalVisor()">&times;</button>
                    </div>
                    <div class="modal-visor-body">
                        <iframe id="iframeVisorPdf" src=""></iframe>
                    </div>
                </div>
            </div>
            <div id="modalFlujo" class="modal-visor" style="z-index: 2000;">
                <div class="modal-visor-content" style="max-width: 600px; height: auto; max-height: 85vh;">
                    <div class="modal-visor-header" style="background:#1a2a4a;border-bottom:none;">
                        <h3 style="color:white;display:flex;align-items:center;gap:8px;">
                            <svg viewBox="0 0 24 24" style="width:18px;height:18px;fill:white;">
                                <path
                                    d="M23 8c0 1.1-.9 2-2 2-.18 0-.35-.02-.51-.07l-3.56 3.55c.05.16.07.34.07.52 0 1.1-.9 2-2 2s-2-.9-2-2c0-.18.02-.36.07-.52l-2.55-2.55c-.16.05-.34.07-.52.07s-.36-.02-.52-.07l-4.55 4.56c.05.16.07.33.07.51 0 1.1-.9 2-2 2s-2-.9-2-2 .9-2 2-2c.18 0 .35.02.51.07l4.56-4.55C8.02 9.36 8 9.18 8 9c0-1.1.9-2 2-2s2 .9 2 2c0 .18-.02.36-.07.52l2.55 2.55c.16-.05.34-.07.52-.07s.36.02.52.07l3.55-3.56C19.02 8.35 19 8.18 19 8c0-1.1.9-2 2-2s2 .9 2 2z" />
                            </svg>
                            Flujo Operativo
                        </h3>
                        <button type="button" onclick="cerrarModalFlujo()"
                            style="background:#e74c3c;color:white;border:none;border-radius:6px;padding:6px 14px;font-size:12px;font-weight:700;cursor:pointer;box-shadow:0 2px 6px rgba(0,0,0,0.2);transition:background 0.2s;">
                            X </button>
                    </div>
                    <div class="modal-visor-body" style="background:#ffffff;padding:24px;overflow-y:auto;">
                        <div id="flujoContainer" class="timeline-wrapper">
                            <!-- Loaded via JS -->
                        </div>
                    </div>
                </div>
            </div>
            <div id="zfnToastHost" class="zfn-toast-host"></div>
        </form>
        <script>
            function abrirModalVisor(idDoc) {
                document.getElementById('iframeVisorPdf').src = '../BandejaTrabajo/ServirPdf.ashx?idDoc=' + idDoc;
                document.getElementById('modalVisorPdf').style.display = 'flex';
            }
            function cerrarModalVisor() {
                document.getElementById('modalVisorPdf').style.display = 'none';
                document.getElementById('iframeVisorPdf').src = '';
            }

            function abrirModalFlujo(idDoc) {
                document.getElementById('flujoContainer').innerHTML = '<div style="text-align:center;padding:30px;color:#888;font-weight:600;">Cargando flujo operativo...</div>';
                document.getElementById('modalFlujo').style.display = 'flex';

                fetch('ObtenerFlujoDocumento.ashx?idDoc=' + idDoc)
                    .then(res => res.json())
                    .then(data => {
                        if (data.error) {
                            document.getElementById('flujoContainer').innerHTML = '<div style="color:#e74c3c;padding:20px;text-align:center;font-weight:600;">' + data.error + '</div>';
                            return;
                        }
                        if (data.length === 0) {
                            document.getElementById('flujoContainer').innerHTML = '<div style="padding:30px;color:#888;text-align:center;font-weight:600;">No hay historial registrado para este documento.</div>';
                            return;
                        }
                        let html = '';
                        data.forEach(item => {
                            let titulo = item.EstadoNuevo;
                            if (item.EstadoAnterior) {
                                titulo = item.EstadoAnterior + ' &rarr; ' + item.EstadoNuevo;
                            }
                            html += `
                    <div class="timeline-node">
                        <div class="timeline-dot ${item.ColorBadge}"></div>
                        <div class="timeline-card">
                            <div class="timeline-meta-row">
                                <div class="timeline-action-title">${titulo}</div>
                                <div class="timeline-timestamp">${item.FechaCambio}</div>
                            </div>
                            <div class="timeline-card-body">
                                <div><strong>Usuario:</strong> ${item.LoginUsuarioAccion}</div>
                                ${item.DetalleAccion ? `<div style="margin-top:4px;"><em>${item.DetalleAccion}</em></div>` : ''}
                            </div>
                        </div>
                    </div>`;
                        });
                        document.getElementById('flujoContainer').innerHTML = html;
                    })
                    .catch(e => {
                        document.getElementById('flujoContainer').innerHTML = '<div style="color:#e74c3c;padding:20px;text-align:center;font-weight:600;">Error al conectar con el servidor.</div>';
                    });
            }

            function cerrarModalFlujo() {
                document.getElementById('modalFlujo').style.display = 'none';
            }

            function filtrarTablaDocs() {
                var input = document.getElementById('txtBuscarDoc');
                if (!input) return;
                var filter = input.value.toLowerCase().trim();
                filter = filter.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                var rows = document.querySelectorAll('.doc-row');
                for (var i = 0; i < rows.length; i++) {
                    var tdCodigo = rows[i].getElementsByTagName('td')[0];
                    var tdTitulo = rows[i].getElementsByTagName('td')[1];
                    if (tdCodigo && tdTitulo) {
                        var textCodigo = (tdCodigo.textContent || tdCodigo.innerText).toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                        var textTitulo = (tdTitulo.textContent || tdTitulo.innerText).toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
                        if (textCodigo.indexOf(filter) > -1 || textTitulo.indexOf(filter) > -1) {
                            rows[i].style.display = "";
                        } else {
                            rows[i].style.display = "none";
                        }
                    }
                }
            }
        </script>
    </body>

    </html>