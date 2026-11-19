<%--
    Document   : mis_calificaciones
    Redesigned : Liana's — Rewind aesthetic
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
    int total       = calificaciones.size();
    int promedioInt = (int) Math.round(promedio);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Mis Calificaciones</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── SUBHEADER ── */
    .page-subheader { border-bottom: 1px solid #ddd; background: #fff; }
    .page-subheader-inner {
      max-width: 1000px; margin: 0 auto; padding: 24px 32px;
    }
    .page-subheader-inner .sub {
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 400;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa; margin-bottom: 4px;
    }
    .page-subheader-inner h1 {
      font-family: 'IM Fell English', Georgia, serif; font-size: 1.75rem;
      font-style: italic; font-weight: 400; color: #111; line-height: 1; margin: 0;
    }

    /* ── WRAPPER ── */
    .page-wrapper { max-width: 1000px; margin: 0 auto; padding: 40px 32px 80px; }

    /* ── REP SUMMARY ── */
    .rep-summary {
      display: flex; align-items: center; gap: 48px;
      border: 1px solid #ddd; padding: 32px 36px; margin-bottom: 40px; background: #fff;
    }
    .rep-score-num {
      font-family: 'IM Fell English', Georgia, serif; font-size: 4rem;
      font-weight: 400; color: #111; line-height: 1;
    }
    .rep-stars-row { display: flex; gap: 3px; margin: 8px 0 6px; }
    .star-icon { width: 18px; height: 18px; fill: currentColor; }
    .star-on  { color: #c8a46e; }
    .star-off { color: #ddd; }
    .rep-count {
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 400;
      letter-spacing: .05em; text-transform: uppercase; color: #aaa;
    }
    .rep-desc {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #666; line-height: 1.8; max-width: 340px;
    }

    /* ── TABLE ── */
    .reviews-table { width: 100%; border-collapse: collapse; margin-bottom: 60px; }
    .reviews-table thead th {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa;
      padding: 0 16px 12px; text-align: left; border-bottom: 1px solid #eee;
    }
    .reviews-table tbody td {
      padding: 16px; border-bottom: 1px solid #eee;
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #333; vertical-align: middle;
    }
    .reviews-table tbody tr:last-child td { border-bottom: none; }
    .reviews-table tbody tr:hover { background: #fafafa; }
    .order-num  { font-weight: 500; color: #111; font-size: 12px; letter-spacing: .03em; }
    .buyer-name { color: #555; }
    .comment-cell { color: #888; font-style: italic; max-width: 280px; }
    .date-cell { color: #aaa; font-size: 11px; white-space: nowrap; }

    .stars-inline { display: inline-flex; gap: 2px; vertical-align: middle; }
    .stars-inline .star-icon { width: 13px; height: 13px; }
    .score-label { font-size: 11px; color: #aaa; margin-left: 5px; vertical-align: middle;
                   font-family: 'Inter', sans-serif; font-weight: 300; }

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
      .rep-summary { flex-direction: column; gap: 20px; padding: 24px; }
      .page-wrapper { padding: 24px 16px 60px; }
      .page-subheader-inner { padding: 16px; }
    }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="page-subheader">
  <div class="page-subheader-inner">
    <p class="sub">Reputación del vendedor</p>
    <h1>Mis Calificaciones</h1>
  </div>
</div>

<div class="page-wrapper">

  <%-- Tarjeta de reputación --%>
  <div class="rep-summary">
    <div>
      <div class="rep-score-num"><%= String.format("%.1f", promedio) %></div>
      <div class="rep-stars-row">
        <% for (int i = 1; i <= 5; i++) { %>
          <svg class="star-icon <%= i <= promedioInt ? "star-on" : "star-off" %>"
               viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
          </svg>
        <% } %>
      </div>
      <div class="rep-count"><%= total %> calificaciones recibidas</div>
    </div>
    <p class="rep-desc">
      Tu reputación se actualiza automáticamente con cada calificación que recibes de los compradores.
      Mantener una puntuación alta aumenta la visibilidad de tus productos.
    </p>
  </div>

  <% if (calificaciones.isEmpty()) { %>
    <div class="empty-box">
      <p class="empty-eyebrow">Sin registros</p>
      <h3>Aún no tienes calificaciones</h3>
      <p>Aparecerán aquí cuando los compradores evalúen sus órdenes contigo.</p>
    </div>
  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="reviews-table">
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
          <td><span class="order-num">#<%= c.getIdOrden() %></span></td>
          <td class="buyer-name">
            <%= c.getNombreEvaluador() != null ? c.getNombreEvaluador() : "Comprador" %>
          </td>
          <td>
            <span class="stars-inline">
              <% for (int i = 1; i <= 5; i++) { %>
                <svg class="star-icon <%= i <= c.getPuntaje() ? "star-on" : "star-off" %>"
                     viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
                </svg>
              <% } %>
            </span>
            <span class="score-label">(<%= c.getPuntaje() %>/5)</span>
          </td>
          <td class="comment-cell">
            <%= (c.getComentario() != null && !c.getComentario().isEmpty())
                ? c.getComentario() : "Sin comentario" %>
          </td>
          <td class="date-cell"><%= c.getFecha() %></td>
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
