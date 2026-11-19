<%--
    Document   : calificacion_form
    Redesigned : Liana's — Rewind aesthetic
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
  <title>Liana's — Calificar orden</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── LAYOUT ── */
    .cal-wrap {
      min-height: 70vh; display: flex; align-items: center; justify-content: center;
      padding: 48px 20px; background: #fafafa;
    }
    .cal-card {
      background: #fff; border: 1px solid #ddd;
      padding: 44px; width: 100%; max-width: 520px;
    }

    /* ── TYPOGRAPHY ── */
    .cal-eyebrow {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .15em; text-transform: uppercase; color: #aaa; margin-bottom: 8px;
    }
    .cal-title {
      font-family: 'IM Fell English', Georgia, serif; font-size: 1.6rem;
      font-style: italic; font-weight: 400; color: #111; margin-bottom: 6px; line-height: 1.2;
    }
    .cal-sub {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #888; margin-bottom: 28px;
    }

    /* ── ORDEN INFO ── */
    .info-orden {
      background: #f7f5f2; border-left: 2px solid #c8a46e;
      padding: 12px 16px; margin-bottom: 28px;
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300; color: #555;
    }
    .info-orden strong { color: #111; font-weight: 500; }
    .info-orden .entregada { color: #4a7c59; font-weight: 500; }

    /* ── FORM ── */
    .form-grupo { margin-bottom: 22px; }
    .form-label {
      display: block; font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .12em; text-transform: uppercase; color: #aaa; margin-bottom: 10px;
    }
    .form-label .optional {
      font-weight: 300; text-transform: none; letter-spacing: 0; color: #bbb;
    }

    /* ── STAR SELECTOR ── */
    .star-group {
      display: flex; gap: 6px; margin-bottom: 6px;
      flex-direction: row-reverse; justify-content: flex-end;
    }
    .star-group input[type=radio] { display: none; }
    .star-group label {
      cursor: pointer; color: #ddd; transition: color .12s; line-height: 1;
    }
    .star-group label svg {
      width: 28px; height: 28px; display: block; fill: currentColor;
    }
    /* CSS trick: row-reverse + ~ selects preceding stars */
    .star-group input:checked ~ label,
    .star-group label:hover,
    .star-group label:hover ~ label { color: #c8a46e; }

    .star-hint {
      font-family: 'Inter', sans-serif; font-size: 11px; color: #bbb;
      margin-top: 4px; margin-bottom: 20px;
    }

    /* ── TEXTAREA ── */
    .form-textarea {
      width: 100%; padding: 12px; border: 1px solid #ccc; border-radius: 0;
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #111; background: #fff; outline: none;
      resize: vertical; min-height: 90px; box-sizing: border-box;
      transition: border-color .15s;
    }
    .form-textarea:focus { border-color: #111; }
    .form-textarea::placeholder { color: #bbb; }

    /* ── BUTTONS ── */
    .acciones { display: flex; gap: 10px; margin-top: 10px; }
    .btn-cancel {
      padding: 11px 20px; border: 1px solid #ccc; background: #fff;
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 400;
      letter-spacing: .05em; color: #555; text-decoration: none; cursor: pointer;
      transition: border-color .15s, color .15s; display: inline-flex; align-items: center;
    }
    .btn-cancel:hover { border-color: #111; color: #111; }
    .btn-submit {
      flex: 1; padding: 11px 20px; border: none; background: #111;
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 500;
      letter-spacing: .08em; text-transform: uppercase; color: #fff;
      cursor: pointer; transition: background .15s;
    }
    .btn-submit:hover { background: #333; }

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
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="cal-wrap">
  <div class="cal-card">
    <p class="cal-eyebrow">Tu opinión importa</p>
    <h1 class="cal-title">Calificar vendedor</h1>
    <p class="cal-sub">Cuéntanos cómo fue tu experiencia de compra</p>

    <% if (error != null) { %>
      <div class="alert alert-error" style="margin-bottom:16px;"><%= error %></div>
    <% } %>

    <div class="info-orden">
      Orden <strong>#<%= orden.getIdOrden() %></strong>
      &nbsp;·&nbsp; $&nbsp;<%= String.format("%,.0f", orden.getTotal()) %> COP
      &nbsp;·&nbsp; <span class="entregada">Entregada</span>
    </div>

    <form action="<%= ctx %>/calificacion" method="post">
      <input type="hidden" name="idOrden" value="<%= orden.getIdOrden() %>"/>

      <div class="form-grupo">
        <label class="form-label">Puntaje *</label>
        <div class="star-group">
          <input type="radio" name="puntaje" id="s5" value="5" required/>
          <label for="s5" title="5 · Excelente">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </label>
          <input type="radio" name="puntaje" id="s4" value="4"/>
          <label for="s4" title="4 · Muy bueno">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </label>
          <input type="radio" name="puntaje" id="s3" value="3"/>
          <label for="s3" title="3 · Bueno">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </label>
          <input type="radio" name="puntaje" id="s2" value="2"/>
          <label for="s2" title="2 · Regular">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </label>
          <input type="radio" name="puntaje" id="s1" value="1"/>
          <label for="s1" title="1 · Malo">
            <svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
              <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
            </svg>
          </label>
        </div>
        <p class="star-hint">Haz clic en las estrellas para seleccionar tu puntaje</p>
      </div>

      <div class="form-grupo">
        <label class="form-label" for="comentario">
          Comentario <span class="optional">(opcional)</span>
        </label>
        <textarea id="comentario" name="comentario" class="form-textarea" maxlength="500"
                  placeholder="Describe tu experiencia: calidad del producto, tiempo de entrega, atención del vendedor..."></textarea>
      </div>

      <div class="acciones">
        <a href="<%= ctx %>/orden?accion=listar" class="btn-cancel">Cancelar</a>
        <button type="submit" class="btn-submit">Enviar calificación</button>
      </div>
    </form>
  </div>
</div>

<footer class="liana-footer">
  <div class="brand">Liana's</div>
  <p>© 2026 Liana's · Bogotá, Colombia</p>
</footer>
</body>
</html>
