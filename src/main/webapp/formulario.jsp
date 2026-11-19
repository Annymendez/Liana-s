<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Persona, model.Producto" %>
<%
    Persona usuario = (Persona) session.getAttribute("usuario");
    if (usuario == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    String rol = usuario.getTipo();
    String ctx = request.getContextPath();

    /* ── leer atributos del servlet ── */
    String id               = request.getAttribute("id")               != null ? (String) request.getAttribute("id")               : "";
    String titulo           = request.getAttribute("titulo")           != null ? (String) request.getAttribute("titulo")           : "";
    String precio           = request.getAttribute("precio")           != null ? (String) request.getAttribute("precio")           : "";
    String categoria        = request.getAttribute("categoria")        != null ? (String) request.getAttribute("categoria")        : "";
    String marca            = request.getAttribute("marca")            != null ? (String) request.getAttribute("marca")            : "";
    String stock            = request.getAttribute("stock")            != null ? (String) request.getAttribute("stock")            : "1";
    String color            = request.getAttribute("color")            != null ? (String) request.getAttribute("color")            : "";
    String descripcion      = request.getAttribute("descripcion")      != null ? (String) request.getAttribute("descripcion")      : "";
    String estadoProducto   = request.getAttribute("estadoProducto")   != null ? (String) request.getAttribute("estadoProducto")   : "";
    String imagenUrl        = request.getAttribute("imagenUrl")        != null ? (String) request.getAttribute("imagenUrl")        : "";
    String visibilidad      = request.getAttribute("visibilidad")      != null ? (String) request.getAttribute("visibilidad")      : "activo";
    String politicaDev      = request.getAttribute("politicaDevolucion") != null ? (String) request.getAttribute("politicaDevolucion") : "";
    String error            = request.getAttribute("error")            != null ? (String) request.getAttribute("error")            : "";

    /* si viene de accion=editar, el servlet pone un Producto en el atributo "producto" */
    Producto prod = (Producto) request.getAttribute("producto");
    if (prod != null) {
        id             = String.valueOf(prod.getIdProducto());
        titulo         = prod.getTitulo()         != null ? prod.getTitulo()         : "";
        precio         = String.valueOf(prod.getPrecio());
        marca          = prod.getMarca()          != null ? prod.getMarca()          : "";
        stock          = String.valueOf(prod.getStock());
        descripcion    = prod.getDescripcion()    != null ? prod.getDescripcion()    : "";
        estadoProducto = prod.getEstadoProducto() != null ? prod.getEstadoProducto() : "";
        imagenUrl      = prod.getImagenUrl()      != null ? prod.getImagenUrl()      : "";
    }

    boolean esEdicion = !id.isEmpty();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= esEdicion ? "Editar producto" : "Publicar producto" %> &ndash; Liana's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/estilo.css">
    <style>
        body { background: #fff; }

        .page {
            max-width: 680px;
            margin: 0 auto;
            padding: 60px 20px 100px;
        }

        .page-heading {
            font-family: 'IM Fell English', serif;
            font-size: 32px;
            font-weight: 400;
            font-style: italic;
            margin-bottom: 6px;
        }
        .page-subheading {
            font-size: 13px;
            color: #888;
            margin-bottom: 48px;
        }
        .page-subheading a { color: #888; }

        .form-group { margin-bottom: 24px; }
        .form-group label {
            display: block;
            font-size: 11px;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: #555;
            margin-bottom: 8px;
        }
        .form-group input[type="text"],
        .form-group input[type="number"],
        .form-group input[type="url"],
        .form-group textarea,
        .form-group select {
            width: 100%;
            border: 1px solid #bbb;
            border-radius: 0;
            padding: 12px 14px;
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            font-weight: 300;
            color: #111;
            background: #fff;
            outline: none;
            transition: border-color .15s;
            appearance: none;
            -webkit-appearance: none;
            box-sizing: border-box;
        }
        .form-group input:focus,
        .form-group textarea:focus,
        .form-group select:focus { border-color: #111; }
        .form-group textarea { resize: vertical; min-height: 100px; }
        .form-group select {
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='12' height='8' viewBox='0 0 12 8'%3E%3Cpath d='M1 1l5 5 5-5' stroke='%23555' stroke-width='1.5' fill='none'/%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 14px center;
            padding-right: 36px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .form-divider {
            border: none;
            border-top: 1px solid #e8e8e8;
            margin: 36px 0;
        }

        .img-hint {
            font-size: 11px;
            color: #bbb;
            margin-top: 6px;
            letter-spacing: .02em;
        }

        .btn-row { display: flex; gap: 16px; margin-top: 40px; }
        .btn-submit {
            flex: 1;
            padding: 14px 20px;
            background: #111;
            color: #fff;
            border: 1px solid #111;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .12em;
            text-transform: uppercase;
            cursor: pointer;
            transition: background .15s;
        }
        .btn-submit:hover { background: #333; }
        .btn-cancel {
            padding: 14px 20px;
            background: #fff;
            color: #111;
            border: 1px solid #111;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .12em;
            text-transform: uppercase;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: background .15s;
        }
        .btn-cancel:hover { background: #f5f5f5; text-decoration: none; }

        .error-msg {
            border: 1px solid #c00;
            padding: 12px 16px;
            font-size: 13px;
            color: #c00;
            margin-bottom: 32px;
        }

        .publishing-as { margin-top: 20px; font-size: 12px; color: #aaa; }

        @media (max-width: 600px) {
            .form-row { grid-template-columns: 1fr; }
            .btn-row { flex-direction: column; }
            .btn-cancel { justify-content: center; }
        }
    </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<main class="page">

    <h1 class="page-heading"><%= esEdicion ? "Editar producto" : "Publicar producto" %></h1>
    <p class="page-subheading">
        <% if (!esEdicion) { %>
            &iquest;Buscas algo? <a href="<%= ctx %>/producto?accion=listar">Ir al cat&aacute;logo</a>
        <% } else { %>
            Actualiza la informaci&oacute;n de tu publicaci&oacute;n.
        <% } %>
    </p>

    <% if (!error.isEmpty()) { %>
    <div class="error-msg"><%= error %></div>
    <% } %>

    <form action="<%= ctx %>/producto?accion=<%= esEdicion ? "actualizar" : "guardar" %>"
          method="post">

        <% if (esEdicion) { %>
        <input type="hidden" name="idProducto" value="<%= id %>">
        <% } %>
        <input type="hidden" name="visibilidad"        value="<%= visibilidad.isEmpty() ? "activo" : visibilidad %>">
        <input type="hidden" name="politicaDevolucion" value="<%= politicaDev %>">

        <div class="form-group">
            <label for="titulo">Nombre del producto</label>
            <input type="text" id="titulo" name="titulo" value="<%= titulo %>"
                   placeholder="Ej. Bolso de cuero caf&eacute;" required>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="precio">Precio (COP)</label>
                <input type="number" id="precio" name="precio" value="<%= precio %>"
                       placeholder="0" min="0" required>
            </div>
            <div class="form-group">
                <label for="stock">Unidades disponibles</label>
                <input type="number" id="stock" name="stock"
                       value="<%= stock.isEmpty() ? "1" : stock %>"
                       min="1" required>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="categoria">Categoría</label>
                <select id="categoria" name="categoria">
                    <option value="">Seleccionar</option>
                    <% String[] cats = {"Ropa","Accesorios","Zapatos","Bolsos","Joyería","Vintage","Archivo","Otro"};
                       for (String c : cats) { %>
                    <option value="<%= c %>" <%= c.equals(categoria) ? "selected" : "" %>><%= c %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-group">
                <label for="marca">Marca</label>
                <input type="text" id="marca" name="marca" value="<%= marca %>"
                       placeholder="Ej. Zara, sin marca...">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label for="estadoProducto">Estado</label>
                <select id="estadoProducto" name="estadoProducto">
                    <option value="">Seleccionar</option>
                    <option value="nuevo" <%= "nuevo".equals(estadoProducto) ? "selected" : "" %>>Nuevo</option>
                    <option value="usado" <%= "usado".equals(estadoProducto) ? "selected" : "" %>>Usado</option>
                </select>
            </div>
        </div>

        <div class="form-group">
            <label for="descripcion">Descripci&oacute;n</label>
            <textarea id="descripcion" name="descripcion"
                      placeholder="Describe el producto: material, detalles, historia..."><%= descripcion %></textarea>
        </div>

        <hr class="form-divider">

        <div class="form-group">
            <label for="imagenUrl">URL de imagen</label>
            <input type="url" id="imagenUrl" name="imagenUrl"
                   value="<%= imagenUrl %>"
                   placeholder="https://...">
            <p class="img-hint">Sube la imagen a Imgur, Google Drive o cualquier host y pega el enlace directo.</p>
        </div>

        <div class="btn-row">
            <button type="submit" class="btn-submit">
                <%= esEdicion ? "Guardar cambios" : "Publicar producto" %>
            </button>
            <a href="<%= ctx %>/producto?accion=listar" class="btn-cancel">Cancelar</a>
        </div>

        <p class="publishing-as">
            Publicando como <%= usuario.getNombre() %> &middot; <%= usuario.getTipo() %>
        </p>

    </form>

</main>

</body>
</html>
