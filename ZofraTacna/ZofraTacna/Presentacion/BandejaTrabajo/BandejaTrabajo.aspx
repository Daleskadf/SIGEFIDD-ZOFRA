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
        .doc-card{background:white;border-radius:12px;padding:20px 24px;margin-bottom:16px;box-shadow:0 1px 4px rgba(0,0,0,.06);display:flex;flex-wrap:wrap;gap:16px 16px;align-items:stretch}
        .doc-card-header{display:flex;align-items:center;gap:10px;margin-bottom:0;width:100%;flex-shrink:0}
        .doc-title{font-size:16px;font-weight:600;color:#1a2a4a;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:70%}
        .doc-desc{font-size:13px;color:#666;margin-bottom:0;margin-top:2px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;width:100%;flex-shrink:0}
        /* CONTENEDOR DE SECCIONES HORIZONTALES */
        .doc-card > .card-section{flex:1;min-width:240px;display:flex;flex-direction:column;align-self:stretch}
        /* BADGES */
        .badge{padding:4px 10px;border-radius:6px;font-size:11px;font-weight:600}
        .badge-alta{background:#ffcdd2;color:#b71c1c}
        .badge-media{background:#fff9c4;color:#f57f17}
        .badge-baja{background:#c8e6c9;color:#2e7d32}
        .badge-estado{background:#e3f2fd;color:#1565c0}
        .badge-firma{background:#ffe0b2;color:#e65100}
        /* BOTONES — acción principal alineada al borde derecho de la sección (space-between con detalle a la izquierda) */
        .section-botones{border-top:1px solid #eef0f5;padding-top:12px;margin-top:12px;width:100%;display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:14px;padding-left:clamp(12px,6%,56px);padding-right:clamp(12px,6%,56px)}
        .section-botones button{border-radius:7px;padding:12px 16px;min-height:42px;font-size:12px;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;gap:6px;transition:background .2s,color .2s,border-color .2s,opacity .2s}
        /* Secundario: contorno institucional (contrasta con sólidos) */
        .btn-detalle{background:#fff;color:#1a2a4a;border:1.5px solid #c9d0de}
        .btn-detalle:hover:not(:disabled){background:#f4f6fa;border-color:#1a2a4a}
        .btn-detalle:disabled{opacity:0.55;cursor:not-allowed;border-style:dashed}
        .btn-detalle-activo{background:linear-gradient(135deg,#8b1a1a,#c0392b);color:white;border:1px solid #7d1717;box-shadow:0 6px 16px rgba(139,26,26,.22)}
        .btn-detalle.btn-detalle-activo:hover{background:linear-gradient(135deg,#a32121,#d44736);color:white;border-color:#7d1717;transform:translateY(-1px)}
        /* Firma: verde — distinto del flujo revisión */
        .btn-firma{background:#1b5e20;color:white;border:1px solid #145418}
        .btn-firma:hover{background:#145418}
        /* Revisión: mismo azul institucional que la barra lateral */
        .btn-revision{background:#1a2a4a;color:white;border:1px solid #152238}
        .btn-revision:hover{background:#243a62}
        .estado-conforme{display:inline-flex;align-items:center;justify-content:center;min-height:40px;padding:10px 16px;border-radius:10px;background:linear-gradient(135deg,#2a3f6f,#1a2a4a);color:#fff;font-size:12px;font-weight:700;box-shadow:0 8px 18px rgba(26,42,74,.3)}
        .estado-observado{display:inline-flex;align-items:center;justify-content:center;min-height:40px;padding:10px 16px;border-radius:10px;background:linear-gradient(135deg,#8b1a1a,#c0392b);color:#fff;font-size:12px;font-weight:700;box-shadow:0 8px 18px rgba(139,26,26,.3)}
        /* SECCIONES DEL CARD */
        .section-subtitle{font-size:12px;font-weight:600;color:#1a2a4a;margin-bottom:10px;text-transform:uppercase;letter-spacing:0.5px}
        .section-content{display:flex;flex-direction:column;gap:8px;flex:1}
        /* Primera columna: empuja la fila de botones al pie de la sección para alinear alturas entre las 3 secciones */
        .card-section.section-acciones .section-content{min-height:100%}
        .doc-card > .card-section:not(:first-of-type){border-left:1px solid #e8eaf0;padding-left:16px}
        /* PRIMERA SECCIÓN - CARACTERÍSTICAS */
        .section-meta{display:flex;align-items:center;gap:18px;font-size:12px;color:#999;flex-wrap:wrap}
        .section-meta svg{width:13px;height:13px;fill:#bbb;margin-right:3px;vertical-align:middle}
        .section-horas{background:#f9f9fb;border-left:3px solid #1a2a4a;padding:10px 12px;border-radius:4px;font-size:11px;color:#555;display:flex;flex-direction:column;gap:8px}
        .section-horas > div{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
        .section-horas svg{width:12px;height:12px;fill:#1a2a4a;flex-shrink:0}
        .tiempo-ok{color:#2e7d32;font-weight:600}
        .tiempo-vencido{color:#c0392b;font-weight:600;background:#ffebee;padding:2px 6px;border-radius:3px}
        .card-section.section-acciones .section-botones{margin-top:auto}
        /* SEGUNDA SECCIÓN - REVISORES */
        .revisores-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px;align-content:flex-start;flex:1}
        .revisor-item{padding:6px 10px;background:#f5f5f5;border-radius:6px;font-size:12px;color:#555;border-left:2px solid #1a2a4a;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .revisor-item.revisor-ok{background:#eaf2ff;border-left-color:#1a56db;color:#163b7a}
        .revisor-item.revisor-obs{background:#ffebee;border-left-color:#c0392b;color:#7f1d1d}
        /* TERCERA SECCIÓN - FIRMA */
        .section-firma{min-height:60px;display:flex;align-items:flex-start;justify-content:flex-start;color:#ccc;font-size:13px;flex:1}
        .firma-list{width:100%;display:grid;grid-template-columns:1fr 1fr;gap:10px;align-content:flex-start;flex:1}
        .firma-item{display:flex;align-items:center;gap:8px;padding:6px 10px;background:#f5f5f5;border-radius:6px;font-size:12px;color:#555;border-left:2px solid #1a2a4a;overflow:hidden}
        .firma-num{display:inline-flex;align-items:center;justify-content:center;width:20px;height:20px;border-radius:10px;background:#1a2a4a;color:#fff;font-size:11px;font-weight:700;flex-shrink:0}
        .firma-login{min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
        .firma-empty{color:#bbb;font-size:12px}
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
        <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1; overflow-y: auto;">
                <asp:Literal ID="litSidebarNav" runat="server"/>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
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
                            <span class='badge <%# Eval("EstadoBadgeCss") %>'><%# Eval("EstadoDesc") %></span>
                        </div>
                        <div class="doc-desc"><%# Eval("Descripcion") %></div>
                        
                        <!-- SECCIÓN 1: CARACTERÍSTICAS + acciones (botones en extremos) -->
                        <div class="card-section section-acciones">
                            <div class="section-content">
                                <div class="section-meta">
                                    <span><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16h14V8l-6-6z"/></svg><%# Eval("TipoDocumento") %></span>
                                    <span><svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg><%# Eval("Registrador") %></span>
                                    <span><svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg><%# Eval("FechaCreacionStr") %></span>
                                </div>
                                <div class="section-horas">
                                    <div><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-5.04-6.71l2.75 3.54h2.92l-4.3-5.92 4.3-5.92h-2.92l-2.75 3.92-2.75-3.92H7.3l4.3 5.92-4.3 5.92h2.92l2.75-3.54z"/></svg>
                                    <strong>Máx. Revisión:</strong> <%# Eval("FechaMaxRevision") %> <span class='<%# Eval("FechaMaxRevisionTexto").ToString().Contains("fuera") ? "tiempo-vencido" : "tiempo-ok" %>'><%# Eval("FechaMaxRevisionTexto") %></span></div>
                                    <div><svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zm-5.04-6.71l2.75 3.54h2.92l-4.3-5.92 4.3-5.92h-2.92l-2.75 3.92-2.75-3.92H7.3l4.3 5.92-4.3 5.92h2.92l2.75-3.54z"/></svg>
                                    <strong>Máx. Aprobación:</strong> <%# Eval("FechaMaxFirma") %> <span class='<%# Eval("FechaMaxFirmaTexto").ToString().Contains("fuera") ? "tiempo-vencido" : "tiempo-ok" %>'><%# Eval("FechaMaxFirmaTexto") %></span></div>
                                </div>
                                <div class="section-botones">
                                    <%# (bool)Eval("PuedeEditarRevision")
                                        ? string.Format("<button class='btn-detalle btn-detalle-activo' type='button' onclick=\"window.location.href='EmitirRevision.aspx?id={0}'\"><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>Editar Revisión</button>", Eval("IdDocumento"))
                                        : "<button class='btn-detalle' type='button' disabled><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:currentColor'><path d='M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z'/></svg>Editar Revisión</button>" %>
                                    <%# (bool)Eval("EsConformeRevision")
                                        ? "<span class='estado-conforme'>Conforme</span>"
                                        : ((bool)Eval("EsObservadoRevision")
                                            ? "<span class='estado-observado'>Observado</span>"
                                        : ((string)Eval("EstadoCodigo") == "PEN" || (string)Eval("EstadoCodigo") == "FPAR"
                                            ? "<button class='btn-firma' type='button'><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>Firmar Documento</button>"
                                            : string.Format("<button type='button' class='btn-revision' onclick=\"window.location.href='EmitirRevision.aspx?id={0}'\"><svg viewBox='0 0 24 24' style='width:14px;height:14px;fill:white'><path d='M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25z'/></svg>Emitir Revisión</button>", Eval("IdDocumento")))) %>
                                </div>
                            </div>
                        </div>
                        
                        <!-- SECCIÓN 2: REVISORES ASIGNADOS -->
                        <div class="card-section">
                            <div class="section-subtitle">Revisores Asignados</div>
                            <div class="section-content">
                                <div class="revisores-grid">
                                    <%# !string.IsNullOrEmpty(Eval("RevisoresHtml").ToString()) 
                                        ? Eval("RevisoresHtml") 
                                        : "<div style='grid-column:1/-1;color:#ccc;font-size:12px'>Sin revisores asignados</div>" %>
                                </div>
                            </div>
                        </div>
                        
                        <!-- SECCIÓN 3: ORDEN DE FIRMA -->
                        <div class="card-section">
                            <div class="section-subtitle">Orden de Firma</div>
                            <div class="section-firma">
                                <div class="firma-list">
                                    <%# Eval("FirmantesOrdenHtml") %>
                                </div>
                            </div>
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
