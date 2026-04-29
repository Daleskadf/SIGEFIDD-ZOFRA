<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="ZofraTacna.Login" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Inicio de Sesión</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #1a2a4a 0%, #6b1a1a 100%);
        }
        .card {
            background: #fff;
            border-radius: 16px;
            padding: 40px 36px 32px;
            width: 420px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
        }
        .logo-wrap { text-align: center; margin-bottom: 28px; }
        .logo-icon {
            width: 56px; height: 56px;
            background: linear-gradient(135deg, #1a2a4a, #8b1a1a);
            border-radius: 14px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 12px;
        }
        .logo-icon svg { width: 30px; height: 30px; fill: white; }
        .title { font-size: 22px; font-weight: 700; letter-spacing: 1px; }
        .title span:first-child { color: #1a2a4a; }
        .title span:last-child  { color: #8b1a1a; }
        .subtitle { font-size: 11px; color: #888; letter-spacing: 2px; margin-top: 4px; }
        .sim-badge {
            display: inline-block;
            background: #fff8e1;
            color: #b45309;
            border: 1px solid #fcd34d;
            border-radius: 20px;
            padding: 4px 14px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .5px;
            margin-top: 12px;
        }
        .form-group { margin-bottom: 22px; }
        .form-group label {
            display: block;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1px;
            color: #555;
            margin-bottom: 8px;
        }
        .ddl-wrap { position: relative; }
        .ddl-wrap select {
            width: 100%;
            padding: 13px 40px 13px 14px;
            border: 1.5px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            color: #333;
            outline: none;
            appearance: none;
            background: white;
            cursor: pointer;
            font-family: 'Segoe UI', sans-serif;
            transition: border-color .2s;
        }
        .ddl-wrap select:focus { border-color: #1a2a4a; }
        .ddl-arrow {
            position: absolute; right: 14px; top: 50%;
            transform: translateY(-50%);
            pointer-events: none; color: #aaa; font-size: 14px;
        }
        .user-preview {
            margin-top: 12px;
            background: #f8f9fc;
            border: 1.5px solid #e8eaf0;
            border-radius: 8px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            min-height: 52px;
        }
        .preview-avatar {
            width: 36px; height: 36px;
            background: linear-gradient(135deg, #1a2a4a, #8b1a1a);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: white; font-size: 13px; font-weight: 700;
            flex-shrink: 0;
        }
        .preview-info .preview-name { font-size: 14px; font-weight: 600; color: #1a2a4a; }
        .preview-info .preview-rol  { font-size: 11px; color: #888; margin-top: 2px; }
        .preview-badge {
            margin-left: auto;
            background: #eef0f8;
            color: #1a2a4a;
            border-radius: 10px;
            padding: 3px 10px;
            font-size: 11px;
            font-weight: 600;
        }
        .btn-login {
            width: 100%;
            padding: 14px;
            background: linear-gradient(90deg, #1a2a4a, #8b1a1a);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            letter-spacing: 0.5px;
            margin-top: 4px;
        }
        .btn-login:hover { opacity: 0.9; }
        .nota {
            text-align: center;
            margin-top: 18px;
            font-size: 11px;
            color: #bbb;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="card">
            <div class="logo-wrap">
                <div class="logo-icon">
                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg>
                </div>
                <div class="title"><span>SIGEFIDD</span><span>-ZOFRA</span></div>
                <div class="subtitle">ZONA FRANCA DE TACNA &mdash; PER&Uacute;</div>
                <div class="sim-badge">&#9654; Modo Simulaci&oacute;n</div>
            </div>

            <div class="form-group">
                <label>SELECCIONE UN USUARIO</label>
                <div class="ddl-wrap">
                    <asp:DropDownList ID="ddlUsuario" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlUsuario_SelectedIndexChanged"/>
                    <span class="ddl-arrow">&#9660;</span>
                </div>
                <div class="user-preview">
                    <div class="preview-avatar"><asp:Literal ID="litPreviewAvatar" runat="server">?</asp:Literal></div>
                    <div class="preview-info">
                        <div class="preview-name"><asp:Literal ID="litPreviewNombre" runat="server">Seleccione un usuario</asp:Literal></div>
                        <div class="preview-rol"><asp:Literal ID="litPreviewRol" runat="server">&nbsp;</asp:Literal></div>
                    </div>
                    <span class="preview-badge" style="display:<asp:Literal ID="litBadgeDisplay" runat="server">none</asp:Literal>"><asp:Literal ID="litPreviewCodigo" runat="server"/></span>
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Ingresar al Sistema" CssClass="btn-login" OnClick="btnLogin_Click" />

            <div class="nota">
                Modo de simulaci&oacute;n &mdash; Sin autenticaci&oacute;n real.<br/>
                Cada usuario accede a su men&uacute; seg&uacute;n el rol asignado en la BD.
            </div>
        </div>
    </form>
</body>
</html>
