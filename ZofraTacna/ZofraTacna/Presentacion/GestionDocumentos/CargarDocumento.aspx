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

            <div class="form-group">
                <label class="form-label">ÁREA (UNIDAD ORGÁNICA) <span class="required">*</span></label>
                <asp:DropDownList ID="ddlArea" runat="server" CssClass="form-input"/>
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
            <!-- Buscador de empleados y asignación de participantes -->
            <div class="plazos-box">
                <div class="plazos-title">Asignar Revisores y Firmantes</div>
                <div class="plazos-sub">Busque empleados por nombre o login y asígnelos como revisores o firmantes.</div>

                <div style="margin-bottom:20px;">
                    <label class="form-label">BUSCAR EMPLEADO <span class="required">*</span></label>
                    <asp:TextBox ID="txtBuscador" runat="server" CssClass="form-input" placeholder="Escriba nombre o login..." AutoPostBack="true" OnTextChanged="txtBuscador_TextChanged"/>
                    <asp:ListBox ID="lstBuscador" runat="server" style="width:100%;margin-top:8px;border:1.5px solid #e0e0e0;border-radius:8px;max-height:200px;" Visible="false" OnSelectedIndexChanged="lstBuscador_SelectedIndexChanged" AutoPostBack="true" SelectionMode="Single"/>
                </div>

                <!-- Dos columnas: Revisores y Firmantes -->
                <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-top:20px;">
                    <!-- COLUMNA IZQUIERDA: REVISORES -->
                    <div style="border:1.5px solid #e8eaf0;border-radius:8px;padding:16px;background:#f8f9fc;">
                        <div style="font-size:13px;font-weight:700;color:#1a2a4a;margin-bottom:12px;">
                            ✓ REVISORES (sin orden)
                        </div>
                        <div id="listaRevisores" style="min-height:100px;border:1px dashed #ccc;border-radius:6px;padding:12px;background:white;">
                            <!-- Revisores agregados aquí -->
                        </div>
                        <div style="font-size:11px;color:#999;margin-top:8px;">
                            Haz clic en un empleado para asignar como revisor
                        </div>
                    </div>

                    <!-- COLUMNA DERECHA: FIRMANTES -->
                    <div style="border:1.5px solid #e8eaf0;border-radius:8px;padding:16px;background:#f8f9fc;">
                        <div style="font-size:13px;font-weight:700;color:#1a2a4a;margin-bottom:12px;">
                            🔏 FIRMANTES (con orden)
                        </div>
                        <div id="listaFirmantes" style="min-height:100px;border:1px dashed #ccc;border-radius:6px;padding:12px;background:white;">
                            <!-- Firmantes agregados aquí con orden -->
                        </div>
                        <div style="font-size:11px;color:#999;margin-top:8px;">
                            Haz clic en un empleado para asignar como firmante
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
    // BUSCADOR: Evento keyup para filtrar empleados
    // ============================================================
    document.addEventListener('DOMContentLoaded', function() {
        let txtBuscador = document.getElementById('<%= txtBuscador.ClientID %>');
        if (txtBuscador) {
            txtBuscador.addEventListener('keyup', function() {
                let lstBuscador = document.getElementById('<%= lstBuscador.ClientID %>');
                let valor = this.value.toLowerCase().trim();
                textoOriginalBuscador = this.value;

                if (valor.length > 0) {
                    __doPostBack('<%= lstBuscador.ClientID %>', 'Search');
                } else {
                    lstBuscador.style.display = 'none';
                }
            });
        }
    });

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
            listaRevisoresDiv.innerHTML = '<div style="color:#999;text-align:center;padding:20px;">Sin revisores</div>';
        } else {
            let html = '';
            for (let i = 0; i < revisores.length; i++) {
                let r = revisores[i];
                html += '<div class="participante-tag" data-login="' + r.login + '" ';
                html += 'style="background:#e8f5e9;border:1px solid #4caf50;color:#1b5e20;';
                html += 'display:inline-flex;align-items:center;gap:8px;padding:8px 12px;';
                html += 'border-radius:6px;margin:4px;font-size:13px;">';
                html += r.nombre;
                html += '<span class="close-btn" style="cursor:pointer;margin-left:4px;font-weight:bold;font-size:16px;" ';
                html += 'onclick="removerRevisor(\'' + r.login + '\')">×</span>';
                html += '</div>';
            }
            listaRevisoresDiv.innerHTML = html;
        }

        // -------- COLUMNA FIRMANTES --------
        let listaFirmantesDiv = document.getElementById('listaFirmantes');
        if (!listaFirmantesDiv) {
            console.error('No se encontró elemento listaFirmantes');
            return;
        }

        if (firmantes.length === 0) {
            listaFirmantesDiv.innerHTML = '<div style="color:#999;text-align:center;padding:20px;">Sin firmantes</div>';
        } else {
            let html = '';
            for (let i = 0; i < firmantes.length; i++) {
                let f = firmantes[i];
                html += '<div class="participante-tag" data-login="' + f.login + '" ';
                html += 'style="background:#e3f2fd;border:1px solid #2196f3;color:#0d47a1;';
                html += 'display:inline-flex;align-items:center;gap:8px;padding:8px 12px;';
                html += 'border-radius:6px;margin:4px;font-size:13px;">';
                html += '<input type="number" class="orden-input" value="' + f.orden + '" ';
                html += 'min="1" max="' + firmantes.length + '" ';
                html += 'onchange="actualizarOrden(\'' + f.login + '\', this.value)" ';
                html += 'style="width:40px;padding:4px;border:1px solid #2196f3;border-radius:4px;text-align:center;"/>';
                html += '<span style="flex:1;">' + f.nombre + '</span>';
                html += '<span class="close-btn" style="cursor:pointer;font-weight:bold;font-size:16px;" ';
                html += 'onclick="removerFirmante(\'' + f.login + '\')">×</span>';
                html += '</div>';
            }
            listaFirmantesDiv.innerHTML = html;
        }

        // Actualizar campo oculto del servidor
        guardarParticipantes();
    }

    // ============================================================
    // REMOVER: Revisor (también lo saca de firmantes)
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
    // REMOVER: Firmante (solo de firmantes)
    // ============================================================
    function removerFirmante(login) {
        firmantes = firmantes.filter(f => f.login !== login);
        firmantes.forEach((f, idx) => f.orden = idx + 1);
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
        console.log('✓ Firmante eliminado');
    }

    // ============================================================
    // ORDEN: Actualizar números de firma
    // ============================================================
    function actualizarOrden(login, nuevoOrden) {
        let orden = parseInt(nuevoOrden);
        if (isNaN(orden) || orden < 1) orden = 1;
        if (orden > firmantes.length) orden = firmantes.length;

        let firmante = firmantes.find(f => f.login === login);
        if (firmante) {
            let anterior = firmante.orden;
            firmante.orden = orden;

            if (orden > anterior) {
                firmantes
                    .filter(f => f.orden > anterior && f.orden <= orden && f.login !== login)
                    .forEach(f => f.orden--);
            } else {
                firmantes
                    .filter(f => f.orden < anterior && f.orden >= orden && f.login !== login)
                    .forEach(f => f.orden++);
            }

            firmantes.sort((a, b) => a.orden - b.orden);
            firmantes.forEach((f, idx) => f.orden = idx + 1);

            renderizarParticipantes();
            guardarParticipantesEnSessionStorage();
        }
    }

    // ============================================================
    // GUARDAR: En campo oculto del servidor (para POST)
    // ============================================================
    function guardarParticipantes() {
        let participantes = [];
        let loginsProcesados = new Set();

        // IMPORTANTE: Todos los participantes se guardan como REVISOR en la BD
        // Los que aparecen en firmantes solo tienen el orden, pero el rol es REVISOR

        // Agregar REVISORES
        revisores.forEach(r => {
            participantes.push({
                login: r.login,
                nombre: r.nombre,
                tipo: 'REV',  // ← SIEMPRE REVISOR
                orden: 0
            });
            loginsProcesados.add(r.login);
        });

        // Agregar FIRMANTES que NO sean revisores
        // PERO también como REVISOR en BD
        firmantes.forEach(f => {
            if (!loginsProcesados.has(f.login)) {
                participantes.push({
                    login: f.login,
                    nombre: f.nombre,
                    tipo: 'REV',  // ← TAMBIÉN REVISOR
                    orden: 0
                });
                loginsProcesados.add(f.login);
            }
        });

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
    // MODAL: Selector de años
    // ============================================================
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

    // ============================================================
    // PREVIEW: Código de documento
    // ============================================================
    function actualizarPreview() {
        var codigo = (document.getElementById('<%= txtCodigoDoc.ClientID %>').value || 'RS').toUpperCase();
        var numero = document.getElementById('<%= txtNumeroDoc.ClientID %>').value || '1';
        var ano = document.getElementById('<%= txtAnoDoc.ClientID %>').value || '2026';

        numero = numero.replace(/[^0-9]/g, '');
        numero = ('000' + numero).slice(-4);

        var resultado = codigo + '-' + numero + '-' + ano;
        document.getElementById('<%= litCodigoPreview.ClientID %>').textContent = resultado;
    }

    // ============================================================
    // INICIALIZACIÓN: Después de DOMContentLoaded
    // ============================================================
    document.addEventListener('DOMContentLoaded', function() {
        // Renderizar participantes recuperados
        renderizarParticipantes();

        // Setup de eventos para código, número y año
        var txtCodigo = document.getElementById('<%= txtCodigoDoc.ClientID %>');
        var txtNumero = document.getElementById('<%= txtNumeroDoc.ClientID %>');
        var txtAno = document.getElementById('<%= txtAnoDoc.ClientID %>');
        var modal = document.getElementById('modalAnoSelector');

        if (txtCodigo) {
            txtCodigo.addEventListener('keyup', function() {
                this.value = this.value.replace(/[^A-Za-z]/g, '').toUpperCase();
                actualizarPreview();
            });
        }

        if (txtNumero) {
            txtNumero.addEventListener('keyup', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
                actualizarPreview();
            });
        }

        if (modal) {
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    cerrarSelectorAnos();
                }
            });
        }

        actualizarPreview();
    });

    // ============================================================
    // LIMPIAR: Al enviar el formulario (guardar participantes)
    // ============================================================
    window.addEventListener('beforeunload', function() {
        // Los datos en sessionStorage se mantienen hasta cerrar el navegador
    });
</script>
</form>
</body>
</html>