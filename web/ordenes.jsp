<%-- 
    Document   : Ordenes
    Created on : 8/04/2026, 10:25:57 p. m.
    Author     : annym
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
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Pedidos</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
.rol-admin   { background:#2c2217; color:#f5f0e8; }
    .rol-vendedor{ background:#8b6247; color:#fff; }
    .rol-comprador{ background:#c8a882; color:#2c2217; }

    .tabla { width:100%; border-collapse:collapse; background:var(--white); border-radius:12px; overflow:hidden; box-shadow:var(--shadow-sm); margin-bottom:60px; }
    .tabla thead th { background:var(--dark); color:var(--cream); padding:14px 18px; text-align:left; font-size:.78rem; letter-spacing:1px; text-transform:uppercase; }
    .tabla tbody td { padding:13px 18px; border-bottom:1px solid var(--sand); font-size:.9rem; vertical-align:middle; }
    .tabla tbody tr:hover { background:var(--cream); }

    .eb           { padding:4px 12px; border-radius:20px; font-size:.72rem; font-weight:700; text-transform:uppercase; }
    .eb-pendiente { background:#fff8e1; color:#8b6000; }
    .eb-pagado    { background:#e8f5e9; color:#2e7d32; }
    .eb-enviado   { background:#e3f2fd; color:#1565c0; }
    .eb-entregado { background:#f3e5f5; color:#6a1b9a; }
    .eb-cancelado { background:#fce4ec; color:#880e4f; }

    .btn-cal {
      display:inline-block;
      background:#f5a623; color:#fff !important;
      padding:6px 14px; border-radius:8px;
      font-size:.8rem; font-weight:700;
      text-decoration:none; border:none; cursor:pointer;
    }
    .btn-cal:hover { background:#d4881a; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="container">

  <div class="section-header">
    <div>
      <p class="sub"><%= "comprador".equals(rol) ? "Tu historial de compras" : "Gestión de pedidos" %></p>
      <h2><%= "comprador".equals(rol) ? "Mis Pedidos" : "Órdenes" %></h2>
    </div>
    <% if ("comprador".equals(rol)) { %>
      <a href="<%= ctx %>/producto?accion=listar" class="btn btn-outline">🛍️ Seguir comprando</a>
    <% } %>
  </div>

  <%-- Mensajes --%>
  <% if ("calificado".equals(msg)) { %><div class="alert alert-success">⭐ Calificación enviada. ¡Gracias!</div><% } %>
  <% if ("creado".equals(msg))     { %><div class="alert alert-success">✅ Compra realizada correctamente.</div><% } %>
  <% if ("actualizado".equals(msg)){ %><div class="alert alert-success">✅ Estado actualizado.</div><% } %>
  <% if ("recibido".equals(msg))   { %><div class="alert alert-success">✅ Recepción confirmada. Fondos liberados.</div><% } %>
  <% if ("cancelado".equals(msg))  { %><div class="alert alert-warning">🗑️ Orden cancelada.</div><% } %>
  <% if ("yaCalificado".equals(error)) { %><div class="alert alert-error">⚠️ Ya calificaste esta orden.</div><% } %>

  <% if (ordenes == null || ordenes.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">📦</div>
      <h3><%= "comprador".equals(rol) ? "Aún no tienes pedidos" : "No hay órdenes" %></h3>
      <% if ("comprador".equals(rol)) { %>
        <a href="<%= ctx %>/producto?accion=listar" class="btn btn-primary">🛍️ Ver catálogo</a>
      <% } %>
    </div>
  <% } else { %>
  <div style="overflow-x:auto;">
  <table class="tabla">
    <thead>
      <tr>
        <th>#</th>
        <% if (!"comprador".equals(rol)) { %><th>Comprador</th><% } %>
        <th>Total</th>
        <th>Estado</th>
        <th>Fondos</th>
        <th>Fecha</th>
        <th>Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% for (Orden o : ordenes) {
         String estadoOrden = o.getEstadoOrden(); // "pendiente","pagado","enviado","entregado","cancelado"
    %>
      <tr>
        <td><strong>#<%= o.getIdOrden() %></strong></td>
        <% if (!"comprador".equals(rol)) { %>
          <td><%= o.getNombreComprador() %></td>
        <% } %>
        <td style="font-weight:700;color:var(--terra);">$ <%= String.format("%,.0f", o.getTotal()) %> COP</td>
        <td><span class="eb eb-<%= estadoOrden %>"><%= estadoOrden.toUpperCase() %></span></td>
        <td><%= o.isFondosRetenidos() ? "🔒 Retenidos" : "✅ Liberados" %></td>
        <td style="color:var(--muted);font-size:.82rem;"><%= o.getFechaCreacion() %></td>
        <td>
          <%-- ── ACCIONES PARA COMPRADOR ── --%>
          <% if ("comprador".equals(rol)) { %>

            <% if ("enviado".equals(estadoOrden)) { %>
              <a href="<%= ctx %>/orden?accion=confirmarRecepcion&id=<%= o.getIdOrden() %>"
                 class="btn btn-sm btn-edit"
                 onclick="return confirm('¿Confirmas que recibiste el pedido?')">
                 ✅ Confirmar recepción
              </a>
            <% } else if ("entregado".equals(estadoOrden)) { %>
              <a href="<%= ctx %>/calificacion?accion=formulario&idOrden=<%= o.getIdOrden() %>"
                 class="btn-cal">
                 ⭐ Calificar
              </a>
            <% } else if ("pendiente".equals(estadoOrden)) { %>
              <a href="<%= ctx %>/orden?accion=cancelar&id=<%= o.getIdOrden() %>"
                 class="btn btn-sm btn-delete"
                 onclick="return confirm('¿Cancelar esta orden?')">❌ Cancelar</a>
            <% } else { %>
              <span style="color:var(--muted);font-size:.8rem;">—</span>
            <% } %>

          <%-- ── ACCIONES PARA VENDEDOR / ADMIN ── --%>
          <% } else { %>
            <form action="<%= ctx %>/orden" method="get" style="display:flex;gap:6px;align-items:center;">
              <input type="hidden" name="accion" value="cambiarEstado"/>
              <input type="hidden" name="id" value="<%= o.getIdOrden() %>"/>
              <select name="estado" style="padding:5px 8px;border:1.5px solid var(--sand);border-radius:4px;font-size:.78rem;background:var(--cream);">
                <option value="pendiente"  <%= "pendiente" .equals(estadoOrden) ? "selected":"" %>>Pendiente</option>
                <option value="pagado"     <%= "pagado"    .equals(estadoOrden) ? "selected":"" %>>Pagado</option>
                <option value="enviado"    <%= "enviado"   .equals(estadoOrden) ? "selected":"" %>>Enviado</option>
                <option value="entregado"  <%= "entregado" .equals(estadoOrden) ? "selected":"" %>>Entregado</option>
                <option value="cancelado"  <%= "cancelado" .equals(estadoOrden) ? "selected":"" %>>Cancelado</option>
              </select>
              <button type="submit" class="btn btn-sm btn-edit">Guardar</button>
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

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
