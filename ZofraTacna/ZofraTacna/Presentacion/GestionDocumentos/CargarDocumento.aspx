<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CargarDocumento.aspx.cs" Inherits="ZofraTacna.Presentacion.CargarDocumento" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8"/><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>SIGEFIDD-ZOFRA | Cargar Documento</title>
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
        .content .sub{font-size:13px;color:#888;margin-top:2px;margin-bottom:28px}
        .form-label{font-size:11px;font-weight:700;letter-spacing:1px;color:#555;margin-bottom:6px;display:block}
        .required{color:#c0392b}
        .form-input{width:100%;padding:12px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;color:#333;font-family:'Segoe UI',sans-serif;outline:none}
        .form-input:focus{border-color:#1a2a4a}
        textarea.form-input{resize:vertical;min-height:90px}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px}
        .form-group{margin-bottom:20px}
        .plazos-box{border:1.5px solid #e8eaf0;border-radius:12px;padding:20px;margin-bottom:20px}
        .plazos-box.plazos-zona-plazos{background:linear-gradient(165deg,#f2faf5 0%,#e3f2e8 45%,#f7fcf9 100%);border-color:#a8d4b8;box-shadow:0 2px 14px rgba(46,125,50,.09)}
        .plazos-box.plazos-zona-plazos .plazos-sub{color:#2e7d32}
        .plazos-box.plazos-zona-asignacion{background:linear-gradient(165deg,#f4f6ff 0%,#e8ecfc 40%,#fafbff 100%);border-color:#b8c4e8;box-shadow:0 2px 14px rgba(26,42,74,.08)}
        .plazos-box.plazos-zona-asignacion .plazos-sub{color:#3949ab}
        .plazos-title{font-size:14px;font-weight:600;color:#1a2a4a;margin-bottom:4px}
        .plazos-sub{font-size:12px;color:#3b5bdb;margin-bottom:16px}
        .plazos-hint{font-size:11px;color:#aaa;margin-top:4px}
        .upload-zone{border:2px dashed #b0b8d0;border-radius:10px;padding:40px;text-align:center;cursor:pointer;background:#fafbff;margin-bottom:24px;position:relative}
        .upload-zone:hover{border-color:#1a2a4a;background:#f0f2ff}
        .upload-zone svg{width:36px;height:36px;fill:#aab;margin-bottom:10px}
        .upload-zone .uz-title{font-size:14px;font-weight:500;color:#555;margin-bottom:4px}
        .upload-zone .uz-sub{font-size:12px;color:#aaa}
        .upload-zone input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer}
            .form-actions{display:flex;flex-wrap:wrap;gap:12px;justify-content:flex-end;align-items:center}
            .btn-accion{min-width:200px;padding:12px 24px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;box-sizing:border-box;text-align:center;line-height:1.25;white-space:nowrap}
            .btn-accion.btn-accion-cancel{min-width:132px;padding:12px 18px}
            .btn-submit{background:linear-gradient(90deg,#1a2a4a,#8b1a1a);color:white;border:none;box-shadow:0 4px 12px rgba(26,42,74,.2)}
            .btn-submit:hover{filter:brightness(1.05)}
            .btn-cancel{padding:12px 24px;background:white;color:#555;border:1.5px solid #ddd;border-radius:8px;font-size:14px;cursor:pointer}
            .btn-cancel-rojo{background:linear-gradient(135deg,#c0392b,#8b1a1a);color:white;border:1.5px solid #7d1717;box-shadow:0 4px 12px rgba(192,57,43,.25)}
            .btn-cancel-rojo:hover{background:linear-gradient(135deg,#d44736,#a32121)}
            .btn-visualizar{background:linear-gradient(90deg,#1a2a4a,#2a3f6f);color:white;border:1.5px solid #1a2a4a;box-shadow:0 4px 12px rgba(26,42,74,.25)}
            .btn-visualizar:hover{background:linear-gradient(90deg,#2a3f6f,#1a2a4a)}
            #btnVisualizar{margin-right:16px}
            @media (min-width:640px){#btnVisualizar{margin-right:28px}}
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
            .alert-ok{background:#d4edda;color:#155724;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px}
            .alert-err{background:#f8d7da;color:#721c24;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px}
            /* Estilos para buscador y participantes */
            .empleado-resultado{padding:10px 12px;border-bottom:1px solid #f0f0f0;cursor:pointer;font-size:13px;display:flex;justify-content:space-between;align-items:center}
            .empleado-resultado:hover{background:#f5f5f5}
            .empleado-nombre{font-weight:600;color:#1a2a4a}
            .empleado-login{font-size:11px;color:#999}
            .badge-novedad{background:#fff3cd;color:#856404;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600}
            .participante-tag{display:inline-flex;align-items:center;gap:8px;background:#e8eaf0;color:#1a2a4a;padding:8px 12px;border-radius:6px;font-size:12px;font-weight:600;margin:4px;cursor:move;position:relative;user-select:none}
            .participante-tag:hover{background:#d8dce0}
            .participante-tag .close-btn{cursor:pointer;color:#c0392b;font-weight:bold;padding:0 4px}
            .participante-tag .close-btn:hover{color:#8b1a1a}
            .orden-input{width:35px;height:32px;padding:4px;border:1.5px solid #ddd;border-radius:4px;text-align:center;font-size:12px;font-weight:600}
            .orden-input:focus{border-color:#1a2a4a;outline:none}
            .drop-zone-active{background:#e8f4ff !important;border-color:#1a2a4a !important}
            
            /* Estilos para el dropdown de búsqueda */
            #dropdownResultados{
                animation: slideDown 0.15s ease-out;
                border-left: 1.5px solid #1a2a4a !important;
                border-right: 1.5px solid #1a2a4a !important;
                border-bottom: 1.5px solid #1a2a4a !important;
            }
            
            @keyframes slideDown {
                from {
                    opacity: 0;
                    transform: translateY(-5px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }
            
            .empleado-resultado-item {
                transition: all 0.15s ease;
            }
            
            .empleado-resultado-item:hover {
                background: #f5f5f5 !important;
                padding-left: 20px;
            }
        </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" enctype="multipart/form-data" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon"><svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg></div>
            <div class="logo-text"><div class="top">SIGEFIDD<span>-ZOFRA</span></div><div class="bot">ZONA FRANCA DE TACNA</div></div>
        </div>
        <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1; overflow-y: auto;">
                <asp:Literal ID="litSidebarNav" runat="server"/>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Cargar Documento</div>
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
            <h1>Cargar Nuevo Documento</h1>
            <p class="sub">Ingrese los metadatos del documento y adjunte el archivo PDF</p>

            <div class="form-group">
                <label class="form-label">C&Oacute;DIGO DE DOCUMENTO <span class="required">*</span></label>
                <asp:TextBox ID="txtCodigoDocumentoCompleto" runat="server" CssClass="form-input" MaxLength="120"
                    placeholder="Ej: RS-0001-2026 (código, n&uacute;mero y a&ntilde;o en un solo campo)" />
                <div style="font-size:11px;color:#999;margin-top:6px;line-height:1.4;">
                    Ingrese manualmente el c&oacute;digo completo tal como debe guardarse en el sistema (incluye prefijo, correlativo y a&ntilde;o si aplica).
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">ASUNTO <span class="required">*</span></label>
                <asp:TextBox ID="txtAsunto" runat="server" CssClass="form-input" placeholder="Ej: Contrato de Servicios Profesionales"/>
            </div>

            <div class="form-group">
                <label class="form-label">DESCRIPCIÓN</label>
                <asp:TextBox ID="txtDescripcion" runat="server" TextMode="MultiLine" CssClass="form-input" placeholder="Breve descripción del documento"/>
            </div>
            <div class="form-row">
                <div>
                    <label class="form-label">CATEGOR&Iacute;A <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-input"/>
                </div>
                <div>
                    <label class="form-label">PRIORIDAD <span class="required">*</span></label>
                    <asp:DropDownList ID="ddlPrioridad" runat="server" CssClass="form-input">
                        <asp:ListItem Value="ALTA">Alta</asp:ListItem>
                        <asp:ListItem Value="MEDIA" Selected="True">Media</asp:ListItem>
                        <asp:ListItem Value="BAJA">Baja</asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">ÁREA (UNIDAD ORGÁNICA) <span class="required">*</span></label>
                <asp:DropDownList ID="ddlArea" runat="server" CssClass="form-input"/>
            </div>
            <div class="plazos-box plazos-zona-plazos">
                <div class="plazos-title">Gesti&oacute;n de Plazos por Etapa</div>
                <div class="plazos-sub">Establezca los tiempos l&iacute;mite para cada fase del proceso.</div>
                <div class="form-row" style="margin-bottom:0">
                    <div>
                        <label class="form-label">PLAZO PARA REVISI&Oacute;N (HORAS) <span class="required">*</span></label>
                        <asp:TextBox ID="txtPlazoRevision" runat="server" CssClass="form-input" Text="24"/>
                        <div class="plazos-hint">Tiempo l&iacute;mite para completar la revisi&oacute;n</div>
                    </div>
                    <div>
                        <label class="form-label">PLAZO PARA FIRMA (HORAS) <span class="required">*</span></label>
                        <asp:TextBox ID="txtPlazoFirma" runat="server" CssClass="form-input" Text="48"/>
                        <div class="plazos-hint">Tiempo l&iacute;mite para completar todas las firmas</div>
                    </div>
                </div>
            </div>
            <!-- Buscador de empleados y asignación de participantes -->
            <div class="plazos-box plazos-zona-asignacion">
                <div class="plazos-title">Asignar Revisores y Firmantes</div>
                <div class="plazos-sub">Busque empleados por nombre o login y asígnelos como revisores o firmantes.</div>

                <div style="margin-bottom:20px;position:relative;">
                    <label class="form-label">BUSCAR EMPLEADO <span class="required">*</span></label>
                    <asp:TextBox ID="txtBuscador" runat="server" CssClass="form-input" placeholder="Escriba nombre o login..." AutoComplete="off"/>
                    <div id="dropdownResultados" style="display:none;position:absolute;top:100%;left:0;right:0;background:white;border:1.5px solid #1a2a4a;border-top:none;border-radius:0 0 8px 8px;max-height:280px;overflow-y:auto;z-index:1000;box-shadow:0 8px 16px rgba(0,0,0,0.1);">
                        <!-- Resultados se cargan dinámicamente aquí -->
                    </div>
                    <asp:ListBox ID="lstBuscador" runat="server" style="display:none;" OnSelectedIndexChanged="lstBuscador_SelectedIndexChanged" SelectionMode="Single"/>
                </div>

                <!-- Dos columnas: Revisores y Firmantes -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:20px;">
                    <!-- COLUMNA IZQUIERDA: REVISORES -->
                    <div style="border:1.5px solid rgba(168,212,184,.85);border-radius:10px;padding:16px;background:rgba(255,255,255,.72);backdrop-filter:blur(4px);">
                        <div style="font-size:13px;font-weight:700;color:#1b5e20;margin-bottom:12px;">
                            ✓ REVISORES
                        </div>
                        <div id="listaRevisores" class="revisores-wrap" role="list" aria-label="Lista de revisores">
                        </div>
                        <p class="revisores-hint">Misma persona en ambas listas: quitar en una columna la elimina de la otra.</p>
                        <div style="font-size:11px;color:#6b8f76;margin-top:6px;">
                            Elige un empleado en el buscador para añadirlo
                        </div>
                    </div>

                    <!-- COLUMNA DERECHA: FIRMANTES -->
                    <div style="border:1.5px solid rgba(184,196,232,.9);border-radius:10px;padding:16px;background:rgba(255,255,255,.72);backdrop-filter:blur(4px);">
                        <div style="font-size:13px;font-weight:700;color:#1a2a4a;margin-bottom:12px;">
                            🔏 FIRMANTES (orden de firma)
                        </div>
                        <div id="listaFirmantes" class="firmantes-wrap" role="list" aria-label="Lista de firmantes">
                            <!-- Firmantes: tarjetas reordenables -->
                        </div>
                        <p class="firmantes-hint">Arrastra las tarjetas para cambiar el orden, o usa ▲ ▼. El número indica la secuencia de firma.</p>
                        <div style="font-size:11px;color:#999;margin-top:4px;">
                            Haz clic en un empleado arriba para asignarlo también como firmante
                        </div>
                    </div>
                </div>

                <!-- Campo oculto para pasar los datos al servidor -->
                <asp:HiddenField ID="hfParticipantes" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label">ARCHIVO PDF <span class="required">*</span></label>
                <div class="upload-zone" onclick="document.getElementById('filePDF').click()">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zm-2 8H7v-2h4v2zm6-4H7v-2h10v2z"/></svg>
                    <div class="uz-title">Haga clic para seleccionar un archivo PDF</div>
                    <div class="uz-sub">Solo archivos PDF (max 15MB)</div>
                    <asp:FileUpload ID="filePDF" runat="server" Style="display:none" Accept=".pdf" onchange="mostrarNombreArchivo()"/>
                </div>
                <asp:Label ID="lblMensaje" runat="server" Visible="false" Style="margin-top:12px;display:block;" />
                <asp:Label ID="lblArchivo" runat="server" Style="font-size:13px;color:#555;margin-top:8px;display:block;"/>
            </div>
            <div class="form-actions">
                <button type="button" id="btnVisualizar" class="btn-accion btn-visualizar" onclick="abrirVisorPDF()" style="display:none;">📄 Visualizar Documento</button>
                <asp:Button ID="btnCargar" runat="server" Text="Cargar Documento" CssClass="btn-accion btn-submit" OnClick="btnCargar_Click" OnClientClick="return validarAntesDeEnviar();"/>
                <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn-accion btn-accion-cancel btn-cancel-rojo" OnClick="btnCancelar_Click" CausesValidation="false"/>
            </div>
            
            <!-- Modal Visor de PDF -->
            <div id="modalVisorPDF" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:2000;align-items:center;justify-content:center;">
                <div style="background:white;border-radius:12px;width:95%;height:95%;max-width:900px;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
                    <!-- Header del Modal -->
                    <div style="display:flex;justify-content:space-between;align-items:center;padding:16px 24px;border-bottom:1.5px solid #e8eaf0;background:#f8f9fc;">
                        <div style="font-size:16px;font-weight:700;color:#1a2a4a;">Previsualización de Documento PDF</div>
                        <button type="button" onclick="cerrarVisorPDF()" style="background:none;border:none;font-size:28px;cursor:pointer;color:#999;padding:0;width:32px;height:32px;display:flex;align-items:center;justify-content:center;">✕</button>
                    </div>
                    <!-- Contenedor del PDF -->
                    <div id="visorPDFContenedor" style="flex:1;overflow:auto;display:flex;align-items:center;justify-content:center;background:#f5f5f5;">
                        <div id="pdfSpinner" style="text-align:center;">
                            <div style="font-size:14px;color:#999;margin-bottom:16px;">Cargando documento...</div>
                            <div style="width:40px;height:40px;border:4px solid #e0e0e0;border-top-color:#1a2a4a;border-radius:50%;animation:spin 0.8s linear infinite;margin:0 auto;"></div>
                        </div>
                        <iframe id="pdfIframe" style="width:100%;height:100%;border:none;display:none;"></iframe>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    // ============================================================
    // VARIABLES GLOBALES - PERSISTENTES CON SESSIONST ORAGE
    // ============================================================
    let revisores = [];
    let firmantes = [];
    let textoOriginalBuscador = "";

    // ============================================================
    // INICIALIZAR INMEDIATAMENTE (NO ESPERAR A DOMContentLoaded)
    // ============================================================
    (function() {
        try {
            let revGuardados = sessionStorage.getItem('revisores_temp');
            let firGuardados = sessionStorage.getItem('firmantes_temp');

            if (revGuardados) {
                revisores = JSON.parse(revGuardados);
                console.log('✓ Revisores recuperados:', revisores.length);
            }
            if (firGuardados) {
                firmantes = JSON.parse(firGuardados);
                console.log('✓ Firmantes recuperados:', firmantes.length);
            }
        } catch (e) {
            console.error('Error al cargar participantes inicial:', e);
        }
    })();

    // ============================================================
    // BUSCADOR: Evento keyup para filtrar empleados SIN POSTBACK
    // ============================================================
    document.addEventListener('DOMContentLoaded', function() {
        let txtBuscador = document.getElementById('<%= txtBuscador.ClientID %>');
        let dropdown = document.getElementById('dropdownResultados');
        
        if (txtBuscador) {
            txtBuscador.addEventListener('keyup', function(e) {
                let valor = this.value.toLowerCase().trim();
                
                if (e.key === 'Escape') {
                    dropdown.style.display = 'none';
                    return;
                }
                
                if (valor.length === 0) {
                    dropdown.style.display = 'none';
                    return;
                }
                
                // Filtrar empleados localmente
                filtrarEmpleadosLocal(valor);
            });
            
            // Cerrar dropdown cuando se hace click afuera
            document.addEventListener('click', function(e) {
                if (e.target !== txtBuscador && !dropdown.contains(e.target)) {
                    dropdown.style.display = 'none';
                }
            });
        }
    });

    // ============================================================
    // FILTRAR: Buscar empleados localmente
    // ============================================================
    function filtrarEmpleadosLocal(termino) {
        // Obtener todos los items del ListBox oculto
        let lstBuscador = document.getElementById('<%= lstBuscador.ClientID %>');
        let dropdown = document.getElementById('dropdownResultados');
        
        if (!lstBuscador || !dropdown) return;
        
        let resultados = [];
        let items = lstBuscador.options;
        
        for (let i = 0; i < items.length; i++) {
            let texto = items[i].text.toLowerCase();
            let valor = items[i].value;
            
            if (texto.includes(termino)) {
                resultados.push({
                    login: valor,
                    texto: items[i].text
                });
            }
        }
        
        // Mostrar resultados
        if (resultados.length === 0) {
            dropdown.innerHTML = '<div style="padding:16px;text-align:center;color:#999;">No se encontraron resultados</div>';
            dropdown.style.display = 'block';
            return;
        }
        
        let html = '';
        resultados.slice(0, 10).forEach(res => {
            html += '<div class="empleado-resultado-item" data-login="' + res.login + '" style="padding:12px 16px;border-bottom:1px solid #f0f0f0;cursor:pointer;display:flex;justify-content:space-between;align-items:center;transition:all 0.2s;">' +
                    '<div>' +
                    '<div style="font-weight:600;color:#1a2a4a;font-size:13px;">' + res.texto.split('|')[0] + '</div>' +
                    '<div style="font-size:11px;color:#999;">' + (res.texto.split('|')[1] || res.login) + '</div>' +
                    '</div>' +
                    '</div>';
        });
        
        dropdown.innerHTML = html;
        dropdown.style.display = 'block';
        
        // Agregar eventos click a cada resultado
        document.querySelectorAll('.empleado-resultado-item').forEach(item => {
            item.addEventListener('click', function() {
                let login = this.getAttribute('data-login');
                let texto = this.textContent.trim();
                seleccionarEmpleadoDelDropdown(login, texto);
            });
            
            item.addEventListener('mouseenter', function() {
                this.style.background = '#f5f5f5';
            });
            
            item.addEventListener('mouseleave', function() {
                this.style.background = 'white';
            });
        });
    }

    // ============================================================
    // SELECCIONAR: Empleado del dropdown
    // ============================================================
    function seleccionarEmpleadoDelDropdown(login, texto) {
        let txtBuscador = document.getElementById('<%= txtBuscador.ClientID %>');
        let dropdown = document.getElementById('dropdownResultados');
        
        // Limpiar búsqueda
        txtBuscador.value = '';
        dropdown.style.display = 'none';
        
        // Agregar empleado
        agregarParticipanteAuto(login, texto);
        
        // Enfocar de nuevo para permitir agregar más
        txtBuscador.focus();
    }

    // ============================================================
    // AGREGAR: Función automática (EN AMBAS COLUMNAS)
    // ============================================================
    function agregarParticipanteAuto(login, nombre) {
        console.log('Agregando:', login, nombre);
        console.log('Revisores antes:', revisores.length);
        console.log('Firmantes antes:', firmantes.length);

        // Verificar si ya existe
        if (revisores.some(r => r.login === login) || firmantes.some(f => f.login === login)) {
            alert('✓ ' + nombre + ' ya ha sido asignado');
            return;
        }

        // Agregar como REVISOR
        revisores.push({ login: login, nombre: nombre });

        // Agregar como FIRMANTE con orden
        firmantes.push({ 
            login: login, 
            nombre: nombre, 
            orden: firmantes.length + 1 
        });

        console.log('Revisores después:', revisores.length);
        console.log('Firmantes después:', firmantes.length);

        // Renderizar y guardar
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    }

    // ============================================================
    // RENDERIZAR: Mostrar revisores y firmantes en columnas
    // ============================================================
    function renderizarParticipantes() {
        console.log('Renderizando... Revisores:', revisores.length, 'Firmantes:', firmantes.length);

        // -------- COLUMNA REVISORES --------
        let listaRevisoresDiv = document.getElementById('listaRevisores');
        if (!listaRevisoresDiv) {
            console.error('No se encontró elemento listaRevisores');
            return;
        }

        if (revisores.length === 0) {
            listaRevisoresDiv.innerHTML = '<div style="color:#6b8f76;text-align:center;padding:28px 16px;font-size:13px;">Sin revisores asignados<br><span style="font-size:12px;opacity:.9">Usa el buscador para añadir participantes</span></div>';
        } else {
            let html = '';
            for (let i = 0; i < revisores.length; i++) {
                let r = revisores[i];
                let escLogin = String(r.login).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
                html += '<div class="revisor-card" data-login="' + String(r.login).replace(/"/g, '&quot;') + '" role="listitem">';
                html += '<div class="revisor-badge" title="Revisor">R</div>';
                html += '<div class="revisor-nombre" title="' + String(r.nombre).replace(/"/g, '&quot;') + '">' + r.nombre + '</div>';
                html += '<button type="button" class="revisor-btn-quitar" title="Quitar revisor (también quita de firmantes)" onclick="removerRevisor(\'' + escLogin + '\'); return false;">×</button>';
                html += '</div>';
            }
            listaRevisoresDiv.innerHTML = html;
        }

        // -------- COLUMNA FIRMANTES (tarjetas + arrastrar) --------
        let listaFirmantesDiv = document.getElementById('listaFirmantes');
        if (!listaFirmantesDiv) {
            console.error('No se encontró elemento listaFirmantes');
            return;
        }

        if (firmantes.length === 0) {
            listaFirmantesDiv.innerHTML = '<div style="color:#8898b8;text-align:center;padding:28px 16px;font-size:13px;">Sin firmantes asignados<br><span style="font-size:12px;opacity:.9">Usa el buscador para añadir participantes</span></div>';
        } else {
            let html = '';
            for (let i = 0; i < firmantes.length; i++) {
                let f = firmantes[i];
                let escLogin = String(f.login).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
                html += '<div class="firmante-card" data-index="' + i + '" data-login="' + f.login.replace(/"/g, '&quot;') + '" role="listitem">';
                html += '<div class="firmante-handle" draggable="true" title="Arrastrar para reordenar">⋮⋮</div>';
                html += '<div class="firmante-orden" title="Orden de firma">' + (i + 1) + '</div>';
                html += '<div class="firmante-nombre" title="' + String(f.nombre).replace(/"/g, '&quot;') + '">' + f.nombre + '</div>';
                html += '<div class="firmante-actions">';
                html += '<button type="button" class="firmante-btn-flecha" title="Subir"' + (i === 0 ? ' disabled' : '') + ' onclick="moverFirmanteArriba(' + i + '); return false;">▲</button>';
                html += '<button type="button" class="firmante-btn-flecha" title="Bajar"' + (i === firmantes.length - 1 ? ' disabled' : '') + ' onclick="moverFirmanteAbajo(' + i + '); return false;">▼</button>';
                html += '</div>';
                html += '<button type="button" class="firmante-btn-quitar" title="Quitar" onclick="removerFirmante(\'' + escLogin + '\'); return false;">×</button>';
                html += '</div>';
            }
            listaFirmantesDiv.innerHTML = html;
            enlazarArrastreFirmantes();
        }

        // Actualizar campo oculto del servidor
        guardarParticipantes();
    }

    function reorderFirmantes(fromIndex, toIndex) {
        if (fromIndex === toIndex) return;
        if (fromIndex < 0 || toIndex < 0 || fromIndex >= firmantes.length || toIndex >= firmantes.length) return;
        let item = firmantes.splice(fromIndex, 1)[0];
        firmantes.splice(toIndex, 0, item);
        firmantes.forEach(function (x, idx) { x.orden = idx + 1; });
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    }

    function moverFirmanteArriba(index) {
        if (index <= 0) return;
        reorderFirmantes(index, index - 1);
    }

    function moverFirmanteAbajo(index) {
        if (index >= firmantes.length - 1) return;
        reorderFirmantes(index, index + 1);
    }

    function enlazarArrastreFirmantes() {
        let cards = document.querySelectorAll('#listaFirmantes .firmante-card');
        cards.forEach(function (card) {
            let handle = card.querySelector('.firmante-handle');
            if (!handle) return;

            handle.addEventListener('dragstart', function (e) {
                let idx = parseInt(card.getAttribute('data-index'), 10);
                e.dataTransfer.setData('text/plain', String(idx));
                e.dataTransfer.effectAllowed = 'move';
                card.classList.add('firmante-dragging');
            });
            handle.addEventListener('dragend', function () {
                card.classList.remove('firmante-dragging');
                document.querySelectorAll('#listaFirmantes .firmante-card').forEach(function (c) {
                    c.classList.remove('firmante-drag-over');
                });
            });

            card.addEventListener('dragover', function (e) {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
                card.classList.add('firmante-drag-over');
            });
            card.addEventListener('dragleave', function (e) {
                if (!card.contains(e.relatedTarget)) card.classList.remove('firmante-drag-over');
            });
            card.addEventListener('drop', function (e) {
                e.preventDefault();
                card.classList.remove('firmante-drag-over');
                let from = parseInt(e.dataTransfer.getData('text/plain'), 10);
                let to = parseInt(card.getAttribute('data-index'), 10);
                if (!isNaN(from) && !isNaN(to)) reorderFirmantes(from, to);
            });
        });
    }

    // ============================================================
    // REMOVER: Revisor (también quita de firmantes; al revés en removerFirmante)
    // ============================================================
    function removerRevisor(login) {
        revisores = revisores.filter(r => r.login !== login);
        firmantes = firmantes.filter(f => f.login !== login);
        firmantes.forEach((f, idx) => f.orden = idx + 1);
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
        console.log('✓ Revisor eliminado');
    }

    // ============================================================
    // REMOVER: Firmante (también lo saca de revisores)
    // ============================================================
    function removerFirmante(login) {
        firmantes = firmantes.filter(f => f.login !== login);
        revisores = revisores.filter(r => r.login !== login);
        firmantes.forEach((f, idx) => f.orden = idx + 1);
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
        console.log('✓ Firmante eliminado');
    }

    // ============================================================
    // GUARDAR: En campo oculto del servidor (para POST)
    // ============================================================
    function guardarParticipantes() {
        let participantes = [];
        let participantesSet = new Set();

        // Guardar revisores como REV (solo revisión, sin firma)
        revisores.forEach((r, idx) => {
            if (participantesSet.has(r.login)) return;
            participantes.push({
                login: r.login,
                nombre: r.nombre,
                tipo: 'REV',
                orden: 0  // Revisores no firman
            });
            participantesSet.add(r.login);
        });

        // Guardar firmantes como FIR con su orden secuencial
        // El servidor insertará CADA firmante DOS VECES:
        // 1. Como REV (Orden=0) para revisar
        // 2. Como FIR (Orden=su_posicion) para firmar
        firmantes.forEach((f, idx) => {
            if (participantesSet.has(f.login)) {
                // Si ya existe como revisor, actualizamos su orden de firma
                let part = participantes.find(p => p.login === f.login);
                if (part) {
                    part.tipo = 'FIR';  // Ahora también es firmante
                    part.orden = idx + 1;
                }
            } else {
                participantes.push({
                    login: f.login,
                    nombre: f.nombre,
                    tipo: 'FIR',  // Firmante (será insertado dos veces en BD)
                    orden: idx + 1  // Orden secuencial de firma
                });
                participantesSet.add(f.login);
            }
        });

        console.log('Participantes guardados:', participantes);
        document.getElementById('<%= hfParticipantes.ClientID %>').value = JSON.stringify(participantes);
    }

    // ============================================================
    // GUARDAR: En sessionStorage (para persistencia entre postbacks)
    // ============================================================
    function guardarParticipantesEnSessionStorage() {
        try {
            sessionStorage.setItem('revisores_temp', JSON.stringify(revisores));
            sessionStorage.setItem('firmantes_temp', JSON.stringify(firmantes));
            console.log('✓ Guardado en sessionStorage. Revisores:', revisores.length, 'Firmantes:', firmantes.length);
        } catch (e) {
            console.error('Error al guardar en sessionStorage:', e);
        }
    }

    // ============================================================
    // INICIALIZACIÓN: Después de DOMContentLoaded
    // ============================================================
    document.addEventListener('DOMContentLoaded', function() {
        renderizarParticipantes();
    });

    // ============================================================
    // ARCHIVO: Mostrar nombre del archivo seleccionado
    // ============================================================
    function mostrarNombreArchivo() {
        let fileInput = document.getElementById('<%= filePDF.ClientID %>');
        let lblArchivo = document.getElementById('<%= lblArchivo.ClientID %>');
        let btnVisualizar = document.getElementById('btnVisualizar');

        if (fileInput.files.length > 0) {
            let archivo = fileInput.files[0];
            let nombreArchivo = archivo.name;
            let tamanoMB = (archivo.size / (1024 * 1024)).toFixed(2);

            // Mostrar nombre y tamaño
            lblArchivo.innerHTML = '✓ <strong style="color:#27ae60;">Archivo cargado:</strong> ' + nombreArchivo + ' (' + tamanoMB + ' MB)';
            lblArchivo.style.color = '#27ae60';

            // Mostrar botón visualizar
            btnVisualizar.style.display = 'inline-block';

            // Guardar referencia del archivo para el visor
            window.pdfArchivoActual = archivo;
        } else {
            lblArchivo.innerHTML = '';
            btnVisualizar.style.display = 'none';
            window.pdfArchivoActual = null;
        }
    }

    // ============================================================
    // VISOR PDF: Abrir modal con previsualización
    // ============================================================
    function abrirVisorPDF() {
        if (!window.pdfArchivoActual) {
            alert('Por favor selecciona un archivo PDF primero');
            return;
        }

        let modal = document.getElementById('modalVisorPDF');
        let iframe = document.getElementById('pdfIframe');
        let spinner = document.getElementById('pdfSpinner');

        // Mostrar modal
        modal.style.display = 'flex';
        spinner.style.display = 'block';
        iframe.style.display = 'none';

        // Limpiar URL anterior si existe
        if (window.pdfBlobURL) {
            URL.revokeObjectURL(window.pdfBlobURL);
        }

        // Usar URL.createObjectURL para mejor rendimiento
        try {
            window.pdfBlobURL = URL.createObjectURL(window.pdfArchivoActual);
            iframe.src = window.pdfBlobURL;
            
            // Mostrar iframe después de 500ms (mejor que esperar onload)
            setTimeout(function() {
                spinner.style.display = 'none';
                iframe.style.display = 'block';
            }, 500);
            
        } catch(e) {
            console.error('Error al abrir PDF:', e);
            spinner.innerHTML = '<div style="color:#c0392b;font-size:14px;">❌ Error al cargar el PDF</div>';
            setTimeout(function() {
                modal.style.display = 'none';
                spinner.innerHTML = '<div style="font-size:14px;color:#999;margin-bottom:16px;">Cargando documento...</div><div style="width:40px;height:40px;border:4px solid #e0e0e0;border-top-color:#1a2a4a;border-radius:50%;animation:spin 0.8s linear infinite;margin:0 auto;"></div>';
            }, 2000);
        }
    }

    // ============================================================
    // VISOR PDF: Cerrar modal
    // ============================================================
    function cerrarVisorPDF() {
        let modal = document.getElementById('modalVisorPDF');
        let iframe = document.getElementById('pdfIframe');
        let spinner = document.getElementById('pdfSpinner');

        modal.style.display = 'none';
        iframe.onload = null; // Limpiar event listeners
        iframe.src = '';
        iframe.style.display = 'none';
        spinner.style.display = 'block';
        
        // Limpiar objeto URL para liberar memoria
        if (window.pdfBlobURL) {
            URL.revokeObjectURL(window.pdfBlobURL);
            window.pdfBlobURL = null;
        }
    }

    // Cerrar modal al hacer click fuera del contenedor
    document.addEventListener('DOMContentLoaded', function() {
        let modal = document.getElementById('modalVisorPDF');
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    cerrarVisorPDF();
                }
            });
        }
    });

    window.limpiarAsignacionParticipantes = function () {
        revisores = [];
        firmantes = [];
        try {
            sessionStorage.removeItem('revisores_temp');
            sessionStorage.removeItem('firmantes_temp');
        } catch (err) { }
        var hf = document.getElementById('<%= hfParticipantes.ClientID %>');
        if (hf) hf.value = '';
        var tb = document.getElementById('<%= txtBuscador.ClientID %>');
        if (tb) tb.value = '';
        var dd = document.getElementById('dropdownResultados');
        if (dd) dd.style.display = 'none';
        renderizarParticipantes();
    };

    function validarAntesDeEnviar() {
        let errores = [];

        let codigoCompleto = (document.getElementById('<%= txtCodigoDocumentoCompleto.ClientID %>') || {}).value || '';
        let asunto = (document.getElementById('<%= txtAsunto.ClientID %>') || {}).value || '';
        let categoria = (document.getElementById('<%= ddlCategoria.ClientID %>') || {}).value || '';
        let area = (document.getElementById('<%= ddlArea.ClientID %>') || {}).value || '';
        let participantes = (document.getElementById('<%= hfParticipantes.ClientID %>') || {}).value || '';
        let fileInput = document.getElementById('<%= filePDF.ClientID %>');

        if (!codigoCompleto.trim()) errores.push('Código de documento (completo)');
        if (!asunto.trim()) errores.push('Asunto');
        if (!categoria) errores.push('Categoría');
        if (!area) errores.push('Área (unidad orgánica)');
        if (!participantes || participantes === '[]') errores.push('Asignar revisores/firmantes');
        if (!fileInput || fileInput.files.length === 0) errores.push('Archivo PDF');

        if (errores.length > 0) {
            alert('Faltan completar estos campos:\n- ' + errores.join('\n- '));
            return false; // evita postback para no perder el archivo seleccionado
        }

        return true;
    }

    window.addEventListener('beforeunload', function () {
        // sessionStorage persiste en la pestaña hasta limpiar explícitamente
    });
</script>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
</body>
</html>