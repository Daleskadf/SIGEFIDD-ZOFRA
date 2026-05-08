(function () {
    function qs(id) { return document.getElementById(id); }

    function getEndpoint() {
        var f = document.getElementById('form1');
        if (f && f.getAttribute('data-zfn-notify')) return f.getAttribute('data-zfn-notify');
        var b = document.body;
        return b ? b.getAttribute('data-zfn-notify') : '';
    }

    function fetchJson(url) {
        return fetch(url, { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
            .then(function (r) {
                if (r.status === 401) return { ok: false, unauthorized: true };
                return r.json();
            });
    }

    function showToast(text) {
        var host = qs('zfnToastHost');
        if (!host || !text) return;
        var el = document.createElement('div');
        el.className = 'zfn-toast';
        el.textContent = text;
        host.appendChild(el);
        requestAnimationFrame(function () { el.classList.add('zfn-toast--in'); });
        setTimeout(function () {
            el.classList.remove('zfn-toast--in');
            el.classList.add('zfn-toast--out');
            setTimeout(function () {
                if (el.parentNode) el.parentNode.removeChild(el);
            }, 400);
        }, 2000);
    }

    function setBadge(n) {
        var b = qs('zfnBellBadge');
        if (!b) return;
        if (n > 0) {
            b.textContent = n > 99 ? '99+' : String(n);
            b.classList.add('zfn-on');
        } else {
            b.classList.remove('zfn-on');
            b.textContent = '';
        }
    }

    function renderList(items, bodyEl) {
        if (!bodyEl) return;
        if (!items || !items.length) {
            bodyEl.innerHTML = '<div class="zfn-bell-empty">No hay alertas recientes.</div>';
            return;
        }
        var html = items.map(function (it) {
            var det = (it.DetalleAccion || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            var asunto = (it.Asunto || '').replace(/</g, '&lt;').replace(/>/g, '&gt;');
            var fechaL = it.fechaTxt || it.FechaTxt || '';
            return '<div class="zfn-bell-item">' +
                '<div class="zfn-bell-item-meta"><strong>' + (it.LoginUsuarioAccion || '') + '</strong><span>' + fechaL + '</span></div>' +
                '<div class="zfn-bell-item-doc">' + (it.CodigoDocumento || '') + '</div>' +
                '<div>' + det + '</div>' +
                '<div style="font-size:11px;color:#888;margin-top:4px;">' + asunto + '</div></div>';
        }).join('');
        bodyEl.innerHTML = html;
    }

    function maxIdFromItems(items) {
        var m = 0;
        if (!items) return m;
        for (var i = 0; i < items.length; i++)
            if (items[i].IdHistorial > m) m = items[i].IdHistorial;
        return m;
    }

    function getLoginKey() {
        // Lee el login del elemento ya renderizado en el topbar (presente en todas las vistas)
        var el = document.querySelector('.user-name');
        var login = el ? (el.textContent || el.innerText || '').trim() : 'default';
        return 'zfn_ack_' + (login || 'default');
    }

    function loadAck() {
        try { return parseInt(localStorage.getItem(getLoginKey()) || '0', 10) || 0; }
        catch (e) { return 0; }
    }

    function saveAck(v) {
        try { localStorage.setItem(getLoginKey(), String(v)); } catch (e) { }
    }

    function boot() {
        var ep = getEndpoint();
        if (!ep || !qs('zfnBellBtn')) return;

        var toastSince = 0;
        var ackBell = loadAck();   // <-- persiste entre sesiones
        var panel = qs('zfnBellPanel');
        var bodyEl = qs('zfnBellPanelBody');
        var btn = qs('zfnBellBtn');

        fetchJson(ep + (ep.indexOf('?') >= 0 ? '&' : '?') + 'mode=init')
            .then(function (data) {
                if (!data || !data.ok) return;
                toastSince = data.cursor || data.Cursor || 0;
                // NO sobreescribir ackBell con el cursor: el usuario puede tener no-leidas
                var items0 = data.items || data.Items;
                if (items0 && bodyEl) renderList(items0, bodyEl);
                // Contar cuantos items hay desde ackBell guardado
                var unread = 0;
                if (items0) {
                    items0.forEach(function (it) {
                        if (it.IdHistorial > ackBell) unread++;
                    });
                }
                setBadge(unread);
            })
            .catch(function () { });

        function poll() {
            fetchJson(ep + (ep.indexOf('?') >= 0 ? '&' : '?') + 'mode=poll&since=' + encodeURIComponent(toastSince) + '&ackBell=' + encodeURIComponent(ackBell))
                .then(function (data) {
                    if (!data || data.unauthorized || !data.ok) return;
                    var unread = (typeof data.unreadBell === 'number') ? data.unreadBell : (typeof data.UnreadBell === 'number' ? data.UnreadBell : 0);
                    setBadge(unread);
                    var news = data.news || data.News || [];
                    if (news.length) {
                        news.forEach(function (n) {
                            showToast(n.ToastText || n.toastText || (n.LoginUsuarioAccion + ' · ' + n.CodigoDocumento));
                        });
                    }
                    var next = (typeof data.nextSince === 'number') ? data.nextSince : data.NextSince;
                    if (typeof next === 'number' && next > toastSince)
                        toastSince = next;
                })
                .catch(function () { });
        }

        setInterval(poll, 5000);
        setTimeout(poll, 1500);

        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            var open = panel.classList.toggle('zfn-open');
            btn.setAttribute('aria-expanded', open ? 'true' : 'false');
            if (open) {
                fetchJson(ep + (ep.indexOf('?') >= 0 ? '&' : '?') + 'mode=list')
                    .then(function (data) {
                        if (!data || !data.ok) return;
                        var listItems = data.items || data.Items;
                        renderList(listItems, bodyEl);
                        var maxC = (typeof data.maxCursor === 'number') ? data.maxCursor : data.MaxCursor;
                        if (typeof maxC === 'number' && maxC > ackBell) {
                            ackBell = maxC;
                            saveAck(ackBell);   // <-- guardar al leer
                        } else {
                            var mx = maxIdFromItems(listItems);
                            if (mx > ackBell) {
                                ackBell = mx;
                                saveAck(ackBell);
                            }
                        }
                        setBadge(0);
                        poll();
                    })
                    .catch(function () { });
            }
        });

        document.addEventListener('click', function () {
            if (panel && panel.classList.contains('zfn-open')) {
                panel.classList.remove('zfn-open');
                if (btn) btn.setAttribute('aria-expanded', 'false');
            }
        });
        if (panel) panel.addEventListener('click', function (e) { e.stopPropagation(); });
    }

    if (document.readyState === 'loading')
        document.addEventListener('DOMContentLoaded', boot);
    else
        boot();
})();
