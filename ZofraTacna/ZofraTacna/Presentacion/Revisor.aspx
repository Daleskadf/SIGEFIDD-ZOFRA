<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Revisor.aspx.cs" Inherits="ZofraTacna.Revisor" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Revisor</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; }
        body { font-family: 'Segoe UI', sans-serif; background: #f0f2f5; display: flex; height: 100vh; }

        .sidebar { width: 230px; min-width: 230px; background: #1a2a4a; display: flex; flex-direction: column; height: 100vh; }
        .sidebar-logo { padding: 20px 18px 16px; border-bottom: 1px solid rgba(255,255,255,0.08); display: flex; align-items: center; gap: 10px; }
        .sidebar-logo .logo-icon { width: 36px; height: 36px; background: linear-gradient(135deg, #2a3f6f, #8b1a1a); border-radius: 8px; display: flex; align-items: center; justify-content: center; }
        .sidebar-logo .logo-icon svg { width: 20px; height: 20px; fill: white; }
        .sidebar-logo .logo-text .top { color: white; font-size: 13px; font-weight: 700; letter-spacing: 1px; }
        .sidebar-logo .logo-text .top span { color: #c0392b; }
        .sidebar-logo .logo-text .bot { color: rgba(255,255,255,0.4); font-size: 9px; letter-spacing: 1px; }
        .sidebar-nav { padding: 16px 10px; flex: 1; }
        .nav-item { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 8px; color: rgba(255,255,255,0.6); font-size: 13px; cursor: pointer; margin-bottom: 2px; text-decoration: none; position: relative; }
        .nav-item:hover { background: rgba(255,255,255,0.07); color: white; }
        .nav-item.active { background: linear-gradient(90deg, #2a3f6f, #8b1a1a); color: white; }
        .nav-item svg { width: 17px; height: 17px; fill: currentColor; flex-shrink: 0; }
        .nav-badge { margin-left: auto; background: #c0392b; color: white; border-radius: 10px; font-size: 10px; padding: 1px 6px; font-weight: 600; }
        .nav-item-logout { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 8px; color: white; font-size: 13px; cursor: pointer; margin-top: auto; text-decoration: none; background: #c0392b; border: 1.5px solid #a0271f; margin-bottom: 10px; }
        .nav-item-logout:hover { background: #a0271f; }

        .main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .topbar { background: white; padding: 0 28px; height: 56px; display: flex; align-items: center; justify-content: space-between; border-bottom: 1px solid #e8eaf0; flex-shrink: 0; }
        .breadcrumb { font-size: 13px; color: #999; }
        .breadcrumb strong { color: #1a2a4a; }
        .topbar-right { display: flex; align-items: center; gap: 14px; }
        .user-avatar { width: 34px; height: 34px; background: linear-gradient(135deg, #1a2a4a, #8b1a1a); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: white; font-size: 12px; font-weight: 700; }
        .user-info { display: flex; align-items: center; gap: 8px; }
        .user-name { font-size: 14px; font-weight: 600; color: #333; }
        .role-badge { background: #eef0f8; color: #1a2a4a; border-radius: 12px; padding: 2px 10px; font-size: 11px; font-weight: 600; }
        .btn-logout { padding: 6px 16px; border: 1.5px solid #ddd; border-radius: 6px; background: white; color: #555; font-size: 13px; cursor: pointer; }
        .btn-logout:hover { background: #f5f5f5; }

        .content { flex: 1; padding: 28px; overflow-y: auto; }
        .content-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 24px; }
        .content-header h1 { font-size: 24px; color: #1a2a4a; font-weight: 700; }
        .content-header p  { font-size: 13px; color: #888; margin-top: 2px; }
        .btn-action { display: flex; align-items: center; gap: 8px; background: linear-gradient(90deg, #1a2a4a, #8b1a1a); color: white; border: none; border-radius: 8px; padding: 10px 20px; font-size: 14px; font-weight: 600; cursor: pointer; }
        .btn-action:hover { opacity: 0.9; }

        .stats { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 24px; }
        .stat-card { background: white; border-radius: 12px; padding: 20px; display: flex; align-items: center; gap: 14px; box-shadow: 0 1px 4px rgba(0,0,0,0.06); }
        .stat-icon { width: 44px; height: 44px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
        .stat-icon svg { width: 22px; height: 22px; }
        .stat-icon.yellow { background: #fff8e1; } .stat-icon.yellow svg { fill: #f59f00; }
        .stat-icon.green  { background: #e8f5e9; } .stat-icon.green svg  { fill: #2e7d32; }
        .stat-icon.blue   { background: #eef2ff; } .stat-icon.blue svg   { fill: #3b5bdb; }
        .stat-num   { font-size: 26px; font-weight: 700; color: #1a2a4a; }
        .stat-label { font-size: 12px; color: #888; margin-top: 2px; }

        .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; }
        .section-title { display: flex; align-items: center; gap: 8px; font-size: 15px; font-weight: 600; color: #1a2a4a; }
        .alert-badge { background: #c0392b; color: white; border-radius: 10px; font-size: 11px; padding: 1px 7px; font-weight: 700; }
        .ver-todas { font-size: 12px; color: #3b5bdb; text-decoration: none; }

        .alerta-item { background: white; border-radius: 10px; padding: 14px 18px; margin-bottom: 10px; display: flex; align-items: center; justify-content: space-between; box-shadow: 0 1px 3px rgba(0,0,0,0.05); border-left: 4px solid; }
        .alerta-item.critico { border-color: #c0392b; }
        .alerta-item.urgente { border-color: #f59f00; }
        .alerta-dot { width: 9px; height: 9px; border-radius: 50%; margin-right: 10px; flex-shrink: 0; }
        .alerta-dot.critico { background: #c0392b; }
        .alerta-dot.urgente { background: #f59f00; }
        .alerta-tiempo { font-size: 13px; font-weight: 600; }
        .alerta-tiempo.critico { color: #c0392b; }
        .alerta-tiempo.urgente { color: #f59f00; }
        .alerta-nombre { font-size: 14px; font-weight: 600; color: #222; margin-top: 2px; }
        .alerta-meta   { font-size: 12px; color: #999; margin-top: 2px; }
        .badge-nivel { border-radius: 12px; padding: 3px 12px; font-size: 11px; font-weight: 600; border: 1px solid; }
        .badge-nivel.critico { color: #c0392b; border-color: #c0392b; background: #fff5f5; }
        .badge-nivel.urgente { color: #f59f00; border-color: #f59f00; background: #fffbf0; }
        .sin-alertas { background: white; border-radius: 10px; padding: 30px; text-align: center; color: #aaa; font-size: 14px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); }
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
                <div class="bot">ZONA FRANCA DE TACNA</div>
            </div>
        </div>
        <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1; overflow-y: auto;">
                <a href="Revisor.aspx" class="nav-item active">
                    <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>
                    Inicio
                </a>
                <a href="BandejaTrabajo/BandejaTrabajo.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>
                    Bandeja de Trabajo
                    <span class="nav-badge"><asp:Literal ID="litBadgeBandeja" runat="server" /></span>
                </a>
                <a href="GestionDocumentos/Historial.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
                    Historial
                </a>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>

    <!-- MAIN -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Inicio</div>
            <div class="topbar-right">
                <div class="user-info">
                    <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server" /></div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server" /></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server" /></span>
                </div>
            </div>
        </div>

        <div class="content">
            <div class="content-header">
                <div>
                    <h1>Bienvenido, <asp:Literal ID="litBienvenido" runat="server" /></h1>
                    <p>Dashboard de Revisor</p>
                </div>
                <button class="btn-action" type="button">
                    <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:white;"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>
                    Ver Bandeja
                </button>
            </div>

            <!-- STATS -->
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-icon yellow">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litPendientes" runat="server" /></div><div class="stat-label">Pendientes de revisi&oacute;n</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litRevisados" runat="server" /></div><div class="stat-label">Documentos revisados</div></div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                    </div>
                    <div><div class="stat-num"><asp:Literal ID="litTotal" runat="server" /></div><div class="stat-label">Total documentos</div></div>
                </div>
            </div>

            <!-- ALERTAS -->
            <div class="section-header">
                <div class="section-title">
                    <svg viewBox="0 0 24 24" style="width:18px;height:18px;fill:#f59f00;"><path d="M1 21h22L12 2 1 21zm12-3h-2v-2h2v2zm0-4h-2v-4h2v4z"/></svg>
                    Alertas de Plazos
                    <span class="alert-badge"><asp:Literal ID="litTotalAlertas" runat="server" /></span>
                </div>
                <a href="#" class="ver-todas">Ver todas</a>
            </div>

            <asp:Panel ID="pnlSinAlertas" runat="server" Visible="false">
                <div class="sin-alertas">No hay alertas de plazos pendientes.</div>
            </asp:Panel>

            <asp:Repeater ID="rptAlertas" runat="server">
                <ItemTemplate>
                    <div class="alerta-item <%# Eval("NivelCss") %>">
                        <div style="display:flex;align-items:flex-start;gap:10px;flex:1;">
                            <div class="alerta-dot <%# Eval("NivelCss") %>"></div>
                            <div>
                                <div class="alerta-tiempo <%# Eval("NivelCss") %>">Plazo vencido hace <%# Eval("HorasVencido") %> horas</div>
                                <div class="alerta-nombre"><%# Eval("Asunto") %></div>
                                <div class="alerta-meta"><%# Eval("EstadoDesc") %> &bull; L&iacute;mite: <%# Eval("FechaLimite") %></div>
                            </div>
                        </div>
                        <span class="badge-nivel <%# Eval("NivelCss") %>"><%# Eval("NivelLabel") %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</div>
</form>
</body>
</html>
