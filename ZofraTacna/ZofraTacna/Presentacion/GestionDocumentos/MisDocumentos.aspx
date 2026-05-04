<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MisDocumentos.aspx.cs" Inherits="ZofraTacna.Presentacion.MisDocumentos" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>SIGEFIDD-ZOFRA | Mis Documentos</title>
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
        .content .sub{font-size:13px;color:#888;margin-top:2px;margin-bottom:20px}
        /* FILTER TABS */
        .filter-tabs{display:flex;gap:6px;margin-bottom:20px;flex-wrap:wrap}
        .tab-btn{padding:7px 18px;border-radius:20px;border:1.5px solid #dde1f0;background:white;color:#555;font-size:13px;cursor:pointer;text-decoration:none;font-family:'Segoe UI',sans-serif;font-weight:500;transition:all .15s;display:inline-block}
        .tab-btn:hover{background:#f0f2f8;color:#1a2a4a}
        .tab-btn.tab-active{background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;border-color:transparent}
        /* TABLE */
        .tbl-wrap{background:white;border-radius:12px;box-shadow:0 1px 4px rgba(0,0,0,.06);overflow:hidden}
        table{width:100%;border-collapse:collapse}
        thead tr{background:#f8f9fc}
        thead th{padding:12px 16px;font-size:11px;font-weight:700;color:#888;text-transform:uppercase;letter-spacing:.5px;text-align:left;border-bottom:1px solid #eef0f8}
        tbody tr{border-bottom:1px solid #f4f5fa}
        tbody tr:last-child{border-bottom:none}
        tbody tr:hover{background:#fafbff}
        tbody td{padding:13px 16px;font-size:13px;color:#444;vertical-align:middle}
        .doc-asunto{font-weight:600;color:#1a2a4a;font-size:14px}
        .doc-archivo{color:#aaa;font-size:11px;margin-top:2px}
        .badge{border-radius:10px;padding:3px 10px;font-size:11px;font-weight:600;display:inline-block}
        .badge-pen,.badge-fpar{background:#f5eeff;color:#6b21a8;border:1px solid #d8b4fe}
        .badge-rev{background:#e8f0ff;color:#1a56db;border:1px solid #b3c6ff}
        .badge-fcom{background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9}
        .badge-obs{background:#fff3e0;color:#e65100;border:1px solid #ffcc80}
        .badge-reg{background:#f0f2f8;color:#555;border:1px solid #d0d4e8}
        .plazo-vencido{background:#fdecea;color:#c0392b;padding:2px 8px;border-radius:4px;font-size:11px;font-weight:600;display:inline-block}
        .plazo-warn{background:#fff8e1;color:#b45309;padding:2px 8px;border-radius:4px;font-size:11px;font-weight:600;display:inline-block}
        .plazo-ok{color:#888;font-size:11px}
        .btn-editar-doc{border:none;border-radius:9px;padding:9px 14px;cursor:pointer;font-size:12px;font-weight:700;color:#fff;background:linear-gradient(135deg,#2a3f6f,#1a2a4a);box-shadow:0 6px 16px rgba(26,42,74,.22)}
        .btn-editar-doc:hover{background:linear-gradient(135deg,#355287,#243a62)}
        .btn-editar-doc:disabled{background:#c4cada;box-shadow:none;cursor:not-allowed;color:#f6f7fb}
        .revisores-cell{min-width:230px}
        .revisores-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px 8px}
        .rev-item{font-size:11px;padding:4px 6px;border-radius:6px;background:#f4f6fb;color:#4a546d;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
        .rev-ok{background:#e8f5e9;color:#1b5e20}
        .rev-pend{background:#fff8e1;color:#9a6b00}
        .rev-obs{background:#ffebee;color:#8b1a1a}
        .empty{text-align:center;padding:60px;color:#aaa;font-size:14px}
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
                <asp:Literal ID="litSidebarNav" runat="server"/>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
        </nav>
    </div>
    <!-- MAIN -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Mis Documentos</div>
            <div class="topbar-right">
                <div class="user-info">
                    <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div>
                    <span class="user-name"><asp:Literal ID="litNombre" runat="server"/></span>
                    <span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span>
                </div>
            </div>
        </div>
        <div class="content">
            <h1>Mis Documentos</h1>
            <p class="sub">Gestionar todos los documentos del sistema</p>

            <!-- FILTER TABS -->
            <div class="filter-tabs">
                <asp:LinkButton ID="lbTodos"      runat="server" OnClick="lbTodos_Click"      CssClass="tab-btn">Todos</asp:LinkButton>
                <asp:LinkButton ID="lbPendiente"  runat="server" OnClick="lbPendiente_Click"  CssClass="tab-btn">Pendiente</asp:LinkButton>
                <asp:LinkButton ID="lbRevision"   runat="server" OnClick="lbRevision_Click"   CssClass="tab-btn">Revisi&oacute;n</asp:LinkButton>
                <asp:LinkButton ID="lbFirma"      runat="server" OnClick="lbFirma_Click"      CssClass="tab-btn">Firma</asp:LinkButton>
                <asp:LinkButton ID="lbCompletado" runat="server" OnClick="lbCompletado_Click" CssClass="tab-btn">Completado</asp:LinkButton>
            </div>

            <!-- TABLE -->
            <div class="tbl-wrap">
                <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
                    <div class="empty">No hay documentos para mostrar.</div>
                </asp:Panel>
                <asp:Panel ID="pnlTable" runat="server">
                    <table>
                        <thead>
                            <tr>
                                <th>T&Iacute;TULO</th>
                                <th>CATEGOR&Iacute;A</th>
                                <th>ESTADO</th>
                                <th>REVISORES</th>
                                <th>PLAZOS</th>
                                <th>FECHA</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptDocs" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td>
                                            <div class="doc-asunto"><%# System.Web.HttpUtility.HtmlEncode(Eval("Asunto").ToString()) %></div>
                                            <div class="doc-archivo"><%# System.Web.HttpUtility.HtmlEncode(Eval("NombreArchivo").ToString()) %></div>
                                        </td>
                                        <td><%# System.Web.HttpUtility.HtmlEncode(Eval("AreaCategoria").ToString()) %></td>
                                        <td><span class='badge <%# Eval("BadgeCss") %>'><%# Eval("EstadoDesc") %></span></td>
                                        <td class="revisores-cell"><%# Eval("RevisoresHtml") %></td>
                                        <td><%# Eval("PlazosHtml") %></td>
                                        <td><%# Eval("FechaStr") %></td>
                                        <td>
                                            <button
                                                type="button"
                                                class="btn-editar-doc"
                                                <%# Convert.ToBoolean(Eval("PuedeVerObservaciones")) ? "" : "disabled='disabled' title='Se habilita cuando un revisor registre una observación'" %>
                                                onclick="window.location.href='VerObservaciones.aspx?id=<%# Eval("IdDocumento") %>'">
                                                Ver Observaciones
                                            </button>
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
<script type="text/javascript">
    (function () {
        try {
            sessionStorage.removeItem('revisores_temp');
            sessionStorage.removeItem('firmantes_temp');
        } catch (e) { }
    })();
</script>
</form>
</body>
</html>
