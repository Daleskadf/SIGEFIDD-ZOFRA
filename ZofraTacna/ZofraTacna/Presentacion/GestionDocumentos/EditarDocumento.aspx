<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="EditarDocumento.aspx.cs" Inherits="ZofraTacna.Presentacion.EditarDocumento" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Editar Documento</title>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
    <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
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
        .nav-item svg { width: 17px; height: 17px; fill: currentColor; flex-shrink: 0; }
        .nav-badge { margin-left: auto; background: #c0392b; color: white; border-radius: 10px; font-size: 10px; padding: 1px 6px; font-weight: 600; }
        .main { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
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
        .topbar-right { display: flex; align-items: center; gap: 14px; }
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
        .nav-item-logout:hover { background: linear-gradient(135deg, #a32121, #d44736); }
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
        .btn-back:hover { opacity: 0.92; }
        .btn-back-arrow { font-size: 14px; line-height: 1; }
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
            padding: 12px 22px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            color: #fff;
            border: 1.5px solid #1a2a4a;
            background: linear-gradient(90deg, #1a2a4a, #2a3f6f);
            box-shadow: 0 4px 12px rgba(26, 42, 74, .22);
        }
        .btn-visualizar:hover { filter: brightness(1.05); }
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
            from { transform: rotate(0deg); }
            to { transform: rotate(360deg); }
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
            box-shadow: 0 6px 16px rgba(26, 42, 74, .22);
        }
        .btn-submit:hover { opacity: 0.94; }
        .btn-submit-correccion {
            padding: 14px 32px;
            font-size: 14px;
            border-radius: 10px;
        }
        #lblMensaje { display: block; }
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
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
                <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
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

                <!-- CONTENT -->
                <div class="content">
                    <div class="head">
                        <h1>Editar Documento</h1>
                        <a class="btn-back" href='VerObservaciones.aspx?id=<%= Request.QueryString["id"] %>'><span class="btn-back-arrow" aria-hidden="true">&#8592;</span> Regresar</a>
                    </div>

                    <!-- CÓDIGO DOCUMENTO (un solo campo, igual que en Cargar documento) -->
                    <div class="form-group">
                        <label class="form-label">C&Oacute;DIGO DE DOCUMENTO <span class="required">*</span></label>
                        <asp:TextBox ID="txtCodigoDocumentoCompleto" runat="server" CssClass="form-input" MaxLength="120"
                            placeholder="Ej: RS-0001-2026 (c&oacute;digo completo tal como se guarda en BD)" />
                        <p style="font-size:11px;color:#999;margin-top:6px;line-height:1.4;">
                            Edite el c&oacute;digo completo manualmente si corresponde (prefijo, correlativo y a&ntilde;o seg&uacute;n su formato institucional).
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
                        <div class="upload-zone" onclick="var el=document.getElementById('<%= filePDF.ClientID %>'); if(el) el.click();">
                            📄 Clic para seleccionar un nuevo PDF
                            <asp:FileUpload ID="filePDF" runat="server" Accept=".pdf" onchange="editDocMostrarArchivoYVisor();" />
                        </div>
                        <p class="upload-hint">Si adjunta un PDF, puede previsualizarlo antes de enviar la corrección.</p>
                        <div class="msg-bajo-pdf">
                            <span id="editDocLblArchivo" class="lbl-archivo-ok" style="display:none;" aria-live="polite"></span>
                            <div id="editDocMsgCliente" class="alert-err" style="display:none;margin-top:8px;"></div>
                            <asp:Label ID="lblMensaje" runat="server" EnableViewState="true" Style="display:none;" />
                        </div>
                    </div>

                    <!-- BOTONES ACCIÓN -->
                    <div class="actions">
                        <button type="button" id="btnVisualizarPdf" class="btn-visualizar" style="display:none;" onclick="editDocAbrirVisorPdf();">📄 Visualizar documento</button>
                        <asp:Button ID="btnEnviarCorreccion" runat="server" Text="Enviar Corrección" CssClass="btn-submit btn-submit-correccion" OnClick="btnEnviarCorreccion_Click" OnClientClick="return editDocValidarAntesEnviar();" />
                    </div>

                    <!-- Modal visor PDF (mismo criterio que CargarDocumento) -->
                    <div id="modalVisorPDFEdit" style="display:none;position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.7);z-index:2000;align-items:center;justify-content:center;">
                        <div style="background:white;border-radius:12px;width:95%;height:95%;max-width:900px;display:flex;flex-direction:column;box-shadow:0 20px 60px rgba(0,0,0,0.3);">
                            <div style="display:flex;justify-content:space-between;align-items:center;padding:16px 24px;border-bottom:1.5px solid #e8eaf0;background:#f8f9fc;">
                                <div style="font-size:16px;font-weight:700;color:#1a2a4a;">Previsualización de documento PDF</div>
                                <button type="button" onclick="editDocCerrarVisorPdf()" style="background:none;border:none;font-size:28px;cursor:pointer;color:#999;padding:0;width:36px;height:36px;display:flex;align-items:center;justify-content:center;border-radius:8px;line-height:1;" title="Cerrar" aria-label="Cerrar">✕</button>
                            </div>
                            <div id="visorPDFEditContenedor" style="flex:1;overflow:hidden;display:flex;align-items:center;justify-content:center;background:#3a3a42;min-height:200px;">
                                <div id="pdfSpinnerEdit" style="text-align:center;padding:24px;">
                                    <div style="font-size:14px;color:#ccc;margin-bottom:16px;">Cargando documento…</div>
                                    <div style="width:40px;height:40px;border:4px solid #555;border-top-color:#fff;border-radius:50%;animation:spin 0.8s linear infinite;margin:0 auto;"></div>
                                </div>
                                <iframe id="pdfIframeEdit" style="width:100%;height:100%;border:none;display:none;min-height:400px;"></iframe>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="zfnToastHost" class="zfn-toast-host"></div>
    </form>
    <script type="text/javascript">
        window.editDocPdfArchivo = null;
        window.editDocPdfBlobUrl = null;
        window.editDocLockTimer = null;
        window.editDocId = parseInt('<%= Request.QueryString["id"] ?? "0" %>', 10) || 0;
        window.editDocLockToken = '<%= LockToken %>';

        function editDocGet(id) { return document.getElementById(id); }

        function editDocMostrarArchivoYVisor() {
            var fileInput = editDocGet('<%= filePDF.ClientID %>');
            var lblArchivo = editDocGet('editDocLblArchivo');
            var btnVis = editDocGet('btnVisualizarPdf');
            var msgCli = editDocGet('editDocMsgCliente');
            if (msgCli) { msgCli.style.display = 'none'; msgCli.textContent = ''; }
            if (!fileInput || !lblArchivo) return;
            if (fileInput.files.length > 0) {
                var archivo = fileInput.files[0];
                var mb = (archivo.size / (1024 * 1024)).toFixed(2);
                lblArchivo.innerHTML = '✓ <strong>Archivo listo:</strong> ' + archivo.name.replace(/</g, '&lt;') + ' (' + mb + ' MB). Puede enviar la corrección o cambiar el archivo.';
                lblArchivo.style.display = 'block';
                lblArchivo.style.color = '#1e7e34';
                if (btnVis) btnVis.style.display = 'inline-block';
                window.editDocPdfArchivo = archivo;
            } else {
                lblArchivo.innerHTML = '';
                lblArchivo.style.display = 'none';
                if (btnVis) btnVis.style.display = 'none';
                window.editDocPdfArchivo = null;
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
            var modal = editDocGet('modalVisorPDFEdit');
            if (modal) {
                modal.addEventListener('click', function (e) {
                    if (e.target === modal) editDocCerrarVisorPdf();
                });
            }
            if (window.editDocId > 0 && window.editDocLockToken) {
                editDocEnviarBloqueo('touch');
                window.editDocLockTimer = setInterval(function () { editDocEnviarBloqueo('touch'); }, 15000);
            }
        });

        function editDocValidarAntesEnviar() {
            var msgCli = editDocGet('editDocMsgCliente');
            var lblSrv = editDocGet('<%= lblMensaje.ClientID %>');
            if (lblSrv) { lblSrv.style.display = 'none'; }
            var errores = [];
            var codCompleto = (editDocGet('<%= txtCodigoDocumentoCompleto.ClientID %>') || {}).value || '';
            var asunto = (editDocGet('<%= txtAsunto.ClientID %>') || {}).value || '';
            var cat = (editDocGet('<%= ddlCategoria.ClientID %>') || {}).value || '';
            var pri = (editDocGet('<%= ddlPrioridad.ClientID %>') || {}).value || '';
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
    </script>
</body>
</html>
