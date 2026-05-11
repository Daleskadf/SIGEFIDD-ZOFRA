/* Asignación revisores/firmantes — misma lógica que CargarDocumento; ids en window.GP_IDS */
(function () {
    'use strict';

    var revisores = [];
    var firmantes = [];

    function ids() {
        return window.GP_IDS || {};
    }

    function getTxt() {
        return document.getElementById(ids().txt);
    }
    function getLst() {
        return document.getElementById(ids().lst);
    }
    function getHf() {
        return document.getElementById(ids().hf);
    }
    function getDd() {
        return document.getElementById(ids().dd || 'dropdownResultadosGp');
    }

    function storageRevKey() {
        return 'gp_revisores_temp';
    }
    function storageFirKey() {
        return 'gp_firmantes_temp';
    }

    function reconstruirListasDesdeCampoOculto() {
        var hf = getHf();
        if (!hf || !hf.value || !hf.value.trim() || hf.value.trim() === '[]') return false;
        try {
            var arr = JSON.parse(hf.value);
            if (!Array.isArray(arr) || arr.length === 0) return false;
            revisores = [];
            firmantes = [];
            var seenRev = {};
            arr.forEach(function (p) {
                if (!p || !p.login) return;
                var login = p.login;
                var nombre = p.nombre || login;
                if (p.tipo === 'REV' && (!p.orden || p.orden === 0)) {
                    if (!seenRev[login]) {
                        seenRev[login] = true;
                        revisores.push({ login: login, nombre: nombre });
                    }
                }
            });
            var firmRows = arr.filter(function (p) {
                return p && (p.orden > 0 || p.tipo === 'FIR');
            });
            firmRows.sort(function (a, b) { return (a.orden || 0) - (b.orden || 0); });
            firmRows.forEach(function (p) {
                if (!firmantes.some(function (f) { return f.login === p.login; })) {
                    firmantes.push({ login: p.login, nombre: p.nombre || p.login, orden: p.orden || firmantes.length + 1 });
                }
            });
            firmantes.forEach(function (f) {
                if (!revisores.some(function (r) { return r.login === f.login; })) {
                    revisores.push({ login: f.login, nombre: f.nombre });
                }
            });
            firmantes.forEach(function (f, idx) { f.orden = idx + 1; });
            return true;
        } catch (e) {
            return false;
        }
    }

    (function bootFromServerOrStorage() {
        try {
            if (window.__gpParticipantesBoot) {
                var b = window.__gpParticipantesBoot;
                revisores = Array.isArray(b.revisores) ? b.revisores.slice() : [];
                firmantes = Array.isArray(b.firmantes) ? b.firmantes.slice() : [];
                window.__gpParticipantesBoot = null;
                return;
            }
            if (reconstruirListasDesdeCampoOculto()) return;
            var revGuardados = sessionStorage.getItem(storageRevKey());
            var firGuardados = sessionStorage.getItem(storageFirKey());
            if (revGuardados) revisores = JSON.parse(revGuardados);
            if (firGuardados) firmantes = JSON.parse(firGuardados);
        } catch (e) {
            console.error('gp participantes boot:', e);
        }
    })();

    function filtrarEmpleadosLocal(termino) {
        var lstBuscador = getLst();
        var dropdown = getDd();
        if (!lstBuscador || !dropdown) return;

        var resultados = [];
        var items = lstBuscador.options;
        var t = termino.toLowerCase().trim();
        for (var i = 0; i < items.length; i++) {
            var texto = items[i].text.toLowerCase();
            var valor = items[i].value;
            if (texto.indexOf(t) !== -1) {
                resultados.push({ login: valor, texto: items[i].text });
            }
        }

        if (resultados.length === 0) {
            dropdown.innerHTML = '<div style="padding:16px;text-align:center;color:#999;">No se encontraron resultados</div>';
            dropdown.style.display = 'block';
            return;
        }

        var html = '';
        resultados.slice(0, 10).forEach(function (res) {
            html += '<div class="empleado-resultado-item" data-login="' + String(res.login).replace(/"/g, '&quot;') + '" style="padding:12px 16px;border-bottom:1px solid #f0f0f0;cursor:pointer;display:flex;justify-content:space-between;align-items:center;transition:all 0.2s;">' +
                '<div>' +
                '<div style="font-weight:600;color:#1a2a4a;font-size:13px;">' + res.texto.split('|')[0] + '</div>' +
                '<div style="font-size:11px;color:#999;">' + (res.texto.split('|')[1] || res.login) + '</div>' +
                '</div>' +
                '</div>';
        });
        dropdown.innerHTML = html;
        dropdown.style.display = 'block';

        var itemsDom = dropdown.querySelectorAll('.empleado-resultado-item');
        for (var j = 0; j < itemsDom.length; j++) {
            (function (item) {
                item.addEventListener('click', function () {
                    var login = item.getAttribute('data-login');
                    var texto = item.textContent.trim();
                    seleccionarEmpleadoDelDropdown(login, texto);
                });
                item.addEventListener('mouseenter', function () {
                    item.style.background = '#f5f5f5';
                });
                item.addEventListener('mouseleave', function () {
                    item.style.background = 'white';
                });
            })(itemsDom[j]);
        }
    }

    function seleccionarEmpleadoDelDropdown(login, texto) {
        var txtBuscador = getTxt();
        var dropdown = getDd();
        if (txtBuscador) txtBuscador.value = '';
        if (dropdown) dropdown.style.display = 'none';
        agregarParticipanteAuto(login, texto);
        if (txtBuscador) txtBuscador.focus();
    }

    function agregarParticipanteAuto(login, nombre) {
        if (revisores.some(function (r) { return r.login === login; }) ||
            firmantes.some(function (f) { return f.login === login; })) {
            alert('✓ ' + nombre + ' ya ha sido asignado');
            return;
        }
        revisores.push({ login: login, nombre: nombre });
        firmantes.push({ login: login, nombre: nombre, orden: firmantes.length + 1 });
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    }

    function guardarParticipantes() {
        var participantes = [];
        var participantesSet = {};
        function hasSet(l) { return participantesSet.hasOwnProperty(l); }
        function addSet(l) { participantesSet[l] = true; }

        revisores.forEach(function (r) {
            if (hasSet(r.login)) return;
            participantes.push({ login: r.login, nombre: r.nombre, tipo: 'REV', orden: 0 });
            addSet(r.login);
        });

        firmantes.forEach(function (f, idx) {
            if (hasSet(f.login)) {
                for (var i = 0; i < participantes.length; i++) {
                    if (participantes[i].login === f.login) {
                        participantes[i].tipo = 'FIR';
                        participantes[i].orden = idx + 1;
                        break;
                    }
                }
            } else {
                participantes.push({ login: f.login, nombre: f.nombre, tipo: 'FIR', orden: idx + 1 });
                addSet(f.login);
            }
        });

        var hf = getHf();
        if (hf) hf.value = JSON.stringify(participantes);
    }

    function guardarParticipantesEnSessionStorage() {
        try {
            sessionStorage.setItem(storageRevKey(), JSON.stringify(revisores));
            sessionStorage.setItem(storageFirKey(), JSON.stringify(firmantes));
        } catch (e) {
            console.error('sessionStorage gp:', e);
        }
    }

    function reorderFirmantes(fromIndex, toIndex) {
        if (fromIndex === toIndex) return;
        if (fromIndex < 0 || toIndex < 0 || fromIndex >= firmantes.length || toIndex >= firmantes.length) return;
        var item = firmantes.splice(fromIndex, 1)[0];
        firmantes.splice(toIndex, 0, item);
        firmantes.forEach(function (x, idx) { x.orden = idx + 1; });
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    }

    function enlazarArrastreFirmantes() {
        var cards = document.querySelectorAll('#listaFirmantes .firmante-card');
        cards.forEach(function (card) {
            var handle = card.querySelector('.firmante-handle');
            if (!handle) return;

            handle.addEventListener('dragstart', function (e) {
                var idx = parseInt(card.getAttribute('data-index'), 10);
                e.dataTransfer.setData('text/plain', String(idx));
                e.dataTransfer.effectAllowed = 'move';
                card.classList.add('firmante-dragging');
            });
            handle.addEventListener('dragend', function () {
                card.classList.remove('firmante-dragging');
                document.querySelectorAll('#listaFirmantes .firmante-card').forEach(function (c) {
                    c.classList.remove('firmante-drag-over');
                });
            });

            card.addEventListener('dragover', function (e) {
                e.preventDefault();
                e.dataTransfer.dropEffect = 'move';
                card.classList.add('firmante-drag-over');
            });
            card.addEventListener('dragleave', function (e) {
                if (!card.contains(e.relatedTarget)) card.classList.remove('firmante-drag-over');
            });
            card.addEventListener('drop', function (e) {
                e.preventDefault();
                card.classList.remove('firmante-drag-over');
                var from = parseInt(e.dataTransfer.getData('text/plain'), 10);
                var to = parseInt(card.getAttribute('data-index'), 10);
                if (!isNaN(from) && !isNaN(to)) reorderFirmantes(from, to);
            });
        });
    }

    function renderizarParticipantes() {
        var listaRevisoresDiv = document.getElementById('listaRevisores');
        if (!listaRevisoresDiv) return;

        if (revisores.length === 0) {
            listaRevisoresDiv.innerHTML = '<div style="color:#6b8f76;text-align:center;padding:28px 16px;font-size:13px;">Sin revisores asignados<br><span style="font-size:12px;opacity:.9">Usa el buscador para añadir participantes</span></div>';
        } else {
            var html = '';
            for (var i = 0; i < revisores.length; i++) {
                var r = revisores[i];
                var escLogin = String(r.login).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
                html += '<div class="revisor-card" data-login="' + String(r.login).replace(/"/g, '&quot;') + '" role="listitem">';
                html += '<div class="revisor-badge" title="Revisor">R</div>';
                html += '<div class="revisor-nombre" title="' + String(r.nombre).replace(/"/g, '&quot;') + '">' + r.nombre + '</div>';
                html += '<button type="button" class="revisor-btn-quitar" title="Quitar revisor (también quita de firmantes)" onclick="window.gpRemoverRevisor(\'' + escLogin + '\'); return false;">×</button>';
                html += '</div>';
            }
            listaRevisoresDiv.innerHTML = html;
        }

        var listaFirmantesDiv = document.getElementById('listaFirmantes');
        if (!listaFirmantesDiv) return;

        if (firmantes.length === 0) {
            listaFirmantesDiv.innerHTML = '<div style="color:#8898b8;text-align:center;padding:28px 16px;font-size:13px;">Sin firmantes asignados<br><span style="font-size:12px;opacity:.9">Usa el buscador para añadir participantes</span></div>';
        } else {
            var htmlF = '';
            for (var j = 0; j < firmantes.length; j++) {
                var f = firmantes[j];
                var escLoginF = String(f.login).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
                htmlF += '<div class="firmante-card" data-index="' + j + '" data-login="' + String(f.login).replace(/"/g, '&quot;') + '" role="listitem">';
                htmlF += '<div class="firmante-handle" draggable="true" title="Arrastrar para reordenar">⋮⋮</div>';
                htmlF += '<div class="firmante-orden" title="Orden de firma">' + (j + 1) + '</div>';
                htmlF += '<div class="firmante-nombre" title="' + String(f.nombre).replace(/"/g, '&quot;') + '">' + f.nombre + '</div>';
                htmlF += '<div class="firmante-actions">';
                htmlF += '<button type="button" class="firmante-btn-flecha" title="Subir"' + (j === 0 ? ' disabled' : '') + ' onclick="window.gpMoverFirmanteArriba(' + j + '); return false;">▲</button>';
                htmlF += '<button type="button" class="firmante-btn-flecha" title="Bajar"' + (j === firmantes.length - 1 ? ' disabled' : '') + ' onclick="window.gpMoverFirmanteAbajo(' + j + '); return false;">▼</button>';
                htmlF += '</div>';
                htmlF += '<button type="button" class="firmante-btn-quitar" title="Quitar" onclick="window.gpRemoverFirmante(\'' + escLoginF + '\'); return false;">×</button>';
                htmlF += '</div>';
            }
            listaFirmantesDiv.innerHTML = htmlF;
            enlazarArrastreFirmantes();
        }
        guardarParticipantes();
    }

    window.gpRemoverRevisor = function (login) {
        revisores = revisores.filter(function (r) { return r.login !== login; });
        firmantes = firmantes.filter(function (f) { return f.login !== login; });
        firmantes.forEach(function (f, idx) { f.orden = idx + 1; });
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    };

    window.gpRemoverFirmante = function (login) {
        firmantes = firmantes.filter(function (f) { return f.login !== login; });
        revisores = revisores.filter(function (r) { return r.login !== login; });
        firmantes.forEach(function (f, idx) { f.orden = idx + 1; });
        renderizarParticipantes();
        guardarParticipantesEnSessionStorage();
    };

    window.gpMoverFirmanteArriba = function (index) {
        if (index <= 0) return;
        reorderFirmantes(index, index - 1);
    };

    window.gpMoverFirmanteAbajo = function (index) {
        if (index >= firmantes.length - 1) return;
        reorderFirmantes(index, index + 1);
    };

    window.gpValidarAntesGuardar = function () {
        guardarParticipantes();
        var hf = getHf();
        if (!hf || !hf.value || hf.value.trim() === '' || hf.value.trim() === '[]') {
            alert('Debe asignar al menos un revisor o firmante.');
            return false;
        }
        return true;
    };

    document.addEventListener('DOMContentLoaded', function () {
        var txtBuscador = getTxt();
        var dropdown = getDd();
        if (txtBuscador && dropdown) {
            txtBuscador.addEventListener('keyup', function (e) {
                var valor = txtBuscador.value.toLowerCase().trim();
                if (e.key === 'Escape') {
                    dropdown.style.display = 'none';
                    return;
                }
                if (valor.length === 0) {
                    dropdown.style.display = 'none';
                    return;
                }
                filtrarEmpleadosLocal(valor);
            });
            document.addEventListener('click', function (e) {
                if (e.target !== txtBuscador && !dropdown.contains(e.target)) {
                    dropdown.style.display = 'none';
                }
            });
        }
        renderizarParticipantes();
    });
})();
