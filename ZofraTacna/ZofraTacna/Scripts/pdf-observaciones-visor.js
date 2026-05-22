/**
 * Visor PDF con marcadores de observacion (PDF.js).
 * config: { host, pdfUrl, apiUrl, idDocumento, login, modo: 'editar'|'ver', puedeAnotar }
 */
(function (global) {
    'use strict';

    var PDFJS_CDN = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/';

    function cargarScript(src) {
        return new Promise(function (resolve, reject) {
            if (document.querySelector('script[src="' + src + '"]')) {
                resolve();
                return;
            }
            var s = document.createElement('script');
            s.src = src;
            s.onload = function () { resolve(); };
            s.onerror = reject;
            document.head.appendChild(s);
        });
    }

    function asegurarPdfJs() {
        if (global.pdfjsLib) {
            global.pdfjsLib.GlobalWorkerOptions.workerSrc = PDFJS_CDN + 'pdf.worker.min.js';
            return Promise.resolve(global.pdfjsLib);
        }
        return cargarScript(PDFJS_CDN + 'pdf.min.js').then(function () {
            global.pdfjsLib.GlobalWorkerOptions.workerSrc = PDFJS_CDN + 'pdf.worker.min.js';
            return global.pdfjsLib;
        });
    }

    function fetchJson(url, options) {
        return fetch(url, Object.assign({ credentials: 'same-origin' }, options || {}))
            .then(function (r) {

                return r.text().then(function (text) {

                    console.log("=== RESPUESTA DEL SERVIDOR ===");
                    console.log(text);

                    if (!r.ok) {
                        throw new Error(text);
                    }

                    try {
                        return JSON.parse(text);
                    } catch (e) {
                        return {
                            ok: false,
                            raw: text
                        };
                    }
                });

            });
    }

    function PdfObservacionesVisor(config) {
        this.config = config || {};
        this.host = typeof config.host === 'string' ? document.querySelector(config.host) : config.host;
        this.marcadores = [];
        this.modoAnotacion = false;
        this.pdfDoc = null;
        this.pageElements = {};
        this.popover = null;
        this.banner = null;
        this.pendingPlacement = null;
    }

    PdfObservacionesVisor.prototype.init = function () {
        var self = this;
        if (!this.host) return Promise.reject(new Error('no_host'));
        this.host.innerHTML = '<div class="pdf-viewer-loading">Cargando documento…</div>';
        this._crearUiExtra();
        return asegurarPdfJs()
            .then(function () { return self._cargarMarcadores(); })
            .then(function () { return self._renderPdf(); })
            .then(function () {
                self._pintarMarcadores();
                if (self.config.onReady) self.config.onReady(self);
            })
            .catch(function (err) {
                self.host.innerHTML = '<div class="pdf-viewer-error">No se pudo cargar el PDF.</div>';
                if (self.config.onError) self.config.onError(err);
            });
    };

    PdfObservacionesVisor.prototype._crearUiExtra = function () {
        var wrap = this.host.closest('.pdf-simple-host') || this.host.parentElement;
        if (!wrap) return;
        this.banner = document.createElement('div');
        this.banner.className = 'pdf-annot-banner';
        this.banner.innerHTML = '<span>Clic para un marcador, o arrastre para resaltar un &aacute;rea. Esc para salir.</span><button type="button" data-act="salir">Salir del modo</button>';
        var self = this;
        this.banner.querySelector('[data-act="salir"]').addEventListener('click', function () {
            self.desactivarModoAnotacion();
        });
        wrap.style.position = 'relative';
        wrap.insertBefore(this.banner, this.host);

        this.popover = document.createElement('div');
        this.popover.className = 'pdf-marker-popover';
        this.popover.setAttribute('role', 'dialog');
        document.body.appendChild(this.popover);
        document.addEventListener('click', function (e) {
            if (!self.popover.classList.contains('visible')) return;
            if (self.popover.contains(e.target)) return;
            if (e.target.closest && e.target.closest('.pdf-marker-pin, .pdf-marker-highlight')) return;
            self._cerrarPopover();
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                if (self.modoAnotacion) self.desactivarModoAnotacion();
                self._cerrarPopover();
            }
        });
    };

    PdfObservacionesVisor.prototype._cargarMarcadores = function () {
        var self = this;
        var incluir = this.config.modo === 'editar' && this.config.puedeAnotar ? '1' : '0';
        var url = this.config.apiUrl + '?idDoc=' + encodeURIComponent(this.config.idDocumento) +
            '&borrador=' + incluir;
        return fetchJson(url).then(function (data) {
            if (!data.ok) throw new Error(data.error || 'api');
            self.tablaDisponible = data.tablaDisponible !== false;
            self.marcadores = (data.items || []).map(function (m) {
                return {
                    id: m.id,
                    tipo: m.tipo || 'pin',
                    pagina: m.pagina,
                    posX: m.posX,
                    posY: m.posY,
                    ancho: m.ancho,
                    alto: m.alto,
                    textoSeleccionado: m.textoSeleccionado,
                    comentario: m.comentario,
                    login: m.login,
                    esBorrador: !!m.esBorrador,
                    fecha: m.fecha
                };
            });
        });
    };

    PdfObservacionesVisor.prototype._renderPdf = function () {
        var self = this;
        var pdfjsLib = global.pdfjsLib;
        this.host.innerHTML = '<div class="pdf-viewer-scroll"><div class="pdf-viewer-pages"></div></div>';
        this.scrollEl = this.host.querySelector('.pdf-viewer-scroll');
        this.pagesEl = this.host.querySelector('.pdf-viewer-pages');

        return pdfjsLib.getDocument({ url: this.config.pdfUrl, withCredentials: true }).promise
            .then(function (pdf) {
                self.pdfDoc = pdf;
                var chain = Promise.resolve();
                for (var p = 1; p <= pdf.numPages; p++) {
                    (function (pageNum) {
                        chain = chain.then(function () { return self._renderPage(pageNum); });
                    })(p);
                }
                return chain;
            });
    };

    PdfObservacionesVisor.prototype._renderPage = function (pageNum) {
        var self = this;
        return this.pdfDoc.getPage(pageNum).then(function (page) {
            var viewport = page.getViewport({ scale: 1.35 });
            var wrap = document.createElement('div');
            wrap.className = 'pdf-page-wrap';
            wrap.setAttribute('data-page', String(pageNum));
            wrap.style.width = viewport.width + 'px';
            wrap.style.height = viewport.height + 'px';

            var canvas = document.createElement('canvas');
            var ctx = canvas.getContext('2d');
            canvas.width = viewport.width;
            canvas.height = viewport.height;
            wrap.appendChild(canvas);

            var annotLayer = document.createElement('div');
            annotLayer.className = 'pdf-annot-layer';
            annotLayer.setAttribute('data-page', String(pageNum));
            wrap.appendChild(annotLayer);

            self.pagesEl.appendChild(wrap);
            self.pageElements[pageNum] = { wrap: wrap, layer: annotLayer, w: viewport.width, h: viewport.height };

            return page.render({ canvasContext: ctx, viewport: viewport }).promise;
        });
    };

    PdfObservacionesVisor.prototype._pintarMarcadores = function () {
        var self = this;
        Object.keys(this.pageElements).forEach(function (key) {
            var pe = self.pageElements[key];
            var layer = pe.layer;
            layer.querySelectorAll('.pdf-marker-pin, .pdf-marker-highlight').forEach(function (n) { n.remove(); });
        });
        this.marcadores.forEach(function (m) {
            self._crearElementoMarcador(m);
        });
    };

    PdfObservacionesVisor.prototype._crearElementoMarcador = function (m) {
        var pe = this.pageElements[m.pagina];
        if (!pe) return null;
        var layer = pe.layer;
        var el;
        if (m.tipo === 'highlight' && m.ancho != null && m.alto != null) {
            el = document.createElement('div');
            el.className = 'pdf-marker-highlight' + (m.esBorrador ? ' borrador' : '');
            el.style.left = (m.posX * 100) + '%';
            el.style.top = (m.posY * 100) + '%';
            el.style.width = (m.ancho * 100) + '%';
            el.style.height = (m.alto * 100) + '%';
        } else {
            el = document.createElement('button');
            el.type = 'button';
            el.className = 'pdf-marker-pin' + (m.esBorrador ? ' borrador' : '');
            el.style.left = (m.posX * 100) + '%';
            el.style.top = (m.posY * 100) + '%';
            el.setAttribute('aria-label', 'Observación');
        }
        el.setAttribute('data-id', String(m.id));
        var self = this;
        el.addEventListener('click', function (e) {
            e.stopPropagation();
            self._mostrarPopover(m, el);
        });
        layer.appendChild(el);
        return el;
    };

    PdfObservacionesVisor.prototype.activarModoAnotacion = function () {
        if (!this.config.puedeAnotar || this.config.modo !== 'editar') return;
        this.modoAnotacion = true;
        if (this.banner) this.banner.classList.add('visible');
        var self = this;
        Object.keys(this.pageElements).forEach(function (key) {
            var pe = self.pageElements[key];
            var layer = pe.layer;
            var pageNum = parseInt(key, 10);
            layer.classList.add('modo-activo');
            if (layer._bound) return;
            layer._bound = true;
            var drag = { active: false, x0: 0, y0: 0, box: null };

            layer.addEventListener('mousedown', function (e) {
                if (!self.modoAnotacion) return;
                if (e.target.closest('.pdf-marker-pin, .pdf-marker-highlight')) return;
                var rect = layer.getBoundingClientRect();
                drag.active = true;
                drag.x0 = e.clientX - rect.left;
                drag.y0 = e.clientY - rect.top;
                drag.box = document.createElement('div');
                drag.box.className = 'pdf-marker-highlight borrador';
                drag.box.style.pointerEvents = 'none';
                layer.appendChild(drag.box);
                self._actualizarCajaArrastre(drag, layer, e.clientX, e.clientY);
            });

            layer.addEventListener('mousemove', function (e) {
                if (!drag.active || !drag.box) return;
                self._actualizarCajaArrastre(drag, layer, e.clientX, e.clientY);
            });

            function finalizar(e) {
                if (!drag.active) return;
                drag.active = false;
                var rect = layer.getBoundingClientRect();
                var x1 = e.clientX - rect.left;
                var y1 = e.clientY - rect.top;
                var dx = Math.abs(x1 - drag.x0);
                var dy = Math.abs(y1 - drag.y0);
                if (drag.box && drag.box.parentNode) drag.box.parentNode.removeChild(drag.box);
                drag.box = null;
                if (dx > 8 || dy > 8) {
                    var left = Math.min(drag.x0, x1) / rect.width;
                    var top = Math.min(drag.y0, y1) / rect.height;
                    var w = dx / rect.width;
                    var h = dy / rect.height;
                    self._solicitarComentario({
                        tipo: 'highlight',
                        pagina: pageNum,
                        posX: Math.max(0, Math.min(1, left)),
                        posY: Math.max(0, Math.min(1, top)),
                        ancho: Math.max(0.01, Math.min(1, w)),
                        alto: Math.max(0.01, Math.min(1, h)),
                        textoSeleccionado: ''
                    });
                } else {
                    var x = drag.x0 / rect.width;
                    var y = drag.y0 / rect.height;
                    self._solicitarComentario({
                        tipo: 'pin',
                        pagina: pageNum,
                        posX: Math.max(0, Math.min(1, x)),
                        posY: Math.max(0, Math.min(1, y)),
                        ancho: null,
                        alto: null,
                        textoSeleccionado: ''
                    });
                }
            }

            layer.addEventListener('mouseup', finalizar);
            layer.addEventListener('mouseleave', function (e) {
                if (drag.active) finalizar(e);
            });
        });
        if (this.config.onModoAnotacion) this.config.onModoAnotacion(true);
    };

    PdfObservacionesVisor.prototype._actualizarCajaArrastre = function (drag, layer, clientX, clientY) {
        if (!drag.box) return;
        var rect = layer.getBoundingClientRect();
        var x1 = clientX - rect.left;
        var y1 = clientY - rect.top;
        var left = Math.min(drag.x0, x1);
        var top = Math.min(drag.y0, y1);
        var w = Math.abs(x1 - drag.x0);
        var h = Math.abs(y1 - drag.y0);
        drag.box.style.left = (left / rect.width * 100) + '%';
        drag.box.style.top = (top / rect.height * 100) + '%';
        drag.box.style.width = (w / rect.width * 100) + '%';
        drag.box.style.height = (h / rect.height * 100) + '%';
    };

    PdfObservacionesVisor.prototype.desactivarModoAnotacion = function () {
        this.modoAnotacion = false;
        if (this.banner) this.banner.classList.remove('visible');
        Object.keys(this.pageElements).forEach(function (key) {
            var layer = this.pageElements[key].layer;
            layer.classList.remove('modo-activo');
        }.bind(this));
        if (this.config.onModoAnotacion) this.config.onModoAnotacion(false);
    };

    PdfObservacionesVisor.prototype._solicitarComentario = function (placement) {
        this.pendingPlacement = placement;
        if (this.config.onNuevoMarcador) {
            this.config.onNuevoMarcador(placement);
        }
    };

    PdfObservacionesVisor.prototype.guardarMarcadorConComentario = function (comentario) {
        var p = this.pendingPlacement;
        if (!p || !comentario || !comentario.trim()) return Promise.reject(new Error('empty'));
        var self = this;
        var body = {
            idDocumento: this.config.idDocumento,
            tipo: p.tipo,
            pagina: p.pagina,
            posX: p.posX,
            posY: p.posY,
            ancho: p.ancho,
            alto: p.alto,
            textoSeleccionado: p.textoSeleccionado || '',
            comentario: comentario.trim()
        };
        return fetchJson(this.config.apiUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(body)
        }).then(function (data) {
            if (!data.ok) throw new Error(data.error || 'save');
            body.id = data.idMarcador;
            body.login = self.config.login;
            body.esBorrador = true;
            body.comentario = comentario.trim();
            self.marcadores.push(body);
            self._crearElementoMarcador(body);
            self.pendingPlacement = null;
            if (self.config.onMarcadorGuardado) self.config.onMarcadorGuardado(self.contarBorradores());
            return data;
        });
    };

    PdfObservacionesVisor.prototype.contarBorradores = function () {
        return this.marcadores.filter(function (m) { return m.esBorrador; }).length;
    };

    PdfObservacionesVisor.prototype.contarPublicados = function () {
        return this.marcadores.filter(function (m) { return !m.esBorrador; }).length;
    };

    PdfObservacionesVisor.prototype._mostrarPopover = function (m, anchor) {
        var self = this;
        var fechaTxt = m.fecha ? new Date(m.fecha).toLocaleString('es-PE') : '';
        var html = '<div class="pop-meta">' + escapeHtml(m.login || '') +
            (fechaTxt ? ' — ' + escapeHtml(fechaTxt) : '') +
            ' · Pág. ' + m.pagina + '</div>' +
            '<div class="pop-text">' + escapeHtml(m.comentario || '') + '</div>';
        if (m.textoSeleccionado) {
            html += '<div class="pop-meta" style="margin-top:8px">Texto señalado:</div><div class="pop-text" style="font-style:italic">' +
                escapeHtml(m.textoSeleccionado) + '</div>';
        }
        var puedeBorrar = this.config.modo === 'editar' && this.config.puedeAnotar &&
            m.esBorrador && m.login === this.config.login;
        if (puedeBorrar) {
            html += '<div class="pop-actions"><button type="button" class="pop-btn-del" data-del="1">Eliminar</button>' +
                '<button type="button" class="pop-btn-close" data-close="1">Cerrar</button></div>';
        } else {
            html += '<div class="pop-actions"><button type="button" class="pop-btn-close" data-close="1">Cerrar</button></div>';
        }
        this.popover.innerHTML = html;
        var rect = anchor.getBoundingClientRect();
        this.popover.style.left = Math.min(rect.left, global.innerWidth - 360) + 'px';
        this.popover.style.top = (rect.bottom + 8) + 'px';
        this.popover.classList.add('visible');
        this.popover.querySelector('[data-close="1"]').addEventListener('click', function () {
            self._cerrarPopover();
        });
        var delBtn = this.popover.querySelector('[data-del="1"]');
        if (delBtn) {
            delBtn.addEventListener('click', function () {
                self._eliminarMarcador(m.id);
            });
        }
    };

    PdfObservacionesVisor.prototype._cerrarPopover = function () {
        if (this.popover) this.popover.classList.remove('visible');
    };

    PdfObservacionesVisor.prototype._eliminarMarcador = function (id) {
        var self = this;
        var url = this.config.apiUrl + '?idMarcador=' + encodeURIComponent(id) +
            '&idDoc=' + encodeURIComponent(this.config.idDocumento);
        fetch(url, { method: 'DELETE', credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (!data.ok) {
                    alert(data.error || 'No se pudo eliminar.');
                    return;
                }
                self.marcadores = self.marcadores.filter(function (m) { return m.id !== id; });
                self._pintarMarcadores();
                self._cerrarPopover();
                if (self.config.onMarcadorGuardado) self.config.onMarcadorGuardado(self.contarBorradores());
            });
    };

    PdfObservacionesVisor.prototype.refrescar = function () {
        var self = this;
        return this._cargarMarcadores().then(function () {
            self._pintarMarcadores();
        });
    };

    function escapeHtml(s) {
        if (!s) return '';
        return String(s)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
    }

    global.PdfObservacionesVisor = {
        create: function (config) {
            var v = new PdfObservacionesVisor(config);
            return v;
        }
    };
})(window);
