<%--
    Document   : lista
    Catálogo de productos (comprador) / inventario (vendedor y admin).

    Filtros nuevos (marca, talla, color): aparecen solos cuando el ProductoServlet
    envía estas listas como atributos de la petición. Mientras no existan, no se
    muestran, así la página sigue funcionando con el backend actual.
        request.setAttribute("marcas",  List<String>)   opciones del filtro Marca
        request.setAttribute("tallas",  List<String>)   opciones del filtro Talla
        request.setAttribute("colores", List<String>)   opciones del filtro Color
        request.setAttribute("marca" / "talla" / "color", String)  valor elegido
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, java.util.LinkedHashMap, java.util.Map, model.Producto, model.Persona, util.Html" %>
<%!
    /** Arma la URL del catálogo con los filtros activos, sin los que se quieren quitar. */
    private static String urlSin(String ctx, Map<String, String> filtros, String... quitar) {
        java.util.Set<String> omitir = new java.util.HashSet<>(java.util.Arrays.asList(quitar));
        StringBuilder sb = new StringBuilder(ctx).append("/producto?accion=listar");
        for (Map.Entry<String, String> e : filtros.entrySet()) {
            if (omitir.contains(e.getKey()) || e.getValue().isEmpty()) continue;
            sb.append('&').append(e.getKey()).append('=').append(Html.url(e.getValue()));
        }
        return sb.toString();
    }

    /** Lee un atributo de la petición como texto ("" si no existe). */
    private static String attr(jakarta.servlet.ServletRequest req, String nombre) {
        Object v = req.getAttribute(nombre);
        return v == null ? "" : v.toString();
    }
%>
<%
    List<Producto> productos = (List<Producto>) request.getAttribute("productos");
    String msg   = request.getParameter("msg");
    String error = (String) request.getAttribute("error");
    String ctx   = request.getContextPath();

    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo() : "";

    if (error == null) error = request.getParameter("error");

    boolean hayFiltro = Boolean.TRUE.equals(request.getAttribute("hayFiltro"));

    // Filtros activos (en este orden). Los vacíos no cuentan ni se muestran.
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

    // Opciones de los filtros nuevos (las envía el servlet; si no, no se dibujan)
    List<String> marcas  = (List<String>) request.getAttribute("marcas");
    List<String> tallas  = (List<String>) request.getAttribute("tallas");
    List<String> colores = (List<String>) request.getAttribute("colores");

    int nFiltros = 0;
    for (String v : filtros.values()) if (!v.isEmpty()) nFiltros++;

    int totalProductos = (productos != null) ? productos.size() : 0;

    List<model.CarritoItem> carrito = (List<model.CarritoItem>) session.getAttribute("carrito");
    int carritoSize = (carrito != null) ? carrito.size() : 0;

    // CA016: id_vendedor del usuario actual para mostrar botones solo al propietario
    int idVendedorUsuario = -1;
    if ("vendedor".equals(rol)) {
        try {
            dao.VendedorDAO vdao = new dao.VendedorDAO();
            model.Vendedor vActual = vdao.buscarPorIdPersona(usuario.getIdPersona());
            if (vActual != null) idVendedorUsuario = vActual.getIdVendedor();
        } catch (Exception ignored) {}
    }

    String[] categorias = { "Tecnologia", "Ropa", "Muebles", "Hogar", "Deportes", "Libros", "Juguetes", "Otro" };
    String[] etiquetasTexto = { "buscar", "categoria", "marca", "talla", "color", "estado" };
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Catálogo</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <link rel="stylesheet" href="<%= ctx %>/catalogo.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="catalogo-subheader">
  <div class="catalogo-subheader-inner">
    <div>
      <p class="sub"><% if ("comprador".equals(rol)) { %>Explora y compra<% } else if ("vendedor".equals(rol)) { %>Mis publicaciones<% } else { %>Gestión de inventario<% } %></p>
      <h1>Catálogo</h1>
    </div>
    <div class="resultado-info">
      <span class="resultado-count"><strong><%= totalProductos %></strong> <%= totalProductos == 1 ? "resultado" : "resultados" %></span>
      <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
        <a href="<%= ctx %>/producto?accion=nuevo" class="btn btn-outline btn-sm">+ Nuevo</a>
      <% } else if ("comprador".equals(rol)) { %>
        <a href="<%= ctx %>/carrito?accion=ver" class="btn btn-outline btn-sm">
          Ver carrito<% if (carritoSize > 0) { %> (<%= carritoSize %>)<% } %>
        </a>
      <% } %>
    </div>
  </div>
</div>

<div class="catalogo-wrapper<% if ("admin".equals(rol)) { %> sin-filtros<% } %>">

  <!-- FILTROS -->
  <aside class="filtros-col">
    <form method="get" action="<%= ctx %>/producto" id="filtrosForm">
      <input type="hidden" name="accion" value="listar">

      <div class="filtros-header">
        <h3>Filtros</h3>
        <span class="filtros-count <%= nFiltros > 0 ? "visible" : "" %>"><%= nFiltros %></span>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Buscar</span>
        <div class="filtro-search-wrap">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <input type="text" name="buscar" placeholder="Nombre o descripción..."
                 value="<%= Html.esc(fBuscar) %>">
        </div>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Categoría</span>
        <div class="cat-chips">
          <label class="cat-chip <%= fCat.isEmpty() ? "activo" : "" %>">
            <input type="radio" name="categoria" value="" <%= fCat.isEmpty() ? "checked" : "" %>
                   onchange="this.form.submit()">
            <span class="cat-chip-dot"></span><span>Todas</span>
          </label>
          <% for (String cat : categorias) { boolean sel = cat.equals(fCat); %>
          <label class="cat-chip <%= sel ? "activo" : "" %>">
            <input type="radio" name="categoria" value="<%= Html.esc(cat) %>" <%= sel ? "checked" : "" %>
                   onchange="this.form.submit()">
            <span class="cat-chip-dot"></span><span><%= Html.esc(cat) %></span>
          </label>
          <% } %>
        </div>
      </div>

      <% if (marcas != null && !marcas.isEmpty()) { %>
      <div class="filtro-grupo">
        <span class="filtro-label">Marca</span>
        <select name="marca" class="filtro-select" onchange="this.form.submit()">
          <option value="" <%= fMarca.isEmpty() ? "selected" : "" %>>Todas</option>
          <% for (String m : marcas) { %>
            <option value="<%= Html.esc(m) %>" <%= m.equals(fMarca) ? "selected" : "" %>><%= Html.esc(m) %></option>
          <% } %>
        </select>
      </div>
      <% } %>

      <% if (tallas != null && !tallas.isEmpty()) { %>
      <div class="filtro-grupo">
        <span class="filtro-label">Talla</span>
        <div class="filtro-chips">
          <label class="filtro-chip <%= fTalla.isEmpty() ? "activo" : "" %>">
            <input type="radio" name="talla" value="" <%= fTalla.isEmpty() ? "checked" : "" %>
                   onchange="this.form.submit()">Todas
          </label>
          <% for (String t : tallas) { boolean sel = t.equals(fTalla); %>
          <label class="filtro-chip <%= sel ? "activo" : "" %>">
            <input type="radio" name="talla" value="<%= Html.esc(t) %>" <%= sel ? "checked" : "" %>
                   onchange="this.form.submit()"><%= Html.esc(t) %>
          </label>
          <% } %>
        </div>
      </div>
      <% } %>

      <% if (colores != null && !colores.isEmpty()) { %>
      <div class="filtro-grupo">
        <span class="filtro-label">Color</span>
        <div class="filtro-chips">
          <label class="filtro-chip <%= fColor.isEmpty() ? "activo" : "" %>">
            <input type="radio" name="color" value="" <%= fColor.isEmpty() ? "checked" : "" %>
                   onchange="this.form.submit()">Todos
          </label>
          <% for (String c : colores) { boolean sel = c.equals(fColor); %>
          <label class="filtro-chip <%= sel ? "activo" : "" %>">
            <input type="radio" name="color" value="<%= Html.esc(c) %>" <%= sel ? "checked" : "" %>
                   onchange="this.form.submit()"><%= Html.esc(c) %>
          </label>
          <% } %>
        </div>
      </div>
      <% } %>

      <div class="filtro-grupo">
        <span class="filtro-label">Precio (COP)</span>
        <div class="precio-inputs">
          <div class="precio-field">
            <span>Mínimo</span>
            <input type="number" name="min" placeholder="0" value="<%= Html.esc(fMin) %>" min="0" step="5000">
          </div>
          <div class="precio-field">
            <span>Máximo</span>
            <input type="number" name="max" placeholder="Sin límite" value="<%= Html.esc(fMax) %>" min="0" step="5000">
          </div>
        </div>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Estado</span>
        <select name="estado" class="filtro-select" onchange="this.form.submit()">
          <option value=""      <%= fEstado.isEmpty()           ? "selected" : "" %>>Todos</option>
          <option value="nuevo" <%= "nuevo".equals(fEstado) ? "selected" : "" %>>Nuevo</option>
          <option value="usado" <%= "usado".equals(fEstado) ? "selected" : "" %>>Usado</option>
        </select>
      </div>

      <div class="filtro-grupo">
        <span class="filtro-label">Ordenar por</span>
        <select name="orden" class="filtro-select" onchange="this.form.submit()">
          <option value=""            <%= filtroOrden.isEmpty()                ? "selected" : "" %>>Relevancia</option>
          <option value="precio_asc"  <%= "precio_asc".equals(filtroOrden)  ? "selected" : "" %>>Menor precio</option>
          <option value="precio_desc" <%= "precio_desc".equals(filtroOrden) ? "selected" : "" %>>Mayor precio</option>
          <option value="nombre_asc"  <%= "nombre_asc".equals(filtroOrden)  ? "selected" : "" %>>Nombre A-Z</option>
          <option value="nombre_desc" <%= "nombre_desc".equals(filtroOrden) ? "selected" : "" %>>Nombre Z-A</option>
          <option value="stock_desc"  <%= "stock_desc".equals(filtroOrden)  ? "selected" : "" %>>Mayor stock</option>
          <option value="reciente"    <%= "reciente".equals(filtroOrden)    ? "selected" : "" %>>Más recientes</option>
        </select>
      </div>

      <div class="filtros-actions">
        <button type="submit" class="btn btn-primary">Aplicar filtros</button>
        <% if (hayFiltro) { %>
          <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary">Limpiar filtros</a>
        <% } %>
      </div>
    </form>
  </aside>

  <!-- PRODUCTOS -->
  <section class="productos-col">
    <div class="productos-inner">

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

      <!-- Etiquetas de filtros activos (CA023): cada una se quita con su "x" -->
      <% if (nFiltros > 0) { %>
        <div class="filtro-tags">
          <% for (String k : etiquetasTexto) {
               String v = filtros.get(k);
               if (v.isEmpty()) continue;
               String texto = k.equals("buscar") ? "\"" + v + "\"" : v;
          %>
            <span class="filtro-tag"><%= Html.esc(texto) %>
              <a href="<%= Html.esc(urlSin(ctx, filtros, k)) %>" title="Quitar filtro">x</a>
            </span>
          <% } %>
          <% if (!fMin.isEmpty() || !fMax.isEmpty()) {
               String textoPrecio = !fMin.isEmpty() && !fMax.isEmpty() ? "$" + fMin + " - $" + fMax
                                  : !fMin.isEmpty() ? "Desde $" + fMin : "Hasta $" + fMax;
          %>
            <span class="filtro-tag"><%= Html.esc(textoPrecio) %>
              <a href="<%= Html.esc(urlSin(ctx, filtros, "min", "max")) %>" title="Quitar filtro">x</a>
            </span>
          <% } %>
        </div>
      <% } %>

      <div class="catalogo-divider"></div>

      <% if (productos == null || productos.isEmpty()) { %>
        <% if (hayFiltro) { %>
          <div class="empty-state">
            <h3>Sin resultados</h3>
            <p>No encontramos productos con esos criterios. Prueba quitando algún filtro.</p>
            <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">Ver todos los productos</a>
          </div>
        <% } else { %>
          <div class="empty-state">
            <h3>El catálogo está vacío</h3>
            <p>Aún no hay productos publicados.</p>
            <% if ("admin".equals(rol) || "vendedor".equals(rol)) { %>
              <a href="<%= ctx %>/producto?accion=nuevo" class="btn btn-primary">Publicar producto</a>
            <% } %>
          </div>
        <% } %>
      <% } else { %>
        <div class="product-grid">
          <% for (Producto p : productos) {
               String detalleUrl = ctx + "/producto?accion=detalle&id=" + p.getIdProducto();
               String imgUrl     = p.getImagenUrl() != null ? p.getImagenUrl() : "";
               String inicial    = (p.getCategoria() != null && !p.getCategoria().isEmpty())
                                   ? p.getCategoria().substring(0, 1) : "L";
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
                <p class="card-cat"><%= Html.esc(p.getCategoria()) %></p>
                <h3 class="card-title"><%= Html.esc(p.getTitulo()) %></h3>
                <p class="card-price">$ <%= String.format("%,.0f", p.getPrecio()) %> COP</p>
                <% if (p.getStock() == 0) { %>
                  <p class="card-stock stock-cero">Sin stock</p>
                <% } else if (p.getStock() == 1) { %>
                  <p class="card-unica">Pieza única</p>
                <% } else { %>
                  <p class="card-stock"><%= p.getStock() %> disponibles</p>
                <% } %>
              </div>
            </a>
            <div class="card-body" style="padding-top:0;">
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
                  <a href="<%= ctx %>/producto?accion=editar&id=<%= p.getIdProducto() %>"
                     class="btn btn-sm btn-edit">Editar</a>
                  <a href="<%= ctx %>/producto?accion=eliminar&id=<%= p.getIdProducto() %>"
                     class="btn btn-sm btn-delete"
                     onclick="return confirm('¿Eliminar este producto?')">Eliminar</a>
                <% } %>
              </div>
            </div>
          </div>
          <% } %>
        </div>
      <% } %>
    </div>
  </section>

</div>

<script>
// Actualiza el contador de filtros mientras se escribe, sin recargar la página.
(function () {
  var form  = document.getElementById('filtrosForm');
  var badge = document.querySelector('.filtros-count');
  if (!form || !badge) return;
  var nombres = ['buscar', 'categoria', 'marca', 'talla', 'color', 'min', 'max', 'estado'];
  function contar() {
    var n = 0;
    nombres.forEach(function (nombre) {
      var campos = form.querySelectorAll('[name="' + nombre + '"]');
      if (!campos.length) return;
      var valor = '';
      if (campos[0].type === 'radio') {
        var marcado = form.querySelector('[name="' + nombre + '"]:checked');
        valor = marcado ? marcado.value : '';
      } else {
        valor = campos[0].value;
      }
      if (valor && String(valor).trim() !== '') n++;
    });
    badge.textContent = n;
    badge.classList.toggle('visible', n > 0);
  }
  form.addEventListener('input', contar);
})();
</script>
</body>
</html>
