<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CargarDocumento.aspx.cs" Inherits="ZofraTacna.Presentacion.CargarDocumento" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8"/><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>SIGEFIDD-ZOFRA | Cargar Documento</title>
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
        .content .sub{font-size:13px;color:#888;margin-top:2px;margin-bottom:28px}
        .form-label{font-size:11px;font-weight:700;letter-spacing:1px;color:#555;margin-bottom:6px;display:block}
        .required{color:#c0392b}
        .form-input{width:100%;padding:12px 14px;border:1.5px solid #e0e0e0;border-radius:8px;font-size:14px;color:#333;font-family:'Segoe UI',sans-serif;outline:none}
        .form-input:focus{border-color:#1a2a4a}
        textarea.form-input{resize:vertical;min-height:90px}
        .form-row{display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:20px}
        .form-group{margin-bottom:20px}
        .plazos-box{border:1.5px solid #e8eaf0;border-radius:10px;padding:20px;margin-bottom:20px}
        .plazos-title{font-size:14px;font-weight:600;color:#1a2a4a;margin-bottom:4px}
        .plazos-sub{font-size:12px;color:#3b5bdb;margin-bottom:16px}
        .plazos-hint{font-size:11px;color:#aaa;margin-top:4px}
        .upload-zone{border:2px dashed #b0b8d0;border-radius:10px;padding:40px;text-align:center;cursor:pointer;background:#fafbff;margin-bottom:24px;position:relative}
        .upload-zone:hover{border-color:#1a2a4a;background:#f0f2ff}
        .upload-zone svg{width:36px;height:36px;fill:#aab;margin-bottom:10px}
        .upload-zone .uz-title{font-size:14px;font-weight:500;color:#555;margin-bottom:4px}
        .upload-zone .uz-sub{font-size:12px;color:#aaa}
        .upload-zone input[type=file]{position:absolute;inset:0;opacity:0;cursor:pointer}
        .form-actions{display:flex;gap:12px}
        .btn-submit{padding:12px 28px;background:linear-gradient(90deg,#1a2a4a,#8b1a1a);color:white;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer}
        .btn-cancel{padding:12px 24px;background:white;color:#555;border:1.5px solid #ddd;border-radius:8px;font-size:14px;cursor:pointer}
        .alert-ok{background:#d4edda;color:#155724;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px}
        .alert-err{background:#f8d7da;color:#721c24;padding:12px 16px;border-radius:8px;margin-bottom:16px;font-size:13px}
    </style>
</head>
<body>
<form id="form1" runat="server" enctype="multipart/form-data" style="display:flex;width:100%;height:100vh;overflow:hidden;">
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
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Cargar Documento</div>
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
            <h1>Cargar Nuevo Documento</h1>
            <p class="sub">Ingrese los metadatos del documento y adjunte el archivo PDF</p>
            <asp:Label ID="lblMensaje" runat="server" Visible="false" />

            <div class="form-group">
                <label class="form-label">CÓDIGO DE DOCUMENTO <span class="required">*</span></label>
                <div style="display:grid;grid-template-columns:1.2fr 1fr 1fr;gap:12px;align-items:flex-end;">
                    <div>
                        <label style="font-size:11px;color:#888;display:block;margin-bottom:6px;">CÓDIGO (letras)</label>
                        <asp:TextBox ID="txtCodigoDoc" runat="server" CssClass="form-input" placeholder="RS" style="text-transform:uppercase;"/>
                    </div>
                    <div>
                        <label style="font-size:11px;color:#888;display:block;margin-bottom:6px;">NÚMERO</label>
                        <asp:TextBox ID="txtNumeroDoc" runat="server" CssClass="form-input" placeholder="1" />
                    </div>
                    <div>
                        <label style="font-size:11px;color:#888;display:block;margin-bottom:6px;">AÑO</label>
                        <asp:TextBox ID="txtAnoDoc" runat="server" CssClass="form-input" Text="2026" ReadOnly="true" style="background:#f5f5f5;cursor:pointer;"/>
                        <button type="button" onclick="abrirSelectorAnos()" style="position:absolute;right:12px;margin-top:-38px;background:linear-gradient(90deg,#1a2a4a,#8b1a1a);color:white;border:none;border-radius:4px;padding:8px 12px;cursor:pointer;font-size:14px;">📅</button>
                    </div>
                </div>
                <div style="font-size:11px;color:#999;margin-top:6px;">
                    Resultado: <strong><asp:Literal ID="litCodigoPreview" runat="server" Text="RS-0001-2026"/></strong>
                </div>
            </div>

            <!-- Modal Selector de Años -->
            <div id="modalAnoSelector" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.5);z-index:1000;align-items:center;justify-content:center;">
                <div style="background:white;border-radius:12px;padding:24px;width:90%;max-width:400px;box-shadow:0 10px 40px rgba(0,0,0,0.3);">
                    <div style="font-size:16px;font-weight:700;color:#1a2a4a;margin-bottom:16px;">Seleccionar Año</div>
                    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;max-height:300px;overflow-y:auto;margin-bottom:16px;">
                        <asp:Literal ID="litAnosLista" runat="server"/>
                    </div>
                    <div style="display:flex;gap:8px;justify-content:flex-end;">
                        <button type="button" onclick="cerrarSelectorAnos()" style="padding:8px 16px;border:1.5px solid #ddd;border-radius:6px;background:white;color:#555;cursor:pointer;">Cancelar</button>
                    </div>
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
            <div class="plazos-box">
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
            <div class="plazos-box">
                <div class="plazos-title">Asignar Firmantes</div>
                <div class="plazos-sub">Seleccione los usuarios que deben firmar este documento en orden.</div>
   
                <div class="form-row">
                    <div>
                        <label class="form-label">USUARIO</label>
                        <asp:DropDownList ID="ddlFirmante" runat="server" CssClass="form-input"/>
                    </div>
                    <div style="display:flex;align-items:flex-end;">
                        <asp:Button ID="btnAgregarFirmante" runat="server" Text="+ Agregar"
                            CssClass="btn-submit" OnClick="btnAgregarFirmante_Click"
                            CausesValidation="false" Style="margin-bottom:0"/>
                    </div>
                </div>

                <!-- Lista de firmantes agregados -->
                <asp:Repeater ID="rptFirmantes" runat="server" OnItemCommand="rptFirmantes_ItemCommand">
                    <HeaderTemplate>
                        <table style="width:100%;margin-top:12px;border-collapse:collapse;">
                        <tr style="background:#f0f2f5;font-size:12px;font-weight:700;color:#555;">
                            <td style="padding:8px 12px;">ORDEN</td>
                            <td style="padding:8px 12px;">USUARIO</td>
                            <td style="padding:8px 12px;">TIPO</td>
                            <td style="padding:8px 12px;"></td>
                        </tr>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr style="border-bottom:1px solid #eee;font-size:13px;">
                            <td style="padding:8px 12px;"><%# Eval("Orden") %></td>
                            <td style="padding:8px 12px;"><%# Eval("Login") %></td>
                            <td style="padding:8px 12px;"><%# Eval("Tipo") %></td>
                            <td style="padding:8px 12px;">
                                <asp:LinkButton runat="server" CommandName="Eliminar"
                                    CommandArgument='<%# Eval("Login") %>'
                                    Style="color:#c0392b;font-size:12px;">Quitar</asp:LinkButton>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></table></FooterTemplate>
                </asp:Repeater>

                <!-- Campo oculto para pasar la lista al servidor -->
                <asp:HiddenField ID="hfFirmantes" runat="server" />
            </div>

            <div class="form-group">
                <label class="form-label">ARCHIVO PDF <span class="required">*</span></label>
                <div class="upload-zone" onclick="document.getElementById('filePDF').click()">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zm-2 8H7v-2h4v2zm6-4H7v-2h10v2z"/></svg>
                    <div class="uz-title">Haga clic para seleccionar un archivo PDF</div>
                    <div class="uz-sub">Solo archivos PDF (max 10MB)</div>
                    <asp:FileUpload ID="filePDF" runat="server" Style="display:none" Accept=".pdf"/>
                </div>
                <asp:Label ID="lblArchivo" runat="server" Style="font-size:13px;color:#555"/>
            </div>
            <div class="form-actions">
                <asp:Button ID="btnCargar" runat="server" Text="Cargar Documento" CssClass="btn-submit" OnClick="btnCargar_Click"/>
                <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn-cancel" OnClick="btnCancelar_Click" CausesValidation="false"/>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
    // Manejo del modal de años
    function abrirSelectorAnos() {
        document.getElementById('modalAnoSelector').style.display = 'flex';
    }

    function cerrarSelectorAnos() {
        document.getElementById('modalAnoSelector').style.display = 'none';
    }

    function seleccionarAno(ano) {
        document.getElementById('<%= txtAnoDoc.ClientID %>').value = ano;
        actualizarPreview();
        cerrarSelectorAnos();
    }

    // Actualizar vista previa en tiempo real
    function actualizarPreview() {
        var codigo = (document.getElementById('<%= txtCodigoDoc.ClientID %>').value || 'RS').toUpperCase();
        var numero = document.getElementById('<%= txtNumeroDoc.ClientID %>').value || '1';
        var ano = document.getElementById('<%= txtAnoDoc.ClientID %>').value || '2026';

        // Convertir número a 4 dígitos con ceros a la izquierda
        numero = numero.replace(/[^0-9]/g, ''); // Solo números
        numero = ('000' + numero).slice(-4); // Rellena con ceros a la izquierda

        var resultado = codigo + '-' + numero + '-' + ano;
        document.getElementById('<%= litCodigoPreview.ClientID %>').textContent = resultado;
    }

    // Event listeners
    document.addEventListener('DOMContentLoaded', function() {
        var txtCodigo = document.getElementById('<%= txtCodigoDoc.ClientID %>');
        var txtNumero = document.getElementById('<%= txtNumeroDoc.ClientID %>');
        var txtAno = document.getElementById('<%= txtAnoDoc.ClientID %>');
        var modal = document.getElementById('modalAnoSelector');

        // Solo letras en código
        if (txtCodigo) {
            txtCodigo.addEventListener('keyup', function() {
                this.value = this.value.replace(/[^A-Za-z]/g, '').toUpperCase();
                actualizarPreview();
            });
        }

        // Solo números en número
        if (txtNumero) {
            txtNumero.addEventListener('keyup', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                actualizarPreview();
            });
        }

        // Cerrar modal al hacer click fuera
        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    cerrarSelectorAnos();
                }
            });
        }

        // Inicializar preview
        actualizarPreview();
    });
</script>
</form>
</body>
</html>