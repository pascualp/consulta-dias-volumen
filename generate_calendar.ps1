$jsonPath = "C:\Users\Antonia\.gemini\antigravity\scratch\extracted_data.json"
$outputPath = "C:\Users\Antonia\.gemini\antigravity\scratch\calendar_dashboard.html"

if (!(Test-Path $jsonPath)) {
    Write-Host "Error: JSON file not found at $jsonPath"
    exit
}

$rawJson = Get-Content -Raw -Path $jsonPath

$part1 = @'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Calendario de Actividad y Volumen de Ventas</title>
    <!-- Google Fonts Inter -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-color: #f8fafc;
            --card-bg: #ffffff;
            --text-main: #0f172a;
            --text-muted: #64748b;
            --primary: #3b82f6;
            --primary-light: #eff6ff;
            --primary-gradient: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
            --accent: #10b981;
            --border-color: #e2e8f0;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -2px rgba(0, 0, 0, 0.1);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -4px rgba(0, 0, 0, 0.1);
            --radius-md: 12px;
            --radius-lg: 16px;
            --transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        }

        [data-theme="dark"] {
            --bg-color: #0b0f19;
            --card-bg: #151f32;
            --text-main: #f1f5f9;
            --text-muted: #94a3b8;
            --primary: #3b82f6;
            --primary-light: #1e293b;
            --primary-gradient: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
            --border-color: #1e293b;
            --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.3);
            --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.3), 0 2px 4px -2px rgba(0, 0, 0, 0.3);
            --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.4), 0 4px 6px -4px rgba(0, 0, 0, 0.4);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            color: var(--text-main);
            transition: var(--transition);
            min-height: 100vh;
            padding: 24px;
        }

        .container {
            max-width: 1440px;
            margin: 0 auto;
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--primary-gradient);
            padding: 24px 32px;
            border-radius: var(--radius-lg);
            color: #ffffff;
            box-shadow: var(--shadow-lg);
            position: relative;
            overflow: hidden;
        }

        header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -30%;
            width: 80%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, rgba(255,255,255,0) 60%);
            pointer-events: none;
            transform: rotate(-15deg);
        }

        .header-title h1 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 4px;
            letter-spacing: -0.5px;
        }

        .header-title p {
            font-size: 14px;
            opacity: 0.9;
            font-weight: 300;
        }

        .header-controls {
            display: flex;
            align-items: center;
            gap: 16px;
            z-index: 10;
        }

        .theme-btn {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.25);
            color: #ffffff;
            padding: 10px 16px;
            border-radius: 9999px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: var(--transition);
            backdrop-filter: blur(4px);
        }

        .theme-btn:hover {
            background: rgba(255, 255, 255, 0.25);
            transform: translateY(-2px);
        }

        /* Filter Controls */
        .controls-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            padding: 24px;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .controls-top {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
        }

        .filter-group {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .filter-label {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-main);
        }

        /* Multi-select Dropdown CSS */
        .multiselect-container {
            position: relative;
            display: inline-block;
        }

        .multiselect-btn {
            padding: 10px 16px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background-color: var(--bg-color);
            color: var(--text-main);
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            min-width: 280px;
            transition: var(--transition);
            user-select: none;
        }

        .multiselect-btn:hover {
            border-color: var(--primary);
        }

        .multiselect-dropdown {
            position: absolute;
            top: calc(100% + 6px);
            left: 0;
            z-index: 100;
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-lg);
            padding: 16px;
            min-width: 300px;
            display: none;
            flex-direction: column;
            gap: 12px;
        }

        .multiselect-dropdown.show {
            display: flex;
        }

        .multiselect-actions {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 8px;
        }

        .multiselect-link {
            color: var(--primary);
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
            user-select: none;
        }

        .multiselect-link:hover {
            text-decoration: underline;
        }

        .multiselect-options {
            max-height: 220px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 8px;
            padding-right: 4px;
        }

        .multiselect-options::-webkit-scrollbar {
            width: 4px;
        }

        .multiselect-options::-webkit-scrollbar-thumb {
            background-color: var(--border-color);
            border-radius: 2px;
        }

        .multiselect-option {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
            cursor: pointer;
            padding: 4px 0;
            user-select: none;
        }

        .multiselect-option input {
            cursor: pointer;
            width: 15px;
            height: 15px;
            border-radius: 4px;
            border: 1px solid var(--border-color);
        }

        /* Autocomplete results dropdown */
        .autocomplete-item {
            padding: 10px 14px;
            cursor: pointer;
            font-size: 13.5px;
            border-radius: 6px;
            transition: var(--transition);
            user-select: none;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex-shrink: 0;
            line-height: 1.4;
            display: block;
        }

        .autocomplete-item:hover {
            background-color: var(--primary-light);
            color: var(--primary);
            font-weight: 600;
        }

        /* Month Tabs */
        .month-tabs {
            display: flex;
            background-color: var(--bg-color);
            padding: 4px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
        }

        .month-tab {
            padding: 8px 20px;
            border-radius: 6px;
            border: none;
            background: transparent;
            color: var(--text-muted);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: var(--transition);
        }

        .month-tab.active {
            background-color: var(--card-bg);
            color: var(--primary);
            box-shadow: var(--shadow-sm);
        }

        /* Week Toggles CSS */
        .week-toggles-container {
            display: flex;
            flex-direction: column;
            gap: 8px;
            width: 100%;
            border-top: 1px solid var(--border-color);
            padding-top: 16px;
        }

        .week-toggles-label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .week-toggles-list {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .week-pill {
            padding: 8px 16px;
            border-radius: 9999px;
            border: 1px solid var(--border-color);
            background-color: var(--bg-color);
            color: var(--text-muted);
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: var(--transition);
            display: flex;
            align-items: center;
            gap: 8px;
            user-select: none;
        }

        .week-pill.active {
            background-color: var(--primary-light);
            color: var(--primary);
            border-color: var(--primary);
            font-weight: 600;
            box-shadow: var(--shadow-sm);
        }

        .week-pill.active svg {
            fill: var(--primary);
        }

        .week-pill:hover {
            border-color: var(--primary);
        }

        /* KPI Row */
        .kpi-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        @media (max-width: 768px) {
            .kpi-row {
                grid-template-columns: 1fr;
            }
        }

        .kpi-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            padding: 20px 24px;
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 6px;
            transition: var(--transition);
        }

        .kpi-title {
            font-size: 12px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .kpi-value {
            font-size: 24px;
            font-weight: 700;
            letter-spacing: -0.5px;
        }

        /* Dashboard Main Layout */
        .main-layout {
            display: grid;
            grid-template-columns: 1.8fr 1.2fr;
            gap: 24px;
            align-items: start;
        }

        @media (max-width: 1024px) {
            .main-layout {
                grid-template-columns: 1fr;
            }
        }

        /* Calendar Section (Separated cards stacked) */
        .calendar-card {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 16px;
            transition: var(--transition);
        }

        .calendar-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 12px;
            margin-bottom: 8px;
        }

        .calendar-month-name {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-main);
            display: flex;
            align-items: center;
        }

        .non-delivery-notice {
            font-size: 11px;
            color: var(--text-muted);
            background-color: var(--bg-color);
            padding: 4px 10px;
            border-radius: 4px;
            font-weight: 500;
        }

        /* Calendar Grid */
        .calendar-grid {
            display: flex;
            flex-direction: column;
            gap: 0;
            width: 100%;
        }

        .calendar-header-row {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 12px;
            margin-bottom: 12px;
        }

        .weekday-label {
            text-align: center;
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            padding: 4px 0;
            border-bottom: 2px solid var(--border-color);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .calendar-row {
            display: grid;
            grid-template-columns: repeat(6, 1fr);
            gap: 12px;
            margin-bottom: 12px;
            transition: opacity 0.2s ease;
        }

        /* Day Cells */
        .day-cell {
            background-color: var(--bg-color);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            aspect-ratio: 1.15;
            padding: 8px 10px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            cursor: pointer;
            transition: var(--transition);
            position: relative;
            user-select: none;
        }

        .day-cell.empty {
            background-color: transparent !important;
            border: 1px dashed var(--border-color);
            cursor: default;
            opacity: 0.3;
        }

        .day-cell:not(.empty):hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-md);
            border-color: var(--primary) !important;
            z-index: 10;
        }

        .day-cell.active {
            border-color: var(--primary) !important;
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.25);
            z-index: 10;
        }

        .day-number {
            font-size: 13px;
            font-weight: 700;
            color: var(--text-muted);
            align-self: flex-start;
        }

        .day-volume {
            font-size: 13px;
            font-weight: 700;
            text-align: center;
            margin: auto 0;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .day-tx-count {
            font-size: 10px;
            font-weight: 500;
            color: var(--text-muted);
            align-self: flex-end;
        }

        /* Heatmap Styles */
        .hm-empty { background-color: var(--bg-color); color: var(--text-main); }
        .hm-empty .day-number, .hm-empty .day-tx-count { color: var(--text-muted); }

        .hm-level-1 { background-color: rgba(59, 130, 246, 0.08); border-color: rgba(59, 130, 246, 0.15); color: var(--text-main); }
        .hm-level-1 .day-number { color: var(--text-main); }
        .hm-level-1 .day-tx-count { color: var(--text-muted); }

        .hm-level-2 { background-color: rgba(59, 130, 246, 0.18); border-color: rgba(59, 130, 246, 0.25); color: var(--text-main); }
        .hm-level-2 .day-number { color: var(--text-main); }
        .hm-level-2 .day-tx-count { color: var(--text-muted); }

        .hm-level-3 { background-color: rgba(59, 130, 246, 0.35); border-color: rgba(59, 130, 246, 0.45); color: var(--text-main); }
        .hm-level-3 .day-number { color: var(--text-main); font-weight: 800; }
        .hm-level-3 .day-tx-count { color: var(--text-main); font-weight: 600; }

        .hm-level-4 { background-color: rgba(59, 130, 246, 0.65); border-color: rgba(59, 130, 246, 0.75); color: #ffffff; }
        .hm-level-4 .day-number, .hm-level-4 .day-tx-count { color: rgba(255, 255, 255, 0.9); font-weight: 800; }
        .hm-level-4 .day-volume { font-weight: 800; }

        .hm-level-5 { background-color: rgba(29, 78, 216, 0.9); border-color: rgba(29, 78, 216, 1); color: #ffffff; box-shadow: var(--shadow-sm); }
        .hm-level-5 .day-number, .hm-level-5 .day-tx-count { color: #ffffff; font-weight: 800; }
        .hm-level-5 .day-volume { font-weight: 900; }

        /* Detail Pane styling */
        .detail-pane {
            background-color: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-md);
            box-shadow: var(--shadow-sm);
            padding: 24px;
            display: flex;
            flex-direction: column;
            gap: 20px;
            min-height: 520px;
        }

        .detail-header {
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 16px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .detail-header h3 {
            font-size: 17px;
            font-weight: 700;
            letter-spacing: -0.3px;
            line-height: 1.3;
        }

        .detail-header-sub {
            font-size: 13px;
            color: var(--text-muted);
            margin-top: 2px;
            font-weight: 500;
        }

        .detail-kpi-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
        }

        .detail-kpi-card {
            background-color: var(--bg-color);
            border: 1px solid var(--border-color);
            padding: 12px 16px;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .detail-kpi-title {
            font-size: 11px;
            color: var(--text-muted);
            font-weight: 600;
            text-transform: uppercase;
        }

        .detail-kpi-value {
            font-size: 16px;
            font-weight: 700;
        }

        /* Search input */
        .search-container {
            position: relative;
            width: 100%;
        }

        .search-input {
            width: 100%;
            padding: 10px 16px 10px 36px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background-color: var(--bg-color);
            color: var(--text-main);
            font-size: 13px;
            transition: var(--transition);
        }

        .search-input:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15);
        }

        .search-icon {
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            width: 16px;
            height: 16px;
            fill: var(--text-muted);
            pointer-events: none;
        }

        /* Table details */
        .table-wrapper {
            flex-grow: 1;
            overflow-y: auto;
            max-height: 320px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }

        th {
            text-align: left;
            padding: 10px 14px;
            background-color: var(--bg-color);
            color: var(--text-muted);
            font-weight: 600;
            border-bottom: 2px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 1;
        }

        td {
            padding: 10px 14px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-main);
        }

        tr:last-child td {
            border-bottom: none;
        }

        tr:hover td {
            background-color: var(--primary-light);
        }

        .badge {
            display: inline-block;
            padding: 3px 6px;
            border-radius: 4px;
            font-size: 10px;
            font-weight: 600;
            text-transform: uppercase;
        }

        .badge-primary {
            background-color: var(--primary-light);
            color: var(--primary);
        }

        .empty-state {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            flex-grow: 1;
            color: var(--text-muted);
            text-align: center;
            gap: 12px;
            padding: 40px;
        }

        .empty-state svg {
            width: 48px;
            height: 48px;
            stroke: var(--text-muted);
            opacity: 0.5;
        }
    </style>
</head>
<body>
    <div class="container">
        <!-- Header -->
        <header>
            <div class="header-title">
                <h1>Calendario de Actividad y Volumen de Ventas</h1>
                <p>Planificaci&oacute;n de Repartos <span style="margin:0 8px; opacity:0.4;">|</span> An&aacute;lisis de Abril y Mayo de 2026</p>
            </div>
            <div class="header-controls">
                <button class="theme-btn" onclick="toggleTheme()">
                    <svg style="width: 16px; height: 16px; fill: currentColor;" viewBox="0 0 24 24">
                        <path d="M12,18C11.11,18 10.26,17.8 9.5,17.45C11.56,16.5 13,14.42 13,12C13,9.58 11.56,7.5 9.5,6.55C10.26,6.2 11.11,6 12,6A6,6 0 0,1 18,12A6,6 0 0,1 12,18M20,8.69V4H15.31L12,0.69L8.69,4H4V8.69L0.69,12L4,15.31V20H8.69L12,23.31L15.31,20H20V15.31L23.31,12L20,8.69Z" />
                    </svg>
                    <span>Modo Claro</span>
                </button>
            </div>
        </header>

        <!-- Controls Card -->
        <div class="controls-card">
            <div class="controls-top">
                <div class="filter-group" id="zone-filter-group">
                    <span class="filter-label">Filtrar Zonas:</span>
                    <!-- Custom Multi-select dropdown -->
                    <div class="multiselect-container" id="multiselect-zones">
                        <div class="multiselect-btn" onclick="toggleZonesDropdown(event)">
                            <span id="multiselect-label">Todas las Zonas</span>
                            <svg style="width: 16px; height: 16px; fill: currentColor;" viewBox="0 0 24 24">
                                <path d="M7.41,8.58L12,13.17L16.59,8.58L18,10L12,16L6,10L7.41,8.58Z" />
                            </svg>
                        </div>
                        <div class="multiselect-dropdown" id="multiselect-dropdown-menu">
                            <div class="multiselect-actions">
                                <span class="multiselect-link" onclick="selectAllZones(event)">Marcar todas</span>
                                <span class="multiselect-link" onclick="selectNoZones(event)">Desmarcar todas</span>
                            </div>
                            <div class="multiselect-options" id="multiselect-options-list">
                                <!-- Generated dynamically -->
                            </div>
                        </div>
                    </div>
                </div>

                <div class="month-tabs">
                    <button class="month-tab active" id="tab-month-4" onclick="selectMonth(4)">Abril 2026</button>
                    <button class="month-tab" id="tab-month-5" onclick="selectMonth(5)">Mayo 2026</button>
                </div>
            </div>

            <!-- Dynamic Week Visibility Toggles -->
            <div class="week-toggles-container" id="week-toggles-block">
                <div class="week-toggles-label">Mostrar/Ocultar Semanas:</div>
                <div class="week-toggles-list" id="week-toggles-list">
                    <!-- Dynamic week pills loaded here -->
                </div>
            </div>
        </div>

        <!-- KPI Summary for active filters & month -->
        <div class="kpi-row">
            <div class="kpi-card">
                <div class="kpi-title" id="kpi-1-title">Ventas del Mes Seleccionado</div>
                <div class="kpi-value" id="kpi-month-sales">€0.00</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title" id="kpi-2-title">Pedidos del Mes Seleccionado</div>
                <div class="kpi-value" id="kpi-month-tx">0</div>
            </div>
            <div class="kpi-card">
                <div class="kpi-title" id="kpi-3-title">Ticket Promedio del Mes</div>
                <div class="kpi-value" id="kpi-month-avg">€0.00</div>
            </div>
        </div>

        <!-- Main Dashboard Layout -->
        <div class="main-layout">
            <!-- Left: Stacked Calendars list by active Zones OR Dedicated Client Calendar -->
            <div id="calendars-container" style="display: flex; flex-direction: column; gap: 24px; width: 100%;">
                <!-- Dynamic calendar cards generated here -->
            </div>

            <!-- Right: Dynamic Sticky Detail Pane -->
            <div style="position: sticky; top: 24px; width:100%;">
                <div class="detail-pane" id="detail-pane">
                    
                    <!-- Permanent Search Input placed at the top of the details/ficha card as requested -->
                    <div style="position: relative; margin-bottom: 16px; width: 100%;">
                        <div style="font-size:11px; font-weight:600; color:var(--text-muted); margin-bottom:6px; text-transform:uppercase; letter-spacing:0.5px;">Buscar Cliente (Abrir Ficha):</div>
                        <div style="position: relative;">
                            <input type="text" class="search-input" id="client-search-global" placeholder="Escribe para buscar cliente..." oninput="onGlobalClientSearch(event)" onfocus="onGlobalClientSearch(event)" autocomplete="off" style="width: 100%; padding-left: 36px; border-color: var(--primary);">
                            <svg class="search-icon" style="left: 12px; width:16px; height:16px; fill:var(--primary);" viewBox="0 0 24 24">
                                <path d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z" />
                            </svg>
                            <div class="multiselect-dropdown" id="client-autocomplete-menu" style="width: 100%; max-height: 220px; overflow-y: auto; box-shadow: var(--shadow-lg);">
                                <!-- Results dynamically generated -->
                            </div>
                        </div>
                    </div>

                    <!-- General Empty State (Lists Top 5 Clients to select directly on the card) -->
                    <div class="empty-state" id="detail-empty" style="flex-direction:column; gap:16px; padding:20px 0;">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2" />
                            <line x1="16" y1="2" x2="16" y2="6" />
                            <line x1="8" y1="2" x2="8" y2="6" />
                            <line x1="3" y1="10" x2="21" y2="10" />
                            <path d="M9 14l2 2 4-4" />
                        </svg>
                        <p style="font-size:13px; font-weight:500;">Selecciona un día en el calendario de la izquierda para ver su desglose, o selecciona un cliente arriba para ver su ficha.</p>
                        
                        <!-- Top 5 Client selector inside details pane card as requested -->
                        <div id="top-clients-quickselect" style="width:100%; border-top:1px solid var(--border-color); padding-top:16px; margin-top:8px;">
                            <!-- Top 5 clients loaded here via JS -->
                        </div>
                    </div>

                    <!-- Standard Day Details Pane -->
                    <div id="detail-content" style="display: none; height: 100%; flex-direction: column; gap: 16px;">
                        <div class="detail-header">
                            <div>
                                <h3 id="detail-date">D&iacute;a: --</h3>
                                <p class="detail-header-sub" id="detail-weekday">D&iacute;a de la semana</p>
                            </div>
                        </div>

                        <div class="detail-kpi-row">
                            <div class="detail-kpi-card">
                                <div class="detail-kpi-title" id="detail-sales-title">Ventas del D&iacute;a en esta Zona</div>
                                <div class="detail-kpi-value" id="detail-sales-val" style="color: var(--primary);">&euro;0.00</div>
                            </div>
                            <div class="detail-kpi-card">
                                <div class="detail-kpi-title" id="detail-tx-title">Pedidos del D&iacute;a</div>
                                <div class="detail-kpi-value" id="detail-tx-val">0 pedidos</div>
                            </div>
                        </div>

                        <!-- Local Client Search within day transactions -->
                        <div class="search-container" id="detail-search-wrapper" style="width: 100%;">
                            <svg class="search-icon" viewBox="0 0 24 24">
                                <path d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z" />
                            </svg>
                            <input type="text" class="search-input" id="client-search" placeholder="Filtrar clientes en esta lista..." oninput="filterClients()">
                        </div>

                        <!-- Timeline / Purchase details table -->
                        <div class="table-wrapper">
                            <table id="detail-table">
                                <thead>
                                    <tr id="detail-table-headers">
                                        <th>Cliente (Ficha)</th>
                                        <th style="width: 70px;">Zona</th>
                                        <th style="text-align: right; width: 110px;">Importe (&euro;)</th>
                                    </tr>
                                </thead>
                                <tbody id="detail-table-body">
                                    <!-- Loaded via JS -->
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Data Injection -->
    <script>
        const rawData = 
'@

$part2 = @'
;

        const monthsES = {
            4: "Abril 2026",
            5: "Mayo 2026"
        };

        const daysOfWeekES = [
            "Domingo",
            "Lunes",
            "Martes",
            "Mi\u00e9rcoles",
            "Jueves",
            "Viernes",
            "S\u00e1bado"
        ];

        let activeMonth = 4; // default April
        
        // Multi-select Zonas Data Structures
        let allZones = [];
        let selectedZones = new Set();
        
        // Week Visibility Data Structures
        let activeMonthWeeksCount = 0;
        let visibleWeeks = new Set(); // holds active week indexes e.g. 0,1,2,3,4,5

        // Client Analysis Mode Data Structures
        let allClients = [];
        let activeClient = null; // holds name of client being analyzed

        let selectedDateStr = null; // selected date in DD/MM/YYYY
        let selectedZone = null; // selected zone for details
        let activeDayTransactions = [];

        // Preprocess raw data to parse JavaScript dates
        const processedDays = rawData.map(day => {
            const parts = day.Date.split('/');
            const dateObj = new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]));
            return {
                ...day,
                dateObj,
                monthNum: dateObj.getMonth() + 1,
                dayNum: dateObj.getDate(),
                weekdayNum: dateObj.getDay() // 0=Sunday, 1=Monday...
            };
        });

        // Initialize unique clients list for autocomplete search
        function initClientsList() {
            const clientsSet = new Set();
            processedDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Client) {
                        clientsSet.add(tx.Client);
                    }
                });
            });
            allClients = Array.from(clientsSet).sort();
        }

        // Initialize drop-down checkboxes for Zonas
        function initZones() {
            const zonesSet = new Set();
            processedDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Zone) {
                        zonesSet.add(tx.Zone);
                    }
                });
            });

            allZones = Array.from(zonesSet).sort();
            
            // By default, select all zones
            allZones.forEach(z => selectedZones.add(z));
            
            // Close dropdown when clicking outside
            document.addEventListener('click', function(event) {
                const menu = document.getElementById('multiselect-dropdown-menu');
                const container = document.getElementById('multiselect-zones');
                if (container && !container.contains(event.target)) {
                    menu.classList.remove('show');
                }
            });

            renderZonesOptions();
        }

        // Render drop-down zone checkboxes
        function renderZonesOptions() {
            const container = document.getElementById('multiselect-options-list');
            if (!container) return;

            const html = allZones.map(z => {
                const isChecked = selectedZones.has(z) ? 'checked' : '';
                return `
                    <label class="multiselect-option" onclick="stopPropagation(event)">
                        <input type="checkbox" value="${z}" ${isChecked} onchange="toggleZoneValue(this)">
                        <span>Zona ${z}</span>
                    </label>
                `;
            }).join('');
            
            container.innerHTML = html;
            updateMultiselectLabel();
        }

        function toggleZonesDropdown(event) {
            event.stopPropagation();
            const menu = document.getElementById('multiselect-dropdown-menu');
            menu.classList.toggle('show');
        }

        function stopPropagation(event) {
            event.stopPropagation();
        }

        function toggleZoneValue(checkbox) {
            const z = checkbox.value;
            if (checkbox.checked) {
                selectedZones.add(z);
            } else {
                selectedZones.delete(z);
            }
            
            updateMultiselectLabel();
            onFilterChange();
        }

        function selectAllZones(event) {
            if (event) event.stopPropagation();
            allZones.forEach(z => selectedZones.add(z));
            renderZonesOptions();
            onFilterChange();
        }

        function selectNoZones(event) {
            if (event) event.stopPropagation();
            selectedZones.clear();
            renderZonesOptions();
            onFilterChange();
        }

        function updateMultiselectLabel() {
            const labelEl = document.getElementById('multiselect-label');
            if (!labelEl) return;
            if (selectedZones.size === allZones.length) {
                labelEl.textContent = "Todas las Zonas (" + allZones.length + ")";
            } else if (selectedZones.size === 0) {
                labelEl.textContent = "Ninguna Zona seleccionada";
            } else {
                labelEl.textContent = selectedZones.size + " Zona" + (selectedZones.size > 1 ? "s" : "") + " selec.";
            }
        }

        // Global Client Search Autocomplete Handlers (Now placed inside right-hand Ficha card!)
        function onGlobalClientSearch(event) {
            const input = document.getElementById('client-search-global');
            const menu = document.getElementById('client-autocomplete-menu');
            const query = input.value.toLowerCase().trim();

            if (query.length === 0) {
                menu.classList.remove('show');
                return;
            }

            const matched = allClients.filter(c => c.toLowerCase().includes(query)).slice(0, 10);
            
            if (matched.length === 0) {
                menu.innerHTML = '<div style="padding: 8px 12px; color: var(--text-muted); font-size: 13px;">No se encontraron clientes</div>';
            } else {
                menu.innerHTML = matched.map(c => `
                    <div class="autocomplete-item" onclick="selectGlobalClient('${c.replace(/'/g, "\\'")}')">${c}</div>
                `).join('');
            }
            menu.classList.add('show');
        }

        function selectGlobalClient(clientName) {
            activeClient = clientName;
            document.getElementById('client-search-global').value = clientName;
            document.getElementById('client-autocomplete-menu').classList.remove('show');
            
            // Clear standard day selections
            selectedDateStr = null;
            selectedZone = null;
            
            // Hide zones filter block to avoid confusion
            document.getElementById('zone-filter-group').style.display = 'none';

            // Recalculate weeks visibility count for safety
            calculateMonthWeeksCount();

            // Refresh everything in Client Mode!
            renderDashboard();
            renderWeekPills();
            
            // Initialize detail pane with client monthly report
            renderClientReportCard();
        }

        function exitClientMode() {
            activeClient = null;
            document.getElementById('client-search-global').value = '';
            document.getElementById('client-autocomplete-menu').classList.remove('show');
            
            // Restore default KPIs titles
            document.getElementById('kpi-1-title').textContent = "Ventas del Mes Seleccionado";
            document.getElementById('kpi-2-title').textContent = "Pedidos del Mes Seleccionado";
            document.getElementById('kpi-3-title').textContent = "Ticket Promedio del Mes";
            
            // Show zones filter block again
            document.getElementById('zone-filter-group').style.display = 'flex';

            selectedDateStr = null;
            selectedZone = null;
            
            // Re-render Empty state including Top Clients quick select list
            document.getElementById('detail-empty').style.display = 'flex';
            document.getElementById('detail-content').style.display = 'none';
            renderTopClientsQuickSelect();

            renderDashboard();
            renderWeekPills();
        }

        // Close global autocomplete dropdown click listener
        document.addEventListener('click', function(event) {
            const menu = document.getElementById('client-autocomplete-menu');
            const input = document.getElementById('client-search-global');
            if (menu && !menu.contains(event.target) && event.target !== input) {
                menu.classList.remove('show');
            }
        });

        // Calculate and render Top 5 clients as clickable select list inside the details pane empty state card
        function renderTopClientsQuickSelect() {
            const container = document.getElementById('top-clients-quickselect');
            if (!container) return;

            // Compute top 5 client sales for the active month
            const clientSales = {};
            const filteredDays = processedDays.filter(d => d.monthNum === activeMonth);
            filteredDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Client) {
                        clientSales[tx.Client] = (clientSales[tx.Client] || 0) + tx.Amount;
                    }
                });
            });

            const sortedClients = Object.keys(clientSales)
                .map(c => ({ name: c, sales: clientSales[c] }))
                .sort((a, b) => b.sales - a.sales)
                .slice(0, 5);

            let html = `
                <p style="font-size:11px; font-weight:600; color:var(--text-muted); margin-bottom:8px; text-transform:uppercase; letter-spacing:0.5px;">Clientes Top del Mes (Haz clic para ver Ficha):</p>
                <div style="display:flex; flex-direction:column; gap:6px;">
            `;

            sortedClients.forEach((tc, idx) => {
                html += `
                    <div class="autocomplete-item" onclick="selectGlobalClient('${tc.name.replace(/'/g, "\\'")}')" style="border: 1px solid var(--border-color); background-color: var(--bg-color); display:flex; justify-content:space-between; align-items:center; border-radius:6px; font-weight:500; font-size:12px; padding:6px 12px;">
                        <span>#${idx+1} ${tc.name}</span>
                        <span style="color:var(--primary); font-weight:700;">${formatMoney(tc.sales)}</span>
                    </div>
                `;
            });
            html += '</div>';

            container.innerHTML = html;
        }

        // Helper: Format Currency
        function formatMoney(value) {
            return new Intl.NumberFormat('es-ES', { style: 'currency', currency: 'EUR' }).format(value);
        }

        // Helper: Format Number
        function formatNumber(value) {
            return new Intl.NumberFormat('es-ES').format(value);
        }

        // Toggle Dark/Light Mode
        function toggleTheme() {
            const isDark = document.body.getAttribute('data-theme') === 'dark';
            const newTheme = isDark ? 'light' : 'dark';
            document.body.setAttribute('data-theme', newTheme);
            document.querySelector('.theme-btn span').textContent = newTheme === 'dark' ? 'Modo Claro' : 'Modo Oscuro';
        }

        // Select active month
        function selectMonth(m) {
            activeMonth = m;
            document.querySelectorAll('.month-tab').forEach(el => el.classList.remove('active'));
            document.getElementById(`tab-month-${m}`).classList.add('active');
            
            // Clear details pane on month change
            selectedDateStr = null;
            selectedZone = null;
            document.getElementById('detail-empty').style.display = 'flex';
            document.getElementById('detail-content').style.display = 'none';
            renderTopClientsQuickSelect(); // update top clients list for the new month

            // Reset week toggles for the new month (default: all visible)
            visibleWeeks.clear();
            calculateMonthWeeksCount();
            for (let i = 0; i < activeMonthWeeksCount; i++) {
                visibleWeeks.add(i);
            }

            renderDashboard();
            renderWeekPills();

            if (activeClient) {
                renderClientReportCard();
            }
        }

        // On filter change
        function onFilterChange() {
            if (activeClient) return; // Zonas checkboxes disabled in Client Mode
            
            // Refresh active date details if selected and its zone is still active
            if (selectedDateStr && selectedZone) {
                if (selectedZones.has(selectedZone)) {
                    const activeEl = document.querySelector('.day-cell.active');
                    selectDay(activeEl, selectedDateStr, selectedZone);
                } else {
                    selectedDateStr = null;
                    selectedZone = null;
                    document.getElementById('detail-empty').style.display = 'flex';
                    document.getElementById('detail-content').style.display = 'none';
                    renderTopClientsQuickSelect();
                }
            }
            renderDashboard();
            renderWeekPills(); // week date ranges can shift slightly depending on active zones sales dates
        }

        // Pre-calculate number of week rows for current active month
        function calculateMonthWeeksCount() {
            const year = 2026;
            const daysInMonth = activeMonth === 4 ? 30 : 31;
            
            const firstDateObj = new Date(year, activeMonth - 1, 1);
            let firstDayWeekday = firstDateObj.getDay(); 
            
            let prependEmptyCount = firstDayWeekday === 0 ? 0 : firstDayWeekday - 1;
            
            // Gather all days except Sundays
            let operationalDaysCount = 0;
            for (let d = 1; d <= daysInMonth; d++) {
                const dateObj = new Date(year, activeMonth - 1, d);
                if (dateObj.getDay() !== 0) {
                    operationalDaysCount++;
                }
            }

            const totalGridCells = prependEmptyCount + operationalDaysCount;
            activeMonthWeeksCount = Math.ceil(totalGridCells / 6);
        }

        // Render week pills dynamic button controls
        function renderWeekPills() {
            const container = document.getElementById('week-toggles-list');
            
            const year = 2026;
            const daysInMonth = activeMonth === 4 ? 30 : 31;
            
            // Re-gather the exact week layout to extract date ranges for pills
            const firstDateObj = new Date(year, activeMonth - 1, 1);
            let firstDayWeekday = firstDateObj.getDay();
            let prependEmptyCount = firstDayWeekday === 0 ? 0 : firstDayWeekday - 1;

            const cells = [];
            // Prepend empties
            for (let i = 0; i < prependEmptyCount; i++) {
                cells.push(null);
            }
            // Add operational days
            for (let d = 1; d <= daysInMonth; d++) {
                const dateObj = new Date(year, activeMonth - 1, d);
                if (dateObj.getDay() !== 0) {
                    cells.push({
                        dayNum: d,
                        dateStr: `${String(d).padStart(2, '0')}/${String(activeMonth).padStart(2, '0')}/2026`
                    });
                }
            }

            // Chunk into weeks (6 cells each)
            const weeks = [];
            for (let i = 0; i < cells.length; i += 6) {
                weeks.push(cells.slice(i, i + 6));
            }

            // Generate pill button HTML
            const pillsHtml = weeks.map((week, index) => {
                const dayCells = week.filter(c => c !== null);
                let rangeText = "";
                if (dayCells.length > 0) {
                    const startDay = dayCells[0].dayNum;
                    const endDay = dayCells[dayCells.length - 1].dayNum;
                    rangeText = `(${String(startDay).padStart(2, '0')}/${String(activeMonth).padStart(2, '0')} - ${String(endDay).padStart(2, '0')}/${String(activeMonth).padStart(2, '0')})`;
                }

                const isActive = visibleWeeks.has(index) ? 'active' : '';

                return `
                    <button class="week-pill ${isActive}" onclick="toggleWeekVisibility(${index})">
                        <svg style="width: 14px; height: 14px; fill: var(--text-muted);" viewBox="0 0 24 24">
                            <path d="M12,9A3,3 0 0,0 9,12A3,3 0 0,0 12,15A3,3 0 0,0 15,12A3,3 0 0,0 12,9M12,4.5C7,4.5 2.73,7.61 1,12C2.73,16.39 7,19.5 12,19.5C17,19.5 21.27,16.39 23,12C21.27,7.61 17,4.5 12,4.5M12,17A5,5 0 0,1 7,12A5,5 0 0,1 12,7A5,5 0 0,1 17,12A5,5 0 0,1 12,17Z" />
                        </svg>
                        <span>Semana ${index + 1} ${rangeText}</span>
                    </button>
                `;
            }).join('');

            container.innerHTML = pillsHtml;
        }

        // Toggle visibility of a week row
        function toggleWeekVisibility(idx) {
            if (visibleWeeks.has(idx)) {
                if (visibleWeeks.size > 1) {
                    visibleWeeks.delete(idx);
                }
            } else {
                visibleWeeks.add(idx);
            }
            
            // Redraw pills
            renderWeekPills();
            
            // Direct DOM hide/show of the rows
            if (activeClient) {
                // In Client Mode, hide row of the dedicated client calendar
                const rowEl = document.getElementById(`week-row-client-${idx}`);
                if (rowEl) {
                    rowEl.style.display = visibleWeeks.has(idx) ? 'grid' : 'none';
                }
            } else {
                // In General Mode, hide row across all rendered zone calendars
                selectedZones.forEach(zone => {
                    const rowEl = document.getElementById(`week-row-${zone}-${idx}`);
                    if (rowEl) {
                        rowEl.style.display = visibleWeeks.has(idx) ? 'grid' : 'none';
                    }
                });
            }
        }

        // Render entire screen
        function renderDashboard() {
            const container = document.getElementById('calendars-container');
            
            // 1. RENDER IN INDIVIDUAL CLIENT MODE
            if (activeClient) {
                renderClientModeDashboard(container);
                return;
            }

            // 2. RENDER IN GENERAL ZONES MODE
            if (selectedZones.size === 0) {
                container.innerHTML = `
                    <div class="calendar-card" style="text-align: center; padding: 48px; color: var(--text-muted);">
                        <h3>Ninguna Zona Seleccionada</h3>
                        <p style="margin-top: 8px; font-size:14px;">Por favor, despliega el panel de zonas superior y selecciona las zonas que deseas analizar.</p>
                    </div>
                `;
                // Clear monthly KPIs
                document.getElementById('kpi-month-sales').textContent = formatMoney(0);
                document.getElementById('kpi-month-tx').textContent = 0;
                document.getElementById('kpi-month-avg').textContent = formatMoney(0);
                return;
            }

            // Render general monthly KPIs
            const filteredDays = processedDays.filter(d => d.monthNum === activeMonth);
            let totalSales = 0;
            let totalTx = 0;
            
            filteredDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (selectedZones.has(tx.Zone)) {
                        totalSales += tx.Amount;
                        totalTx++;
                    }
                });
            });

            document.getElementById('kpi-month-sales').textContent = formatMoney(totalSales);
            document.getElementById('kpi-month-tx').textContent = formatNumber(totalTx);
            document.getElementById('kpi-month-avg').textContent = totalTx > 0 ? formatMoney(totalSales / totalTx) : '€0,00';

            // Generate Separate Stacked Calendars
            const sortedActiveZones = Array.from(selectedZones).sort();
            let calendarsHtml = '';

            sortedActiveZones.forEach(zone => {
                let zoneMaxSales = 0;
                filteredDays.forEach(day => {
                    let sales = 0;
                    day.Transactions.forEach(tx => {
                        if (tx.Zone === zone) sales += tx.Amount;
                    });
                    if (sales > zoneMaxSales) zoneMaxSales = sales;
                });

                let zoneMonthSales = 0;
                let zoneMonthTx = 0;
                filteredDays.forEach(day => {
                    day.Transactions.forEach(tx => {
                        if (tx.Zone === zone) {
                            zoneMonthSales += tx.Amount;
                            zoneMonthTx++;
                        }
                    });
                });

                const gridHtml = buildGridForZone(zone, zoneMaxSales);

                calendarsHtml += `
                    <div class="calendar-card" id="calendar-card-${zone}">
                        <div class="calendar-header">
                            <div class="calendar-month-name">
                                <span class="badge badge-primary" style="font-size:14px; padding:6px 12px; margin-right:12px; border-radius:6px; font-weight:700;">Zona ${zone}</span>
                                <span style="font-size:13px; font-weight:600; color:var(--text-muted);">${formatMoney(zoneMonthSales)} | ${zoneMonthTx} repartos en total</span>
                            </div>
                            <div class="non-delivery-notice">
                                Los domingos no se realizan repartos
                            </div>
                        </div>

                        <div class="calendar-grid">
                            <div class="calendar-header-row">
                                <div class="weekday-label">Lunes</div>
                                <div class="weekday-label">Martes</div>
                                <div class="weekday-label">Mi&eacute;rcoles</div>
                                <div class="weekday-label">Jueves</div>
                                <div class="weekday-label">Viernes</div>
                                <div class="weekday-label">S&aacute;bado</div>
                            </div>
                            <div id="calendar-rows-${zone}">
                                ${gridHtml}
                            </div>
                        </div>
                    </div>
                `;
            });

            container.innerHTML = calendarsHtml;
        }

        // Render dynamic Monday-Saturday grid for a specific zone
        function buildGridForZone(zone, maxSales) {
            const year = 2026;
            const daysInMonth = activeMonth === 4 ? 30 : 31;
            
            const dates = [];
            for (let d = 1; d <= daysInMonth; d++) {
                const dateObj = new Date(year, activeMonth - 1, d);
                if (dateObj.getDay() !== 0) { // Skip Sunday
                    dates.push({
                        dayNum: d,
                        dateObj: dateObj,
                        dateStr: `${String(d).padStart(2, '0')}/${String(activeMonth).padStart(2, '0')}/2026`
                    });
                }
            }

            const firstDateObj = new Date(year, activeMonth - 1, 1);
            let firstDayWeekday = firstDateObj.getDay();
            let prependEmptyCount = firstDayWeekday === 0 ? 0 : firstDayWeekday - 1;

            const cellElements = [];

            // Prepend empty cells
            for (let i = 0; i < prependEmptyCount; i++) {
                cellElements.push('<div class="day-cell empty"></div>');
            }

            // Render operational day cells for this specific zone
            dates.forEach(d => {
                const dayRecord = processedDays.find(pd => pd.Date === d.dateStr);
                
                let daySales = 0;
                let dayTxCount = 0;

                if (dayRecord) {
                    dayRecord.Transactions.forEach(tx => {
                        if (tx.Zone === zone) {
                            daySales += tx.Amount;
                            dayTxCount++;
                        }
                    });
                }

                // Determine Heatmap color level
                let hmClass = 'hm-empty';
                if (daySales > 0 && maxSales > 0) {
                    const ratio = daySales / maxSales;
                    if (ratio <= 0.2) hmClass = 'hm-level-1';
                    else if (ratio <= 0.4) hmClass = 'hm-level-2';
                    else if (ratio <= 0.6) hmClass = 'hm-level-3';
                    else if (ratio <= 0.8) hmClass = 'hm-level-4';
                    else hmClass = 'hm-level-5';
                }

                const isActive = (selectedDateStr === d.dateStr && selectedZone === zone) ? 'active' : '';

                const cellHtml = `
                    <div class="day-cell ${hmClass} ${isActive}" id="cell-${zone}-${d.dateStr}" onclick="selectDay(this, '${d.dateStr}', '${zone}')">
                        <div class="day-number">${d.dayNum}</div>
                        <div class="day-volume">${daySales > 0 ? formatMoney(daySales) : ''}</div>
                        <div class="day-tx-count">${dayTxCount > 0 ? `${dayTxCount} ped.` : ''}</div>
                    </div>
                `;
                cellElements.push(cellHtml);
            });

            // Chunk cells into weeks of 6 columns
            const weeks = [];
            for (let i = 0; i < cellElements.length; i += 6) {
                weeks.push(cellElements.slice(i, i + 6));
            }

            // Construct grid rows html
            let gridHtml = '';
            weeks.forEach((week, index) => {
                const isVisible = visibleWeeks.has(index);
                const displayStyle = isVisible ? 'grid' : 'none';
                
                gridHtml += `
                    <div class="calendar-row week-row-${index}" id="week-row-${zone}-${index}" style="display: ${displayStyle}">
                        ${week.join('')}
                    </div>
                `;
            });

            return gridHtml;
        }

        // Render Dashboard in Client Mode
        function renderClientModeDashboard(container) {
            // Update upper KPIs titles
            document.getElementById('kpi-1-title').textContent = "Compras Totales del Cliente";
            document.getElementById('kpi-2-title').textContent = "Pedidos de este Cliente";
            document.getElementById('kpi-3-title').textContent = "Ticket Medio del Cliente";

            // Calculate monthly stats for this specific client
            const filteredDays = processedDays.filter(d => d.monthNum === activeMonth);
            let clientMonthSales = 0;
            let clientMonthTx = 0;
            
            filteredDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Client === activeClient) {
                        clientMonthSales += tx.Amount;
                        clientMonthTx++;
                    }
                });
            });

            document.getElementById('kpi-month-sales').textContent = formatMoney(clientMonthSales);
            document.getElementById('kpi-month-tx').textContent = formatNumber(clientMonthTx);
            document.getElementById('kpi-month-avg').textContent = clientMonthTx > 0 ? formatMoney(clientMonthSales / clientMonthTx) : '€0,00';

            // Find maximum daily sale of this client in the month to calibrate heatmap
            let clientMaxSales = 0;
            filteredDays.forEach(day => {
                let sales = 0;
                day.Transactions.forEach(tx => {
                    if (tx.Client === activeClient) sales += tx.Amount;
                });
                if (sales > clientMaxSales) clientMaxSales = sales;
            });

            const gridHtml = buildGridForClient(clientMaxSales);

            container.innerHTML = `
                <div class="calendar-card" id="calendar-card-client">
                    <div class="calendar-header">
                        <div class="calendar-month-name">
                            <span class="badge badge-primary" style="background-color: #a855f7; color: white; font-size:14px; padding:6px 12px; border-radius:6px; font-weight:700;">Cliente: ${activeClient}</span>
                            <button onclick="exitClientMode()" class="theme-btn" style="padding: 6px 12px; font-size:12px; height:auto; background:var(--bg-color); border-color:var(--border-color); color:var(--text-main); margin-left:12px;">Cerrar Ficha</button>
                        </div>
                        <div class="non-delivery-notice">
                            Visualización de días de pedidos del cliente (Heatmap Calibrado)
                        </div>
                    </div>

                    <div class="calendar-grid">
                        <div class="calendar-header-row">
                            <div class="weekday-label">Lunes</div>
                            <div class="weekday-label">Martes</div>
                            <div class="weekday-label">Mi&eacute;rcoles</div>
                            <div class="weekday-label">Jueves</div>
                            <div class="weekday-label">Viernes</div>
                            <div class="weekday-label">S&aacute;bado</div>
                        </div>
                        <div id="calendar-rows-client">
                            ${gridHtml}
                        </div>
                    </div>
                </div>
            `;
        }

        // Render dynamic Monday-Saturday grid for active client
        function buildGridForClient(maxSales) {
            const year = 2026;
            const daysInMonth = activeMonth === 4 ? 30 : 31;
            
            const dates = [];
            for (let d = 1; d <= daysInMonth; d++) {
                const dateObj = new Date(year, activeMonth - 1, d);
                if (dateObj.getDay() !== 0) {
                    dates.push({
                        dayNum: d,
                        dateObj: dateObj,
                        dateStr: `${String(d).padStart(2, '0')}/${String(activeMonth).padStart(2, '0')}/2026`
                    });
                }
            }

            const firstDateObj = new Date(year, activeMonth - 1, 1);
            let firstDayWeekday = firstDateObj.getDay();
            let prependEmptyCount = firstDayWeekday === 0 ? 0 : firstDayWeekday - 1;

            const cellElements = [];

            // Prepend empty cells
            for (let i = 0; i < prependEmptyCount; i++) {
                cellElements.push('<div class="day-cell empty"></div>');
            }

            // Render operational day cells for active client
            dates.forEach(d => {
                const dayRecord = processedDays.find(pd => pd.Date === d.dateStr);
                
                let daySales = 0;
                let dayTxCount = 0;
                let zonesSet = new Set();

                if (dayRecord) {
                    dayRecord.Transactions.forEach(tx => {
                        if (tx.Client === activeClient) {
                            daySales += tx.Amount;
                            dayTxCount++;
                            if (tx.Zone) {
                                zonesSet.add(tx.Zone);
                            }
                        }
                    });
                }

                // Determine Heatmap color level specifically for this client sales
                let hmClass = 'hm-empty';
                if (daySales > 0 && maxSales > 0) {
                    const ratio = daySales / maxSales;
                    if (ratio <= 0.2) hmClass = 'hm-level-1';
                    else if (ratio <= 0.4) hmClass = 'hm-level-2';
                    else if (ratio <= 0.6) hmClass = 'hm-level-3';
                    else if (ratio <= 0.8) hmClass = 'hm-level-4';
                    else hmClass = 'hm-level-5';
                }

                const isActive = selectedDateStr === d.dateStr ? 'active' : '';

                // Compact labels: e.g. "Zona 09"
                const zonesText = zonesSet.size > 0 ? "Zona " + Array.from(zonesSet).join(',') : "";

                const cellHtml = `
                    <div class="day-cell ${hmClass} ${isActive}" id="cell-client-${d.dateStr}" onclick="selectDayForClient(this, '${d.dateStr}')">
                        <div class="day-number">${d.dayNum}</div>
                        <div class="day-volume">${daySales > 0 ? formatMoney(daySales) : ''}</div>
                        <div class="day-tx-count" style="font-size: 9px; font-weight:600; color:var(--text-muted);">${daySales > 0 ? zonesText : ''}</div>
                    </div>
                `;
                cellElements.push(cellHtml);
            });

            // Chunk cells into weeks of 6 columns
            const weeks = [];
            for (let i = 0; i < cellElements.length; i += 6) {
                weeks.push(cellElements.slice(i, i + 6));
            }

            // Construct grid rows html
            let gridHtml = '';
            weeks.forEach((week, index) => {
                const isVisible = visibleWeeks.has(index);
                const displayStyle = isVisible ? 'grid' : 'none';
                
                gridHtml += `
                    <div class="calendar-row week-row-${index}" id="week-row-client-${index}" style="display: ${displayStyle}">
                        ${week.join('')}
                    </div>
                `;
            });

            return gridHtml;
        }

        // Click handler for day cell in Client Analysis Mode
        function selectDayForClient(element, dateStr) {
            selectedDateStr = dateStr;
            
            // Remove active style from all day cells
            document.querySelectorAll('.day-cell').forEach(el => el.classList.remove('active'));
            if (element) {
                element.classList.add('active');
            } else {
                const cell = document.getElementById(`cell-client-${dateStr}`);
                if (cell) cell.classList.add('active');
            }

            // Re-render client visual report with this day selected
            renderClientReportCard(dateStr);
        }

        // Calculate a natural language description of client's delivery habits
        function getClientDeliveryHabitsText(allClientOrders) {
            const counts = {
                "Domingo": 0,
                "Lunes": 0,
                "Martes": 0,
                "Mi\u00e9rcoles": 0,
                "Jueves": 0,
                "Viernes": 0,
                "S\u00e1bado": 0
            };
            
            allClientOrders.forEach(order => {
                const parts = order.date.split('/');
                const deliveryDate = new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]));
                
                // Pedido es el día anterior
                const orderDate = new Date(deliveryDate);
                orderDate.setDate(deliveryDate.getDate() - 1);
                
                const dayName = daysOfWeekES[orderDate.getDay()];
                if (counts[dayName] !== undefined) {
                    counts[dayName]++;
                }
            });
            
            const deliveryDayOfOrderDay = {
                "Domingo": "Lunes",
                "Lunes": "Martes",
                "Martes": "Mi\u00e9rcoles",
                "Mi\u00e9rcoles": "Jueves",
                "Jueves": "Viernes",
                "Viernes": "S\u00e1bado",
                "S\u00e1bado": "Lunes"
            };
            
            const pluralDays = {
                "Domingo": "Domingos",
                "Lunes": "Lunes",
                "Martes": "Martes",
                "Mi\u00e9rcoles": "Mi\u00e9rcoles",
                "Jueves": "Jueves",
                "Viernes": "Viernes",
                "S\u00e1bado": "S\u00e1bados"
            };
            
            // Sort days by order counts descending
            const sortedDays = Object.keys(counts)
                .map(day => ({ name: day, count: counts[day] }))
                .filter(d => d.count > 0)
                .sort((a, b) => b.count - a.count);
                
            if (sortedDays.length === 0) {
                return "Este cliente no registra pedidos en el historial.";
            }
            
            let totalOrders = 0;
            sortedDays.forEach(d => totalOrders += d.count);
            
            // Filter significant days to avoid minor one-off outliers
            const significantDays = sortedDays.filter(d => {
                if (totalOrders >= 5) {
                    return d.count >= 2; // must have at least 2 orders if total orders is large
                }
                return true;
            });
            
            if (significantDays.length === 0) {
                significantDays.push(sortedDays[0]);
            }
            
            if (significantDays.length === 1) {
                const oDay = significantDays[0].name;
                const dDay = deliveryDayOfOrderDay[oDay];
                const pDay = pluralDays[oDay];
                return `Este cliente suele <strong>pedir</strong> exclusivamente los <strong>${pDay}</strong> (se le sirve el <strong>${dDay}</strong>, con ${significantDays[0].count} de ${totalOrders} pedidos en total).`;
            }
            
            const topDay = significantDays[0];
            const secondDay = significantDays[1];
            const topDelivery = deliveryDayOfOrderDay[topDay.name];
            const secondDelivery = deliveryDayOfOrderDay[secondDay.name];
            const topPlural = pluralDays[topDay.name];
            const secondPlural = pluralDays[secondDay.name];
            
            if (significantDays.length === 2) {
                return `Este cliente suele <strong>pedir</strong> principalmente los <strong>${topPlural}</strong> (se le sirve el ${topDelivery}) y los <strong>${secondPlural}</strong> (se le sirve el ${secondDelivery}).`;
            }
            
            const thirdDay = significantDays[2];
            const thirdDelivery = deliveryDayOfOrderDay[thirdDay.name];
            const thirdPlural = pluralDays[thirdDay.name];
            return `Este cliente suele <strong>pedir</strong> principalmente los <strong>${topPlural}</strong> (se le sirve el ${topDelivery}), <strong>${secondPlural}</strong> (se le sirve el ${secondDelivery}) y los <strong>${thirdPlural}</strong> (se le sirve el ${thirdDelivery}).`;
        }

        // Render client dedicated visual report card (Right-hand sticky pane)
        function renderClientReportCard(highlightDate = null) {
            document.getElementById('detail-empty').style.display = 'none';
            const detailContent = document.getElementById('detail-content');
            detailContent.style.display = 'flex';

            // Calculate client general stats for the selected month
            const filteredDays = processedDays.filter(d => d.monthNum === activeMonth);
            let clientTotalSales = 0;
            let clientTotalTx = 0;
            let clientZonesSet = new Set();
            let allClientOrders = [];

            filteredDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Client === activeClient) {
                        clientTotalSales += tx.Amount;
                        clientTotalTx++;
                        if (tx.Zone) {
                            clientZonesSet.add(tx.Zone);
                        }
                        allClientOrders.push({
                            date: day.Date,
                            dateObj: day.dateObj,
                            zone: tx.Zone,
                            amount: tx.Amount
                        });
                    }
                });
            });

            // Sort orders chronologically
            allClientOrders.sort((a, b) => b.dateObj - a.dateObj);

            // Update details header
            document.getElementById('detail-date').textContent = `Ficha: ${activeClient}`;
            
            // Gather client orders across ALL months for the habits summary to be precise
            let allTimeClientOrders = [];
            processedDays.forEach(day => {
                day.Transactions.forEach(tx => {
                    if (tx.Client === activeClient) {
                        allTimeClientOrders.push({
                            date: day.Date,
                            dateObj: day.dateObj,
                            zone: tx.Zone,
                            amount: tx.Amount
                        });
                    }
                });
            });

            // Calculate and display delivery habits text summary using all-time data!
            const habitsText = getClientDeliveryHabitsText(allTimeClientOrders);
            
            // Create a styled warning/info card for habits summary inside the header
            document.getElementById('detail-weekday').innerHTML = `
                <div style="background-color: rgba(168, 85, 247, 0.08); border-left: 4px solid #a855f7; padding: 10px 14px; border-radius: 6px; margin: 12px 0 0 0; font-size:12.5px; color:var(--text-main); font-weight: 500; line-height:1.45;">
                    <svg style="width:14px; height:14px; fill:#a855f7; display:inline-block; vertical-align:text-bottom; margin-right:6px;" viewBox="0 0 24 24">
                        <path d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M12,4A8,8 0 0,1 20,12A8,8 0 0,1 12,20A8,8 0 0,1 4,12A8,8 0 0,1 12,4M11,10H13V18H11V10M11,6H13V8H11V6Z" />
                    </svg>
                    ${habitsText}
                </div>
            `;

            // Update details KPIs titles & values
            document.getElementById('detail-sales-title').textContent = "Total Compras del Mes";
            document.getElementById('detail-sales-val').textContent = formatMoney(clientTotalSales);
            document.getElementById('detail-sales-val').style.color = '#a855f7'; // elegant client purple

            document.getElementById('detail-tx-title').textContent = "Repartos Recibidos";
            document.getElementById('detail-tx-val').textContent = `${clientTotalTx} pedidos (Zonas: ${Array.from(clientZonesSet).join(', ')})`;

            // Modify client table headers
            const tableHeaders = document.getElementById('detail-table-headers');
            tableHeaders.innerHTML = `
                <th>D&iacute;a Pedido</th>
                <th>D&iacute;a Entrega</th>
                <th style="width: 70px;">Zona</th>
                <th style="text-align: right; width: 100px;">Importe (&euro;)</th>
            `;

            // Hide search input local filter for client mode (it's not needed as it shows only their orders)
            document.getElementById('detail-search-wrapper').style.display = 'none';

            // Render all purchases list
            const tbody = document.getElementById('detail-table-body');
            
            if (allClientOrders.length === 0) {
                tbody.innerHTML = '<tr><td colspan="4" style="text-align:center; color:var(--text-muted); padding:30px;">Este cliente no registra pedidos en este mes.</td></tr>';
                return;
            }

            tbody.innerHTML = allClientOrders.map(order => {
                const isHighlighted = highlightDate === order.date ? 'style="background-color: rgba(168, 85, 247, 0.15); font-weight:600;"' : '';
                
                // Pedido es el día anterior
                const orderDateObj = new Date(order.dateObj);
                orderDateObj.setDate(order.dateObj.getDate() - 1);
                const orderDateStr = `${String(orderDateObj.getDate()).padStart(2, '0')}/${String(orderDateObj.getMonth() + 1).padStart(2, '0')}/2026`;
                
                return `
                    <tr ${isHighlighted} onclick="selectDayForClient(null, '${order.date}')" style="cursor:pointer;">
                        <td style="font-weight:600; color: var(--text-muted);">${orderDateStr}</td>
                        <td style="font-weight:600;">${order.date}</td>
                        <td><span class="badge" style="background-color: #f3e8ff; color: #a855f7;">Zona ${order.zone}</span></td>
                        <td style="text-align: right; font-weight: 700;">${formatMoney(order.amount)}</td>
                    </tr>
                `;
            }).join('');
        }

        // Select Day and load details in GENERAL stacked mode
        function selectDay(element, dateStr, zone) {
            selectedDateStr = dateStr;
            selectedZone = zone;
            
            // Remove active style from all cells across all calendars
            document.querySelectorAll('.day-cell').forEach(el => el.classList.remove('active'));
            
            if (element) {
                element.classList.add('active');
            } else {
                const cell = document.getElementById(`cell-${zone}-${dateStr}`);
                if (cell) cell.classList.add('active');
            }

            const dayRecord = processedDays.find(pd => pd.Date === dateStr);
            
            const parts = dateStr.split('/');
            const dateObj = new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]));
            const weekdayName = daysOfWeekES[dateObj.getDay()];

            document.getElementById('detail-empty').style.display = 'none';
            const detailContent = document.getElementById('detail-content');
            detailContent.style.display = 'flex';

            // Show search bar again for general mode
            document.getElementById('detail-search-wrapper').style.display = 'block';

            // Restore general table headers
            const tableHeaders = document.getElementById('detail-table-headers');
            tableHeaders.innerHTML = `
                <th>Cliente (Ficha)</th>
                <th style="width: 70px;">Zona</th>
                <th style="text-align: right; width: 110px;">Importe (&euro;)</th>
            `;

            // Dynamic header
            document.getElementById('detail-date').textContent = `D\u00eda: ${dateStr} | Zona ${zone}`;
            document.getElementById('detail-weekday').textContent = `${weekdayName} | Desglose de Operaciones`;

            let daySales = 0;
            let dayTxCount = 0;
            let txs = [];

            if (dayRecord) {
                dayRecord.Transactions.forEach(tx => {
                    if (tx.Zone === zone) {
                        daySales += tx.Amount;
                        dayTxCount++;
                        txs.push(tx);
                    }
                });
            }

            document.getElementById('detail-sales-title').textContent = "Ventas del D\u00eda en esta Zona";
            document.getElementById('detail-sales-val').textContent = formatMoney(daySales);
            document.getElementById('detail-sales-val').style.color = 'var(--primary)'; // restore default primary blue

            document.getElementById('detail-tx-title').textContent = "Pedidos del D\u00eda";
            document.getElementById('detail-tx-val').textContent = `${dayTxCount} ${dayTxCount === 1 ? 'pedido' : 'pedidos'}`;

            // Save active transactions in variable for searching
            activeDayTransactions = txs.sort((a, b) => b.Amount - a.Amount);
            document.getElementById('client-search').value = '';

            renderClientTable(activeDayTransactions);
        }

        // Render client breakdown table (100% exclusive to clicked day and clicked zone)
        function renderClientTable(txs) {
            const tbody = document.getElementById('detail-table-body');
            
            if (txs.length === 0) {
                tbody.innerHTML = '<tr><td colspan="3" style="text-align:center; color:var(--text-muted); padding: 30px;">No se registraron repartos en esta zona y fecha.</td></tr>';
                return;
            }

            tbody.innerHTML = txs.map(tx => `
                <tr onclick="selectGlobalClient('${tx.Client.replace(/'/g, "\\'")}')" style="cursor:pointer;" title="Hacer clic para abrir ficha de este cliente">
                    <td style="font-weight: 600; color: var(--primary); text-decoration: underline; text-decoration-color: rgba(59, 130, 246, 0.2);">${tx.Client}</td>
                    <td><span class="badge badge-primary">Zona ${tx.Zone}</span></td>
                    <td style="text-align: right; font-weight: 600;">${formatMoney(tx.Amount)}</td>
                </tr>
            `).join('');
        }

        // Filter clients locally inside active day details (General Mode)
        function filterClients() {
            const query = document.getElementById('client-search').value.toLowerCase();
            const filtered = activeDayTransactions.filter(tx => 
                tx.Client.toLowerCase().includes(query) || 
                tx.Zone.toLowerCase().includes(query)
            );
            renderClientTable(filtered);
        }

        // On Load
        window.addEventListener('DOMContentLoaded', () => {
            initZones();
            initClientsList();
            calculateMonthWeeksCount();
            
            // Default all weeks visible
            for (let i = 0; i < activeMonthWeeksCount; i++) {
                visibleWeeks.add(i);
            }
            
            renderDashboard();
            renderWeekPills();
            
            // Re-render Empty state including Top Clients quick select list
            renderTopClientsQuickSelect();
            
            // Auto-select first zone and its biggest day to initialize detail pane beautifully
            const firstZone = allZones[0];
            if (firstZone) {
                let maxSalesOverall = 0;
                let topDateStr = null;
                
                processedDays.forEach(day => {
                    let sales = 0;
                    day.Transactions.forEach(tx => {
                        if (tx.Zone === firstZone) sales += tx.Amount;
                    });
                    if (sales > maxSalesOverall) {
                        maxSalesOverall = sales;
                        topDateStr = day.Date;
                    }
                });

                if (topDateStr) {
                    const parts = topDateStr.split('/');
                    const month = parseInt(parts[1]);
                    selectMonth(month);
                    
                    const cell = document.getElementById(`cell-${firstZone}-${topDateStr}`);
                    selectDay(cell, topDateStr, firstZone);
                }
            }
        });
    </script>
</body>
</html>
'@

$completeHtml = $part1 + $rawJson + $part2
# Save using .NET File stream with pure UTF-8 encoding (No BOM) which is universally loaded by browsers!
[System.IO.File]::WriteAllText($outputPath, $completeHtml, [System.Text.Encoding]::UTF8)
Write-Host "Calendar Dashboard generated successfully at $outputPath"
