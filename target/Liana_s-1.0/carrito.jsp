<%--
    Document   : carrito
    Redesigned : Liana's — Rewind aesthetic
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.CarritoItem, model.Persona" %>
<%
    List<CarritoItem> carrito = (List<CarritoItem>) session.getAttribute("carrito");
    if (carrito == null) carrito = new java.util.ArrayList<>();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";
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
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── WRAPPER ── */
    .page-wrapper { max-width: 1000px; margin: 0 auto; padding: 0 32px; }

    /* ── ALERTAS ── */
    .msg {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      padding: 14px 18px; margin-bottom: 24px; border: 1px solid;
    }
    .msg-ok   { color: #2e7d32; border-color: #a5d6a7; background: #f1f8f1; }
    .msg-warn { color: #8b6000; border-color: #e6c97a; background: #fffbf0; }

    /* ── WIZARD DE PASOS ── */
    .wizard {
      display: flex; align-items: center; max-width: 480px; margin: 40px 0 48px;
    }
    .wizard-step {
      display: flex; align-items: center; gap: 10px; flex: 1; position: relative;
    }
    .wizard-step:not(:last-child)::after {
      content: ''; position: absolute; left: 36px; top: 15px;
      width: calc(100% - 36px); height: 1px; background: #eee; z-index: 0;
    }
    .step-circle {
      width: 30px; height: 30px; border: 1px solid #ddd;
      display: flex; align-items: center; justify-content: center;
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 500;
      flex-shrink: 0; position: relative; z-index: 1;
      background: #fff; color: #aaa; transition: all .2s;
    }
    .step-circle.activo { background: #111; color: #fff; border-color: #111; }
    .step-circle.listo  { background: #4a7c59; color: #fff; border-color: #4a7c59; }
    .step-info { display: flex; flex-direction: column; }
    .step-num  {
      font-family: 'Inter', sans-serif; font-size: 9px; letter-spacing: .1em;
      text-transform: uppercase; color: #aaa;
    }
    .step-name {
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 500; color: #111;
    }
    .step-name.inactivo { color: #aaa; font-weight: 300; }

    /* ── LAYOUT ── */
    .carrito-layout {
      display: grid; grid-template-columns: 1fr 300px; gap: 32px;
      align-items: start; padding-bottom: 80px;
    }

    /* ── ITEMS CARD ── */
    .carrito-card { background: #fff; border: 1px solid #ddd; overflow: hidden; }
    .carrito-head {
      background: #111; color: #fff; padding: 14px 24px;
      display: flex; align-items: center; justify-content: space-between;
    }
    .carrito-head h3 {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .15em; text-transform: uppercase; margin: 0; color: #fff;
    }
    .carrito-head a {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 300;
      color: #aaa; text-decoration: none; letter-spacing: .05em; transition: color .15s;
    }
    .carrito-head a:hover { color: #fff; }

    .carrito-item {
      display: grid; grid-template-columns: 36px 1fr auto auto;
      gap: 16px; align-items: center; padding: 18px 24px;
      border-bottom: 1px solid #eee;
    }
    .carrito-item:last-child { border-bottom: none; }

    .item-inicial {
      width: 36px; height: 36px; background: #f5f2ee;
      display: flex; align-items: center; justify-content: center;
      font-family: 'IM Fell English', Georgia, serif; font-size: 1rem;
      font-style: italic; color: #c8a46e; flex-shrink: 0;
    }
    .item-cat {
      font-family: 'Inter', sans-serif; font-size: 9px; letter-spacing: .12em;
      text-transform: uppercase; color: #aaa; font-weight: 500; margin-bottom: 2px;
    }
    .item-name {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 400;
      color: #111; margin-bottom: 2px;
    }
    .item-price {
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 300; color: #888;
    }

    /* ── CANTIDAD ── */
    .qty-control {
      display: flex; align-items: center; border: 1px solid #ddd; overflow: hidden;
    }
    .qty-btn {
      width: 28px; height: 28px; background: #fafafa; border: none;
      cursor: pointer; font-size: .9rem; color: #555;
      display: flex; align-items: center; justify-content: center;
      transition: background .12s;
    }
    .qty-btn:hover { background: #eee; }
    .qty-input {
      width: 36px; height: 28px; text-align: center; border: none; border-left: 1px solid #eee;
      border-right: 1px solid #eee; font-family: 'Inter', sans-serif; font-size: 12px;
      font-weight: 500; color: #111; background: #fff; outline: none;
    }

    .item-acciones { display: flex; flex-direction: column; align-items: flex-end; gap: 6px; }
    .item-subtotal {
      font-family: 'Inter', sans-serif; font-weight: 500; font-size: 13px; color: #111;
    }
    .item-del {
      font-family: 'Inter', sans-serif; color: #bbb; text-decoration: none;
      font-size: 10px; letter-spacing: .05em; transition: color .15s;
    }
    .item-del:hover { color: #c0392b; }

    /* ── RESUMEN LATERAL ── */
    .resumen-card {
      background: #fff; border: 1px solid #ddd; overflow: hidden; position: sticky; top: 88px;
    }
    .resumen-head {
      background: #f7f5f2; border-bottom: 1px solid #ddd; padding: 14px 22px;
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .15em; text-transform: uppercase; color: #555;
    }
    .resumen-body { padding: 22px; }
    .resumen-row {
      display: flex; justify-content: space-between; margin-bottom: 8px;
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 300; color: #888;
    }
    .resumen-row strong {
      font-family: 'Inter', sans-serif; font-weight: 400; color: #333;
    }
    .resumen-div { height: 1px; background: #eee; margin: 14px 0; }
    .resumen-total { display: flex; justify-content: space-between; align-items: baseline; }
    .resumen-total .lbl {
      font-family: 'Inter', sans-serif; font-size: 10px; letter-spacing: .1em;
      text-transform: uppercase; color: #aaa; font-weight: 500;
    }
    .resumen-total .amt {
      font-family: 'IM Fell English', Georgia, serif; font-size: 1.5rem;
      font-style: italic; font-weight: 400; color: #111;
    }
    .resumen-currency {
      font-family: 'Inter', sans-serif; font-size: 10px; color: #aaa;
      text-align: right; margin-top: 2px; font-weight: 300;
    }

    /* ── BOTONES RESUMEN ── */
    .resumen-actions { margin-top: 20px; display: flex; flex-direction: column; gap: 8px; }
    .btn-checkout {
      display: block; padding: 12px; background: #111; color: #fff; text-decoration: none;
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 500;
      letter-spacing: .08em; text-transform: uppercase; text-align: center;
      transition: background .15s;
    }
    .btn-checkout:hover { background: #333; }
    .btn-seguir {
      display: block; padding: 11px; background: #fff; color: #555; text-decoration: none;
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 400;
      letter-spacing: .05em; text-align: center; border: 1px solid #ddd;
      transition: border-color .15s, color .15s;
    }
    .btn-seguir:hover { border-color: #111; color: #111; }

    .resumen-notas {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 300;
      color: #aaa; line-height: 2; margin-top: 16px; text-align: center;
      letter-spacing: .03em;
    }

    /* ── EMPTY ── */
    .empty-box { border: 1px solid #eee; text-align: center; padding: 80px 40px; }
    .empty-box .empty-eyebrow {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .15em; text-transform: uppercase; color: #aaa; margin-bottom: 12px;
    }
    .empty-box h3 {
      font-family: 'IM Fell English', Georgia, serif; font-style: italic;
      font-weight: 400; font-size: 1.4rem; color: #111; margin-bottom: 10px;
    }
    .empty-box p {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #888; margin-bottom: 24px;
    }
    .btn-ver-catalogo {
      display: inline-block; padding: 11px 28px; background: #111; color: #fff;
      text-decoration: none; font-family: 'Inter', sans-serif; font-size: 11px;
      font-weight: 500; letter-spacing: .08em; text-transform: uppercase;
      transition: background .15s;
    }
    .btn-ver-catalogo:hover { background: #333; }

    /* ── FOOTER ── */
    .liana-footer { border-top: 1px solid #eee; padding: 32px; text-align: center; }
    .liana-footer .brand {
      font-family: 'IM Fell English', Georgia, serif; font-style: italic;
      font-size: 1.1rem; color: #111; margin-bottom: 6px;
    }
    .liana-footer p {
      font-family: 'Inter', sans-serif; font-size: 11px;
      letter-spacing: .05em; color: #aaa; font-weight: 300;
    }

    @media (max-width: 800px) {
      .carrito-layout { grid-template-columns: 1fr; }
      .resumen-card { position: static; }
      .page-wrapper { padding: 0 16px; }
    }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="page-wrapper">

  <!-- Wizard de pasos -->
  <div class="wizard">
    <div class="wizard-step">
      <div class="step-circle activo">1</div>
      <div class="step-info">
        <span class="step-num">Paso 1</span>
        <span class="step-name">Carrito</span>
      </div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">2</div>
      <div class="step-info">
        <span class="step-num">Paso 2</span>
        <span class="step-name inactivo">Dirección</span>
      </div>
    </div>
    <div class="wizard-step">
      <div class="step-circle">3</div>
      <div class="step-info">
        <span class="step-num">Paso 3</span>
        <span class="step-name inactivo">Pago</span>
      </div>
    </div>
  </div>

  <% if ("agregado".equals(msg)) { %>
    <div class="msg msg-ok">Producto agregado al carrito.</div>
  <% } %>
  <% if ("vacio".equals(err)) { %>
    <div class="msg msg-warn">Tu carrito está vacío. Agrega productos antes de continuar.</div>
  <% } %>

  <% if (carrito.isEmpty()) { %>
    <div class="empty-box">
      <p class="empty-eyebrow">Carrito vacío</p>
      <h3>Nada por aquí aún</h3>
      <p>Explora el catálogo y agrega los productos que quieras comprar.</p>
      <a href="<%= ctx %>/producto?accion=listar" class="btn-ver-catalogo">Ver catálogo</a>
    </div>
  <% } else { %>
  <div class="carrito-layout">

    <!-- Items del carrito -->
    <div class="carrito-card">
      <div class="carrito-head">
        <h3>Carrito &middot; <%= carrito.size() %> <%= carrito.size()==1 ? "producto" : "productos" %></h3>
        <a href="<%= ctx %>/carrito?accion=vaciar"
           onclick="return confirm('¿Vaciar el carrito?')">Vaciar</a>
      </div>

      <% for (CarritoItem item : carrito) { %>
      <div class="carrito-item">
        <div class="item-inicial">
          <%= item.getTitulo() != null && !item.getTitulo().isEmpty()
              ? String.valueOf(item.getTitulo().charAt(0)).toUpperCase() : "P" %>
        </div>
        <div>
          <p class="item-name"><%= item.getTitulo() %></p>
          <p class="item-price">
            $&nbsp;<%= String.format("%,.0f", item.getPrecioUnitario()) %> COP
            &nbsp;&middot;&nbsp; Stock: <%= item.getStockDisponible() %>
          </p>
        </div>

        <form method="post" action="<%= ctx %>/carrito" id="form-<%= item.getIdProducto() %>">
          <input type="hidden" name="accion"     value="actualizar">
          <input type="hidden" name="idProducto" value="<%= item.getIdProducto() %>">
          <div class="qty-control">
            <button type="button" class="qty-btn"
                    data-id="<%= item.getIdProducto() %>"
                    data-delta="-1"
                    data-max="<%= item.getStockDisponible() %>"
                    onclick="cambiarCant(this)">−</button>
            <input type="number" name="cantidad" class="qty-input"
                   id="qty-<%= item.getIdProducto() %>"
                   value="<%= item.getCantidad() %>"
                   min="1" max="<%= item.getStockDisponible() %>"
                   onchange="this.form.submit()">
            <button type="button" class="qty-btn"
                    data-id="<%= item.getIdProducto() %>"
                    data-delta="1"
                    data-max="<%= item.getStockDisponible() %>"
                    onclick="cambiarCant(this)">+</button>
          </div>
        </form>

        <div class="item-acciones">
          <span class="item-subtotal">$&nbsp;<%= String.format("%,.0f", item.getSubtotal()) %></span>
          <a href="<%= ctx %>/carrito?accion=eliminar&id=<%= item.getIdProducto() %>"
             class="item-del"
             onclick="return confirm('¿Quitar este producto del carrito?')">Quitar</a>
        </div>
      </div>
      <% } %>
    </div>

    <!-- Resumen lateral -->
    <aside class="resumen-card">
      <div class="resumen-head">Resumen de compra</div>
      <div class="resumen-body">
        <% for (CarritoItem item : carrito) { %>
        <div class="resumen-row">
          <span><%= item.getTitulo() %> x<%= item.getCantidad() %></span>
          <strong>$&nbsp;<%= String.format("%,.0f", item.getSubtotal()) %></strong>
        </div>
        <% } %>
        <div class="resumen-div"></div>
        <div class="resumen-total">
          <span class="lbl">Total</span>
          <span class="amt">$&nbsp;<%= String.format("%,.0f", total) %></span>
        </div>
        <p class="resumen-currency">COP · IVA incluido</p>

        <div class="resumen-actions">
          <a href="<%= ctx %>/carrito?accion=checkout" class="btn-checkout">
            Continuar — Dirección de envío
          </a>
          <a href="<%= ctx %>/producto?accion=listar" class="btn-seguir">
            Seguir comprando
          </a>
        </div>

        <p class="resumen-notas">
          Pago 100% seguro<br>
          Envío a todo Colombia<br>
          Fondos protegidos hasta recibir
        </p>
      </div>
    </aside>
  </div>
  <% } %>
</div>

<footer class="liana-footer">
  <div class="brand">Liana's</div>
  <p>© 2026 Liana's · Bogotá, Colombia</p>
</footer>

<script>
function cambiarCant(btn) {
  var id       = btn.getAttribute('data-id');
  var delta    = parseInt(btn.getAttribute('data-delta'));
  var maxStock = parseInt(btn.getAttribute('data-max'));
  var input = document.getElementById('qty-' + id);
  var val = parseInt(input.value) + delta;
  if (val < 1)        val = 1;
  if (val > maxStock) val = maxStock;
  input.value = val;
  document.getElementById('form-' + id).submit();
}
</script>
</body>
</html>
