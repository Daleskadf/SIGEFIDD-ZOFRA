<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="ZofraTacna.Default" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Inicio</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; height: 100vh; }

        /* SIDEBAR */
        .sidebar {
            width: 230px; min-width: 230px;
            background: #1a2a4a;
            display: flex; flex-direction: column;
            height: 100vh;
        }
        .sidebar-logo {
            padding: 20px 18px 16px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            display: flex; align-items: center; gap: 10px;
        }
        .sidebar-logo .logo-icon {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, #2a3f6f, #8b1a1a);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
        }
        .sidebar-logo .logo-icon svg { width: 20px; height: 20px; fill: white; }
        .sidebar-logo .logo-text .top { color: white; font-size: 13px; font-weight: 700; letter-spacing: 1px; }
        .sidebar-logo .logo-text .top span { color: #c0392b; }
        .sidebar-logo .logo-text .bot { color: rgba(255,255,255,0.4); font-size: 9px; letter-spacing: 1px; }
        .sidebar-nav { padding: 16px 10px; flex: 1; overflow-y: auto; }
        .nav-item {
            display: flex; align-items: center; gap: 10px;
            padding: 10px 12px;
            border-radius: 8px;
            color: rgba(255,255,255,0.6);
            font-size: 13px;
            cursor: pointer;
            margin-bottom: 2px;
            text-decoration: none;
            position: relative;
        }
        .nav-item:hover { background: rgba(255,255,255,0.07); color: white; }
        .nav-item.active {
            background: linear-gradient(90deg, #2a3f6f, #8b1a1a);
            color: white;
        }
        .nav-item svg { width: 17px; height: 17px; fill: currentColor; flex-shrink: 0; }
        .nav-badge {
            margin-left: auto;
            background: #c0392b;
            color: white;
            border-radius: 10px;
            font-size: 10px;
            padding: 1px 6px;
            font-weight: 600;
        }

        /* MAIN */
        .main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }

        /* TOPBAR */
        .topbar {
            background: white;
            padding: 0 28px;
            height: 56px;
            display: flex; align-items: center; justify-content: space-between;
            border-bottom: 1px solid #e8eaf0;
            flex-shrink: 0;
        }
        .breadcrumb { font-size: 13px; color: #999; }
        .breadcrumb strong { color: #1a2a4a; }
        .topbar-right { display: flex; align-items: center; gap: 14px; }
        .user-avatar {
            width: 34px; height: 34px;
            background: linear-gradient(135deg, #1a2a4a, #8b1a1a);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 12px; font-weight: 700;
        }
        .user-info { display: flex; align-items: center; gap: 8px; }
        .user-name { font-size: 14px; font-weight: 600; color: #333; }
        .role-badge {
            background: #eef0f8;
            color: #1a2a4a;
            border-radius: 12px;
            padding: 2px 10px;
            font-size: 11px;
            font-weight: 600;
        }
        .btn-logout {
            padding: 6px 16px;
            border: 1.5px solid #ddd;
            border-radius: 6px;
            background: white;
            color: #555;
            font-size: 13px;
            cursor: pointer;
        }
        .btn-logout:hover { background: #f5f5f5; }

        /* CONTENT */
        .content { flex: 1; padding: 28px; overflow-y: auto; }
        .content-header {
            display: flex; justify-content: space-between; align-items: flex-start;
            margin-bottom: 24px;
        }
        .content-header h1 { font-size: 24px; color: #1a2a4a; font-weight: 700; }
        .content-header p  { font-size: 13px; color: #888; margin-top: 2px; }
        .btn-new {
            display: flex; align-items: center; gap: 6px;
            background: linear-gradient(90deg, #1a2a4a, #8b1a1a);
            color: white; border: none; border-radius: 8px;
            padding: 10px 20px; font-size: 14px; font-weight: 600;
            cursor: pointer; white-space: nowrap;
        }
        .btn-new:hover { opacity: 0.9; }

        /* STAT CARDS */
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 24px; }
        .stat-card {
            background: white; border-radius: 12px;
            padding: 20px; display: flex; align-items: center; gap: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
        }
        .stat-icon {
            width: 44px; height: 44px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }
        .stat-icon svg { width: 22px; height: 22px; }
        .stat-icon.blue   { background: #eef2ff; } .stat-icon.blue svg   { fill: #3b5bdb; }
        .stat-icon.yellow { background: #fff8e1; } .stat-icon.yellow svg { fill: #f59f00; }
        .stat-icon.green  { background: #e8f5e9; } .stat-icon.green svg  { fill: #2e7d32; }
        .stat-icon.red    { background: #ffeef0; } .stat-icon.red svg    { fill: #c0392b; }
        .stat-num  { font-size: 26px; font-weight: 700; color: #1a2a4a; }
        .stat-label{ font-size: 12px; color: #888; margin-top: 2px; }

        /* PANELS */
        .panels { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }
        .panel { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
        .panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .panel-header h3 { font-size: 15px; font-weight: 600; color: #1a2a4a; }
        .panel-header a  { font-size: 12px; color: #3b5bdb; text-decoration: none; }

        /* DOC LIST */
        .doc-item { display: flex; align-items: center; gap: 12px; padding: 10px 0; border-bottom: 1px solid #f0f0f0; }
        .doc-item:last-child { border-bottom: none; }
        .doc-icon { width: 34px; height: 34px; background: #f0f2f8; border-radius: 8px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
        .doc-icon svg { width: 16px; height: 16px; fill: #555; }
        .doc-name  { font-size: 13px; font-weight: 500; color: #333; }
        .doc-meta  { font-size: 11px; color: #aaa; margin-top: 2px; }
        .doc-status { margin-left: auto; border-radius: 12px; padding: 3px 10px; font-size: 11px; font-weight: 600; white-space: nowrap; }
        .status-pend { background: #fff3cd; color: #856404; }
        .status-comp { background: #d1f0d1; color: #1a6b1a; }
        .status-rev  { background: #e8eaf0; color: #555; }

        /* ACTIVITY */
        .act-item { display: flex; align-items: flex-start; gap: 10px; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
        .act-item:last-child { border-bottom: none; }
        .act-dot { width: 9px; height: 9px; border-radius: 50%; margin-top: 4px; flex-shrink: 0; }
        .act-text { font-size: 13px; color: #444; }
        .act-time { font-size: 11px; color: #aaa; margin-top: 2px; }

        /* TOOLS */
        .tools { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
        .tool-card {
            background: white; border-radius: 12px; padding: 18px;
            display: flex; align-items: center; gap: 14px;
            box-shadow: 0 1px 4px rgba(0,0,0,0.06);
            cursor: pointer; border: 1.5px solid transparent;
        }
        .tool-card:hover { border-color: #c5cae9; }
        .tool-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
        .tool-icon svg { width: 20px; height: 20px; }
        .tool-icon.purple { background: #f0eeff; } .tool-icon.purple svg { fill: #5c35cc; }
        .tool-icon.pink   { background: #ffeef5; } .tool-icon.pink svg   { fill: #c0392b; }
        .tool-icon.teal   { background: #e8f8f5; } .tool-icon.teal svg   { fill: #148f77; }
        .tool-title { font-size: 13px; font-weight: 600; color: #333; }
        .tool-sub   { font-size: 11px; color: #aaa; margin-top: 2px; }
    </style>
</head>
<body>
<form id="form1" runat="server" style="display:flex; width:100%; height:100vh; overflow:hidden;">
<div style="display:flex; width:100%; height:100vh; overflow:hidden;">

    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg>
            </div>
            <div class="logo-text">
                <div class="top">SIGEFIDD<span>-ZOFRA</span></div>
                <div class="bot">ZONA FRANCA DE TACNA - PER&Uacute;</div>
            </div>
        </div>
        <nav class="sidebar-nav">
            <a href="Default.aspx" class="nav-item active">
                <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                Inicio
            </a>
            <a href="BandejaTrabajo/BandejaTrabajo.aspx" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>
                Bandeja de Trabajo
                <span class="nav-badge" runat="server" id="badgeBandeja">6</span>
            </a>
            <a href="GestionDocumentos/CargarDocumento.aspx" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                Cargar Documento
            </a>
            <a href="GestionDocumentos/MisDocumentos.aspx" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                Mis Documentos
            </a>
            <a href="GestionRoles/GestionRoles.aspx" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                Gesti&oacute;n de Roles
            </a>
            <a href="VisualizarFirmantes/VisualizarFirmantes.aspx" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                Visualizar Firmantes
            </a>
            <a href="#" class="nav-item">
                <svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg>
                Estado del Sistema
            </a>
        </nav>
    </div>

    <!-- MAIN -->
    <div class="main">
        <!-- TOPBAR -->
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Inicio</div>
            <div class="topbar-right">
                <div class="user-info">
                    <div class="user-avatar">
                        <asp:Literal ID="litAvatar" runat="server" />
                    </div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server" /></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server" /></span>
                </div>
                <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesion" CssClass="btn-logout" OnClick="btnCerrarSesion_Click" />
            </div>
        </div>

        <!-- CONTENT -->
        <div class="content">
            <div class="content-header">
                <div>
                    <h1>Bienvenido, <asp:Literal ID="litBienvenido" runat="server" /></h1>
                    <p>Panel de Administraci&oacute;n del Sistema</p>
                </div>
                <button class="btn-new" type="button">&#43; Nuevo Documento</button>
            </div>

            <!-- STATS -->
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litTotal" runat="server" /></div><div class="stat-label">Total documentos</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon yellow">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litPendientes" runat="server" /></div><div class="stat-label">Pendientes</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litCompletados" runat="server" /></div><div class="stat-label">Completados</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon red">
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litUsuarios" runat="server" /></div><div class="stat-label">Usuarios</div></div>
                </div>
            </div>

            <!-- PANELS -->
            <div class="panels">
                <div class="panel">
                    <div class="panel-header">
                        <h3>Documentos recientes</h3>
                        <a href="#">Ver todos</a>
                    </div>
                    <div class="doc-item">
                        <div class="doc-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6z"/></svg></div>
                        <div><div class="doc-name">Contrato_Suministro_2025.pdf</div><div class="doc-meta">Hace 2 horas · <asp:Literal ID="litDocUser1" runat="server" /></div></div>
                        <span class="doc-status status-pend">Pendiente</span>
                    </div>
                    <div class="doc-item">
                        <div class="doc-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6z"/></svg></div>
                        <div><div class="doc-name">Resolución_Administrativa_04.pdf</div><div class="doc-meta">Ayer · Jefatura</div></div>
                        <span class="doc-status status-comp">Completado</span>
                    </div>
                    <div class="doc-item">
                        <div class="doc-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6z"/></svg></div>
                        <div><div class="doc-name">Informe_Inventario_Q1.xlsx</div><div class="doc-meta">15 abr · Farmacia</div></div>
                        <span class="doc-status status-rev">En revisi&oacute;n</span>
                    </div>
                </div>

                <div class="panel">
                    <div class="panel-header">
                        <h3>Actividad del sistema</h3>
                        <a href="#">Ver todo</a>
                    </div>
                    <div class="act-item">
                        <div class="act-dot" style="background:#3b5bdb;"></div>
                        <div><div class="act-text"><asp:Literal ID="litActUser" runat="server" /> subi&oacute; un nuevo documento</div><div class="act-time">Hace 2 horas</div></div>
                    </div>
                    <div class="act-item">
                        <div class="act-dot" style="background:#c0392b;"></div>
                        <div><div class="act-text">Jefatura firm&oacute; Resolución_04</div><div class="act-time">Hace 5 horas</div></div>
                    </div>
                    <div class="act-item">
                        <div class="act-dot" style="background:#2e7d32;"></div>
                        <div><div class="act-text">Usuario Farmacia inici&oacute; sesi&oacute;n</div><div class="act-time">Ayer, 09:12</div></div>
                    </div>
                    <div class="act-item">
                        <div class="act-dot" style="background:#8b6914;"></div>
                        <div><div class="act-text">2 documentos pendientes de revisi&oacute;n</div><div class="act-time">15 abr, 16:40</div></div>
                    </div>
                </div>
            </div>

            <!-- TOOLS (solo visible para Administrador) -->
            <asp:Panel ID="pnlHerramientas" runat="server" Visible="false">
                <h3 style="font-size:15px;color:#1a2a4a;margin-bottom:14px;">Herramientas administrativas</h3>
                <div class="tools">
                    <div class="tool-card">
                        <div class="tool-icon purple"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg></div>
                        <div><div class="tool-title">Gesti&oacute;n de Roles</div><div class="tool-sub">Administrar usuarios</div></div>
                    </div>
                    <div class="tool-card">
                        <div class="tool-icon pink"><svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg></div>
                        <div><div class="tool-title">Visualizar Firmantes</div><div class="tool-sub">Estado de firmas</div></div>
                    </div>
                    <div class="tool-card">
                        <div class="tool-icon teal"><svg viewBox="0 0 24 24"><path d="M3.5 18.49l6-6.01 4 4L22 6.92l-1.41-1.41-7.09 7.97-4-4L2 16.99z"/></svg></div>
                        <div><div class="tool-title">Estado del Sistema</div><div class="tool-sub">Cumplimiento y requisitos</div></div>
                    </div>
                </div>
            </asp:Panel>

        </div>
    </div>
</div>
</form>
</body>
</html>
