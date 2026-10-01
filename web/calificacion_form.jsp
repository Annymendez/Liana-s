<%-- 
    Document   : calificacion_form
    Created on : 4/05/2026, 3:27:20 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Orden, model.Persona" %>
<%
    Orden   orden   = (Orden)   request.getAttribute("orden");
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  ctx     = request.getContextPath();
    String  nombre  = usuario != null ? usuario.getNombre() : "";
    String  rol     = usuario != null ? usuario.getTipo()   : "";
    String  error   = (String) request.getAttribute("error");
    if (orden == null) { response.sendRedirect(ctx + "/orden?accion=listar"); return; }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>MercadoRed — Calificar orden</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    .user-info { display:flex; align-items:center; gap:16px; font-size:.82rem; }
    .rol-badge { padding:3px 10px; border-radius:20px; font-size:.68rem; font-weight:700; letter-spacing:1px; text-transform:uppercase; background:#c8a882; color:#2c2217; }
    .cal-wrap  { min-height:70vh; display:flex; align-items:center; justify-content:center; padding:48px 20px; }
    .cal-card  { background:var(--white); border-radius:20px; padding:44px; width:100%; max-width:540px; box-shadow:var(--shadow); }
    .cal-title { font-family:var(--font-display); font-size:1.6rem; color:var(--dark); margin-bottom:8px; }
    .cal-sub   { color:var(--muted); font-size:.88rem; margin-bottom:32px; }
    .info-orden { background:var(--cream); border-radius:10px; padding:14px 18px; margin-bottom:24px; font-size:.88rem; }
    .info-orden strong { color:var(--dark); }

    /* Estrellas interactivas */
    .star-group { display:flex; gap:8px; margin:16px 0 8px; flex-direction:row-reverse; justify-content:flex-end; }
    .star-group input[type=radio] { display:none; }
    .star-group label {
      font-size:2.2rem; cursor:pointer; color:#ddd; transition:color .15s;
    }
    .star-group input:checked ~ label,
    .star-group label:hover,
    .star-group label:hover ~ label { color:#f5a623; }
    .star-hint { font-size:.78rem; color:var(--muted); margin-bottom:20px; }

    .form-group { margin-bottom:18px; }
    .form-group label { display:block; font-size:.7rem; font-weight:700; letter-spacing:1.5px; text-transform:uppercase; color:var(--muted); margin-bottom:6px; }
    .form-group textarea { width:100%; padding:12px; border:1.5px solid var(--sand); border-radius:8px; font-family:var(--font-body); font-size:.9rem; color:var(--dark); background:var(--cream); outline:none; resize:vertical; min-height:90px; box-sizing:border-box; transition:border-color .2s; }
    .form-group textarea:focus { border-color:var(--terra); background:#fff; }
    .acciones { display:flex; gap:10px; margin-top:8px; }
    .btn-block { flex:1; justify-content:center; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="cal-wrap">
  <div class="cal-card">
    <h1 class="cal-title">⭐ Calificar vendedor</h1>
    <p class="cal-sub">Cuéntanos cómo fue tu experiencia de compra</p>

    <% if (error != null) { %><div class="alert alert-error" style="margin-bottom:16px;"><%= error %></div><% } %>

    <div class="info-orden">
      📦 <strong>Orden #<%= orden.getIdOrden() %></strong> ·
      $ <%= String.format("%,.0f", orden.getTotal()) %> COP ·
      <span style="color:#2e7d32;font-weight:600;">Entregada</span>
    </div>

    <form action="<%= ctx %>/calificacion" method="post">
      <input type="hidden" name="idOrden" value="<%= orden.getIdOrden() %>"/>

      <div class="form-group">
        <label>Puntaje *</label>
        <div class="star-group">
          <input type="radio" name="puntaje" id="s5" value="5" required/>
          <label for="s5" title="5 - Excelente">★</label>
          <input type="radio" name="puntaje" id="s4" value="4"/>
          <label for="s4" title="4 - Muy bueno">★</label>
          <input type="radio" name="puntaje" id="s3" value="3"/>
          <label for="s3" title="3 - Bueno">★</label>
          <input type="radio" name="puntaje" id="s2" value="2"/>
          <label for="s2" title="2 - Regular">★</label>
          <input type="radio" name="puntaje" id="s1" value="1"/>
          <label for="s1" title="1 - Malo">★</label>
        </div>
        <p class="star-hint">Haz clic en las estrellas para seleccionar tu puntaje</p>
      </div>

      <div class="form-group">
        <label>Comentario <span style="color:var(--warm);font-weight:400;">(opcional)</span></label>
        <textarea name="comentario" maxlength="500"
                  placeholder="Describe tu experiencia: calidad del producto, tiempo de entrega, atención del vendedor..."></textarea>
      </div>

      <div class="acciones">
        <a href="<%= ctx %>/orden?accion=listar" class="btn btn-secondary">Cancelar</a>
        <button type="submit" class="btn btn-primary btn-block">⭐ Enviar calificación</button>
      </div>
    </form>
  </div>
</div>

<footer class="footer">
  <div class="footer-brand">MercadoRed</div>
  <p>© 2026 MercadoRed S.A.S. · Bogotá, Colombia</p>
</footer>
</body>
</html>
