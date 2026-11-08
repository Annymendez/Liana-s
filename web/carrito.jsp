<%--
    Document   : carrito
    Paso 1 de la compra: carrito (RF011 / CA024-CA026)

    Datos que recibe: la lista "carrito" (List<CarritoItem>) que guarda CarritoServlet en la sesión.
    Formularios y enlaces que usa el servlet (no cambiar estos nombres):
      POST /carrito  accion=actualizar, idProducto, cantidad
      GET  /carrito?accion=eliminar&id=...   |  ?accion=vaciar  |  ?accion=checkout
--%>
<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List, model.CarritoItem, model.Persona, util.Html" %>
<%
    List<CarritoItem> carrito = (List<CarritoItem>) session.getAttribute("carrito");
    if (carrito == null) carrito = new java.util.ArrayList<>();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  ctx     = request.getContextPath();
    String  msg     = request.getParameter("msg");
    String  err     = request.getParameter("error");

    double total = 0;
    for (CarritoItem i : carrito) total += i.getSubtotal();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Carrito</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <link rel="stylesheet" href="<%= ctx %>/compra.css">
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="container">

  <!-- Pasos de la compra -->
  <div class="wizard">
    <div class="wizard-step">
      <div class="step-circle activo">1</div>
      <div class="step-info"><span class="step-num">Paso 1</span><span class="step-name">Carrito</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">2</div>
      <div class="step-info"><span class="step-num">Paso 2</span><span class="step-name inactivo">Dirección</span></div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">3</div>
      <div class="step-info"><span class="step-num">Paso 3</span><span class="step-name inactivo">Pago</span></div>
    </div>
  </div>

  <% if ("agregado".equals(msg)) { %>
    <div class="alert alert-success" style="margin-bottom:20px;">Producto agregado al carrito.</div>
  <% } %>
  <% if ("vacio".equals(err)) { %>
    <div class="alert alert-warning" style="margin-bottom:20px;">Tu carrito está vacío. Agrega productos antes de continuar.</div>
  <% } %>
  <% if ("datos".equals(err)) { %>
    <div class="alert alert-error" style="margin-bottom:20px;">No pudimos procesar esa acción. Revisa tu carrito e inténtalo de nuevo.</div>
  <% } %>

  <% if (carrito.isEmpty()) { %>
    <div class="empty-state">
      <h3>Tu carrito está vacío</h3>
      <p>Explora el catálogo y agrega las piezas que quieras llevarte.</p>
      <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">Ver catálogo</a>
    </div>
  <% } else { %>
  <div class="carrito-layout">

    <!-- Productos del carrito (CA025) -->
    <div class="carrito-card">
      <div class="carrito-head">
        <h3>Carrito · <%= carrito.size() %> <%= carrito.size() == 1 ? "producto" : "productos" %></h3>
        <a href="<%= ctx %>/carrito?accion=vaciar"
           onclick="return confirm('¿Vaciar el carrito?')">Vaciar carrito</a>
      </div>

      <% for (CarritoItem item : carrito) {
           String titulo  = item.getTitulo() != null ? item.getTitulo() : "";
           String inicial = titulo.isEmpty() ? "L" : titulo.substring(0, 1).toUpperCase();
           boolean unica  = item.getStockDisponible() <= 1;
      %>
      <div class="carrito-item">
        <div class="item-inicial"><%= Html.esc(inicial) %></div>

        <div>
          <p class="item-cat"><%= Html.esc(item.getCategoria()) %></p>
          <p class="item-name">
            <a href="<%= ctx %>/producto?accion=detalle&id=<%= item.getIdProducto() %>"><%= Html.esc(titulo) %></a>
          </p>
          <p class="item-price">$ <%= String.format("%,.0f", item.getPrecioUnitario()) %> COP</p>
        </div>

        <div class="item-cantidad">
        <% if (unica) { %>
          <!-- Pieza única: solo hay una unidad, no tiene sentido cambiar la cantidad -->
          <span class="item-unica">Pieza única</span>
        <% } else { %>
          <form method="post" action="<%= ctx %>/carrito" id="form-<%= item.getIdProducto() %>">
            <input type="hidden" name="accion"     value="actualizar">
            <input type="hidden" name="idProducto" value="<%= item.getIdProducto() %>">
            <div class="qty-control">
              <button type="button" class="qty-btn" aria-label="Quitar una unidad"
                      onclick="cambiarCant(<%= item.getIdProducto() %>, -1, <%= item.getStockDisponible() %>)">-</button>
              <input type="number" name="cantidad" class="qty-input"
                     id="qty-<%= item.getIdProducto() %>"
                     value="<%= item.getCantidad() %>"
                     min="1" max="<%= item.getStockDisponible() %>"
                     onchange="this.form.submit()">
              <button type="button" class="qty-btn" aria-label="Agregar una unidad"
                      onclick="cambiarCant(<%= item.getIdProducto() %>, +1, <%= item.getStockDisponible() %>)">+</button>
            </div>
          </form>
        <% } %>
        </div>

        <div class="item-acciones">
          <span class="item-subtotal">$ <%= String.format("%,.0f", item.getSubtotal()) %></span>
          <a href="<%= ctx %>/carrito?accion=eliminar&id=<%= item.getIdProducto() %>"
             class="item-del"
             onclick="return confirm('¿Quitar este producto del carrito?')">Quitar</a>
        </div>
      </div>
      <% } %>
    </div>

    <!-- Resumen (CA026) -->
    <aside class="resumen-card">
      <div class="resumen-head">Resumen de compra</div>
      <div class="resumen-body">
        <% for (CarritoItem item : carrito) { %>
        <div class="resumen-row">
          <span><%= Html.esc(item.getTitulo()) %><% if (item.getCantidad() > 1) { %> × <%= item.getCantidad() %><% } %></span>
          <strong>$ <%= String.format("%,.0f", item.getSubtotal()) %></strong>
        </div>
        <% } %>
        <div class="resumen-div"></div>
        <div class="resumen-total">
          <span class="lbl">Total</span>
          <span class="amt">$ <%= String.format("%,.0f", total) %></span>
        </div>
        <p class="resumen-moneda">Valores en pesos colombianos (COP)</p>

        <div class="resumen-botones">
          <a href="<%= ctx %>/carrito?accion=checkout" class="btn btn-primary">Continuar: dirección de envío</a>
          <a href="<%= ctx %>/producto?accion=listar" class="btn btn-secondary">Seguir comprando</a>
        </div>

        <div class="resumen-notas">
          Envío a todo Colombia<br>
          Confirmas la recepción desde tus pedidos
        </div>
      </div>
    </aside>
  </div>
  <% } %>
</div>

<footer class="footer">
  <div class="footer-brand">Liana's</div>
  <p>© 2026 Liana's · Bogotá, Colombia</p>
</footer>

<script>
// Sube o baja la cantidad de un producto y envía el formulario.
function cambiarCant(id, delta, maxStock) {
  var input = document.getElementById('qty-' + id);
  var val = parseInt(input.value, 10) + delta;
  if (isNaN(val) || val < 1) val = 1;
  if (val > maxStock)        val = maxStock;
  input.value = val;
  document.getElementById('form-' + id).submit();
}
</script>
</body>
</html>
