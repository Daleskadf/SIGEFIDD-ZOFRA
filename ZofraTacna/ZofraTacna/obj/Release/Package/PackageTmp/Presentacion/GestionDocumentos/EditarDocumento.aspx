<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditarDocumento.aspx.cs"
    Inherits="ZofraTacna.Presentacion.EditarDocumento, ZofraTacna" ResponseEncoding="utf-8"
    ContentType="text/html; charset=utf-8" %>
    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta charset="utf-8" />
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>SIGEFIDD-ZOFRA | Editar Documento</title>
        <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
        <link rel="stylesheet" href="<%= ResolveUrl("~/Content/pdf-observaciones.css") %>" />
        <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
        <script defer src="<%= ResolveUrl("~/Scripts/pdf-observaciones-visor.js") %>"></script>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            html,
            body {
                width: 100%;
                height: 100%;
                overflow: hidden;
            }

            body {
                font-family: 'Segoe UI', sans-serif;
                background: #f0f2f5;
                display: flex;
                height: 100vh;
            }

            .sidebar {
                width: 230px;
                min-width: 230px;
                background: #1a2a4a;
                display: flex;
                flex-direction: column;
                height: 100vh;
            }

            .sidebar-logo {
                padding: 20px 18px 16px;
                border-bottom: 1px solid rgba(255, 255, 255, .08);
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .logo-icon {
                width: 36px;
                height: 36px;
                background: linear-gradient(135deg, #2a3f6f, #8b1a1a);
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
            }

            .logo-icon svg {
                width: 20px;
                height: 20px;
                fill: white;
            }

            .logo-text .top {
                color: white;
                font-size: 13px;
                font-weight: 700;
                letter-spacing: 1px;
            }

            .logo-text .top span {
                color: #c0392b;
            }

            .logo-text .bot {
                color: rgba(255, 255, 255, .4);
                font-size: 9px;
                letter-spacing: 1px;
            }

            .sidebar-nav {
                padding: 16px 10px;
                flex: 1;
                overflow-y: auto;
                display: flex;
                flex-direction: column;
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
                text-decoration: none;
            }

            .nav-item:hover {
                background: rgba(255, 255, 255, .07);
                color: white;
            }

            .nav-item.active {
                background: linear-gradient(90deg, #2a3f6f, #8b1a1a);
                color: white;
            }

            .nav-item svg {
                width: 17px;
                height: 17px;
                fill: currentColor;
                flex-shrink: 0;
            }

            .nav-badge {
                margin-left: auto;
                background: #c0392b;
                color: white;
                border-radius: 10px;
                font-size: 10px;
                padding: 1px 6px;
                font-weight: 600;
            }

            .main {
                flex: 1;
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .topbar {
                background: white;
                padding: 0 28px;
                height: 56px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid #e8eaf0;
                flex-shrink: 0;
            }

            .breadcrumb {
                font-size: 13px;
                color: #999;
            }

            .breadcrumb strong {
                color: #1a2a4a;
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
                font-weight: 700;
            }

            .topbar-right {
                display: flex;
                align-items: center;
                gap: 14px;
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .user-name {
                font-size: 14px;
                font-weight: 600;
                color: #333;
            }

            .role-badge {
                background: #eef0f8;
                color: #1a2a4a;
                border-radius: 12px;
                padding: 2px 10px;
                font-size: 11px;
                font-weight: 600;
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
                font-weight: 600;
                box-shadow: 0 6px 16px rgba(139, 26, 26, .25);
            }

            .nav-item-logout:hover {
                background: linear-gradient(135deg, #a32121, #d44736);
            }

            .content {
                flex: 1;
                padding: 24px 28px;
                overflow: auto;
            }

            .head {
                display: flex;
                justify-content: space-between;
                align-items: flex-start;
                margin-bottom: 24px;
            }

            .head h1 {
                font-size: 24px;
                font-weight: 700;
                color: #1a2a4a;
            }

            .btn-back {
                display: inline-flex;
                align-items: center;
                gap: 8px;
                padding: 10px 16px;
                border-radius: 9px;
                text-decoration: none;
                color: #fff;
                font-size: 12px;
                font-weight: 700;
                background: linear-gradient(135deg, #8b1a1a, #c0392b);
            }

            .btn-back:hover {
                opacity: 0.92;
            }

            .btn-back-arrow {
                font-size: 14px;
                line-height: 1;
            }

            .form-label {
                font-size: 11px;
                font-weight: 700;
                letter-spacing: 1px;
                color: #555;
                margin-bottom: 8px;
                display: block;
            }

            .required {
                color: #c0392b;
            }

            .form-input {
                width: 100%;
                padding: 12px 14px;
                border: 1.5px solid #e0e0e0;
                border-radius: 8px;
                font-size: 14px;
                color: #333;
                outline: none;
                transition: border-color .2s;
            }

            .form-input:focus {
                border-color: #1a2a4a;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 16px;
                margin-bottom: 16px;
            }

            .form-group {
                margin-bottom: 16px;
            }

            .box {
                border: 1.5px solid #e8eaf0;
                border-radius: 10px;
                padding: 16px;
                margin-bottom: 16px;
                background: #fff;
            }

            .obs-item {
                background: #ffebee;
                border-left: 3px solid #c0392b;
                border-radius: 6px;
                padding: 10px 12px;
                font-size: 12px;
                color: #5b2b2b;
                margin-bottom: 8px;
            }

            .upload-zone {
                border: 2px dashed #b0b8d0;
                border-radius: 10px;
                padding: 28px;
                text-align: center;
                background: #fafbff;
                position: relative;
                color: #666;
                font-size: 14px;
            }

            .upload-zone input[type=file] {
                display: none;
            }

            .alert-ok {
                background: #d4edda;
                color: #155724;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 12px;
                font-size: 13px;
            }

            .alert-err {
                background: #f8d7da;
                color: #721c24;
                padding: 12px 16px;
                border-radius: 8px;
                margin-bottom: 12px;
                font-size: 13px;
            }

            .actions {
                display: flex;
                justify-content: flex-end;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
            }

            .btn-visualizar {
                height: 42px;
                padding: 0 20px;
                border-radius: 9px;
                font-size: 13px;
                font-weight: 700;
                cursor: pointer;
                color: #fff;
                border: 1.5px solid #1a2a4a;
                background: linear-gradient(90deg, #1a2a4a, #2a3f6f);
                box-shadow: 0 4px 12px rgba(26, 42, 74, .22);
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .btn-visualizar:hover {
                filter: brightness(1.05);
            }

            .btn-visualizar:disabled {
                opacity: 0.45;
                cursor: not-allowed;
                filter: none;
            }

            .upload-hint {
                font-size: 12px;
                color: #666;
                margin-top: 10px;
                line-height: 1.4;
            }

            .msg-bajo-pdf {
                margin-top: 12px;
                min-height: 0;
            }

            .lbl-archivo-ok {
                font-size: 13px;
                color: #1e7e34;
                font-weight: 600;
                display: block;
                margin-top: 8px;
            }

            @keyframes spin {
                from {
                    transform: rotate(0deg);
                }

                to {
                    transform: rotate(360deg);
                }
            }

            .btn-submit {
                height: 42px;
                padding: 0 20px;
                border: 1.5px solid transparent;
                border-radius: 9px;
                color: #fff;
                font-size: 13px !important;
                font-family: inherit !important;
                font-weight: 700;
                cursor: pointer;
                background: linear-gradient(135deg, #2a3f6f, #1a2a4a);
                transition: opacity .2s;
                box-shadow: 0 6px 16px rgba(26, 42, 74, .22);
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .btn-submit-correccion {
                margin-left: 20px;
            }

            .btn-submit:hover {
                opacity: 0.94;
            }

            .btn-submit-correccion {
                padding: 14px 32px;
                font-size: 14px;
                border-radius: 10px;
            }

            #lblMensaje {
                display: block;
            }

            .modal-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                z-index: 3000;
                align-items: center;
                justify-content: center
            }

            .modal-box {
                background: #fff;
                border-radius: 14px;
                width: min(420px, 92vw);
                box-shadow: 0 20px 60px rgba(0, 0, 0, .35);
                overflow: hidden
            }

            .modal-head {
                background: linear-gradient(135deg, #1a2a4a, #2a3f6f);
                color: #fff;
                padding: 18px 24px;
                font-size: 16px;
                font-weight: 700
            }

            .modal-body {
                padding: 20px 24px;
                font-size: 14px;
                color: #444;
                line-height: 1.6
            }

            .modal-actions {
                padding: 14px 24px 18px;
                display: flex;
                justify-content: flex-end;
                gap: 10px
            }

            .btn-modal-ok {
                padding: 10px 24px;
                border-radius: 8px;
                font-size: 13px;
                font-weight: 700;
                cursor: pointer;
                border: none;
                background: linear-gradient(135deg, #1a2a4a, #2a3f6f);
                color: #fff;
                box-shadow: 0 4px 12px rgba(26, 42, 74, .22)
            }

            .btn-modal-ok:hover {
                filter: brightness(1.08)
            }

            /* Modal Éxito */
            .modal-exito-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.6);
                z-index: 9000;
                align-items: center;
                justify-content: center
            }

            .modal-exito-box {
                background: #fff;
                border-radius: 16px;
                width: min(400px, 92vw);
                box-shadow: 0 24px 64px rgba(0, 0, 0, .35);
                overflow: hidden;
                text-align: center
            }

            .modal-exito-head {
                background: linear-gradient(135deg, #2e7d32, #43a047);
                padding: 28px 24px 20px
            }

            .modal-exito-icon {
                width: 56px;
                height: 56px;
                background: rgba(255, 255, 255, .2);
                border-radius: 50%;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 12px
            }

            .modal-exito-icon svg {
                width: 30px;
                height: 30px;
                fill: #fff
            }

            .modal-exito-title {
                color: #fff;
                font-size: 17px;
                font-weight: 700;
                margin: 0
            }

            .modal-exito-body {
                padding: 20px 24px 24px
            }

            .modal-exito-msg {
                font-size: 13px;
                color: #555;
                margin-bottom: 16px;
                line-height: 1.5
            }

            .modal-exito-bar-wrap {
                background: #e8f5e9;
                border-radius: 8px;
                height: 6px;
                overflow: hidden
            }

            .modal-exito-bar {
                height: 100%;
                background: linear-gradient(90deg, #2e7d32, #43a047);
                width: 100%;
                border-radius: 8px;
                transition: width linear
            }

            /* ── Comparación de versiones PDF ── */

            .btn-comparar {
                display: none;
                height: 42px;
                align-items: center;
                justify-content: center;
                font-size: 13px;
                color: #fff;
                padding: 0 20px;
                border-radius: 9px;
                background: linear-gradient(135deg, #3d5faf, #2a4588);
                border: 1.5px solid #1e3770;
                box-shadow: 0 4px 14px rgba(42, 69, 136, .35);
                text-decoration: none;
                font-weight: 700;
                cursor: pointer;
                font-family: inherit
            }

            .btn-comparar:hover {
                background: linear-gradient(135deg, #4a6fc4, #335099);
                border-color: #2a4588;
                box-shadow: 0 6px 18px rgba(42, 69, 136, .42)
            }

            .btn-cerrar-cmp {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 12px;
                color: #fff;
                padding: 10px 16px;
                border-radius: 10px;
                background: linear-gradient(135deg, #c0392b, #8b1a1a);
                border: 1px solid #7d1717;
                font-weight: 700;
                cursor: pointer;
                font-family: inherit;
                border: none;
            }

            .btn-cerrar-cmp:hover {
                filter: brightness(1.08)
            }

            /* ── Modal Comparación ── */
            .modal-comparacion-overlay {
                display: none;
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.7);
                z-index: 5000;
                align-items: center;
                justify-content: center;
                padding: 20px;
            }

            /* Asegurar que el popover de observaciones se vea por encima del modal */
            .pdf-marker-popover {
                z-index: 6000 !important;
            }

            .modal-comparacion-box {
                background: #fff;
                border-radius: 14px;
                width: 95vw;
                max-width: 1400px;
                height: 90vh;
                max-height: 90vh;
                box-shadow: 0 24px 80px rgba(0, 0, 0, .45);
                display: flex;
                flex-direction: column;
                overflow: hidden;
            }

            .modal-comparacion-head {
                background: linear-gradient(135deg, #1a2a4a, #2a3f6f);
                color: #fff;
                padding: 16px 24px;
                display: flex;
                align-items: center;
                justify-content: space-between;
                flex-shrink: 0;
            }

            .modal-comparacion-head h2 {
                font-size: 16px;
                font-weight: 700;
                margin: 0;
                color: #fff;
            }

            .modal-comparacion-body {
                flex: 1;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                min-height: 0;
            }

            .pdf-compare-bar {
                background: #fafbfd;
                border-bottom: 1px solid #eef0f8;
                padding: 10px 18px;
                margin: 0;
                flex-shrink: 0;
            }

            .pdf-compare-hint {
                font-size: 12px;
                color: #5c6478;
                line-height: 1.45
            }

            .pdf-compare-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 0;
                flex: 1;
                min-height: 0;
                width: 100%;
                overflow: hidden;
                background: #3a3a42
            }

            .pdf-col {
                display: flex;
                flex-direction: column;
                min-width: 0;
                background: #2a2a32;
                overflow: hidden;
                box-shadow: inset 0 0 0 1px rgba(0, 0, 0, .15);
                min-height: 0
            }

            .pdf-col-title {
                font-size: 11px;
                font-weight: 700;
                padding: 10px 12px;
                background: #1a2a4a;
                color: #fff;
                text-transform: uppercase;
                letter-spacing: .4px;
                flex-shrink: 0
            }

            .pdf-col iframe {
                flex: 1;
                min-height: 380px;
                border: none;
                width: 100%;
                background: #52525b
            }

            .pdf-col .pdf-viewer-host {
                flex: 1;
                min-height: 0;
            }

            .pdf-compare-grid.pdf-mode-prev,
            .pdf-compare-grid.pdf-mode-next {
                grid-template-columns: 1fr !important
            }

            /* Actions row: all aligned to the right */
            .actions-row {
                display: flex;
                justify-content: flex-end;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
            }

            .actions-left {
                display: flex;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
            }

            .actions-right {
                display: flex;
                align-items: center;
                gap: 12px;
                flex-wrap: wrap;
            }

            @media (max-width:1100px) {
                .pdf-compare-grid:not(.pdf-mode-prev):not(.pdf-mode-next) {
                    grid-template-columns: 1fr
                }
            }

            /* Searchable combo */
            .combo-search-wrap{position:relative}
            .combo-search-input{width:100%;padding:12px 36px 12px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;color:#333;font-family:'Segoe UI',sans-serif;outline:none;background:white;cursor:text;transition:border-color .2s}
            .combo-search-input:focus{border-color:#1a2a4a}
            .combo-search-input.has-value{font-weight:600;color:#1a2a4a}
            .combo-search-icon{position:absolute;right:12px;top:50%;transform:translateY(-50%);pointer-events:none;width:16px;height:16px;fill:#999}
            .combo-search-clear{position:absolute;right:34px;top:50%;transform:translateY(-50%);background:none;border:none;cursor:pointer;width:20px;height:20px;font-size:16px;color:#c0392b;display:none;padding:0;line-height:1}
            .combo-search-clear:hover{color:#8b1a1a}
            .combo-dropdown{display:none;position:absolute;top:100%;left:0;right:0;background:white;border:1.5px solid #1a2a4a;border-top:none;border-radius:0 0 8px 8px;max-height:220px;overflow-y:auto;z-index:1000;box-shadow:0 8px 16px rgba(0,0,0,.1);animation:gpSlideDown .15s ease-out}
            .combo-dropdown-item{padding:10px 16px;cursor:pointer;font-size:13px;color:#333;border-bottom:1px solid #f0f0f0;transition:all .15s}
            .combo-dropdown-item:last-child{border-bottom:none}
            .combo-dropdown-item:hover{background:#f0f2ff;padding-left:20px;color:#1a2a4a;font-weight:600}
            .combo-dropdown-item.selected{background:#e8f5e9;color:#2e7d32;font-weight:600}
            .combo-dropdown-empty{padding:14px 16px;text-align:center;color:#999;font-size:13px}
            @keyframes gpSlideDown{from{opacity:0;transform:translateY(-5px)}to{opacity:1;transform:translateY(0)}}
        </style>
    </head>

    <body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
        <form id="form1" runat="server" enctype="multipart/form-data"
            style="display:flex;width:100%;height:100vh;overflow:hidden;">
            <div style="display:flex;width:100%;height:100vh;overflow:hidden;">
                <!-- SIDEBAR -->
                <div class="sidebar">
                    <div class="sidebar-logo">
                        <div class="logo-icon">
                            <svg viewBox="0 0 24 24">
                                <path
                                    d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"
                                    fill="currentColor" />
                            </svg>
                        </div>
                        <div class="logo-text">
                            <div class="top">SIGEFIDD<span>-ZOFRA</span></div>
                            <div class="bot">ZONA FRANCA DE TACNA</div>
                        </div>
                    </div>
                    <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
                        <div style="flex:1;overflow-y:auto">
                            <asp:Literal ID="litSidebarNav" runat="server" />
                        </div>
                        <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout"
                            OnClick="btnCerrarSesion_Click" />
                    </nav>
                </div>

                <!-- MAIN CONTENT -->
                <div class="main">
                    <!-- TOPBAR -->
                    <div class="topbar">
                        <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Editar Documento</div>
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

                    <!-- CONTENT -->
                    <div runat="server" id="divContentArea" class="content">
                        <div class="head">
                            <div>
                                <h1>Editar Documento</h1>
                            </div>
                            <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap;">
                                <a class="btn-back"
                                    href='VerObservaciones.aspx?id=<%= Request.QueryString["id"] %>'><span
                                        class="btn-back-arrow" aria-hidden="true">&#8592;</span> Regresar</a>
                            </div>
                        </div>

                        <!-- CÓDIGO DOCUMENTO (un solo campo, igual que en Cargar documento) -->
                        <div class="form-group">
                            <label class="form-label">C&Oacute;DIGO DE DOCUMENTO <span class="required">*</span></label>
                            <asp:TextBox ID="txtCodigoDocumentoCompleto" runat="server" CssClass="form-input"
                                MaxLength="120"
                                placeholder="Ej: RS-0001-2026 (c&oacute;digo completo tal como se guarda en BD)" />
                            <span id="errCodigoEspecial" style="display: none; color: #c0392b; font-size: 11px; margin-top: 4px; font-weight: 600;">error en el nombre no uses caracteres especiales</span>
                            <p style="font-size:11px;color:#999;margin-top:6px;line-height:1.4;">
                                Edite el c&oacute;digo completo manualmente si corresponde (prefijo, correlativo y
                                a&ntilde;o seg&uacute;n su formato institucional).
                            </p>
                        </div>

                        <!-- ASUNTO -->
                        <div class="form-group">
                            <label class="form-label">ASUNTO <span class="required">*</span></label>
                            <asp:TextBox ID="txtAsunto" runat="server" CssClass="form-input" />
                        </div>

                        <!-- DESCRIPCIÓN -->
                        <div class="form-group">
                            <label class="form-label">DESCRIPCIÓN</label>
                            <asp:TextBox ID="txtDescripcion" runat="server" TextMode="MultiLine" CssClass="form-input"
                                Rows="3" />
                        </div>

                        <!-- CATEGORÍA Y PRIORIDAD -->
                        <div class="form-row">
                            <div>
                                <label class="form-label">CATEGORÍA <span class="required">*</span></label>
                                <div class="combo-search-wrap">
                                    <input type="text" id="txtComboCategoria" class="combo-search-input" placeholder="Buscar categoría..." autocomplete="off" />
                                    <button type="button" id="btnClearCategoria" class="combo-search-clear" title="Limpiar">&times;</button>
                                    <svg class="combo-search-icon" viewBox="0 0 24 24"><path d="M7 10l5 5 5-5z"/></svg>
                                    <div id="dropdownCategoria" class="combo-dropdown"></div>
                                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-input" style="display:none" />
                                </div>
                                <div style="font-size:11px;color:#999;margin-top:4px">Escriba para filtrar las categorías disponibles</div>
                            </div>
                            <div>
                                <label class="form-label">PRIORIDAD <span class="required">*</span></label>
                                <div class="combo-search-wrap">
                                    <input type="text" id="txtComboPrioridad" class="combo-search-input" placeholder="Buscar prioridad..." autocomplete="off" />
                                    <button type="button" id="btnClearPrioridad" class="combo-search-clear" title="Limpiar">&times;</button>
                                    <svg class="combo-search-icon" viewBox="0 0 24 24"><path d="M7 10l5 5 5-5z"/></svg>
                                    <div id="dropdownPrioridad" class="combo-dropdown"></div>
                                    <asp:DropDownList ID="ddlPrioridad" runat="server" CssClass="form-input" style="display:none">
                                        <asp:ListItem Value="">Seleccionar...</asp:ListItem>
                                        <asp:ListItem Value="ALTA">Alta</asp:ListItem>
                                        <asp:ListItem Value="MEDIA">Media</asp:ListItem>
                                        <asp:ListItem Value="BAJA">Baja</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div style="font-size:11px;color:#999;margin-top:4px">Escriba para filtrar las prioridades disponibles</div>
                            </div>
                        </div>

                        <!-- PLAZOS -->
                        <div class="form-row">
                            <div>
                                <label class="form-label">PLAZO REVISIÓN (HORAS)</label>
                                <asp:TextBox ID="txtPlazoRevision" runat="server" CssClass="form-input"
                                    placeholder="24" />
                            </div>
                            <div>
                                <label class="form-label">PLAZO FIRMA (HORAS)</label>
                                <asp:TextBox ID="txtPlazoFirma" runat="server" CssClass="form-input" placeholder="48" />
                            </div>
                        </div>

                        <!-- SECCIÓN DOS COLUMNAS: OBSERVACIONES Y NUEVO PDF -->
                        <div class="form-row" style="align-items: stretch; margin-bottom: 24px;">
                            <!-- OBSERVACIONES (Izquierda) -->
                            <div class="box" style="margin-bottom: 0; display: flex; flex-direction: column;">
                                <div class="form-label" style="margin-bottom:12px">OBSERVACIONES</div>
                                <div style="flex: 1; overflow-y: auto; max-height: 280px; padding-right: 4px;">
                                    <asp:Literal ID="litObservaciones" runat="server" />
                                </div>
                            </div>

                            <!-- NUEVO PDF (Derecha) -->
                            <div class="box" style="margin-bottom: 0; display: flex; flex-direction: column;">
                                <div class="form-label" style="margin-bottom:12px">NUEVO PDF (OPCIONAL)</div>
                                <div class="upload-zone" style="flex: 1; display: flex; flex-direction: column; align-items: center; justify-content: center;"
                                    onclick="var el=document.getElementById('<%= filePDF.ClientID %>'); if(el) el.click();">
                                    <svg viewBox="0 0 24 24" style="width:36px;height:36px;fill:#aab;margin-bottom:10px;"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zm-2 8H7v-2h4v2zm6-4H7v-2h10v2z"/></svg>
                                    <div style="font-weight:600; color:#555; margin-bottom: 4px;">Clic para seleccionar un nuevo PDF</div>
                                    <div style="font-size:12px; color:#aaa;">Solo PDF, m&aacute;x. 50 MB</div>
                                    <asp:FileUpload ID="filePDF" runat="server" Accept=".pdf"
                                        onchange="editDocMostrarArchivoYVisor();" />
                                </div>
                                <p class="upload-hint" style="text-align:center;">Si adjunta un PDF, puede previsualizarlo antes de enviar la
                                    corrección.</p>
                                <div class="msg-bajo-pdf" style="text-align:center;">
                                    <span id="editDocLblArchivo" class="lbl-archivo-ok" style="display:none;"
                                        aria-live="polite"></span>
                                    <div id="editDocMsgCliente" class="alert-err" style="display:none;margin-top:8px;">
                                    </div>
                                    <asp:Label ID="lblMensaje" runat="server" EnableViewState="true"
                                        Style="display:none;" />
                                </div>
                            </div>
                        </div>

                        <!-- BOTONES ACCIÓN -->
                        <div class="actions-row">
                            <button type="button" id="btnCompararDocumento" class="btn-comparar"
                                onclick="editDocAbrirComparacion();" title="Comparar con el documento observado">
                                📄 Comparar Documento</button>
                            <button type="button" id="btnVisualizarPdf" class="btn-visualizar" style="display:none;"
                                onclick="editDocAbrirVisorPdf();">👁 Ver documento</button>
                            <asp:Button ID="btnEnviarCorreccion" runat="server" Text="✈️ Enviar Corrección"
                                CssClass="btn-submit btn-submit-correccion" OnClick="btnEnviarCorreccion_Click"
                                OnClientClick="return editDocValidarAntesEnviar();" />
                        </div>

                        <!-- ══ MODAL COMPARAR DOCUMENTO (100% cliente) ══ -->
                        <div id="modalComparacionOverlay" class="modal-comparacion-overlay">
                            <div class="modal-comparacion-box">
                                <div class="modal-comparacion-head">
                                    <h2>Comparaci&oacute;n: Observado vs. Nuevo</h2>
                                    <button type="button" class="btn-cerrar-cmp" onclick="editDocCerrarComparacion();"
                                        title="Cerrar comparaci&oacute;n">✕ Cerrar</button>
                                </div>
                                <div class="modal-comparacion-body">
                                    <div class="pdf-compare-bar">
                                        <p class="pdf-compare-hint">Panel izquierdo: PDF vigente con marcadores de observaci&oacute;n.
                                            Panel derecho: el nuevo PDF que acaba de subir.</p>
                                    </div>
                                    <div class="pdf-compare-grid">
                                        <div class="pdf-col">
                                            <div class="pdf-col-title">📌 Documento observado (con marcadores)</div>
                                            <div id="cmpPdfViewerHost" class="pdf-viewer-host"></div>
                                        </div>
                                        <div class="pdf-col">
                                            <div class="pdf-col-title">📄 Nuevo documento (subido)</div>
                                            <iframe id="cmpPdfNuevoIframe" style="flex:1;width:100%;border:none;min-height:380px;background:#52525b;"></iframe>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Modal visor PDF (mismo criterio que CargarDocumento) -->
                        <div id="modalVisorPDFEdit"
                            style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:2000;align-items:center;justify-content:center;">
                            <div
                                style="background:white;border-radius:12px;width:95%;height:95%;max-width:900px;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
                                <div
                                    style="display:flex;justify-content:space-between;align-items:center;padding:16px 24px;border-bottom:1.5px solid #e8eaf0;background:#f8f9fc;">
                                    <div style="font-size:16px;font-weight:700;color:#1a2a4a;">Previsualización de
                                        documento PDF</div>
                                    <button type="button" onclick="editDocCerrarVisorPdf()"
                                        style="background:none;border:none;font-size:28px;cursor:pointer;color:#999;padding:0;width:36px;height:36px;display:flex;align-items:center;justify-content:center;border-radius:8px;line-height:1;"
                                        title="Cerrar" aria-label="Cerrar">✕</button>
                                </div>
                                <div id="visorPDFEditContenedor"
                                    style="flex:1;overflow:hidden;display:flex;align-items:center;justify-content:center;background:#3a3a42;min-height:200px;">
                                    <div id="pdfSpinnerEdit" style="text-align:center;padding:24px;">
                                        <div style="font-size:14px;color:#ccc;margin-bottom:16px;">Cargando documento…
                                        </div>
                                        <div
                                            style="width:40px;height:40px;border:4px solid #555;border-top-color:#fff;border-radius:50%;animation:spin 0.8s linear infinite;margin:0 auto;">
                                        </div>
                                    </div>
                                    <iframe id="pdfIframeEdit"
                                        style="width:100%;height:100%;border:none;display:none;min-height:400px;"></iframe>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="zfnToastHost" class="zfn-toast-host"></div>
            <!-- Modal Éxito Corrección -->
            <div id="modalExitoCorreccion" class="modal-exito-overlay" aria-hidden="true">
                <div class="modal-exito-box">
                    <div class="modal-exito-head">
                        <div class="modal-exito-icon">
                            <svg viewBox="0 0 24 24">
                                <path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z" />
                            </svg>
                        </div>
                        <p class="modal-exito-title">Corrección enviada correctamente.</p>
                    </div>
                    <div class="modal-exito-body">
                        <p class="modal-exito-msg">Redirigiendo a Mis Documentos en unos segundos&hellip;</p>
                        <div class="modal-exito-bar-wrap">
                            <div id="barraExitoCorreccion" class="modal-exito-bar"></div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Modal Bloqueo Admin -->
                <div id="modalBloqueoAdmin" class="modal-overlay" aria-hidden="true" style="<%= ModoBloqueado ? "display:flex;" : "display:none;" %>">
                <div class="modal-box">
                    <div class="modal-head">Documento en edici&oacute;n</div>
                    <div class="modal-body">
                        <%= System.Web.HttpUtility.HtmlEncode(MensajeBloqueo) %>.
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn-modal-ok"
                            onclick="window.history.length > 1 ? window.history.back() : window.location.href='MisDocumentos.aspx'">Ok</button>
                    </div>
                </div>
            </div>
            <!-- Modal de Bloqueo por Firmas -->
            <div id="modalBloqueoFirmas" class="modal-overlay" aria-hidden="true" style="display:none;">
                <div class="modal-box">
                    <div class="modal-head" style="background: linear-gradient(135deg, #c0392b, #8b1a1a);">Documento Inválido</div>
                    <div class="modal-body">
                        No se puede cargar el documento ya que cuenta con una <strong>firma digital previa</strong>. Por favor, elimine la firma o suba un documento original sin firmas.
                    </div>
                    <div class="modal-actions">
                        <button type="button" class="btn-modal-ok"
                            onclick="document.getElementById('modalBloqueoFirmas').style.display='none';">Entendido</button>
                    </div>
                </div>
            </div>
        </form>
        <script type="text/javascript">
            window.editDocPdfArchivo = null;
            window.editDocPdfBlobUrl = null;
            window.editDocCmpBlobUrl = null;
            window.editDocCmpVisor = null;
            window.editDocLockTimer = null;
            window.editDocBloqueado = '<%= ModoBloqueado ? "1" : "0" %>' === '1';
            window.editDocId = parseInt('<%= Request.QueryString["id"] ?? "0" %>', 10) || 0;
            window.editDocLockToken = '<%= LockToken %>';
            window.editDocPdfVigenteUrl = '<%= PdfVigenteUrl %>';
            window.editDocMarcadorApiUrl = '<%= ResolveUrl("~/Presentacion/BandejaTrabajo/ObservacionMarcador.ashx") %>';
            window.editDocUsarMarcadores = '<%= UsarVisorMarcadores ? "1" : "0" %>' === '1';

            function editDocGet(id) { return document.getElementById(id); }

            function editDocMostrarArchivoYVisor() {
                var fileInput = editDocGet('<%= filePDF.ClientID %>');
                var lblArchivo = editDocGet('editDocLblArchivo');
                var btnVis = editDocGet('btnVisualizarPdf');
                var btnCmp = editDocGet('btnCompararDocumento');
                var msgCli = editDocGet('editDocMsgCliente');
                if (msgCli) { msgCli.style.display = 'none'; msgCli.textContent = ''; }
                if (!fileInput || !lblArchivo) return;
                
                if (fileInput.files.length > 0) {
                    var archivo = fileInput.files[0];
                    var mb = (archivo.size / (1024 * 1024)).toFixed(2);

                    // Validación cliente de firmas previas usando FileReader
                    var reader = new FileReader();
                    reader.onload = function(e) {
                        var content = e.target.result;
                        if (content.indexOf('/ByteRange') !== -1 && (content.indexOf('/adbe.pkcs7.detached') !== -1 || content.indexOf('/Adobe.PPKLite') !== -1)) {
                            document.getElementById('modalBloqueoFirmas').style.display = 'flex';
                            fileInput.value = ''; // Limpiar el input
                            lblArchivo.innerHTML = '';
                            lblArchivo.style.display = 'none';
                            if (btnVis) btnVis.style.display = 'none';
                            if (btnCmp) btnCmp.style.display = 'none';
                            window.editDocPdfArchivo = null;
                            return;
                        }
                        
                        // Si todo está bien, mostrar nombre y botones
                        lblArchivo.innerHTML = '✓ <strong>Archivo listo:</strong> ' + archivo.name.replace(/</g, '&lt;') + ' (' + mb + ' MB). Puede enviar la corrección o cambiar el archivo.';
                        lblArchivo.style.display = 'block';
                        lblArchivo.style.color = '#1e7e34';
                        if (btnVis) btnVis.style.display = 'inline-flex';
                        if (btnCmp && window.editDocPdfVigenteUrl) btnCmp.style.display = 'inline-flex';
                        window.editDocPdfArchivo = archivo;
                    };
                    reader.readAsText(archivo);

                } else {
                    lblArchivo.innerHTML = '';
                    lblArchivo.style.display = 'none';
                    if (btnVis) btnVis.style.display = 'none';
                    if (btnCmp) btnCmp.style.display = 'none';
                    window.editDocPdfArchivo = null;
                }
            }

            /* ── Comparación: abrir modal ── */
            function editDocAbrirComparacion() {
                if (!window.editDocPdfArchivo) {
                    alert('Seleccione un archivo PDF primero.');
                    return;
                }
                var modal = editDocGet('modalComparacionOverlay');
                if (!modal) return;
                modal.style.display = 'flex';

                // Panel derecho: nuevo PDF (blob)
                var ifrNuevo = editDocGet('cmpPdfNuevoIframe');
                if (ifrNuevo) {
                    if (window.editDocCmpBlobUrl) {
                        try { URL.revokeObjectURL(window.editDocCmpBlobUrl); } catch (e) { }
                    }
                    window.editDocCmpBlobUrl = URL.createObjectURL(window.editDocPdfArchivo);
                    ifrNuevo.src = window.editDocCmpBlobUrl;
                }

                // Panel izquierdo: PDF vigente con marcadores
                var host = editDocGet('cmpPdfViewerHost');
                if (host && window.editDocPdfVigenteUrl) {
                    if (window.editDocCmpVisor) {
                        // Ya fue inicializado, refrescar marcadores
                        window.editDocCmpVisor.refrescar();
                    } else if (window.editDocUsarMarcadores && window.PdfObservacionesVisor) {
                        // Inicializar visor PDF.js con marcadores
                        window.editDocCmpVisor = PdfObservacionesVisor.create({
                            host: host,
                            pdfUrl: window.editDocPdfVigenteUrl,
                            apiUrl: window.editDocMarcadorApiUrl,
                            idDocumento: window.editDocId,
                            login: '',
                            modo: 'ver',
                            puedeAnotar: false
                        });
                        window.editDocCmpVisor.init();
                    } else {
                        // Fallback: usar iframe simple si no hay marcadores
                        host.innerHTML = '<iframe src="' + window.editDocPdfVigenteUrl + '" style="width:100%;height:100%;border:none;"></iframe>';
                    }
                }
            }

            /* ── Comparación: cerrar modal ── */
            function editDocCerrarComparacion() {
                var modal = editDocGet('modalComparacionOverlay');
                if (modal) modal.style.display = 'none';
                var ifrNuevo = editDocGet('cmpPdfNuevoIframe');
                if (ifrNuevo) ifrNuevo.src = '';
                if (window.editDocCmpBlobUrl) {
                    try { URL.revokeObjectURL(window.editDocCmpBlobUrl); } catch (e) { }
                    window.editDocCmpBlobUrl = null;
                }
            }

            function editDocAbrirVisorPdf() {
                if (!window.editDocPdfArchivo) {
                    alert('Seleccione un archivo PDF primero.');
                    return;
                }
                var modal = editDocGet('modalVisorPDFEdit');
                var iframe = editDocGet('pdfIframeEdit');
                var spinner = editDocGet('pdfSpinnerEdit');
                if (!modal || !iframe || !spinner) return;
                modal.style.display = 'flex';
                spinner.style.display = 'block';
                iframe.style.display = 'none';
                if (window.editDocPdfBlobUrl) {
                    try { URL.revokeObjectURL(window.editDocPdfBlobUrl); } catch (e) { }
                }
                try {
                    window.editDocPdfBlobUrl = URL.createObjectURL(window.editDocPdfArchivo);
                    iframe.src = window.editDocPdfBlobUrl;
                    setTimeout(function () {
                        spinner.style.display = 'none';
                        iframe.style.display = 'block';
                    }, 400);
                } catch (ex) {
                    spinner.innerHTML = '<div style="color:#ffb4b4;font-size:14px;">No se pudo abrir la vista previa.</div>';
                }
            }

            function editDocCerrarVisorPdf() {
                var modal = editDocGet('modalVisorPDFEdit');
                var iframe = editDocGet('pdfIframeEdit');
                var spinner = editDocGet('pdfSpinnerEdit');
                if (modal) modal.style.display = 'none';
                if (iframe) {
                    iframe.onload = null;
                    iframe.src = '';
                    iframe.style.display = 'none';
                }
                if (spinner) {
                    spinner.style.display = 'block';
                    spinner.innerHTML = '<div style="font-size:14px;color:#ccc;margin-bottom:16px;">Cargando documento…</div><div style="width:40px;height:40px;border:4px solid #555;border-top-color:#fff;border-radius:50%;animation:spin 0.8s linear infinite;margin:0 auto;"></div>';
                }
                if (window.editDocPdfBlobUrl) {
                    try { URL.revokeObjectURL(window.editDocPdfBlobUrl); } catch (e) { }
                    window.editDocPdfBlobUrl = null;
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                // Inicializar combos
                initComboSearch(
                    'txtComboCategoria', 'dropdownCategoria', 'btnClearCategoria',
                    '<%= ddlCategoria.ClientID %>'
                );
                initComboSearch(
                    'txtComboPrioridad', 'dropdownPrioridad', 'btnClearPrioridad',
                    '<%= ddlPrioridad.ClientID %>'
                );

                var modal = editDocGet('modalVisorPDFEdit');
                if (modal) {
                    modal.addEventListener('click', function (e) {
                        if (e.target === modal) editDocCerrarVisorPdf();
                    });
                }
                // Cerrar modal comparación al hacer clic en el overlay
                var modalCmp = editDocGet('modalComparacionOverlay');
                if (modalCmp) {
                    modalCmp.addEventListener('click', function (e) {
                        if (e.target === modalCmp) editDocCerrarComparacion();
                    });
                }
                if (!window.editDocBloqueado && window.editDocId > 0 && window.editDocLockToken) {
                    editDocEnviarBloqueo('touch');
                    window.editDocLockTimer = setInterval(function () { editDocEnviarBloqueo('touch'); }, 15000);
                }
            });

            // ============================================================
            // SEARCHABLE COMBO: Categoría y Prioridad
            // ============================================================
            function initComboSearch(inputId, dropdownId, clearBtnId, ddlClientId) {
                var input = document.getElementById(inputId);
                var dropdown = document.getElementById(dropdownId);
                var clearBtn = document.getElementById(clearBtnId);
                var ddl = document.getElementById(ddlClientId);
                if (!input || !dropdown || !ddl) return;

                // Extraer opciones del DDL oculto
                var allItems = [];
                for (var i = 0; i < ddl.options.length; i++) {
                    var opt = ddl.options[i];
                    if (opt.value === '' || opt.value === 'Seleccionar...') continue;
                    allItems.push({ value: opt.value, text: opt.text });
                }

                // Si ya hay un valor seleccionado, mostrarlo
                if (ddl.value && ddl.value !== '') {
                    var selOpt = ddl.options[ddl.selectedIndex];
                    if (selOpt && selOpt.value !== '') {
                        input.value = selOpt.text;
                        input.classList.add('has-value');
                        if (clearBtn) clearBtn.style.display = 'block';
                    }
                }

                function renderDropdown(filtro) {
                    var filtered = allItems;
                    if (filtro && filtro.length > 0) {
                        var term = filtro.toLowerCase();
                        filtered = allItems.filter(function (it) { return it.text.toLowerCase().indexOf(term) >= 0; });
                    }
                    if (filtered.length === 0) {
                        dropdown.innerHTML = '<div class="combo-dropdown-empty">No se encontraron resultados</div>';
                    } else {
                        var html = '';
                        filtered.forEach(function (it) {
                            var sel = ddl.value === it.value ? ' selected' : '';
                            html += '<div class="combo-dropdown-item' + sel + '" data-val="' + it.value + '">' + it.text + '</div>';
                        });
                        dropdown.innerHTML = html;
                        // Click en cada item
                        dropdown.querySelectorAll('.combo-dropdown-item').forEach(function (el) {
                            el.addEventListener('click', function () {
                                var val = this.getAttribute('data-val');
                                var txt = this.textContent;
                                ddl.value = val;
                                input.value = txt;
                                input.classList.add('has-value');
                                dropdown.style.display = 'none';
                                if (clearBtn) clearBtn.style.display = 'block';
                            });
                        });
                    }
                    dropdown.style.display = 'block';
                }

                // Al escribir, filtrar
                input.addEventListener('input', function () {
                    var val = this.value.trim();
                    if (val.length === 0) {
                        renderDropdown('');
                    } else {
                        renderDropdown(val);
                    }
                    // Si el texto no coincide exactamente, limpiar selección
                    var matchExact = allItems.find(function (it) { return it.text === input.value; });
                    if (!matchExact) {
                        ddl.value = '';
                        input.classList.remove('has-value');
                        if (clearBtn) clearBtn.style.display = 'none';
                    }
                });

                // Al hacer foco, mostrar todo si está vacío o filtrar si hay texto
                input.addEventListener('focus', function () {
                    renderDropdown(this.value.trim());
                });

                // Limpiar
                if (clearBtn) {
                    clearBtn.addEventListener('click', function () {
                        input.value = '';
                        ddl.value = '';
                        input.classList.remove('has-value');
                        clearBtn.style.display = 'none';
                        input.focus();
                        renderDropdown('');
                    });
                }

                // Cerrar al hacer clic fuera
                document.addEventListener('click', function (e) {
                    if (!input.contains(e.target) && !dropdown.contains(e.target) && (!clearBtn || !clearBtn.contains(e.target))) {
                        dropdown.style.display = 'none';
                    }
                });
            }

            function editDocValidarAntesEnviar() {
                var msgCli = editDocGet('editDocMsgCliente');
                var lblSrv = editDocGet('<%= lblMensaje.ClientID %>');
                if (lblSrv) { lblSrv.style.display = 'none'; }

                var errSpan = document.getElementById('errCodigoEspecial');
                if (errSpan) errSpan.style.display = 'none';

                var errores = [];
                var codCompleto = (editDocGet('<%= txtCodigoDocumentoCompleto.ClientID %>') || {}).value || '';
                var asunto = (editDocGet('<%= txtAsunto.ClientID %>') || {}).value || '';
                var cat = (editDocGet('<%= ddlCategoria.ClientID %>') || {}).value || '';
                var pri = (editDocGet('<%= ddlPrioridad.ClientID %>') || {}).value || '';

                if (/[<>]/.test(codCompleto)) {
                    if (errSpan) {
                        errSpan.style.display = 'block';
                        errSpan.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    } else {
                        alert('error en el nombre no uses caracteres especiales');
                    }
                    return false;
                }

                if (!codCompleto.trim()) errores.push('Código de documento (completo)');
                if (!asunto.trim()) errores.push('Asunto');
                if (!cat) errores.push('Categoría');
                if (!pri) errores.push('Prioridad');
                if (errores.length > 0) {
                    if (msgCli) {
                        msgCli.style.display = 'block';
                        msgCli.innerHTML = 'Complete los siguientes campos: <strong>' + errores.join('</strong>, <strong>') + '</strong>.';
                    }
                    return false;
                }
                if (msgCli) { msgCli.style.display = 'none'; msgCli.textContent = ''; }
                return true;
            }

            function editDocEnviarBloqueo(accion) {
                if (!window.editDocId || !window.editDocLockToken) return;
                var url = '<%= ResolveUrl("~/Presentacion/BloqueoFlujo.ashx") %>'
                    + '?accion=' + encodeURIComponent(accion)
                    + '&idDocumento=' + encodeURIComponent(window.editDocId)
                    + '&tipo=REG_EDIT'
                    + '&token=' + encodeURIComponent(window.editDocLockToken);
                try { fetch(url, { method: 'GET', credentials: 'same-origin', keepalive: accion === 'release' }); } catch (e) { }
            }

            window.addEventListener('beforeunload', function () {
                if (window.editDocLockTimer) {
                    clearInterval(window.editDocLockTimer);
                    window.editDocLockTimer = null;
                }
                editDocEnviarBloqueo('release');
            });

            function mostrarModalExitoEditar(urlDestino) {
                var modal = editDocGet('modalExitoCorreccion');
                var barra = editDocGet('barraExitoCorreccion');
                if (!modal || !barra) {
                    window.location.href = urlDestino;
                    return;
                }
                modal.style.display = 'flex';
                modal.setAttribute('aria-hidden', 'false');
                barra.style.width = '100%';
                barra.style.transition = 'none';
                requestAnimationFrame(function () {
                    requestAnimationFrame(function () {
                        barra.style.transition = 'width 3s linear';
                        barra.style.width = '0%';
                    });
                });
                setTimeout(function () {
                    window.location.href = urlDestino;
                }, 3200);
            }
        </script>
    </body>

    </html>