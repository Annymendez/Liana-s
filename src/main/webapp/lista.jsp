<%--
    Catálogo — chips de marcas arriba, filtros ocultos en hover/click.
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.LinkedHashMap, java.util.LinkedHashSet, java.util.Map, model.Producto, model.Persona, util.Html" %>
<%!
    private static String urlSin(String ctx, Map<String, String> filtros, String... quitar) {
        java.util.Set<String> omitir = new java.util.HashSet<>(java.util.Arrays.asList(quitar));
        StringBuilder sb = new StringBuilder(ctx).append("/producto?accion=listar");
        for (Map.Entry<String, String> e : filtros.entrySet()) {
            if (omitir.contains(e.getKey()) || e.getValue().isEmpty()) continue;
            sb.append('&').append(e.getKey()).append('=').append(Html.url(e.getValue()));
        }
        return sb.toString();
    }
    private static String attr(jakarta.servlet.ServletRequest req, String nombre) {
        Object v = req.getAttribute(nombre);
        return v == null ? "" : v.toString();
    }
%>
<%
    List<Producto> productos = (List<Producto>) request.getAttribute("productos");
    if (productos == null) productos = new java.util.ArrayList<>();
    String msg   = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
    String ctx   = request.getContextPath();

    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo() : "";

    if (error == null) error = request.getParameter("error");
    boolean hayFiltro = Boolean.TRUE.equals(request.getAttribute("hayFiltro"));

    Map<String, String> filtros = new LinkedHashMap<>();
    filtros.put("buscar",    attr(request, "buscar"));
    filtros.put("categoria", attr(request, "categoria"));
    filtros.put("marca",     attr(request, "marca"));
    filtros.put("talla",     attr(request, "talla"));
    filtros.put("color",     attr(request, "color"));
    filtros.put("min",       attr(request, "min"));
    filtros.put("max",       attr(request, "max"));
    filtros.put("estado",    attr(request, "estado"));
    String filtroOrden = attr(request, "orden");

    String fBuscar = filtros.get("buscar"), fCat    = filtros.get("categoria"),
           fMarca  = filtros.get("marca"),  fTalla  = filtros.get("talla"),
           fColor  = filtros.get("color"),  fMin    = filtros.get("min"),
           fMax    = filtros.get("max"),    fEstado = filtros.get("estado");

    String[] categorias = {"Ropa", "Bolsos", "Accesorios", "Zapatos", "Joyería"};

    // Marcas desde la BD (todas las activas con stock, independiente del filtro actual)
    @SuppressWarnings("unchecked")
    List<String> marcasSet = (List<String>) request.getAttribute("todasMarcas");
    if (marcasSet == null) marcasSet = new java.util.ArrayList<>();

    // Filtros opcionales que puede enviar el servlet
    List<String> tallas  = (List<String>) request.getAttribute("tallas");
    List<String> colores = (List<String>) request.getAttribute("colores");

    int nFiltros = 0;
    for (String v : filtros.values()) if (!v.isEmpty()) nFiltros++;

    int totalProductos = productos.size();

    List<model.CarritoItem> carrito = (List<model.CarritoItem>) session.getAttribute("carrito");
    int carritoSize = (carrito != null) ? carrito.size() : 0;

    int idVendedorUsuario = -1;
    if ("vendedor".equals(rol)) {
        try {
            dao.VendedorDAO vdao = new dao.VendedorDAO();
            model.Vendedor vActual = vdao.buscarPorIdPersona(usuario.getIdPersona());
            if (vActual != null) idVendedorUsuario = vActual.getIdVendedor();
        } catch (Exception ignored) {}
    }

    String[] etiquetasTexto = { "buscar", "categoria", "marca", "talla", "color", "estado" };
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Catálogo</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ═══════════════════════════════════════════
       SUBHEADER
    ═══════════════════════════════════════════ */
    .cat-subheader {
      border-bottom: 1px solid #e8e8e8;
      padding: 28px 48px 20px;
      display: flex;
      align-items: flex-end;
      justify-content: space-between;
      gap: 16px;
    }
    .cat-subheader-left p {
      font-size: 10px;
      letter-spacing: .14em;
      text-transform: uppercase;
      color: #aaa;
      margin: 0 0 4px;
    }
    .cat-subheader-left h1 {
      font-family: 'IM Fell English', serif;
      font-style: italic;
      font-size: 32px;
      font-weight: 400;
      color: #111;
      margin: 0;
    }
    .cat-subheader-right {
      display: flex;
      align-items: center;
      gap: 16px;
    }
    .cat-count { font-size: 12px; color: #aaa; }
    .cat-count strong { color: #111; }

    /* ═══════════════════════════════════════════
       BARRA DE MARCAS + BOTÓN FILTROS
    ═══════════════════════════════════════════ */
    .marca-bar {
      border-bottom: 1px solid #e8e8e8;
      padding: 0 48px;
      display: flex;
      align-items: stretch;
      position: relative;
      overflow: visible;
    }

    .marca-chip {
      padding: 0 20px;
      height: 44px;
      display: inline-flex;
      align-items: center;
      font-size: 11px;
      font-weight: 500;
      letter-spacing: .1em;
      text-transform: uppercase;
      color: #999;
      text-decoration: none;
      border-bottom: 2px solid transparent;
      white-space: nowrap;
      flex-shrink: 0;
      transition: color .15s, border-color .15s;
    }
    .marca-chip:hover { color: #111; text-decoration: none; }
    .marca-chip.activo { color: #111; border-bottom-color: #111; }

    /* ── MEGA-MENU DE MARCAS (estilo Rewind) ── */
    .marcas-wrap {
      position: static;   /* el mega-menu se posiciona relativo al body */
      display: flex;
      align-items: stretch;
    }
    .marcas-btn {
      display: inline-flex;
      align-items: center;
      gap: 6px;
      height: 44px;
      padding: 0 20px;
      font-size: 11px;
      font-weight: 500;
      letter-spacing: .1em;
      text-transform: uppercase;
      color: #999;
      cursor: pointer;
      border: none;
      background: transparent;
      border-bottom: 2px solid transparent;
      transition: color .15s, border-color .15s;
      flex-shrink: 0;
      white-space: nowrap;
    }
    .marcas-btn svg { width: 9px; height: 9px; transition: transform .2s; }
    .marcas-wrap:hover .marcas-btn,
    .marcas-btn.activo { color: #111; border-bottom-color: #111; }
    .marcas-wrap:hover .marcas-btn svg { transform: rotate(180deg); }
    .marcas-btn .marca-dot {
      width: 5px; height: 5px;
      background: #111; border-radius: 50%;
    }

    /* Panel ancho fijo debajo de la barra */
    .marcas-megamenu {
      display: none;
      position: fixed;         /* sale de cualquier overflow */
      left: 0; right: 0;
      background: #fff;
      border-top: 1px solid #e8e8e8;
      border-bottom: 1px solid #e8e8e8;
      box-shadow: 0 12px 32px rgba(0,0,0,.07);
      z-index: 300;
      padding: 32px 48px 36px;
      animation: slideDown .18s ease;
    }
    .marcas-wrap:hover .marcas-megamenu { display: block; }

    .marcas-megamenu-titulo {
      font-size: 9px;
      letter-spacing: .18em;
      text-transform: uppercase;
      color: #bbb;
      margin: 0 0 20px;
    }

    .marcas-grid {
      display: flex;
      flex-wrap: wrap;
      gap: 0;
      column-gap: 0;
    }

    .marcas-grid a {
      display: block;
      width: 20%;           /* 5 columnas */
      padding: 9px 0;
      font-size: 13px;
      font-weight: 400;
      letter-spacing: .02em;
      color: #333;
      text-decoration: none;
      border-bottom: 1px solid transparent;
      transition: color .12s;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .marcas-grid a:hover { color: #000; text-decoration: underline; }
    .marcas-grid a.activo { color: #000; font-weight: 600; }

    /* Separador entre marcas y botón filtros */
    .marca-bar-sep {
      flex: 1;
    }

    /* Botón "Filtros" a la derecha */
    .filtros-toggle {
      display: inline-flex;
      align-items: center;
      gap: 7px;
      height: 44px;
      padding: 0 16px;
      font-size: 11px;
      font-weight: 500;
      letter-spacing: .08em;
      text-transform: uppercase;
      color: #888;
      cursor: pointer;
      border: none;
      background: transparent;
      border-left: 1px solid #e8e8e8;
      border-bottom: 2px solid transparent;
      transition: color .15s;
      flex-shrink: 0;
      position: relative;
    }
    .filtros-toggle:hover, .filtros-toggle.abierto { color: #111; }
    .filtros-toggle.abierto { border-bottom-color: #111; }
    .filtros-toggle svg { width: 14px; height: 14px; }
    /* Punto indicador si hay filtros activos */
    .filtros-toggle .dot {
      width: 6px; height: 6px;
      background: #111;
      border-radius: 50%;
      display: none;
    }
    .filtros-toggle.tiene-filtros .dot { display: inline-block; }

    /* ═══════════════════════════════════════════
       PANEL DE FILTROS (oculto por defecto)
    ═══════════════════════════════════════════ */
    .filtros-panel {
      display: none;
      border-bottom: 1px solid #e8e8e8;
      background: #fafafa;
      padding: 20px 48px;
      animation: slideDown .15s ease;
    }
    .filtros-panel.visible { display: block; }

    @keyframes slideDown {
      from { opacity: 0; transform: translateY(-6px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .filtros-panel form {
      display: flex;
      flex-wrap: wrap;
      gap: 16px;
      align-items: flex-end;
    }

    .fp-grupo {
      display: flex;
      flex-direction: column;
      gap: 5px;
      min-width: 140px;
    }
    .fp-grupo.wide { min-width: 220px; }
    .fp-label {
      font-size: 9px;
      letter-spacing: .14em;
      text-transform: uppercase;
      color: #aaa;
      font-weight: 600;
    }
    .fp-grupo input[type="text"],
    .fp-grupo input[type="number"],
    .fp-grupo select {
      border: 1px solid #ddd;
      padding: 7px 10px;
      font-family: 'Inter', sans-serif;
      font-size: 12px;
      color: #111;
      background: #fff;
      outline: none;
      width: 100%;
      -webkit-appearance: none;
      appearance: none;
    }
    .fp-grupo input:focus, .fp-grupo select:focus { border-color: #111; }

    .fp-precio-row { display: flex; gap: 8px; align-items: center; }
    .fp-precio-row input { width: 90px; }
    .fp-precio-row span { color: #bbb; font-size: 12px; }

    .fp-search-wrap { position: relative; }
    .fp-search-wrap svg {
      position: absolute; left: 10px; top: 50%; transform: translateY(-50%);
      width: 13px; height: 13px; color: #aaa; pointer-events: none;
    }
    .fp-search-wrap input { padding-left: 30px; }

    .fp-actions { display: flex; gap: 8px; align-items: flex-end; padding-bottom: 1px; }
    .fp-btn-apply {
      padding: 8px 20px;
      background: #111; color: #fff; border: none;
      font-family: 'Inter', sans-serif;
      font-size: 10px; font-weight: 600;
      letter-spacing: .1em; text-transform: uppercase;
      cursor: pointer; transition: background .15s;
    }
    .fp-btn-apply:hover { background: #333; }
    .fp-btn-clear {
      padding: 8px 14px;
      background: transparent; color: #888;
      border: 1px solid #ddd;
      font-family: 'Inter', sans-serif;
      font-size: 10px; font-weight: 500;
      letter-spacing: .08em; text-transform: uppercase;
      text-decoration: none; cursor: pointer;
      display: inline-flex; align-items: center;
      transition: color .15s, border-color .15s;
    }
    .fp-btn-clear:hover { color: #111; border-color: #aaa; text-decoration: none; }

    /* ═══════════════════════════════════════════
       ETIQUETAS FILTROS ACTIVOS
    ═══════════════════════════════════════════ */
    .filtro-tags {
      display: flex; flex-wrap: wrap; gap: 8px;
      padding: 14px 48px 0;
    }
    .filtro-tag {
      display: inline-flex; align-items: center; gap: 6px;
      padding: 4px 10px; background: #111; color: #fff;
      font-size: 10px; letter-spacing: .08em; text-transform: uppercase;
    }
    .filtro-tag a { color: #fff; opacity: .6; text-decoration: none; font-size: 13px; line-height: 1; }
    .filtro-tag a:hover { opacity: 1; }

    /* ═══════════════════════════════════════════
       GRID DE PRODUCTOS
    ═══════════════════════════════════════════ */
    .cat-page { padding: 32px 48px 100px; }

    .product-grid {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 1px;
      background: #e8e8e8;
    }

    .product-card {
      background: #fff;
      display: flex;
      flex-direction: column;
    }

    .card-link {
      text-decoration: none; color: inherit;
      display: flex; flex-direction: column; flex: 1;
    }
    .card-link:hover { text-decoration: none; }

    .card-img {
      aspect-ratio: 3/4;
      background: #f5f5f5;
      overflow: hidden;
      position: relative;
    }
    .card-img-real {
      width: 100%; height: 100%;
      object-fit: cover; display: block;
      transition: transform .4s ease;
    }
    .card-link:hover .card-img-real { transform: scale(1.03); }

    .card-img-placeholder {
      width: 100%; height: 100%;
      display: flex; align-items: center; justify-content: center;
      font-family: 'IM Fell English', serif;
      font-style: italic; font-size: 48px; color: #ddd;
    }

    .card-badges {
      position: absolute; top: 10px; left: 10px;
      display: flex; flex-direction: column; gap: 4px;
    }
    .badge {
      padding: 3px 8px; font-size: 9px; font-weight: 700;
      letter-spacing: .12em; text-transform: uppercase;
    }
    .badge-nuevo  { background: #fff; color: #111; border: 1px solid #111; }
    .badge-usado  { background: rgba(255,255,255,.8); color: #777; border: 1px solid #ccc; }

    .card-body {
      padding: 14px 16px 16px;
      border-top: 1px solid #e8e8e8;
    }
    .card-marca {
      font-size: 9px; font-weight: 700;
      letter-spacing: .14em; text-transform: uppercase;
      color: #111; margin: 0 0 3px;
    }
    .card-title {
      font-size: 13px; font-weight: 300;
      color: #111; line-height: 1.4; margin: 0 0 10px;
    }
    .card-price {
      font-size: 14px; font-weight: 500;
      color: #111; margin: 0 0 4px;
    }
    .card-unica {
      font-size: 10px; letter-spacing: .1em;
      text-transform: uppercase; color: #bbb; margin: 0;
    }
    .card-stock { font-size: 11px; color: #888; margin: 0; }
    .stock-cero { color: #c00; }

    .card-actions {
      display: flex; gap: 1px;
      border-top: 1px solid #e8e8e8;
      background: #e8e8e8;
    }
    .btn-carrito {
      flex: 1; padding: 9px 0;
      background: #111; color: #fff; border: none;
      font-family: 'Inter', sans-serif;
      font-size: 10px; font-weight: 600;
      letter-spacing: .1em; text-transform: uppercase;
      cursor: pointer; transition: background .15s;
    }
    .btn-carrito:hover { background: #333; }

    .btn-action {
      flex: 1; padding: 9px 0;
      background: #fff; border: none;
      font-family: 'Inter', sans-serif;
      font-size: 10px; font-weight: 500;
      letter-spacing: .08em; text-transform: uppercase;
      color: #888; text-decoration: none;
      display: inline-flex; align-items: center; justify-content: center;
      cursor: pointer; transition: background .1s, color .1s;
    }
    .btn-action:hover { background: #f0f0f0; color: #111; text-decoration: none; }
    .btn-action.danger:hover { background: #fff0f0; color: #c00; }

    /* ═══════════════════════════════════════════
       ALERTAS Y EMPTY STATE
    ═══════════════════════════════════════════ */
    .alert {
      padding: 10px 16px; font-size: 13px;
      border: 1px solid; margin-bottom: 20px;
    }
    .alert-success { border-color: #3a3; color: #3a3; }
    .alert-warning  { border-color: #a60; color: #a60; }
    .alert-error    { border-color: #c00; color: #c00; }

    .empty-state { text-align: center; padding: 80px 20px; }
    .empty-state h3 {
      font-family: 'IM Fell English', serif; font-style: italic;
      font-size: 24px; font-weight: 400; color: #aaa; margin: 0 0 8px;
    }
    .empty-state p { font-size: 13px; color: #bbb; margin: 0 0 20px; }

    .btn-nuevo {
      display: inline-flex; align-items: center; gap: 4px;
      padding: 8px 18px; background: #111; color: #fff; border: none;
      font-family: 'Inter', sans-serif;
      font-size: 10px; font-weight: 600;
      letter-spacing: .1em; text-transform: uppercase;
      text-decoration: none; cursor: pointer; transition: background .15s;
    }
    .btn-nuevo:hover { background: #333; color: #fff; text-decoration: none; }

    @media (max-width: 1100px) { .product-grid { grid-template-columns: repeat(3, 1fr); } }
    @media (max-width: 768px) {
      .cat-subheader, .marca-bar, .filtros-panel, .cat-page, .filtro-tags { padding-left: 20px; padding-right: 20px; }
      .product-grid { grid-template-columns: repeat(2, 1fr); }
    }
    @media (max-width: 420px) { .product-grid { grid-template-columns: 1fr; } }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<!-- ── SUBHEADER ──────────────────────────────────── -->
<div class="cat-subheader">
  <div class="cat-subheader-left">
    <p><% if ("comprador".equals(rol)) { %>Explora y compra<% } else if ("vendedor".equals(rol)) { %>Mis publicaciones<% } else { %>Gestión de inventario<% } %></p>
    <h1>Cat&aacute;logo</h1>
  </div>
  <div class="cat-subheader-right">
    <span class="cat-count"><strong><%= totalProductos %></strong> <%= totalProductos == 1 ? "resultado" : "resultados" %></span>
    <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
      <a href="<%= ctx %>/producto?accion=nuevo" class="btn-nuevo">+ Nuevo</a>
    <% } else if ("comprador".equals(rol)) { %>
      <a href="<%= ctx %>/carrito?accion=ver" class="btn-nuevo">
        Ver carrito<% if (carritoSize > 0) { %> (<%= carritoSize %>)<% } %>
      </a>
    <% } %>
  </div>
</div>

<!-- ── BARRA DE MARCAS ────────────────────────────── -->
<div class="marca-bar">
  <a href="<%= ctx %>/producto?accion=listar"
     class="marca-chip <%= fMarca.isEmpty() ? "activo" : "" %>">Todas</a>

  <% if (!marcasSet.isEmpty()) { %>
  <div class="marcas-wrap" id="marcasWrap">
    <button type="button" class="marcas-btn <%= !fMarca.isEmpty() ? "activo" : "" %>">
      Marcas
      <svg viewBox="0 0 10 6" fill="none" stroke="currentColor" stroke-width="1.8">
        <polyline points="1 1 5 5 9 1"/>
      </svg>
      <% if (!fMarca.isEmpty()) { %><span class="marca-dot"></span><% } %>
    </button>
    <div class="marcas-megamenu" id="marcasMegamenu">
      <p class="marcas-megamenu-titulo">Filtrar por marca</p>
      <div class="marcas-grid">
        <a href="<%= ctx %>/producto?accion=listar"
           class="<%= fMarca.isEmpty() ? "activo" : "" %>">Todas las marcas</a>
        <% for (String m : marcasSet) { %>
        <a href="<%= ctx %>/producto?accion=listar&marca=<%= Html.url(m) %>"
           class="<%= m.equalsIgnoreCase(fMarca) ? "activo" : "" %>"><%= Html.esc(m) %></a>
        <% } %>
      </div>
    </div>
  </div>
  <% } %>

  <span class="marca-bar-sep"></span>

  <!-- Botón filtros -->
  <button class="filtros-toggle <%= nFiltros > 0 ? "tiene-filtros" : "" %>" id="filtrosToggle" type="button">
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
      <line x1="4" y1="6" x2="20" y2="6"/>
      <line x1="4" y1="12" x2="14" y2="12"/>
      <line x1="4" y1="18" x2="11" y2="18"/>
    </svg>
    Filtros
    <span class="dot"></span>
  </button>
</div>

<!-- ── PANEL DE FILTROS (oculto por defecto) ─────── -->
<div class="filtros-panel" id="filtrosPanel">
  <form method="get" action="<%= ctx %>/producto" id="filtrosForm">
    <input type="hidden" name="accion" value="listar">
    <% if (!fMarca.isEmpty()) { %><input type="hidden" name="marca" value="<%= Html.esc(fMarca) %>"><% } %>

    <!-- Búsqueda -->
    <div class="fp-grupo wide">
      <span class="fp-label">Buscar</span>
      <div class="fp-search-wrap">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
        </svg>
        <input type="text" name="buscar" placeholder="Nombre o descripción..." value="<%= Html.esc(fBuscar) %>">
      </div>
    </div>

    <!-- Categoría -->
    <div class="fp-grupo">
      <span class="fp-label">Categoría</span>
      <select name="categoria" onchange="this.form.submit()">
        <option value="" <%= fCat.isEmpty() ? "selected" : "" %>>Todas</option>
        <% for (String cat : categorias) { %>
          <option value="<%= Html.esc(cat) %>" <%= cat.equals(fCat) ? "selected" : "" %>><%= Html.esc(cat) %></option>
        <% } %>
      </select>
    </div>

    <% if (tallas != null && !tallas.isEmpty()) { %>
    <div class="fp-grupo">
      <span class="fp-label">Talla</span>
      <select name="talla" onchange="this.form.submit()">
        <option value="" <%= fTalla.isEmpty() ? "selected" : "" %>>Todas</option>
        <% for (String t : tallas) { %>
          <option value="<%= Html.esc(t) %>" <%= t.equals(fTalla) ? "selected" : "" %>><%= Html.esc(t) %></option>
        <% } %>
      </select>
    </div>
    <% } %>

    <% if (colores != null && !colores.isEmpty()) { %>
    <div class="fp-grupo">
      <span class="fp-label">Color</span>
      <select name="color" onchange="this.form.submit()">
        <option value="" <%= fColor.isEmpty() ? "selected" : "" %>>Todos</option>
        <% for (String c : colores) { %>
          <option value="<%= Html.esc(c) %>" <%= c.equals(fColor) ? "selected" : "" %>><%= Html.esc(c) %></option>
        <% } %>
      </select>
    </div>
    <% } %>

    <!-- Estado -->
    <div class="fp-grupo">
      <span class="fp-label">Estado</span>
      <select name="estado" onchange="this.form.submit()">
        <option value=""      <%= fEstado.isEmpty()           ? "selected" : "" %>>Todos</option>
        <option value="nuevo" <%= "nuevo".equals(fEstado) ? "selected" : "" %>>Nuevo</option>
        <option value="usado" <%= "usado".equals(fEstado) ? "selected" : "" %>>Usado</option>
      </select>
    </div>

    <!-- Precio -->
    <div class="fp-grupo">
      <span class="fp-label">Precio COP</span>
      <div class="fp-precio-row">
        <input type="number" name="min" placeholder="Mín" value="<%= Html.esc(fMin) %>" min="0" step="5000">
        <span>–</span>
        <input type="number" name="max" placeholder="Máx" value="<%= Html.esc(fMax) %>" min="0" step="5000">
      </div>
    </div>

    <!-- Ordenar -->
    <div class="fp-grupo">
      <span class="fp-label">Ordenar</span>
      <select name="orden" onchange="this.form.submit()">
        <option value=""            <%= filtroOrden.isEmpty()               ? "selected" : "" %>>Relevancia</option>
        <option value="precio_asc"  <%= "precio_asc".equals(filtroOrden)  ? "selected" : "" %>>Menor precio</option>
        <option value="precio_desc" <%= "precio_desc".equals(filtroOrden) ? "selected" : "" %>>Mayor precio</option>
        <option value="nombre_asc"  <%= "nombre_asc".equals(filtroOrden)  ? "selected" : "" %>>A → Z</option>
        <option value="nombre_desc" <%= "nombre_desc".equals(filtroOrden) ? "selected" : "" %>>Z → A</option>
        <option value="reciente"    <%= "reciente".equals(filtroOrden)    ? "selected" : "" %>>Más recientes</option>
      </select>
    </div>

    <div class="fp-actions">
      <button type="submit" class="fp-btn-apply">Aplicar</button>
      <% if (hayFiltro) { %>
        <a href="<%= ctx %>/producto?accion=listar" class="fp-btn-clear">Limpiar</a>
      <% } %>
    </div>
  </form>
</div>

<!-- ── ETIQUETAS DE FILTROS ACTIVOS ──────────────── -->
<% if (nFiltros > 0) { %>
<div class="filtro-tags">
  <% for (String k : etiquetasTexto) {
       String v = filtros.get(k);
       if (v.isEmpty()) continue;
       String texto = k.equals("buscar") ? "\"" + v + "\"" : v;
  %>
    <span class="filtro-tag"><%= Html.esc(texto) %>
      <a href="<%= Html.esc(urlSin(ctx, filtros, k)) %>" title="Quitar">×</a>
    </span>
  <% } %>
  <% if (!fMin.isEmpty() || !fMax.isEmpty()) {
       String tp = !fMin.isEmpty() && !fMax.isEmpty() ? "$" + fMin + " – $" + fMax
                 : !fMin.isEmpty() ? "Desde $" + fMin : "Hasta $" + fMax;
  %>
    <span class="filtro-tag"><%= Html.esc(tp) %>
      <a href="<%= Html.esc(urlSin(ctx, filtros, "min", "max")) %>" title="Quitar">×</a>
    </span>
  <% } %>
</div>
<% } %>

<!-- ── GRID ───────────────────────────────────────── -->
<div class="cat-page">

  <% if ("creado".equals(msg)) { %>
    <div class="alert alert-success">Producto publicado exitosamente.</div>
  <% } else if ("actualizado".equals(msg)) { %>
    <div class="alert alert-success">Producto actualizado correctamente.</div>
  <% } else if ("eliminado".equals(msg)) { %>
    <div class="alert alert-warning">Producto eliminado del catálogo.</div>
  <% } else if ("agregado".equals(msg)) { %>
    <div class="alert alert-success">Producto agregado al carrito.</div>
  <% } %>
  <% if (error != null && !error.isEmpty()) { %>
    <div class="alert alert-error">No tienes permiso para esa acción.</div>
  <% } %>

  <% if (productos.isEmpty()) { %>
    <div class="empty-state">
      <h3><% if (hayFiltro) { %>Sin resultados<% } else { %>El catálogo está vacío<% } %></h3>
      <p><% if (hayFiltro) { %>Prueba quitando algún filtro.<% } else { %>Aún no hay productos publicados.<% } %></p>
      <% if (hayFiltro) { %>
        <a href="<%= ctx %>/producto?accion=listar" class="btn-nuevo">Ver todos</a>
      <% } else if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
        <a href="<%= ctx %>/producto?accion=nuevo" class="btn-nuevo">Publicar producto</a>
      <% } %>
    </div>
  <% } else { %>
    <div class="product-grid">
      <% for (Producto p : productos) {
           String detalleUrl = ctx + "/producto?accion=detalle&id=" + p.getIdProducto();
           String imgUrl     = p.getImagenUrl() != null ? p.getImagenUrl() : "";
           String marca      = p.getMarca() != null ? p.getMarca().trim() : "";
           String inicial    = marca.isEmpty() ? "L" : marca.substring(0, 1);
      %>
      <div class="product-card">
        <a class="card-link" href="<%= detalleUrl %>">
          <div class="card-img">
            <% if (!imgUrl.isEmpty()) { %>
              <img class="card-img-real" src="<%= Html.esc(imgUrl) %>" alt="<%= Html.esc(p.getTitulo()) %>"
                   onerror="this.style.display='none'; this.nextElementSibling.style.display='flex'">
              <div class="card-img-placeholder" style="display:none;"><%= Html.esc(inicial) %></div>
            <% } else { %>
              <div class="card-img-placeholder"><%= Html.esc(inicial) %></div>
            <% } %>
            <div class="card-badges">
              <span class="badge badge-<%= Html.esc(p.getEstadoProducto()) %>"><%= Html.esc(p.getEstadoProducto()) %></span>
            </div>
          </div>
          <div class="card-body">
            <% if (!marca.isEmpty()) { %><p class="card-marca"><%= Html.esc(marca) %></p><% } %>
            <h3 class="card-title"><%= Html.esc(p.getTitulo()) %></h3>
            <p class="card-price">$ <%= String.format("%,.0f", p.getPrecio()) %> COP</p>
            <% if (p.getStock() == 0) { %>
              <p class="card-stock stock-cero">Sin stock</p>
            <% } else if (p.getStock() == 1) { %>
              <p class="card-unica">Pieza &uacute;nica</p>
            <% } else { %>
              <p class="card-stock"><%= p.getStock() %> disponibles</p>
            <% } %>
          </div>
        </a>
        <div class="card-actions">
          <% if ("comprador".equals(rol) && p.getStock() > 0) { %>
            <form method="post" action="<%= ctx %>/carrito" style="flex:1;display:flex;">
              <input type="hidden" name="accion"     value="agregar">
              <input type="hidden" name="idProducto" value="<%= p.getIdProducto() %>">
              <input type="hidden" name="cantidad"   value="1">
              <button type="submit" class="btn-carrito">+ Agregar al carrito</button>
            </form>
          <% } %>
          <% if ("admin".equals(rol) || ("vendedor".equals(rol) && idVendedorUsuario == p.getIdVendedor())) { %>
            <a href="<%= detalleUrl %>" class="btn-action">Ver</a>
            <a href="<%= ctx %>/producto?accion=editar&id=<%= p.getIdProducto() %>" class="btn-action">Editar</a>
            <a href="<%= ctx %>/producto?accion=eliminar&id=<%= p.getIdProducto() %>"
               class="btn-action danger"
               onclick="return confirm('¿Eliminar este producto?')">Eliminar</a>
          <% } %>
        </div>
      </div>
      <% } %>
    </div>
  <% } %>

</div>

<input type="hidden" id="nFiltrosActivos" value="<%= nFiltros %>">
<script>
(function () {
  var btn   = document.getElementById('filtrosToggle');
  var panel = document.getElementById('filtrosPanel');
  if (!btn || !panel) return;
  var n = parseInt(document.getElementById('nFiltrosActivos').value, 10) || 0;
  if (n > 0) {
    panel.classList.add('visible');
    btn.classList.add('abierto');
  }
  btn.addEventListener('click', function () {
    var abierto = panel.classList.toggle('visible');
    btn.classList.toggle('abierto', abierto);
  });
})();

// ── Mega-menu de marcas: posicionar bajo la barra ──
(function () {
  var wrap  = document.getElementById('marcasWrap');
  var menu  = document.getElementById('marcasMegamenu');
  if (!wrap || !menu) return;

  function posicionar() {
    var bar = wrap.closest('.marca-bar');
    if (!bar) return;
    var rect = bar.getBoundingClientRect();
    menu.style.top = (rect.bottom + window.scrollY) + 'px';
  }

  wrap.addEventListener('mouseenter', posicionar);
  window.addEventListener('resize', function () {
    if (wrap.matches(':hover')) posicionar();
  });
})();
</script>

</body>
</html>
