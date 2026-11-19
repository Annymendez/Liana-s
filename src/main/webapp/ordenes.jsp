<%--
    Document   : Ordenes
    Created on : 8/04/2026, 10:25:57 p. m.
    Author     : annym
    Redesigned : Liana's — Rewind aesthetic
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Orden, model.Persona" %>
<%
    List<Orden> ordenes = (List<Orden>) request.getAttribute("ordenes");
    String msg   = request.getParameter("msg");
    String error = request.getParameter("error");
    String ctx   = request.getContextPath();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    boolean esComprador = "comprador".equals(rol);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Pedidos</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── SUBHEADER ── */
    .page-subheader { border-bottom: 1px solid #ddd; background: #fff; }
    .page-subheader-inner {
      max-width: 1000px; margin: 0 auto; padding: 24px 32px;
      display: flex; align-items: flex-end; justify-content: space-between; gap: 20px;
    }
    .page-subheader-inner .sub {
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 400;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa; margin: 0 0 4px;
    }
    .page-subheader-inner h1 {
      font-family: 'IM Fell English', Georgia, serif; font-size: 1.75rem;
      font-style: italic; font-weight: 400; color: #111; line-height: 1; margin: 0;
    }

    /* ── WRAPPER ── */
    .page-wrapper { max-width: 1000px; margin: 0 auto; padding: 40px 32px 80px; }

    /* ── ALERTAS ── */
    .msg {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      padding: 14px 18px; margin-bottom: 28px; border: 1px solid;
    }
    .msg-ok   { color: #2e7d32; border-color: #a5d6a7; background: #f1f8f1; }
    .msg-warn { color: #8b6000; border-color: #e6c97a; background: #fffbf0; }
    .msg-err  { color: #880e4f; border-color: #f48fb1; background: #fff0f4; }

    /* ── BOTONES ── */
    .r-btn {
      display: inline-block; padding: 7px 16px; border: 1px solid #111;
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 400;
      letter-spacing: .08em; text-transform: uppercase; text-decoration: none;
      background: transparent; color: #111; cursor: pointer;
      transition: background .15s, color .15s;
    }
    .r-btn:hover       { background: #111; color: #fff; }
    .r-btn-dark        { background: #111; color: #fff; }
    .r-btn-dark:hover  { background: #333; }
    .r-btn-gold        { border-color: #c8a46e; color: #c8a46e; }
    .r-btn-gold:hover  { background: #c8a46e; color: #fff; }
    .r-btn-muted       { border-color: #ddd; color: #888; }
    .r-btn-muted:hover { background: #880e4f; border-color: #880e4f; color: #fff; }

    /* ── TABLA ── */
    .orders-table { width: 100%; border-collapse: collapse; margin-bottom: 60px; }
    .orders-table thead th {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa;
      padding: 0 16px 12px; text-align: left; border-bottom: 1px solid #eee;
    }
    .orders-table tbody td {
      padding: 16px; border-bottom: 1px solid #eee;
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #333; vertical-align: middle;
    }
    .orders-table tbody tr:last-child td { border-bottom: none; }
    .orders-table tbody tr:hover { background: #fafafa; }
    .order-num  { font-weight: 500; color: #111; font-size: 12px; letter-spacing: .03em; }
    .buyer-name { color: #555; }
    .price-cell { color: #111; font-weight: 400; white-space: nowrap; }
    .price-cell small { color: #aaa; font-size: 10px; letter-spacing: .05em; margin-left: 2px; }
    .date-cell  { color: #aaa; font-size: 11px; white-space: nowrap; }
    .dash       { color: #ccc; }

    /* ── ESTADOS ── */
    .eb {
      display: inline-block; padding: 3px 10px; border: 1px solid;
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; white-space: nowrap;
    }
    .eb-pendiente { color: #c8a46e; border-color: #c8a46e; }
    .eb-pagado    { color: #111;    border-color: #111; }
    .eb-enviado   { color: #555;    border-color: #bbb; background: #f4f4f4; }
    .eb-entregado { color: #fff;    border-color: #111; background: #111; }
    .eb-cancelado { color: #aaa;    border-color: #ddd; text-decoration: line-through; }

    /* ── FONDOS ── */
    .fondos { font-size: 11px; letter-spacing: .05em; text-transform: uppercase; }
    .fondos-ret { color: #aaa; }
    .fondos-lib { color: #2e7d32; }

    /* ── FORM ESTADO ── */
    .estado-form { display: flex; gap: 6px; align-items: center; margin: 0; }
    .sel-estado {
      padding: 6px 8px; border: 1px solid #ddd; background: #fff; color: #111;
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 300;
      outline: none; cursor: pointer;
    }
    .sel-estado:focus { border-color: #c8a46e; }

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
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300; color: #888;
    }
    .empty-box .r-btn { margin-top: 24px; }

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

    @media (max-width: 700px) {
      .page-wrapper { padding: 24px 16px 60px; }
      .page-subheader-inner { padding: 16px; flex-direction: column; align-items: flex-start; }
    }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="page-subheader">
  <div class="page-subheader-inner">
    <div>
      <p class="sub"><%= esComprador ? "Tu historial de compras" : "Gestión de pedidos" %></p>
      <h1><%= esComprador ? "Mis Pedidos" : "Órdenes" %></h1>
    </div>
    <% if (esComprador) { %>
      <a href="<%= ctx %>/producto?accion=listar" class="r-btn">Seguir comprando</a>
    <% } %>
  </div>
</div>

<div class="page-wrapper">

  <%-- Mensajes --%>
  <% if ("calificado" .equals(msg))    { %><div class="msg msg-ok">Calificación enviada. ¡Gracias!</div><% } %>
  <% if ("creado"     .equals(msg))    { %><div class="msg msg-ok">Compra realizada correctamente.</div><% } %>
  <% if ("actualizado".equals(msg))    { %><div class="msg msg-ok">Estado actualizado.</div><% } %>
  <% if ("recibido"   .equals(msg))    { %><div class="msg msg-ok">Recepción confirmada. Fondos liberados.</div><% } %>
  <% if ("cancelado"  .equals(msg))    { %><div class="msg msg-warn">Orden cancelada.</div><% } %>
  <% if ("yaCalificado".equals(error)) { %><div class="msg msg-err">Ya calificaste esta orden.</div><% } %>

  <% if (ordenes == null || ordenes.isEmpty()) { %>
    <div class="empty-box">
      <p class="empty-eyebrow">Sin registros</p>
      <h3><%= esComprador ? "Aún no tienes pedidos" : "Aún no hay órdenes" %></h3>
      <p><%= esComprador
             ? "Cuando compres una pieza, aparecerá aquí con su estado de envío."
             : "Aparecerán aquí cuando los compradores adquieran tus productos." %></p>
      <% if (esComprador) { %>
        <a href="<%= ctx %>/producto?accion=listar" class="r-btn r-btn-dark">Ver catálogo</a>
      <% } %>
    </div>

  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="orders-table">
      <thead>
        <tr>
          <th>Orden</th>
          <% if (!esComprador) { %><th>Comprador</th><% } %>
          <th>Total</th>
          <th>Estado</th>
          <th>Fondos</th>
          <th>Fecha</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
      <% for (Orden o : ordenes) {
           String estadoOrden = o.getEstadoOrden() != null ? o.getEstadoOrden() : "";
      %>
        <tr>
          <td><span class="order-num">#<%= o.getIdOrden() %></span></td>
          <% if (!esComprador) { %>
            <td class="buyer-name"><%= o.getNombreComprador() != null ? o.getNombreComprador() : "Comprador" %></td>
          <% } %>
          <td class="price-cell">$ <%= String.format("%,.0f", o.getTotal()) %><small>COP</small></td>
          <td><span class="eb eb-<%= estadoOrden %>"><%= estadoOrden %></span></td>
          <td class="fondos <%= o.isFondosRetenidos() ? "fondos-ret" : "fondos-lib" %>">
            <%= o.isFondosRetenidos() ? "Retenidos" : "Liberados" %>
          </td>
          <td class="date-cell"><%= o.getFechaCreacion() %></td>
          <td>
            <%-- ── ACCIONES COMPRADOR ── --%>
            <% if (esComprador) { %>
              <% if ("enviado".equals(estadoOrden)) { %>
                <a href="<%= ctx %>/orden?accion=confirmarRecepcion&id=<%= o.getIdOrden() %>"
                   class="r-btn"
                   onclick="return confirm('¿Confirmas que recibiste el pedido?')">Confirmar recepción</a>
              <% } else if ("entregado".equals(estadoOrden)) { %>
                <a href="<%= ctx %>/calificacion?accion=formulario&idOrden=<%= o.getIdOrden() %>"
                   class="r-btn r-btn-gold">Calificar</a>
              <% } else if ("pendiente".equals(estadoOrden)) { %>
                <a href="<%= ctx %>/orden?accion=cancelar&id=<%= o.getIdOrden() %>"
                   class="r-btn r-btn-muted"
                   onclick="return confirm('¿Cancelar esta orden?')">Cancelar</a>
              <% } else { %>
                <span class="dash">—</span>
              <% } %>

            <%-- ── ACCIONES VENDEDOR / ADMIN ── --%>
            <% } else { %>
              <form action="<%= ctx %>/orden" method="get" class="estado-form">
                <input type="hidden" name="accion" value="cambiarEstado"/>
                <input type="hidden" name="id"     value="<%= o.getIdOrden() %>"/>
                <select name="estado" class="sel-estado">
                  <option value="pendiente" <%= "pendiente".equals(estadoOrden) ? "selected" : "" %>>Pendiente</option>
                  <option value="pagado"    <%= "pagado"   .equals(estadoOrden) ? "selected" : "" %>>Pagado</option>
                  <option value="enviado"   <%= "enviado"  .equals(estadoOrden) ? "selected" : "" %>>Enviado</option>
                  <option value="entregado" <%= "entregado".equals(estadoOrden) ? "selected" : "" %>>Entregado</option>
                  <option value="cancelado" <%= "cancelado".equals(estadoOrden) ? "selected" : "" %>>Cancelado</option>
                </select>
                <button type="submit" class="r-btn r-btn-dark">Guardar</button>
              </form>
            <% } %>
          </td>
        </tr>
      <% } %>
      </tbody>
    </table>
    </div>
  <% } %>
</div>

<footer class="liana-footer">
  <div class="brand">Liana's</div>
  <p>© 2026 Liana's · Bogotá, Colombia</p>
</footer>
</body>
</html>
