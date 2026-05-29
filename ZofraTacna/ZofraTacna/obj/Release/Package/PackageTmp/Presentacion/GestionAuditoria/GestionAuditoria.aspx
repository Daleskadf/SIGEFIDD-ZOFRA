<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GestionAuditoria.aspx.cs" Inherits="ZofraTacna.Presentacion.GestionAuditoria" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" /><meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>SIGEFIDD-ZOFRA | Auditoría del Sistema</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/sigefidd-notificaciones.css") %>" />
    <script defer src="<%= ResolveUrl("~/Scripts/sigefidd-notificaciones.js") %>"></script>
    <style>
        /* CORE RESET & TYPOGRAPHY */
        *{margin:0;padding:0;box-sizing:border-box;font-family:'Outfit','Segoe UI',sans-serif}
        html,body{width:100%;height:100%;overflow:hidden;background-color:#f0f2f5;color:#334155}
        body{display:flex;height:100vh}

        /* SIDEBAR (Exact Match to standard layout) */
        .sidebar{width:230px;min-width:230px;background:#1a2a4a;display:flex;flex-direction:column;height:100vh;box-shadow:2px 0 10px rgba(0,0,0,.08);transition:all 0.3s ease}
        .sidebar-logo{padding:20px 18px 16px;border-bottom:1px solid rgba(255,255,255,.08);display:flex;align-items:center;gap:10px}
        .logo-icon{width:36px;height:36px;background:linear-gradient(135deg,#2a3f6f,#8b1a1a);border-radius:8px;display:flex;align-items:center;justify-content:center}
        .logo-icon svg{width:20px;height:20px;fill:white}
        .logo-text .top{color:white;font-size:13px;font-weight:700;letter-spacing:1px}
        .logo-text .top span{color:#c0392b}
        .logo-text .bot{color:rgba(255,255,255,.4);font-size:9px;letter-spacing:1px;font-weight:500;margin-top:2px}
        .sidebar-nav{padding:16px 10px;flex:1;overflow-y:auto;display:flex;flex-direction:column}
        .nav-item{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:8px;color:rgba(255,255,255,.6);font-size:13px;margin-bottom:2px;text-decoration:none;transition:all 0.2s ease}
        .nav-item:hover{background:rgba(255,255,255,.07);color:white}
        .nav-item.active{background:linear-gradient(90deg,#2a3f6f,#8b1a1a);color:white;font-weight:600}
        .nav-item svg{width:17px;height:17px;fill:currentColor;flex-shrink:0}
        .nav-badge{margin-left:auto;background:#c0392b;color:white;border-radius:10px;font-size:10px;padding:1px 6px;font-weight:600}
        
        .nav-item-logout{display:flex;align-items:center;justify-content:center;gap:10px;padding:10px 12px;border-radius:8px;color:white;font-size:13px;cursor:pointer;margin-top:auto;text-decoration:none;background:linear-gradient(135deg,#8b1a1a,#c0392b);border:1.5px solid #7d1717;margin-bottom:10px;box-shadow:0 6px 16px rgba(139,26,26,.25);font-weight:700;transition:all 0.3s ease}
        .nav-item-logout:hover{background:linear-gradient(135deg,#a32121,#d44736);transform:translateY(-1px)}

        /* MAIN & TOPBAR */
        .main{flex:1;display:flex;flex-direction:column;overflow:hidden;background-color:#f0f2f5}
        .topbar{background:#ffffff;padding:0 28px;height:56px;display:flex;align-items:center;justify-content:space-between;border-bottom:1px solid #e8eaf0;flex-shrink:0;box-shadow:0 1px 4px rgba(0,0,0,0.02)}
        .breadcrumb{font-size:13px;color:#999;font-weight:500}
        .breadcrumb strong{color:#1a2a4a;font-weight:700}
        .topbar-right{display:flex;align-items:center;gap:14px}
        .user-avatar{width:34px;height:34px;background:linear-gradient(135deg,#1a2a4a,#8b1a1a);border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:12px;font-weight:700;box-shadow:0 2px 6px rgba(26,42,74,.2)}
        .user-info{display:flex;align-items:center;gap:8px}
        .user-name{font-size:14px;font-weight:600;color:#333}
        .role-badge{background:#eef0f8;color:#1a2a4a;border-radius:12px;padding:2px 10px;font-size:11px;font-weight:600}

        /* LAYOUT CONTENT */
        .content{flex:1;padding:28px;overflow-y:auto}
        .page-header{margin-bottom:24px;display:flex;align-items:center;justify-content:space-between}
        .page-header h1{font-size:24px;color:#1a2a4a;font-weight:700;letter-spacing:-0.5px}
        .page-header .sub{font-size:13px;color:#888;margin-top:2px;font-weight:500}

        /* PREMIUM SEGMENTED CONTROL (TABS IN LIGHT THEME) */
        .tabs{display:inline-flex;padding:4px;background:#eef0f6;border-radius:10px;gap:2px;margin-bottom:24px;border:1px solid rgba(0,0,0,.04)}
        .tab-btn{padding:8px 20px;background:transparent;border:none;font-size:13px;font-weight:600;color:#64748b;cursor:pointer;border-radius:8px;transition:all 0.25s cubic-bezier(0.4, 0, 0.2, 1);text-decoration:none;display:flex;align-items:center;gap:6px}
        .tab-btn:hover{color:#1a2a4a}
        .tab-btn.active{color:#1a2a4a;background:#ffffff;box-shadow:0 2px 6px rgba(0,0,0,.08);border:1px solid rgba(0,0,0,.02)}
        .tab-btn svg{width:16px;height:16px;fill:currentColor}

        /* PREMIUM LIGHT FILTER CARD / FILTER BAR */
        .filter-card{background:#ffffff;border-radius:12px;padding:20px;border:1px solid #eef0f8;box-shadow:0 1px 4px rgba(0,0,0,.04);margin-bottom:24px}
        .filter-bar{display:flex;gap:16px;align-items:flex-end;flex-wrap:wrap}
        .filter-bar .filter-group:nth-child(1) {flex: 2}
        .filter-group{display:flex;flex-direction:column;gap:6px;flex:1;min-width:180px}
        .filter-group label{font-size:11px;font-weight:700;color:#64748b;letter-spacing:0.5px;text-transform:uppercase}
        .filter-input-wrap{position:relative;display:flex;align-items:center}
        .filter-input-wrap svg{position:absolute;left:12px;width:16px;height:16px;fill:#94a3b8}
        .filter-input{width:100%;padding:9px 12px;padding-left:36px;border:1.5px solid #dde1f0;border-radius:8px;font-size:13px;color:#334155;outline:none;background:#ffffff;transition:all 0.25s ease;font-weight:500}
        .filter-input:focus{border-color:#3b82f6;box-shadow:0 0 0 3px rgba(59,130,246,.15);background:#ffffff}
        .filter-input[type="date"]{padding-left:12px}
        
        .btn-action{padding:0 20px;background:linear-gradient(90deg,#1a2a4a,#2a4a8a);color:white;border:none;border-radius:8px;font-size:13px;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;gap:6px;height:38px;transition:all 0.25s ease;box-shadow:0 4px 12px rgba(26,42,74,.15)}
        .btn-action:hover{transform:translateY(-1px);box-shadow:0 6px 16px rgba(26,42,74,.25)}
        .btn-clear{padding:0 16px;border:1.5px solid #dde1f0;border-radius:8px;background:#ffffff;color:#475569;font-size:13px;cursor:pointer;height:38px;font-weight:600;text-decoration:none;display:inline-flex;align-items:center;justify-content:center;transition:all 0.25s ease}
        .btn-clear:hover{background:#f8fafc;color:#1a2a4a}
        
        .btn-back{padding:8px 16px;background:#ffffff;border:1.5px solid #dde1f0;color:#475569;border-radius:8px;font-size:12.5px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:6px;margin-bottom:20px;transition:all 0.25s ease;box-shadow:0 1px 3px rgba(0,0,0,0.02)}
        .btn-back:hover{transform:translateX(-3px);background:#f8fafc;color:#1a2a4a}

        /* PREMIUM TABLES IN LIGHT THEME */
        .tbl-card{background:#ffffff;border-radius:14px;border:1px solid #eef0f8;box-shadow:0 10px 30px rgba(0,0,0,.02), 0 1px 3px rgba(0,0,0,.01);overflow:hidden;margin-bottom:24px;transition:box-shadow 0.3s ease}
        .tbl-card:hover{box-shadow:0 14px 40px rgba(0,0,0,.03), 0 2px 6px rgba(0,0,0,.02)}
        .table-responsive{width:100%;overflow-x:auto}
        
        .table-premium {
            width: 100%;
            border-collapse: collapse;
        }
        .table-premium tr:first-child {
            background: #f8fafc;
            border-bottom: 2px solid #eef0f6;
        }
        .table-premium th {
            padding: 12px 14px;
            font-size: 10px;
            font-weight: 700;
            color: #475569;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            text-align: left;
        }
        .table-premium tr:not(:first-child) {
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.2s ease;
            background-color: #ffffff;
        }
        .table-premium tr:not(:first-child):last-child {
            border-bottom: none;
        }
        .table-premium tr:not(:first-child):hover {
            background: #f8fafc;
            box-shadow: inset 4px 0 0 0 #2563eb;
        }
        .table-premium td {
            padding: 12px 14px;
            font-size: 12.5px;
            color: #334155;
            vertical-align: middle;
        }

        .tab-panel-fade{animation:fadeIn 0.3s ease}
        @keyframes fadeIn{from{opacity:0;transform:translateY(4px)}to{opacity:1;transform:translateY(0)}}

        /* BADGES (Premium Soft Glows with Live Indicator Dot) */
        .badge{border-radius:8px;padding:3px 10px;font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:6px;text-transform:uppercase;letter-spacing:0.3px}
        .badge::before {
            content:'';
            display:inline-block;
            width:6px;
            height:6px;
            border-radius:50%;
            background-color:currentColor;
            flex-shrink:0;
        }
        .badge-info{background:rgba(59,130,246,0.08);color:#1d4ed8;border:1px solid rgba(59,130,246,0.18)}
        .badge-success{background:rgba(16,185,129,0.08);color:#047857;border:1px solid rgba(16,185,129,0.18)}
        .badge-danger{background:rgba(239,68,68,0.08);color:#b91c1c;border:1px solid rgba(239,68,68,0.18)}
        .badge-warning{background:rgba(245,158,11,0.08);color:#b45309;border:1px solid rgba(245,158,11,0.18)}
        .badge-sec{background:rgba(100,116,139,0.08);color:#475569;border:1px solid rgba(100,116,139,0.18)}
        .badge-purple{background:rgba(139,92,246,0.08);color:#6d28d9;border:1px solid rgba(139,92,246,0.18)}
        .badge-teal{background:rgba(20,184,166,0.08);color:#0f766e;border:1px solid rgba(20,184,166,0.18)}
        .badge-indigo{background:rgba(99,102,241,0.08);color:#4338ca;border:1px solid rgba(99,102,241,0.18)}

        /* HIGH-FIDELITY COLUMN DECORATORS */
        .code-pill {
            font-family:'JetBrains Mono',monospace;
            font-size:12px;
            font-weight:600;
            color:#1e40af;
            background:#eff6ff;
            border:1px solid #dbeafe;
            padding:4px 10px;
            border-radius:6px;
            display:inline-flex;
            align-items:center;
            gap:6px;
            transition:all 0.2s ease;
            text-decoration:none;
        }
        .code-pill:hover {
            background:#dbeafe;
            border-color:#bfdbfe;
            transform:translateY(-0.5px);
        }
        .code-pill svg {
            width:13px;
            height:13px;
            fill:currentColor;
            flex-shrink:0;
        }
        .user-profile-chip {
            display:inline-flex;
            align-items:center;
            gap:8px;
        }
        .user-profile-avatar {
            width:26px;
            height:26px;
            border-radius:50%;
            background:linear-gradient(135deg,#1a2a4a,#2563eb);
            color:#ffffff;
            font-size:10px;
            font-weight:700;
            display:flex;
            align-items:center;
            justify-content:center;
            letter-spacing:0.5px;
            box-shadow:0 2px 4px rgba(37,99,235,0.1);
        }
        .user-profile-name {
            font-size:13px;
            font-weight:600;
            color:#1e293b;
        }
        .doc-subject-title {
            font-size:13.5px;
            font-weight:600;
            color:#1e293b;
            line-height:1.4;
        }
        .date-time-container {
            display:flex;
            flex-direction:column;
            gap:2px;
        }
        .date-part {
            font-family:'JetBrains Mono',monospace;
            font-size:12.5px;
            font-weight:600;
            color:#334155;
        }
        .time-part {
            font-family:'JetBrains Mono',monospace;
            font-size:11px;
            color:#64748b;
        }
        .btn-table-action {
            display:inline-flex;
            align-items:center;
            gap:6px;
            padding:7px 14px;
            background:#f1f5f9;
            border:1px solid #e2e8f0;
            border-radius:8px;
            color:#475569;
            font-size:12px;
            font-weight:600;
            text-decoration:none;
            cursor:pointer;
            transition:all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .btn-table-action:hover {
            background:#2563eb;
            border-color:#2563eb;
            color:#ffffff;
            box-shadow:0 4px 12px rgba(37,99,235,0.2);
            transform:translateY(-1px);
        }
        .btn-table-action svg {
            width:14px;
            height:14px;
            fill:currentColor;
        }

        /* HIGH-FIDELITY DOCUMENT DETAIL UX */
        .doc-detail-grid{display:grid;grid-template-columns:1.05fr 1.95fr;gap:24px;align-items:stretch}
        @media (max-width: 1024px) {
            .doc-detail-grid{grid-template-columns:1fr;align-items:start}
            .timeline-section{height:auto}
            .timeline-wrapper{max-height:450px}
        }

        /* 3D Dashboard Header Card */
        .dash-header-card{background:#ffffff;border-radius:12px;padding:24px;border:1px solid #eef0f8;box-shadow:0 1px 4px rgba(0,0,0,.04);margin-bottom:24px;position:relative;overflow:hidden}
        .dash-header-card::after{content:'';position:absolute;top:0;right:0;width:200px;height:100%;background:radial-gradient(circle,rgba(59,130,246,.03) 0,transparent 70%);pointer-events:none}
        .dash-header-top{display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:16px;flex-wrap:wrap;gap:12px}
        .dash-header-title{font-size:20px;font-weight:700;color:#1a2a4a;letter-spacing:-0.3px}
        .dash-header-code{font-family:'JetBrains Mono',monospace;font-size:12.5px;color:#1d4ed8;background:rgba(59,130,246,.06);padding:3px 8px;border-radius:6px;font-weight:600;border:1px solid rgba(59,130,246,.12);display:inline-block;margin-top:6px}
        
        .grid-dashboard-info{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:16px;margin-top:18px;border-top:1px solid #f1f5f9;padding-top:18px}
        .dash-info-block{display:flex;align-items:center;gap:12px}
        .dash-info-icon{width:38px;height:38px;border-radius:8px;background:#f8fafc;display:flex;align-items:center;justify-content:center;border:1px solid #e2e8f0;color:#64748b}
        .dash-info-icon svg{width:18px;height:18px;fill:currentColor}
        .dash-info-label{font-size:10.5px;color:#64748b;text-transform:uppercase;font-weight:700;letter-spacing:0.5px}
        .dash-info-val{font-size:13.5px;color:#1e293b;font-weight:600;margin-top:1px}

        /* STYLIZED TIMELINE UX */
        .timeline-section{
            background:#ffffff;
            border-radius:12px;
            padding:24px;
            border:1px solid #eef0f8;
            box-shadow:0 1px 4px rgba(0,0,0,.04);
            display:flex;
            flex-direction:column;
            height:0;
            min-height:100%;
        }
        .timeline-wrapper{
            position:relative;
            padding-left:24px;
            margin-top:16px;
            flex:1;
            min-height:0;
            overflow-y:auto;
            padding-right:12px;
        }
        .timeline-wrapper::-webkit-scrollbar{width:6px}
        .timeline-wrapper::-webkit-scrollbar-track{background:#f1f5f9;border-radius:4px}
        .timeline-wrapper::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:4px;transition:background 0.2s}
        .timeline-wrapper::-webkit-scrollbar-thumb:hover{background:#94a3b8}
        .timeline-wrapper::before{content:'';position:absolute;left:5px;top:8px;bottom:8px;width:2px;background:#e2e8f0}
        .timeline-node{position:relative;margin-bottom:24px}
        .timeline-node:last-child{margin-bottom:0}
        .timeline-dot{position:absolute;left:-24px;top:4px;width:10px;height:10px;border-radius:50%;background:#64748b;border:2.5px solid #ffffff;box-shadow:0 0 0 2px #e2e8f0;transition:all 0.2s ease}
        .timeline-dot.blue{background:#3b82f6;box-shadow:0 0 0 2px rgba(59,130,246,.3)}
        .timeline-dot.green{background:#10b981;box-shadow:0 0 0 2px rgba(16,185,129,.3)}
        .timeline-dot.red{background:#ef4444;box-shadow:0 0 0 2px rgba(239,68,68,.3)}
        .timeline-dot.yellow{background:#f59e0b;box-shadow:0 0 0 2px rgba(245,158,11,.3)}
        
        .timeline-card{background:#f8fafc;border-radius:10px;padding:12px 16px;border:1px solid #f1f5f9;transition:all 0.2s ease}
        .timeline-card:hover{transform:translateX(3px);border-color:#e2e8f0;background:#ffffff;box-shadow:0 2px 8px rgba(0,0,0,.02)}
        .timeline-meta-row{display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;flex-wrap:wrap;gap:6px}
        .timeline-action-title{font-size:13.5px;font-weight:700;color:#1e293b}
        .timeline-timestamp{font-size:11px;font-weight:600;color:#64748b;font-family:'JetBrains Mono',monospace}
        .timeline-card-body{font-size:12.5px;color:#475569;line-height:1.4}
        .timeline-card-body strong{color:#0f172a}
        .timeline-badges-row{display:flex;gap:6px;margin-top:8px;border-top:1px solid #f1f5f9;padding-top:8px;align-items:center}
        .timeline-badge-label{font-size:10px;color:#64748b;font-weight:600}

        /* CARDS / CONTAINERS IN THE RIGHT COLUMN */
        .right-column-container{display:flex;flex-direction:column;gap:24px}
        .premium-card{background:#ffffff;border-radius:12px;padding:24px;border:1px solid #eef0f8;box-shadow:0 1px 4px rgba(0,0,0,.04)}
        .premium-card-title{font-size:14.5px;font-weight:700;color:#1a2a4a;margin-bottom:16px;display:flex;align-items:center;gap:8px;border-bottom:1px solid #f1f5f9;padding-bottom:10px}
        .premium-card-title svg{width:18px;height:18px;fill:currentColor}
        .premium-card-title span{height:2px;flex:1;background:#f1f5f9;border-radius:1px;margin-left:6px}

        /* CARD DECKS INSTEAD OF BORING TABLES (Scrollable if > 2 items) */
        .cards-deck{display:flex;flex-direction:column;max-height:390px;overflow-y:auto;padding-right:6px}
        .cards-deck::-webkit-scrollbar{width:6px}
        .cards-deck::-webkit-scrollbar-track{background:#f1f5f9;border-radius:4px}
        .cards-deck::-webkit-scrollbar-thumb{background:#cbd5e1;border-radius:4px;transition:background 0.2s}
        .cards-deck::-webkit-scrollbar-thumb:hover{background:#94a3b8}
        
        /* 1. Signature Certificate Passport */
        .sig-passport-card{background:#f8fafc;border-radius:10px;border:1px solid #e2e8f0;border-left:4px solid #10b981;padding:14px;position:relative;overflow:hidden;transition:all 0.25s ease;margin-bottom:12px}
        .sig-passport-card:hover{border-color:#a7f3d0;border-left-color:#10b981;box-shadow:0 2px 8px rgba(16,185,129,.05);background:#ffffff}
        .sig-pass-header{display:flex;align-items:center;justify-content:space-between;margin-bottom:10px;flex-wrap:wrap;gap:6px}
        .sig-pass-user-wrap{display:flex;align-items:center;gap:10px}
        .sig-pass-icon-shield{width:32px;height:32px;border-radius:6px;background:rgba(16,185,129,.08);border:1px solid rgba(16,185,129,.15);display:flex;align-items:center;justify-content:center;color:#057857}
        .sig-pass-icon-shield svg{width:16px;height:16px;fill:currentColor}
        .sig-pass-user-name{font-size:13px;font-weight:700;color:#1e293b}
        .sig-pass-user-role{font-size:11px;color:#64748b;margin-top:1px;font-weight:500}
        .sig-pass-date{font-size:11px;font-weight:600;color:#64748b;font-family:'JetBrains Mono',monospace}
        .sig-pass-body{background:#ffffff;border-radius:8px;padding:8px 10px;border:1px solid #f1f5f9}
        .sig-pass-label{font-size:9px;font-weight:700;color:#64748b;letter-spacing:0.5px;margin-bottom:4px;text-transform:uppercase}
        .hash-token-wrap{display:flex;align-items:center;justify-content:space-between;gap:8px}
        .hash-token-code{font-family:'JetBrains Mono',monospace;font-size:11px;color:#047857;word-break:break-all;line-height:1.3}
        .btn-copy-token{background:transparent;border:none;color:#94a3b8;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:4px;border-radius:4px;transition:all 0.2s}
        .btn-copy-token:hover{color:#1e293b;background:#f1f5f9}
        .btn-copy-token svg{width:14px;height:14px;fill:currentColor}

        /* 2. PDF Annotation Sticky Notes */
        .pdf-sticky-card{background:#fffbeb;border:1px solid #fef3c7;border-left:4px solid #f59e0b;border-radius:10px;padding:14px;position:relative;margin-bottom:12px}
        .pdf-sticky-card::after{content:'';position:absolute;top:0;right:0;width:0;height:0;border-style:solid;border-width:0 10px 10px 0;border-color:transparent #f59e0b transparent transparent;pointer-events:none}
        .pdf-sticky-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:8px;flex-wrap:wrap;gap:6px}
        .pdf-sticky-author{display:flex;align-items:center;gap:8px}
        .pdf-sticky-avatar{width:26px;height:26px;border-radius:50%;background:rgba(245,158,11,.1);border:1px solid rgba(245,158,11,.2);display:flex;align-items:center;justify-content:center;color:#b45309;font-size:10.5px;font-weight:700}
        .pdf-sticky-author-name{font-size:12.5px;font-weight:700;color:#1e293b}
        .pdf-sticky-date{font-size:11px;color:#64748b}
        .pdf-sticky-badges{display:flex;gap:4px;align-items:center}
        
        .coord-badge{font-size:10px;font-weight:700;padding:2px 6px;border-radius:4px;display:inline-flex;align-items:center;gap:3px;font-family:'JetBrains Mono',monospace}
        .page-badge{background:rgba(245,158,11,.1);color:#b45309;border:1px solid rgba(245,158,11,.2)}
        .geo-badge{background:rgba(0,0,0,.04);color:#475569;border:1px solid rgba(0,0,0,.06)}

        .pdf-sticky-highlight{background:rgba(245,158,11,.04);border-radius:6px;padding:8px 10px;border:1.5px dashed rgba(245,158,11,.15);margin-bottom:8px}
        .sticky-section-label{font-size:9px;color:#b45309;font-weight:700;letter-spacing:0.5px;margin-bottom:4px;text-transform:uppercase}
        .sticky-highlight-text{font-size:12px;color:#475569;font-style:italic;line-height:1.4}
        
        .pdf-sticky-comment{background:rgba(255,255,255,.6);border-radius:6px;padding:8px 10px;border:1px solid rgba(245,158,11,.1)}
        .sticky-comment-text{font-size:12.5px;color:#1e293b;line-height:1.4;font-weight:500}

        /* 3. Resolution Cards */
        .resolution-card{background:#f0fdf4;border:1px solid #dcfce7;border-left:4px solid #10b981;border-radius:10px;padding:14px;margin-bottom:12px}
        .res-card-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:10px}
        .res-card-title{font-size:12.5px;font-weight:700;color:#047857;display:flex;align-items:center;gap:4px}
        
        .res-steps-flow{display:flex;flex-direction:column;gap:8px;position:relative}
        .res-flow-step{padding:8px 10px;border-radius:6px;background:rgba(255,255,255,.6);border:1px solid rgba(0,0,0,.03)}
        .res-flow-step.resolved{background:rgba(16,185,129,.04);border-color:rgba(16,185,129,.15)}
        .res-step-label{font-size:9.5px;font-weight:700;color:#64748b;margin-bottom:2px;text-transform:uppercase}
        .res-flow-step.resolved .res-step-label{color:#047857}
        .res-step-text{font-size:12px;color:#475569;line-height:1.4}
        .res-step-text.italic{font-style:italic}
        .res-flow-arrow{display:flex;justify-content:center;color:rgba(0,0,0,.15);margin:-2px 0}
        .res-flow-arrow svg{width:14px;height:14px;fill:currentColor}

        /* EMPTY DATA / FALLBACK BOX */
        .fallback-box{text-align:center;padding:32px 16px;color:#64748b;font-size:13px;background:rgba(0,0,0,.01);border-radius:8px;border:1.5px dashed rgba(0,0,0,.06);display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px}
        .fallback-box svg{width:32px;height:32px;fill:rgba(0,0,0,.15)}

        /* BUTTON PRINT UX */
        .btn-print{padding:0 16px;background:#ffffff;border:1.5px solid #dde1f0;color:#475569;border-radius:8px;font-size:12.5px;font-weight:600;cursor:pointer;display:inline-flex;align-items:center;justify-content:center;gap:6px;height:38px;transition:all 0.25s ease;box-shadow:0 1px 3px rgba(0,0,0,0.02)}
        .btn-print:hover{background:#f8fafc;color:#1d4ed8;border-color:#3b82f6}
        .btn-print svg{width:16px;height:16px;fill:currentColor}

        /* PRINT STYLING */
        @media print {
            body, html{background:#ffffff !important;color:#000000 !important;overflow:visible !important;height:auto !important}
            .sidebar, .topbar, .tabs, .filter-card, .btn-back, .btn-print, .nav-item-logout{display:none !important}
            .main{background:#ffffff !important;overflow:visible !important;display:block !important}
            .content{padding:0 !important;overflow:visible !important}
            .doc-detail-grid{display:block !important}
            .right-column-container, .timeline-section, .premium-card, .dash-header-card{box-shadow:none !important;border:1px solid #cccccc !important;margin-bottom:20px !important;page-break-inside:avoid}
            .timeline-card, .sig-passport-card, .pdf-sticky-card, .resolution-card{background:#ffffff !important;border:1px solid #e2e8f0 !important}
        }
    </style>
</head>
<body data-zfn-notify="<%= ResolveUrl("~/Presentacion/Notificaciones.ashx") %>">
<form id="form1" runat="server" style="display:flex;width:100%;height:100vh;overflow:hidden;">
<div style="display:flex;width:100%;height:100vh;overflow:hidden;">
    
    <!-- SIDEBAR -->
    <div class="sidebar">
        <div class="sidebar-logo">
            <div class="logo-icon">
                <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 14H9V8h2v8zm4 0h-2V8h2v8z"/></svg>
            </div>
            <div class="logo-text">
                <div class="top">SIGEFIDD<span>-ZOFRA</span></div>
                <div class="bot">ZONA FRANCA DE TACNA</div>
            </div>
        </div>
        <nav class="sidebar-nav" style="display: flex; flex-direction: column; height: 100%;">
            <div style="flex: 1; overflow-y: auto;">
                <a href="../Default.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/></svg>Inicio
                </a>
                <a href="../BandejaTrabajo/BandejaTrabajo.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M20 6h-2.18c.07-.44.18-.88.18-1.34C18 2.54 15.96.5 13.34.5c-1.3 0-2.48.54-3.34 1.4L9 3l-1-.94C7.12 1.04 5.94.5 4.66.5 2.04.5 0 2.54 0 4.66 0 5.12.11 5.56.18 6H0v14h20V6z"/></svg>Bandeja de Trabajo
                    <span class="nav-badge"><asp:Literal ID="litBadge" runat="server"/></span>
                </a>
                <a href="../GestionDocumentos/CargarDocumento.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>Cargar Documento
                </a>
                <a href="../GestionDocumentos/MisDocumentos.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>Mis Documentos
                </a>
                <a href="../GestionRoles/GestionRoles.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>Gestión de Roles
                </a>
                <a href="../VisualizarFirmantes/VisualizarFirmantes.aspx" class="nav-item">
                    <svg viewBox="0 0 24 24"><path d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04c.39-.39.39-1.02 0-1.41l-2.34-2.34c-.39-.39-1.02-.39-1.41 0l-1.83 1.83 3.75 3.75 1.83-1.83z"/></svg>Visualizar Firmantes
                </a>
                <a href="GestionAuditoria.aspx" class="nav-item active">
                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.95-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.53c-.26-.81-1-1.4-1.9-1.4h-1v-3c0-.55-.45-1-1-1h-6v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.4z"/></svg>Auditoría
                </a>
            </div>
            <asp:Button ID="btnCerrarSesion" runat="server" Text="Cerrar Sesión" CssClass="nav-item-logout" OnClick="btnCerrarSesion_Click" UseSubmitBehavior="false" />
        </nav>
    </div>

    <!-- MAIN PANEL -->
    <div class="main">
        <div class="topbar">
            <div class="breadcrumb"><strong>SIGEFIDD-ZOFRA</strong> / Auditoría de Seguridad</div>
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

        <div class="content">
            <div class="page-header">
                <div>
                    <h1>Auditoría del Sistema</h1>
                    <div class="sub">Trazabilidad operativa completa de documentos, firmas digitales y actividades de usuarios</div>
                </div>
            </div>

            <!-- PREMIUM SEGMENTED TAB SELECTOR -->
            <div class="tabs">
                <asp:LinkButton ID="btnTabDoc" runat="server" CssClass="tab-btn active" OnClick="btnTabDoc_Click">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                    Auditoría de Documentos
                </asp:LinkButton>
                <asp:LinkButton ID="btnTabUser" runat="server" CssClass="tab-btn" OnClick="btnTabUser_Click">
                    <svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                    Actividad de Usuarios
                </asp:LinkButton>
            </div>

            <asp:HiddenField ID="hfActiveTab" runat="server" Value="documentos" />

            <!-- ========================================== -->
            <!-- TAB 1: AUDITORÍA DE DOCUMENTOS            -->
            <!-- ========================================== -->
            <asp:Panel ID="pnlTabDocumentos" runat="server" Visible="true" CssClass="tab-panel-fade">
                
                <!-- LISTADO DE DOCUMENTOS -->
                <asp:Panel ID="pnlListadoDocumentos" runat="server" DefaultButton="btnBuscarDoc">
                    
                    <div class="filter-card">
                        <div class="filter-bar">
                            <div class="filter-group">
                                <label>Filtrar por Asunto, Código o Registrador</label>
                                <div class="filter-input-wrap">
                                    <svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                                    <asp:TextBox ID="txtBusquedaDoc" runat="server" CssClass="filter-input" placeholder="Escribe asunto, código de documento o usuario..." />
                                </div>
                            </div>
                            <div class="filter-group" style="max-width:200px;">
                                <label>Fecha de Creación Desde</label>
                                <asp:TextBox ID="txtFechaInicioDoc" runat="server" CssClass="filter-input" TextMode="Date" />
                            </div>
                            <div class="filter-group" style="max-width:200px;">
                                <label>Hasta</label>
                                <asp:TextBox ID="txtFechaFinDoc" runat="server" CssClass="filter-input" TextMode="Date" />
                            </div>
                            <asp:Button ID="btnBuscarDoc" runat="server" Text="Buscar Documentos" CssClass="btn-action" OnClick="btnBuscarDoc_Click" />
                            <asp:LinkButton ID="btnClearDoc" runat="server" Text="Limpiar Filtros" CssClass="btn-clear" OnClick="btnClearDoc_Click" />
                        </div>
                    </div>

                    <div class="tbl-card">
                        <div class="table-responsive">
                            <asp:GridView ID="gvDocumentos" runat="server" AutoGenerateColumns="False" 
                                           CssClass="table-premium" GridLines="None" Width="100%"
                                           OnRowCommand="gvDocumentos_RowCommand" ShowHeaderWhenEmpty="true"
                                           UseAccessibleHeader="true">
                                 <Columns>
                                     <asp:TemplateField HeaderText="CÓDIGO DE DOCUMENTO">
                                         <ItemTemplate>
                                             <span class="code-pill">
                                                 <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                                                 <%# Eval("CodigoDocumento") %>
                                             </span>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="ASUNTO DEL DOCUMENTO">
                                         <ItemTemplate>
                                             <span class="doc-subject-title"><%# Eval("Asunto") %></span>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="TIPO">
                                         <ItemTemplate>
                                             <span class='badge <%# Eval("TipoDocumento").ToString() == "RESOLUCION" ? "badge-purple" : 
                                                                     (Eval("TipoDocumento").ToString() == "INFORME" ? "badge-teal" : 
                                                                     (Eval("TipoDocumento").ToString() == "MEMORANDO" ? "badge-indigo" : "badge-sec")) %>'>
                                                 <%# Eval("TipoDocumento") %>
                                             </span>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="ESTADO ACTUAL">
                                         <ItemTemplate>
                                             <span class='badge <%# GetTimelineColor(Eval("EstadoActual").ToString()) == "green" ? "badge-success" : 
                                                                     (GetTimelineColor(Eval("EstadoActual").ToString()) == "red" ? "badge-danger" : 
                                                                     (GetTimelineColor(Eval("EstadoActual").ToString()) == "yellow" ? "badge-warning" : "badge-info")) %>'>
                                                 <%# Eval("EstadoActual") %>
                                             </span>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="REGISTRADOR">
                                         <ItemTemplate>
                                             <div class="user-profile-chip">
                                                 <div class="user-profile-avatar">
                                                     <%# Eval("LoginUsuarioRegistrador").ToString().Length >= 2 ? Eval("LoginUsuarioRegistrador").ToString().Substring(0, 2).ToUpper() : Eval("LoginUsuarioRegistrador").ToString().ToUpper() %>
                                                 </div>
                                                 <span class="user-profile-name"><%# Eval("LoginUsuarioRegistrador") %></span>
                                             </div>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="FECHA DE REGISTRO">
                                         <ItemTemplate>
                                             <div class="date-time-container">
                                                 <span class="date-part"><%# Eval("FechaCreacion", "{0:dd/MM/yyyy}") %></span>
                                                 <span class="time-part"><%# Eval("FechaCreacion", "{0:HH:mm}") %></span>
                                             </div>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                     <asp:TemplateField HeaderText="ACCIONES DE AUDITORÍA">
                                         <ItemTemplate>
                                             <asp:LinkButton ID="lnkVerAuditoria" runat="server" CommandName="VerAuditoria" 
                                                             CommandArgument='<%# Eval("IdDocumento") %>' CssClass="btn-table-action">
                                                 <svg viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                                                 Ver Auditoría
                                             </asp:LinkButton>
                                         </ItemTemplate>
                                     </asp:TemplateField>
                                 </Columns>
                                 <EmptyDataTemplate>
                                     <div class="fallback-box">
                                         <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm-2 16c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm1-5h-2V8h2v5z"/></svg>
                                         No se encontraron documentos registrados bajo los criterios de búsqueda actuales.
                                     </div>
                                 </EmptyDataTemplate>
                             </asp:GridView>
                        </div>
                    </div>

                </asp:Panel>

                <!-- DETALLE DE UN DOCUMENTO SELECCIONADO (AUDIT DASHBOARD LAYOUT) -->
                <asp:Panel ID="pnlDetalleDocumento" runat="server" Visible="false">
                    
                    <asp:LinkButton ID="lnkVolverListado" runat="server" CssClass="btn-back" OnClick="lnkVolverListado_Click">
                        <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:currentColor;"><path d="M20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.41-1.41L7.83 13H20v-2z"/></svg>
                        Volver al Listado de Documentos
                    </asp:LinkButton>

                    <!-- Premium Dashboard Header Card -->
                    <div class="dash-header-card">
                        <div class="dash-header-top">
                            <div>
                                <span class="badge badge-sec">Trazabilidad Integral</span>
                                <div class="dash-header-title" style="margin-top:6px;"><asp:Label ID="lblDetAsunto" runat="server" /></div>
                                <span class="dash-header-code"><asp:Label ID="lblDetCodigo" runat="server" /></span>
                            </div>
                            <div>
                                <span class="badge badge-info" style="font-size:12px;padding:6px 16px;box-shadow:0 0 12px rgba(59,130,246,.2)">
                                    Estado: <asp:Label ID="lblDetEstado" runat="server" style="font-weight:800;margin-left:4px;" />
                                </span>
                            </div>
                        </div>
                        
                        <div class="grid-dashboard-info">
                            <div class="dash-info-block">
                                <div class="dash-info-icon">
                                    <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>
                                </div>
                                <div>
                                    <div class="dash-info-label">Tipo Documento</div>
                                    <div class="dash-info-val"><asp:Label ID="lblDetTipo" runat="server" /></div>
                                </div>
                            </div>
                            <div class="dash-info-block">
                                <div class="dash-info-icon">
                                    <svg viewBox="0 0 24 24"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                                </div>
                                <div>
                                    <div class="dash-info-label">Registrador Original</div>
                                    <div class="dash-info-val"><asp:Label ID="lblDetRegistrador" runat="server" /></div>
                                </div>
                            </div>
                            <div class="dash-info-block">
                                <div class="dash-info-icon">
                                    <svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg>
                                </div>
                                <div>
                                    <div class="dash-info-label">Fecha y Hora Registro</div>
                                    <div class="dash-info-val"><asp:Label ID="lblDetFechaCrea" runat="server" /></div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="doc-detail-grid">
                        
                        <!-- LEFT COLUMN: FLOW TIMELINE -->
                        <div class="timeline-section">
                                <div class="premium-card-title" style="border:none;padding:0;margin:0;">
                                    <svg viewBox="0 0 24 24" style="color:#2563eb;"><path d="M13 3c-4.97 0-9 4.03-9 9H1l3.89 3.89.07.14L9 12H6c0-3.87 3.13-7 7-7s7 3.13 7 7-3.13 7-7 7c-1.93 0-3.68-.79-4.94-2.06l-1.42 1.42C8.27 19.99 10.51 21 13 21c4.97 0 9-4.03 9-9s-4.03-9-9-9zm-1 5v5l4.28 2.54.72-1.21-3.5-2.08V8H12z"/></svg>
                                    Línea de Tiempo del Flujo Operativo
                                </div>
                                <div style="font-size:12.5px;color:#94a3b8;margin-top:4px;margin-bottom:20px;font-weight:500;">Historial de todas las transiciones de estado del documento</div>

                                <div class="timeline-wrapper">
                                    <asp:Repeater ID="rptTimeline" runat="server">
                                        <ItemTemplate>
                                            <div class="timeline-node">
                                                <div class='timeline-dot <%# GetTimelineColor(Eval("EstadoNuevo").ToString()) %>'></div>
                                                <div class="timeline-card">
                                                    <div class="timeline-meta-row">
                                                        <div class="timeline-action-title">
                                                            <%# System.Web.HttpUtility.HtmlEncode(Eval("DetalleAccion").ToString()) %>
                                                        </div>
                                                        <div class="timeline-timestamp">
                                                            <%# Eval("FechaCambio", "{0:dd/MM/yyyy HH:mm:ss}") %>
                                                        </div>
                                                    </div>
                                                    <div class="timeline-card-body">
                                                        Operación efectuada por el usuario <strong><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginUsuarioAccion").ToString()) %></strong> en el flujo documental.
                                                    </div>
                                                    <div class="timeline-badges-row">
                                                        <span class="timeline-badge-label">Transición:</span>
                                                        <span class="badge badge-sec" style="font-size:10px;padding:2px 8px;"><%# System.Web.HttpUtility.HtmlEncode(string.IsNullOrEmpty(Eval("EstadoAnterior").ToString()) ? "Inicio" : Eval("EstadoAnterior").ToString()) %></span>
                                                        <svg viewBox="0 0 24 24" style="width:12px;height:12px;fill:rgba(255,255,255,0.4);"><path d="M16.01 11H4v2h12.01v3L20 12l-3.99-4v3z"/></svg>
                                                        <span class='badge <%# GetTimelineColor(Eval("EstadoNuevo").ToString()) == "green" ? "badge-success" : 
                                                                                (GetTimelineColor(Eval("EstadoNuevo").ToString()) == "red" ? "badge-danger" : 
                                                                                (GetTimelineColor(Eval("EstadoNuevo").ToString()) == "yellow" ? "badge-warning" : "badge-info")) %>' 
                                                              style="font-size:10px;padding:2px 8px;"><%# System.Web.HttpUtility.HtmlEncode(Eval("EstadoNuevo").ToString()) %></span>
                                                    </div>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                                
                                <asp:Panel ID="pnlTimelineEmpty" runat="server" Visible="false">
                                    <div class="fallback-box" style="padding: 24px;">
                                        <svg viewBox="0 0 24 24"><path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67V7z"/></svg>
                                        No se registraron movimientos de estado históricos.
                                    </div>
                                </asp:Panel>
                            </div>

                        <!-- RIGHT COLUMN: CERTIFICATES & ANNOTATIONS -->
                        <div class="right-column-container">
                            
                            <!-- 1. CERTIFICACIÓN DIGITAL (FIRMAS) -->
                            <div class="premium-card">
                                <div class="premium-card-title">
                                    <svg viewBox="0 0 24 24" style="color:#10b981;"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm-2 16l-4-4 1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8z"/></svg>
                                    Garantía de Certificación & Firmas Digitales Aplicadas
                                    <span></span>
                                </div>
                                
                                <div class="cards-deck">
                                    <asp:GridView ID="gvDetFirmas" runat="server" AutoGenerateColumns="False" 
                                                  GridLines="None" Width="100%" ShowHeader="false" ShowHeaderWhenEmpty="true">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <div class="sig-passport-card">
                                                        <div class="sig-pass-header">
                                                            <div class="sig-pass-user-wrap">
                                                                <div class="sig-pass-icon-shield">
                                                                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                                                                </div>
                                                                <div>
                                                                    <div class="sig-pass-user-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginUsuario").ToString()) %></div>
                                                                    <div class="sig-pass-user-role">Firmante Acreditado del Sistema</div>
                                                                </div>
                                                            </div>
                                                            <div style="text-align:right;">
                                                                <span class="badge badge-success" style="font-size:10px;"><%# System.Web.HttpUtility.HtmlEncode(Eval("EstadoFirma").ToString()) %></span>
                                                                <div class="sig-pass-date" style="margin-top:6px;"><%# Eval("FechaFirma", "{0:dd/MM/yyyy HH:mm:ss}") %></div>
                                                            </div>
                                                        </div>
                                                        <div class="sig-pass-body">
                                                            <div class="sig-pass-label">Token / Hash Criptográfico Único de Verificación</div>
                                                            <div class="hash-token-wrap">
                                                                <span class="hash-token-code"><%# System.Web.HttpUtility.HtmlEncode(Eval("FirmaDigitalHash").ToString()) %></span>
                                                                <button type="button" class="btn-copy-token" title="Copiar Hash" onclick="navigator.clipboard.writeText('<%# System.Web.HttpUtility.HtmlEncode(Eval("FirmaDigitalHash").ToString()) %>'); alert('¡Criptohash copiado exitosamente!');">
                                                                    <svg viewBox="0 0 24 24"><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/></svg>
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="fallback-box">
                                                <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                                                El documento actual no posee firmas digitales completadas en su historial.
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>

                            <!-- 2. MARCADORES ACTIVOS EN PDF -->
                            <div class="premium-card">
                                <div class="premium-card-title">
                                    <svg viewBox="0 0 24 24" style="color:#f59e0b;"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                                    Marcadores de Observación Colocados en PDF (Visor Web)
                                    <span></span>
                                </div>
                                
                                <div class="cards-deck">
                                    <asp:GridView ID="gvDetMarcadores" runat="server" AutoGenerateColumns="False" 
                                                  GridLines="None" Width="100%" ShowHeader="false" ShowHeaderWhenEmpty="true">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <div class="pdf-sticky-card">
                                                        <div class="pdf-sticky-header">
                                                            <div class="pdf-sticky-author">
                                                                <div class="pdf-sticky-avatar">
                                                                    <%# System.Web.HttpUtility.HtmlEncode(Eval("LoginUsuario").ToString().Substring(0, Math.Min(2, Eval("LoginUsuario").ToString().Length)).ToUpper()) %>
                                                                </div>
                                                                <div>
                                                                    <div class="pdf-sticky-author-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginUsuario").ToString()) %></div>
                                                                    <div class="pdf-sticky-date">Marcado el <%# Eval("FechaCreacion", "{0:dd/MM/yyyy HH:mm}") %></div>
                                                                </div>
                                                            </div>
                                                            <div class="pdf-sticky-badges">
                                                                <span class="coord-badge page-badge">
                                                                    Pág. <%# Eval("Pagina") %>
                                                                </span>
                                                                <span class="coord-badge geo-badge" title="Coordenadas X/Y">
                                                                    X: <%# Convert.ToDouble(Eval("PosX")).ToString("F0") %> | Y: <%# Convert.ToDouble(Eval("PosY")).ToString("F0") %>
                                                                </span>
                                                            </div>
                                                        </div>
                                                        <div class="pdf-sticky-highlight">
                                                            <div class="sticky-section-label">Texto seleccionado del visor PDF</div>
                                                            <div class="sticky-highlight-text">"<%# System.Web.HttpUtility.HtmlEncode(Eval("TextoSeleccionado").ToString()) %>"</div>
                                                        </div>
                                                        <div class="pdf-sticky-comment">
                                                            <div class="sticky-section-label">Comentario de Observación</div>
                                                            <div class="sticky-comment-text"><%# System.Web.HttpUtility.HtmlEncode(Eval("Comentario").ToString()) %></div>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="fallback-box">
                                                <svg viewBox="0 0 24 24"><path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg>
                                                No se registran notas de observación activas en las coordenadas de este PDF.
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>

                            <!-- 3. HISTORIAL DE LEVANTAMIENTOS -->
                            <div class="premium-card">
                                <div class="premium-card-title">
                                    <svg viewBox="0 0 24 24" style="color:#10b981;"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg>
                                    Historial Completo de Observaciones Corregidas (Subsanaciones)
                                    <span></span>
                                </div>
                                
                                <div class="cards-deck">
                                    <asp:GridView ID="gvDetSubsanadas" runat="server" AutoGenerateColumns="False" 
                                                  GridLines="None" Width="100%" ShowHeader="false" ShowHeaderWhenEmpty="true">
                                        <Columns>
                                            <asp:TemplateField>
                                                <ItemTemplate>
                                                    <div class="resolution-card">
                                                        <div class="res-card-header">
                                                            <div class="res-card-title">
                                                                <svg viewBox="0 0 24 24" style="width:16px;height:16px;fill:currentColor;"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg>
                                                                Ciclo Subsanado
                                                            </div>
                                                            <span class="badge badge-success">CORREGIDO</span>
                                                        </div>
                                                        <div class="res-steps-flow">
                                                            <div class="res-flow-step">
                                                                <div class="res-step-label">Observado por <strong><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginRevisor").ToString()) %></strong> el <%# Eval("FechaObservacion", "{0:dd/MM/yyyy HH:mm}") %></div>
                                                                <div class="res-step-text italic">"<%# System.Web.HttpUtility.HtmlEncode(Eval("Comentario").ToString()) %>"</div>
                                                            </div>
                                                            <div class="res-flow-arrow">
                                                                <svg viewBox="0 0 24 24"><path d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
                                                            </div>
                                                            <div class="res-flow-step resolved">
                                                                <div class="res-step-label">Levantado / Subsanado por <strong><%# System.Web.HttpUtility.HtmlEncode(Eval("LoginLevantamiento").ToString()) %></strong></div>
                                                                <div class="res-step-text">
                                                                    Levantamiento procesado y aprobado exitosamente el <strong><%# Eval("FechaLevantamiento", "{0:dd/MM/yyyy HH:mm}") %></strong>.
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </ItemTemplate>
                                            </asp:TemplateField>
                                        </Columns>
                                        <EmptyDataTemplate>
                                            <div class="fallback-box">
                                                <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg>
                                                No se registra ningún historial de levantamiento de observaciones para este documento.
                                            </div>
                                        </EmptyDataTemplate>
                                    </asp:GridView>
                                </div>
                            </div>
                            
                        </div>
                    </div>

                </asp:Panel>

            </asp:Panel>

            <!-- ========================================== -->
            <!-- TAB 2: ACTIVIDAD DE USUARIOS              -->
            <!-- ========================================== -->
            <asp:Panel ID="pnlTabUsuarios" runat="server" Visible="false" CssClass="tab-panel-fade" DefaultButton="btnBuscarUsr">
                
                <div class="filter-card">
                    <div class="filter-bar">
                        <div class="filter-group">
                            <label>Seleccionar Usuario del Sistema</label>
                            <div class="filter-input-wrap">
                                <svg viewBox="0 0 24 24" style="left:14px;"><path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                                <asp:DropDownList ID="ddlUsuariosActividad" runat="server" CssClass="filter-input" style="padding-left:42px;" />
                            </div>
                        </div>
                        <div class="filter-group" style="max-width:200px;">
                            <label>Rango de Fecha Desde</label>
                            <asp:TextBox ID="txtFechaInicioUsr" runat="server" CssClass="filter-input" TextMode="Date" />
                        </div>
                        <div class="filter-group" style="max-width:200px;">
                            <label>Hasta</label>
                            <asp:TextBox ID="txtFechaFinUsr" runat="server" CssClass="filter-input" TextMode="Date" />
                        </div>
                        <asp:Button ID="btnBuscarUsr" runat="server" Text="Consultar Actividad" CssClass="btn-action" OnClick="btnBuscarUsr_Click" />
                        <asp:LinkButton ID="btnClearUsr" runat="server" Text="Limpiar" CssClass="btn-clear" OnClick="btnClearUsr_Click" />
                    </div>
                </div>

                <div class="tbl-card">
                    <div class="table-responsive">
                        <asp:GridView ID="gvActividadUsuarios" runat="server" AutoGenerateColumns="False" 
                                       CssClass="table-premium" GridLines="None" Width="100%" ShowHeaderWhenEmpty="true"
                                       UseAccessibleHeader="true">
                             <Columns>
                                 <asp:TemplateField HeaderText="FECHA Y HORA">
                                     <ItemTemplate>
                                         <div class="date-time-container">
                                             <span class="date-part"><%# Eval("Fecha", "{0:dd/MM/yyyy}") %></span>
                                             <span class="time-part"><%# Eval("Fecha", "{0:HH:mm:ss}") %></span>
                                         </div>
                                     </ItemTemplate>
                                 </asp:TemplateField>
                                 <asp:TemplateField HeaderText="USUARIO OPERADOR">
                                     <ItemTemplate>
                                         <div class="user-profile-chip">
                                             <div class="user-profile-avatar">
                                                 <%# Eval("Usuario").ToString().Length >= 2 ? Eval("Usuario").ToString().Substring(0, 2).ToUpper() : Eval("Usuario").ToString().ToUpper() %>
                                             </div>
                                             <span class="user-profile-name"><%# System.Web.HttpUtility.HtmlEncode(Eval("Usuario").ToString()) %></span>
                                         </div>
                                     </ItemTemplate>
                                 </asp:TemplateField>
                                 <asp:TemplateField HeaderText="ACCIÓN OPERATIVA">
                                     <ItemTemplate>
                                         <span class='badge <%# GetAccionBadge(Eval("TipoAccion").ToString()) %>'>
                                             <%# System.Web.HttpUtility.HtmlEncode(Eval("TipoAccion").ToString()) %>
                                         </span>
                                     </ItemTemplate>
                                 </asp:TemplateField>
                                 <asp:TemplateField HeaderText="DOCUMENTO AFECTADO">
                                     <ItemTemplate>
                                         <span class="code-pill">
                                             <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-1.99.9-1.99 2L4 20c0 1.1.89 2 1.99 2H18c1.1 0 2-.9 2-2V8l-6-6zm2 16H8v-2h8v2zm0-4H8v-2h8v2zm-3-5V3.5L18.5 9H13z"/></svg>
                                             <%# System.Web.HttpUtility.HtmlEncode(Eval("CodigoDocumento").ToString()) %>
                                         </span>
                                     </ItemTemplate>
                                 </asp:TemplateField>
                                 <asp:TemplateField HeaderText="DETALLE TÉCNICO DE LA ACCIÓN">
                                     <ItemTemplate>
                                         <span style="font-weight: 500; color: #475569;"><%# System.Web.HttpUtility.HtmlEncode(Eval("Detalle").ToString()) %></span>
                                     </ItemTemplate>
                                 </asp:TemplateField>
                             </Columns>
                             <EmptyDataTemplate>
                                 <div class="fallback-box">
                                     <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"/></svg>
                                     No se registraron transacciones o actividades para el usuario o rango de fechas solicitado.
                                 </div>
                             </EmptyDataTemplate>
                         </asp:GridView>
                    </div>
                </div>

            </asp:Panel>

        </div>
    </div>
</div>
<div id="zfnToastHost" class="zfn-toast-host"></div>
</form>
</body>
</html>
