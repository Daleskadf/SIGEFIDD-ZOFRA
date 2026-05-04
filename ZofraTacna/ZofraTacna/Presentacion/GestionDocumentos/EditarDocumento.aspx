<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditarDocumento.aspx.cs" Inherits="ZofraTacna.Presentacion.EditarDocumento" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Editar Documento</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body { width: 100%; height: 100%; overflow: hidden; }
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
            border-bottom: 1px solid rgba(255,255,255,.08);
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
        .logo-icon svg { width: 20px; height: 20px; fill: white; }
        .logo-text .top { color: white; font-size: 13px; font-weight: 700; letter-spacing: 1px; }
        .logo-text .top span { color: #c0392b; }
        .logo-text .bot { color: rgba(255,255,255,.4); font-size: 9px; letter-spacing: 1px; }
        .sidebar-nav { padding: 16px 10px; flex: 1; overflow-y: auto; display: flex; flex-direction: column; }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px 12px;
            border-radius: 8px;
            color: rgba(255,255,255,.6);
            font-size: 13px;
            margin-bottom: 2px;
            text-decoration: none;
        }
        .nav-item:hover { background: rgba(255,255,255,.07); color: white; }
        .nav-item.active { background: linear-gradient(90deg, #2a3f6f, #8b1a1a); color: white; }
        .nav-item svg { width: 18px; height: 18px; }
        .main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .topbar {
            background: white;
            padding: 0 28px;
            height: 56px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #e8eaf0;
        }
        .breadcrumb { font-size: 13px; color: #999; }
        .breadcrumb strong { color: #1a2a4a; }
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
        .user-info { display: flex; align-items: center; gap: 8px; }
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
            border: none;
            margin-bottom: 10px;
            font-weight: 600;
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
        .btn-back:hover { opacity: 0.9; }
        .form-label {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1px;
            color: #555;
            margin-bottom: 8px;
            display: block;
        }
        .required { color: #c0392b; }
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
        .form-input:focus { border-color: #1a2a4a; }
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 16px;
        }
        .form-group { margin-bottom: 16px; }
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
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
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
            gap: 10px;
        }
        .btn-submit {
            padding: 12px 24px;
            border: none;
            border-radius: 9px;
            color: #fff;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            background: linear-gradient(135deg, #2a3f6f, #1a2a4a);
            transition: opacity .2s;
        }
        .btn-submit:hover { opacity: 0.9; }
        #lblMensaje { display: block; margin-bottom: 12px; }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data" style="display:flex;width:100%;height:100vh;overflow:hidden;">
        <div style="display:flex;width:100%;height:100vh;overflow:hidden;">
            <!-- SIDEBAR -->
            <div class="sidebar">
                <div class="sidebar-logo">
                    <div class="logo-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z" fill="currentColor"/></svg>
                    </div>
                    <div class="logo-text">
                        <div class="top">SIGEFIDD<span>-ZOFRA</span></div>
                        <div class="bot">ZONA FRANCA DE TACNA</div>
                    </div>
                </div>
                <nav class="sidebar-nav">
                    <div style="flex:1;overflow-y:auto">
                        <asp:Literal ID="litSidebarNav" runat="server"/>
                    </div>
                    <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" />
                </nav>
            </div>

            <!-- MAIN CONTENT -->
            <div class="main">
                <!-- TOPBAR -->
                <div class="topbar">
                    <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Editar Documento</div>
                    <div class="user-info">
                        <div class="user-avatar"><asp:Literal ID="litAvatar" runat="server"/></div>
                        <span><asp:Literal ID="litNombre" runat="server"/></span>
                        <span class="role-badge"><asp:Literal ID="litRol" runat="server"/></span>
                    </div>
                </div>

                <!-- CONTENT -->
                <div class="content">
                    <asp:Label ID="lblMensaje" runat="server" Visible="false" />

                    <div class="head">
                        <h1>Editar Documento</h1>
                        <a class="btn-back" href="MisDocumentos.aspx"> Regresar</a>
                    </div>

                    <!-- CÓDIGO DOCUMENTO -->
                    <div class="form-group">
                        <label class="form-label">CÓDIGO DE DOCUMENTO <span class="required">*</span></label>
                        <div class="form-row" style="grid-template-columns:1.2fr 1fr 1fr">
                            <asp:TextBox ID="txtCodigoDoc" runat="server" CssClass="form-input" placeholder="Ej: RS"/>
                            <asp:TextBox ID="txtNumeroDoc" runat="server" CssClass="form-input" placeholder="Ej: 001"/>
                            <asp:TextBox ID="txtAnoDoc" runat="server" CssClass="form-input" placeholder="Ej: 2026"/>
                        </div>
                    </div>

                    <!-- ASUNTO -->
                    <div class="form-group">
                        <label class="form-label">ASUNTO <span class="required">*</span></label>
                        <asp:TextBox ID="txtAsunto" runat="server" CssClass="form-input" />
                    </div>

                    <!-- DESCRIPCIÓN -->
                    <div class="form-group">
                        <label class="form-label">DESCRIPCIÓN</label>
                        <asp:TextBox ID="txtDescripcion" runat="server" TextMode="MultiLine" CssClass="form-input" Rows="3" />
                    </div>

                    <!-- CATEGORÍA Y PRIORIDAD -->
                    <div class="form-row">
                        <div>
                            <label class="form-label">CATEGORÍA <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-input"/>
                        </div>
                        <div>
                            <label class="form-label">PRIORIDAD <span class="required">*</span></label>
                            <asp:DropDownList ID="ddlPrioridad" runat="server" CssClass="form-input">
                                <asp:ListItem Value="">Seleccionar...</asp:ListItem>
                                <asp:ListItem Value="ALTA">Alta</asp:ListItem>
                                <asp:ListItem Value="MEDIA">Media</asp:ListItem>
                                <asp:ListItem Value="BAJA">Baja</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>

                    <!-- PLAZOS -->
                    <div class="form-row">
                        <div>
                            <label class="form-label">PLAZO REVISIÓN (HORAS)</label>
                            <asp:TextBox ID="txtPlazoRevision" runat="server" CssClass="form-input" placeholder="24" />
                        </div>
                        <div>
                            <label class="form-label">PLAZO FIRMA (HORAS)</label>
                            <asp:TextBox ID="txtPlazoFirma" runat="server" CssClass="form-input" placeholder="48" />
                        </div>
                    </div>

                    <!-- OBSERVACIONES -->
                    <div class="box">
                        <div class="form-label" style="margin-bottom:12px">OBSERVACIONES</div>
                        <asp:Literal ID="litObservaciones" runat="server"/>
                    </div>

                    <!-- NUEVO PDF -->
                    <div class="box">
                        <div class="form-label" style="margin-bottom:12px">NUEVO PDF (OPCIONAL)</div>
                        <div class="upload-zone">
                            📄 Clic para seleccionar un nuevo PDF
                            <asp:FileUpload ID="filePDF" runat="server" Accept=".pdf" />
                        </div>
                    </div>

                    <!-- BOTONES ACCIÓN -->
                    <div class="actions">
                        <asp:Button ID="btnEnviarCorreccion" runat="server" Text="Enviar Corrección" CssClass="btn-submit" OnClick="btnEnviarCorreccion_Click" />
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
