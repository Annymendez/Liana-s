<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Producto, model.Persona" %>
<%
    Persona usuario = (Persona) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String rol   = usuario.getTipo();
    String ctx   = request.getContextPath();

    List<Producto> productos = (List<Producto>) request.getAttribute("productos");
    if (productos == null) productos = new ArrayList<>();

    String filtroCat  = request.getParameter("categoria") != null ? request.getParameter("categoria") : "";
    String filtroMarca = request.getParameter("marca")    != null ? request.getParameter("marca")    : "";

    // Filtrar en JSP
    List<Producto> filtrados = new ArrayList<>();
    for (Producto p : productos) {
        boolean okCat   = filtroCat.isEmpty()   || filtroCat.equalsIgnoreCase(p.getCategoria());
        boolean okMarca = filtroMarca.isEmpty() || filtroMarca.equalsIgnoreCase(p.getMarca());
        if (okCat && okMarca) filtrados.add(p);
    }

    // Recoger marcas únicas
    LinkedHashSet<String> marcasSet = new LinkedHashSet<>();
    for (Producto p : productos) {
        if (p.getMarca() != null && !p.getMarca().trim().isEmpty()) marcasSet.add(p.getMarca().trim());
    }

    // Recoger categorías únicas
    LinkedHashSet<String> catSet = new LinkedHashSet<>();
    for (Producto p : productos) {
        if (p.getCategoria() != null && !p.getCategoria().trim().isEmpty()) catSet.add(p.getCategoria().trim());
    }

    // Agrupar filtrados por marca
    LinkedHashMap<String, List<Producto>> porMarca = new LinkedHashMap<>();
    for (Producto p : filtrados) {
        String m = (p.getMarca() != null && !p.getMarca().trim().isEmpty()) ? p.getMarca().trim() : "Sin marca";
        porMarca.computeIfAbsent(m, k -> new ArrayList<>()).add(p);
    }

    String msgOk  = request.getParameter("ok")    != null ? request.getParameter("ok")    : "";
    String msgErr = request.getParameter("error")  != null ? request.getParameter("error") : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cat&aacute;logo &ndash; Liana's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/estilo.css">
    <style>
        body { background: #fff; }

        /* ── TOOLBAR ── */
        .cat-toolbar {
            border-bottom: 1px solid #e8e8e8;
            padding: 0 40px;
            display: flex;
            align-items: center;
            gap: 0;
            overflow-x: auto;
            scrollbar-width: none;
        }
        .cat-toolbar::-webkit-scrollbar { display: none; }

        .cat-toolbar-label {
            font-size: 10px;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: #aaa;
            margin-right: 20px;
            white-space: nowrap;
            flex-shrink: 0;
        }

        .filter-btn {
            padding: 0 16px;
            height: 44px;
            display: inline-flex;
            align-items: center;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #888;
            text-decoration: none;
            border-bottom: 2px solid transparent;
            white-space: nowrap;
            transition: color .15s, border-color .15s;
            flex-shrink: 0;
        }
        .filter-btn:hover { color: #111; text-decoration: none; }
        .filter-btn.active { color: #111; border-bottom-color: #111; }

        /* ── BRAND FILTER ROW ── */
        .brand-row {
            border-bottom: 1px solid #e8e8e8;
            padding: 0 40px;
            display: flex;
            align-items: center;
            gap: 0;
            overflow-x: auto;
            scrollbar-width: none;
        }
        .brand-row::-webkit-scrollbar { display: none; }

        /* ── PAGE ── */
        .cat-page {
            max-width: 1280px;
            margin: 0 auto;
            padding: 0 40px 100px;
        }

        /* ── TOAST ── */
        .toast {
            margin: 20px 0 0;
            padding: 10px 16px;
            font-size: 13px;
            border: 1px solid;
        }
        .toast.ok  { border-color: #3a3; color: #3a3; }
        .toast.err { border-color: #c00; color: #c00; }

        /* ── BRAND SECTION ── */
        .brand-section { margin-top: 60px; }

        .brand-header {
            display: flex;
            align-items: baseline;
            gap: 20px;
            margin-bottom: 32px;
            padding-bottom: 14px;
            border-bottom: 1px solid #111;
        }
        .brand-name {
            font-family: 'Inter', sans-serif;
            font-weight: 700;
            font-size: 20px;
            letter-spacing: .06em;
            text-transform: uppercase;
            color: #111;
        }
        .brand-count {
            font-size: 11px;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #bbb;
        }

        /* ── PRODUCT GRID ── */
        .prod-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1px;
            background: #e8e8e8;
        }

        /* ── PRODUCT CARD ── */
        .prod-card {
            background: #fff;
            display: flex;
            flex-direction: column;
            text-decoration: none;
            color: inherit;
            transition: background .15s;
            position: relative;
        }
        .prod-card:hover { background: #fafafa; text-decoration: none; }

        .prod-img {
            aspect-ratio: 3/4;
            background: #f5f5f5;
            overflow: hidden;
            position: relative;
        }
        .prod-img img {
            width: 100%; height: 100%;
            object-fit: cover;
            display: block;
        }
        .prod-img-placeholder {
            width: 100%; height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #ccc;
        }

        .prod-badge {
            position: absolute;
            top: 12px;
            left: 12px;
            background: #fff;
            border: 1px solid #111;
            padding: 3px 8px;
            font-size: 9px;
            font-weight: 700;
            letter-spacing: .14em;
            text-transform: uppercase;
            color: #111;
        }
        .prod-badge.vendido {
            background: #111;
            color: #fff;
            border-color: #111;
        }

        .prod-info {
            padding: 14px 16px 20px;
            border-top: 1px solid #e8e8e8;
        }
        .prod-brand-tag {
            font-family: 'Inter', sans-serif;
            font-weight: 700;
            font-size: 10px;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: #111;
            margin-bottom: 4px;
        }
        .prod-name {
            font-size: 13px;
            font-weight: 300;
            color: #111;
            line-height: 1.4;
            margin-bottom: 8px;
        }
        .prod-meta {
            font-size: 11px;
            color: #aaa;
            margin-bottom: 6px;
        }
        .prod-price {
            font-size: 14px;
            font-weight: 500;
            color: #111;
        }
        .prod-price-na {
            font-size: 12px;
            color: #bbb;
            font-style: italic;
        }

        /* ── ACTIONS (vendedor/admin) ── */
        .prod-actions {
            display: flex;
            gap: 1px;
            border-top: 1px solid #e8e8e8;
            background: #e8e8e8;
        }
        .prod-action-btn {
            flex: 1;
            padding: 8px 0;
            background: #fff;
            border: none;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            font-size: 10px;
            font-weight: 500;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #888;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            transition: background .1s, color .1s;
        }
        .prod-action-btn:hover { background: #f0f0f0; color: #111; text-decoration: none; }
        .prod-action-btn.danger:hover { background: #fff0f0; color: #c00; }

        /* ── EMPTY STATE ── */
        .empty-state {
            text-align: center;
            padding: 80px 20px;
        }
        .empty-icon { font-size: 36px; margin-bottom: 20px; opacity: .4; }
        .empty-title {
            font-family: 'IM Fell English', serif;
            font-style: italic;
            font-size: 22px;
            color: #aaa;
            margin-bottom: 8px;
        }
        .empty-sub {
            font-size: 13px;
            color: #bbb;
        }

        /* ── PUBLISH BUTTON ── */
        .publish-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 10px 20px;
            background: #111;
            color: #fff;
            border: 1px solid #111;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .1em;
            text-transform: uppercase;
            text-decoration: none;
            margin: 32px 0 0;
            transition: background .15s;
        }
        .publish-btn:hover { background: #333; color: #fff; text-decoration: none; }

        @media (max-width: 1024px) {
            .prod-grid { grid-template-columns: repeat(3, 1fr); }
        }
        @media (max-width: 768px) {
            .cat-toolbar, .brand-row { padding: 0 16px; }
            .cat-page { padding: 0 16px 80px; }
            .prod-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 400px) {
            .prod-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<!-- TOOLBAR: Categorías -->
<div class="cat-toolbar">
    <span class="cat-toolbar-label">Categor&iacute;a</span>
    <a href="<%= ctx %>/producto?accion=listar<%= filtroMarca.isEmpty() ? "" : "&marca=" + filtroMarca %>"
       class="filter-btn <%= filtroCat.isEmpty() ? "active" : "" %>">Todas</a>
    <% for (String cat : catSet) { %>
    <a href="<%= ctx %>/producto?accion=listar&categoria=<%= java.net.URLEncoder.encode(cat,"UTF-8") %><%= filtroMarca.isEmpty() ? "" : "&marca=" + java.net.URLEncoder.encode(filtroMarca,"UTF-8") %>"
       class="filter-btn <%= filtroCat.equalsIgnoreCase(cat) ? "active" : "" %>"><%= cat %></a>
    <% } %>
</div>

<!-- BRAND FILTER ROW -->
<% if (!marcasSet.isEmpty()) { %>
<div class="brand-row">
    <span class="cat-toolbar-label">Marca</span>
    <a href="<%= ctx %>/producto?accion=listar<%= filtroCat.isEmpty() ? "" : "&categoria=" + java.net.URLEncoder.encode(filtroCat,"UTF-8") %>"
       class="filter-btn <%= filtroMarca.isEmpty() ? "active" : "" %>">Todas</a>
    <% for (String m : marcasSet) { %>
    <a href="<%= ctx %>/producto?accion=listar&marca=<%= java.net.URLEncoder.encode(m,"UTF-8") %><%= filtroCat.isEmpty() ? "" : "&categoria=" + java.net.URLEncoder.encode(filtroCat,"UTF-8") %>"
       class="filter-btn <%= filtroMarca.equalsIgnoreCase(m) ? "active" : "" %>"><%= m %></a>
    <% } %>
</div>
<% } %>

<div class="cat-page">

    <% if (!msgOk.isEmpty()) { %><div class="toast ok"><%= msgOk %></div><% } %>
    <% if (!msgErr.isEmpty()) { %><div class="toast err"><%= msgErr %></div><% } %>

    <% if ("vendedor".equals(rol) || "admin".equals(rol)) { %>
    <a href="<%= ctx %>/producto?accion=nuevo" class="publish-btn">+ Publicar producto</a>
    <% } %>

    <% if (porMarca.isEmpty()) { %>
    <div class="empty-state">
        <div class="empty-icon">&#128084;</div>
        <div class="empty-title">No hay productos</div>
        <div class="empty-sub">
            <% if ("vendedor".equals(rol)) { %>
                Publica tu primer producto usando el bot&oacute;n de arriba.
            <% } else { %>
                Vuelve pronto &mdash; el archivo crece.
            <% } %>
        </div>
    </div>
    <% } %>

    <% for (Map.Entry<String, List<Producto>> entry : porMarca.entrySet()) {
        String marcaNombre = entry.getKey();
        List<Producto> items = entry.getValue();
    %>
    <section class="brand-section">
        <div class="brand-header">
            <span class="brand-name"><%= marcaNombre.toUpperCase() %></span>
            <span class="brand-count"><%= items.size() %> <%= items.size() == 1 ? "pieza" : "piezas" %></span>
        </div>

        <div class="prod-grid">
        <% for (Producto p : items) {
            boolean vendido = "vendido".equalsIgnoreCase(p.getEstado()) || "inactivo".equalsIgnoreCase(p.getEstado());
            String precioStr = "";
            try {
                double pr = Double.parseDouble(String.valueOf(p.getPrecio()));
                precioStr = String.format("%,.0f", pr);
            } catch (Exception e2) { precioStr = String.valueOf(p.getPrecio()); }
        %>
        <div class="prod-card">
            <!-- Imagen -->
            <div class="prod-img">
                <% if (p.getImagen() != null && !p.getImagen().isEmpty()) { %>
                <img src="<%= ctx %>/uploads/<%= p.getImagen() %>" alt="<%= p.getNombre() %>">
                <% } else { %>
                <div class="prod-img-placeholder">sin imagen</div>
                <% } %>
                <% if (vendido) { %><span class="prod-badge vendido">Vendido</span><% } %>
                <% if ("nuevo".equalsIgnoreCase(p.getEstado())) { %><span class="prod-badge">Nuevo</span><% } %>
            </div>

            <!-- Info -->
            <div class="prod-info">
                <div class="prod-brand-tag"><%= marcaNombre.toUpperCase() %></div>
                <div class="prod-name"><%= p.getNombre() %></div>
                <div class="prod-meta">
                    <% if (p.getEstado() != null && !p.getEstado().isEmpty()) { %>Estado: <%= p.getEstado() %><% } %>
                    <% if (p.getTalla() != null && !p.getTalla().isEmpty()) { %> &middot; Talla <%= p.getTalla() %><% } %>
                </div>
                <% if (!vendido) { %>
                <div class="prod-price">$ <%= precioStr %> COP</div>
                <% } else { %>
                <div class="prod-price-na">Vendido</div>
                <% } %>
            </div>

            <!-- Acciones -->
            <% if ("vendedor".equals(rol) || "admin".equals(rol)) { %>
            <div class="prod-actions">
                <a href="<%= ctx %>/producto?accion=detalle&id=<%= p.getId() %>" class="prod-action-btn">Ver</a>
                <a href="<%= ctx %>/producto?accion=editar&id=<%= p.getId() %>" class="prod-action-btn">Editar</a>
                <a href="<%= ctx %>/producto?accion=eliminar&id=<%= p.getId() %>"
                   class="prod-action-btn danger"
                   onclick="return confirm('¿Eliminar este producto?')">Eliminar</a>
            </div>
            <% } else { %>
            <div class="prod-actions">
                <a href="<%= ctx %>/producto?accion=detalle&id=<%= p.getId() %>" class="prod-action-btn">Ver detalle</a>
                <% if (!vendido) { %>
                <a href="<%= ctx %>/carrito?accion=agregar&id=<%= p.getId() %>" class="prod-action-btn">+ Carrito</a>
                <% } %>
            </div>
            <% } %>
        </div>
        <% } %>
        </div>
    </section>
    <% } %>

</div>

</body>
</html>
