<%--
    Document   : admin_vendedores
    Created on : 26/04/2026, 11:24:16 p. m.
    Author     : annym
    Redesigned : Liana's — Rewind aesthetic
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Vendedor, model.Persona" %>
<%
    List<Vendedor> vendedores = (List<Vendedor>) request.getAttribute("vendedores");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
    Persona usuario = (Persona) session.getAttribute("usuario");
    String  nombre  = usuario != null ? usuario.getNombre() : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Validación de Vendedores</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
    /* ── SUBHEADER ── */
    .page-subheader { border-bottom: 1px solid #ddd; background: #fff; }
    .page-subheader-inner {
      max-width: 1100px; margin: 0 auto; padding: 24px 32px;
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
    .page-wrapper { max-width: 1100px; margin: 0 auto; padding: 40px 32px 80px; }

    /* ── ALERTAS ── */
    .msg {
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      padding: 14px 18px; margin-bottom: 28px; border: 1px solid;
    }
    .msg-ok   { color: #2e7d32; border-color: #a5d6a7; background: #f1f8f1; }
    .msg-warn { color: #8b6000; border-color: #e6c97a; background: #fffbf0; }

    /* ── BOTONES ── */
    .r-btn {
      display: inline-block; padding: 7px 14px; border: 1px solid #111;
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .08em; text-transform: uppercase; text-decoration: none;
      background: transparent; color: #111; cursor: pointer; white-space: nowrap;
      transition: background .15s, color .15s, border-color .15s;
    }
    .r-btn:hover       { background: #111; color: #fff; }
    .r-btn-dark        { background: #111; color: #fff; }
    .r-btn-dark:hover  { background: #333; }
    .r-btn-gold        { border-color: #c8a46e; color: #c8a46e; }
    .r-btn-gold:hover  { background: #c8a46e; color: #fff; }
    .r-btn-danger      { border-color: #ddd; color: #888; }
    .r-btn-danger:hover{ background: #880e4f; border-color: #880e4f; color: #fff; }

    /* ── TABLA ── */
    .admin-table { width: 100%; border-collapse: collapse; margin-bottom: 60px; }
    .admin-table thead th {
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa;
      padding: 0 14px 12px; text-align: left; border-bottom: 1px solid #eee;
      white-space: nowrap;
    }
    .admin-table tbody td {
      padding: 16px 14px; border-bottom: 1px solid #eee;
      font-family: 'Inter', sans-serif; font-size: 13px; font-weight: 300;
      color: #333; vertical-align: middle;
    }
    .admin-table tbody tr:last-child td { border-bottom: none; }
    .admin-table tbody tr:hover { background: #fafafa; }
    .id-cell    { font-weight: 500; color: #111; font-size: 12px; letter-spacing: .03em; }
    .name-cell  { color: #111; font-weight: 400; white-space: nowrap; }
    .small-cell { color: #777; font-size: 12px; }
    .dash       { color: #ccc; }
    .muted      { color: #aaa; font-size: 11px; letter-spacing: .05em; text-transform: uppercase; }

    /* ── ETIQUETAS ── */
    .eb {
      display: inline-block; padding: 3px 10px; border: 1px solid;
      font-family: 'Inter', sans-serif; font-size: 10px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; white-space: nowrap;
    }
    .eb-activo     { color: #2e7d32; border-color: #a5d6a7; }
    .eb-inactivo   { color: #aaa;    border-color: #ddd; }
    .eb-sancionado { color: #880e4f; border-color: #f48fb1; }
    .eb-admin      { color: #fff;    border-color: #111; background: #111; }
    .eb-vendedor   { color: #111;    border-color: #111; }
    .eb-comprador  { color: #c8a46e; border-color: #c8a46e; }
    .eb-validada   { color: #fff;    border-color: #111; background: #111; }
    .eb-pendiente  { color: #c8a46e; border-color: #c8a46e; }

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
      .page-wrapper { padding: 24px 16px 60px; }
      .page-subheader-inner { padding: 16px; flex-direction: column; align-items: flex-start; }
    }
    /* ── PROPIOS DE ESTA PÁGINA ── */
    .doc-link {
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 500;
      letter-spacing: .05em; text-transform: uppercase; color: #c8a46e;
      text-decoration: none; border-bottom: 1px solid #c8a46e; padding-bottom: 1px;
    }
    .doc-link:hover { color: #111; border-color: #111; }
    .sin-doc { color: #aaa; font-size: 12px; font-style: italic; }
    .acciones { display: flex; gap: 6px; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="page-subheader">
  <div class="page-subheader-inner">
    <div>
      <p class="sub">Panel de administración</p>
      <h1>Validación de Vendedores</h1>
    </div>
    <a href="<%= ctx %>/admin?accion=usuarios" class="r-btn">Gestión de usuarios</a>
  </div>
</div>

<div class="page-wrapper">

  <%-- Mensajes --%>
  <% if ("validado".equals(msg)) { %>
    <div class="msg msg-ok">Identidad validada. El vendedor ya puede publicar productos.</div>
  <% } else if ("rechazado".equals(msg)) { %>
    <div class="msg msg-warn">Vendedor rechazado y cuenta sancionada.</div>
  <% } %>

  <% if (vendedores == null || vendedores.isEmpty()) { %>
    <div class="empty-box">
      <p class="empty-eyebrow">Sin registros</p>
      <h3>No hay vendedores registrados</h3>
      <p>Aparecerán aquí cuando alguien se registre como vendedor.</p>
    </div>
  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="admin-table">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre</th>
          <th>Documento</th>
          <th>Correo</th>
          <th>Banco</th>
          <th>Doc. digital</th>
          <th>Cuenta</th>
          <th>Identidad</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
      <% for (Vendedor v : vendedores) {
           String docPath = v.getDocumentoPath();
           String nombreArchivo = "";
           if (docPath != null && !docPath.isEmpty()) {
               nombreArchivo = docPath.contains("/")
                   ? docPath.substring(docPath.lastIndexOf("/") + 1)
                   : docPath;
           }
           String estado = v.getEstado() != null ? v.getEstado() : "inactivo";
      %>
        <tr>
          <td><span class="id-cell">#<%= v.getIdVendedor() %></span></td>
          <td class="name-cell"><%= v.getNombre() != null ? v.getNombre() : "—" %></td>
          <td class="small-cell"><%= v.getDocumento() != null ? v.getDocumento() : "—" %></td>
          <td class="small-cell"><%= v.getCorreo() != null ? v.getCorreo() : "—" %></td>
          <td class="small-cell">
            <% if (v.getBanco() != null && !v.getBanco().isEmpty()) { %><%= v.getBanco() %><% } else { %><span class="dash">—</span><% } %>
          </td>

          <%-- Documento digital (CA011) --%>
          <td>
            <% if (!nombreArchivo.isEmpty()) { %>
              <a href="<%= ctx %>/documento?archivo=<%= nombreArchivo %>" target="_blank" class="doc-link">Ver documento</a>
            <% } else { %>
              <span class="sin-doc">Sin documento</span>
            <% } %>
          </td>

          <%-- Estado de la cuenta --%>
          <td><span class="eb eb-<%= estado %>"><%= estado %></span></td>

          <%-- Identidad validada (CA012) --%>
          <td>
            <% if (v.isIdentidadValidada()) { %>
              <span class="eb eb-validada">Validada</span>
            <% } else { %>
              <span class="eb eb-pendiente">Pendiente</span>
            <% } %>
          </td>

          <%-- Acciones --%>
          <td>
            <% if (!v.isIdentidadValidada()) { %>
              <div class="acciones">
                <a href="<%= ctx %>/admin?accion=validar&id=<%= v.getIdVendedor() %>"
                   class="r-btn r-btn-dark"
                   onclick="return confirm('¿Validar identidad de <%= v.getNombre() %>?')">Validar</a>
                <a href="<%= ctx %>/admin?accion=rechazar&id=<%= v.getIdVendedor() %>"
                   class="r-btn r-btn-danger"
                   onclick="return confirm('¿Rechazar y sancionar a <%= v.getNombre() %>?')">Rechazar</a>
              </div>
            <% } else { %>
              <span class="muted">Ya validado</span>
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
