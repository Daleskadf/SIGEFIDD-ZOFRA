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
        .search-wrap { position: relative; margin-bottom: 6px; }
        .search-wrap input {
            width: 100%; padding: 10px 14px 10px 36px;
            border: 1.5px solid #e0e0e0; border-radius: 8px;
            font-size: 13px; color: #333; outline: none;
            font-family: 'Segoe UI', sans-serif; transition: border-color .2s;
        }
        .search-wrap input:focus { border-color: #1a2a4a; }
        .search-wrap input::placeholder { color: #bbb; }
        .search-icon {
            position: absolute; left: 11px; top: 50%;
            transform: translateY(-50%); color: #bbb; font-size: 14px;
            pointer-events: none;
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
                <div class="search-wrap">
                    <span class="search-icon">&#128269;</span>
                    <input type="text" id="txtBuscar" placeholder="Buscar usuario..." autocomplete="off" oninput="filtrar(this.value)" />
                </div>
                <div class="ddl-wrap">
                    <asp:DropDownList ID="ddlUsuario" runat="server" />
                    <span class="ddl-arrow">&#9660;</span>
                </div>
                <div class="user-preview" id="userPreview">
                    <div class="preview-avatar" id="pvAvatar">?</div>
                    <div class="preview-info">
                        <div class="preview-name" id="pvNombre">Seleccione un usuario</div>
                        <div class="preview-rol" id="pvRol">&nbsp;</div>
                    </div>
                    <span class="preview-badge" id="pvBadge" style="display:none"></span>
                </div>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="Ingresar al Sistema" CssClass="btn-login" OnClick="btnLogin_Click" />

            <div class="nota">
                Modo de simulaci&oacute;n &mdash; Sin autenticaci&oacute;n real.<br/>
                Cada usuario accede a su men&uacute; seg&uacute;n el rol asignado en la BD.
            </div>
        </div>
    </form>
    <script type="text/javascript">
        var _opts = [];
        var _selId = '<%= ddlUsuario.ClientID %>';

        window.addEventListener('load', function () {
            var sel = document.getElementById(_selId);
            for (var i = 0; i < sel.options.length; i++) {
                var o = sel.options[i];
                _opts.push({
                    v: o.value,
                    t: o.text,
                    rol: o.getAttribute('data-rol') || '',
                    rolNombre: o.getAttribute('data-rolnombre') || ''
                });
            }
            sel.addEventListener('change', actualizarPreview);
            actualizarPreview();
        });

        function filtrar(q) {
            q = q.toLowerCase().trim();
            var sel = document.getElementById(_selId);
            var prev = sel.value;
            // Solo filtrar items reales (excluir placeholder con value vacio)
            var usuarios = _opts.filter(function (o) { return o.v !== ''; });
            var res = q === '' ? _opts : usuarios.filter(function (o) {
                return o.v.toLowerCase().indexOf(q) >= 0;
            });
            sel.innerHTML = '';
            var found = false;
            for (var i = 0; i < res.length; i++) {
                var opt = document.createElement('option');
                opt.value = res[i].v;
                opt.text = res[i].t;
                opt.setAttribute('data-rol', res[i].rol);
                opt.setAttribute('data-rolnombre', res[i].rolNombre);
                if (res[i].v === prev) { opt.selected = true; found = true; }
                sel.appendChild(opt);
            }
            if (!found && res.length > 0) sel.selectedIndex = 0;
            actualizarPreview();
        }

        function actualizarPreview() {
            var sel = document.getElementById(_selId);
            var av = document.getElementById('pvAvatar');
            var nm = document.getElementById('pvNombre');
            var rl = document.getElementById('pvRol');
            var bg = document.getElementById('pvBadge');

            if (!sel || sel.selectedIndex < 0 || !sel.value) {
                av.textContent = '?';
                nm.textContent = 'Seleccione un usuario';
                rl.innerHTML = '\u00a0';
                bg.style.display = 'none';
                bg.textContent = '';
                return;
            }
            var opt = sel.options[sel.selectedIndex];
            var login = sel.value;
            var rol = opt.getAttribute('data-rol') || '';
            var rolNombre = opt.getAttribute('data-rolnombre') || '';

            av.textContent = login.length >= 2 ? login.substring(0, 2).toUpperCase() : login.toUpperCase();
            nm.textContent = login;
            rl.textContent = rolNombre;
            if (rol) {
                bg.textContent = rol;
                bg.style.display = 'inline-block';
            } else {
                bg.style.display = 'none';
            }
        }
    </script>
</body>
</html>
