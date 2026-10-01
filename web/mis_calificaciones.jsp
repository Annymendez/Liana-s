<%-- 
    Document   : mis_calificaciones
    Created on : 4/05/2026, 3:31:31 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Calificacion, model.Persona" %>
<%
    List<Calificacion> calificaciones = (List<Calificacion>) request.getAttribute("calificaciones");
    double promedio = request.getAttribute("promedio") != null ? (Double) request.getAttribute("promedio") : 0.0;
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  ctx     = request.getContextPath();
    if (calificaciones == null) calificaciones = new java.util.ArrayList<>();
    int total = calificaciones.size();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Mis Calificaciones</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; background:#8b6247; color:#fff; }
    .rep-card { background:var(--white); border-radius:16px; padding:32px; box-shadow:var(--shadow-sm); display:flex; align-items:center; gap:32px; margin-bottom:40px; }
    .rep-score { font-family:var(--font-display); font-size:4rem; color:var(--terra); line-height:1; }
    .rep-stars { font-size:1.6rem; }
    .rep-total { color:var(--muted); font-size:.88rem; margin-top:6px; }
    .tabla { width:100%; border-collapse:collapse; background:var(--white); border-radius:12px; overflow:hidden; box-shadow:var(--shadow-sm); margin-bottom:60px; }
    .tabla thead th { background:var(--dark); color:var(--cream); padding:13px 18px; text-align:left; font-size:.78rem; letter-spacing:1px; text-transform:uppercase; }
    .tabla tbody td { padding:14px 18px; border-bottom:1px solid var(--sand); font-size:.88rem; vertical-align:middle; }
    .tabla tbody tr:hover { background:var(--cream); }
    .stars-display { color:#f5a623; font-size:1.1rem; }
    .comentario-cell { color:var(--muted); font-style:italic; max-width:300px; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="container">
  <div class="section-header">
    <div>
      <p class="sub">Sistema de reputación</p>
      <h2>⭐ Mis Calificaciones</h2>
    </div>
  </div>

  <%-- Tarjeta de reputación general --%>
  <div class="rep-card">
    <div>
      <div class="rep-score"><%= String.format("%.1f", promedio) %></div>
      <div class="rep-stars">
        <% for (int i = 1; i <= 5; i++) { %>
          <%= i <= (int) Math.round(promedio) ? "⭐" : "☆" %>
        <% } %>
      </div>
      <div class="rep-total"><%= total %> calificaciones recibidas</div>
    </div>
    <div>
      <p style="font-size:.88rem;color:var(--muted);line-height:1.8;max-width:300px;">
        Tu reputación se actualiza automáticamente con cada calificación que recibes de los compradores.
        Mantener una puntuación alta aumenta la visibilidad de tus productos.
      </p>
    </div>
  </div>

  <% if (calificaciones.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">⭐</div>
      <h3>Aún no tienes calificaciones</h3>
      <p>Las calificaciones aparecerán aquí cuando los compradores evalúen sus órdenes contigo.</p>
    </div>
  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="tabla">
      <thead>
        <tr>
          <th>Orden</th>
          <th>Comprador</th>
          <th>Puntaje</th>
          <th>Comentario</th>
          <th>Fecha</th>
        </tr>
      </thead>
      <tbody>
      <% for (Calificacion c : calificaciones) { %>
        <tr>
          <td><strong>#<%= c.getIdOrden() %></strong></td>
          <td><%= c.getNombreEvaluador() != null ? c.getNombreEvaluador() : "Comprador" %></td>
          <td>
            <span class="stars-display"><%= c.getEstrellas() %></span>
            <span style="font-size:.82rem;color:var(--muted);margin-left:4px;">(<%= c.getPuntaje() %>/5)</span>
          </td>
          <td class="comentario-cell">
            <%= (c.getComentario() != null && !c.getComentario().isEmpty())
                ? c.getComentario() : "Sin comentario" %>
          </td>
          <td style="color:var(--muted);font-size:.82rem;"><%= c.getFecha() %></td>
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

