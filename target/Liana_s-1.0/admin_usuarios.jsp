<%--
    Document   : admin_usuarios
    Created on : 6/05/2026, 11:04:11 p. m.
    Author     : annym
    Redesigned : Liana's — Rewind aesthetic
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Persona" %>
<%
    List<Persona> usuarios = (List<Persona>) request.getAttribute("usuarios");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
    Persona yo   = (Persona) session.getAttribute("usuario");
    String nombre = yo != null ? yo.getNombre() : "";
    String tipoFiltro = request.getParameter("tipo");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Gestión de Usuarios</title>
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
    /* ── FILTROS (tabs subrayados como en Catálogo) ── */
    .tabs { display: flex; gap: 0; border-bottom: 1px solid #eee; margin-bottom: 32px; }
    .tab {
      padding: 12px 22px; margin-bottom: -1px; text-decoration: none;
      font-family: 'Inter', sans-serif; font-size: 11px; font-weight: 500;
      letter-spacing: .1em; text-transform: uppercase; color: #aaa;
      border-bottom: 2px solid transparent; transition: color .15s;
    }
    .tab:hover  { color: #111; }
    .tab.activo { color: #111; border-bottom-color: #111; }

    /* ── ACCIONES ── */
    .acciones { display: flex; gap: 10px; align-items: center; flex-wrap: nowrap; }
    .mini-form { display: flex; align-items: stretch; margin: 0; }
    .mini-sel {
      padding: 6px 8px; border: 1px solid #ddd; border-right: none; background: #fff;
      font-family: 'Inter', sans-serif; font-size: 12px; font-weight: 300; color: #111;
      outline: none; cursor: pointer;
    }
    .mini-sel:focus { border-color: #c8a46e; }
    .mini-ok {
      padding: 0 10px; border: 1px solid #111; background: #111; color: #fff;
      font-size: 12px; cursor: pointer; transition: background .15s;
    }
    .mini-ok:hover { background: #c8a46e; border-color: #c8a46e; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="page-subheader">
  <div class="page-subheader-inner">
    <div>
      <p class="sub">Panel de administración</p>
      <h1>Gestión de Usuarios</h1>
    </div>
    <a href="<%= ctx %>/admin?accion=vendedores" class="r-btn">Validar vendedores</a>
  </div>
</div>

<div class="page-wrapper">

  <% if ("eliminado".equals(msg))   { %><div class="msg msg-ok">Usuario eliminado.</div><% } %>
  <% if ("actualizado".equals(msg)) { %><div class="msg msg-ok">Usuario actualizado.</div><% } %>

  <%-- Filtro por tipo --%>
  <div class="tabs">
    <a href="<%= ctx %>/admin?accion=usuarios"                class="tab <%= tipoFiltro == null ? "activo" : "" %>">Todos</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=admin"     class="tab <%= "admin"    .equals(tipoFiltro) ? "activo" : "" %>">Admins</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=vendedor"  class="tab <%= "vendedor" .equals(tipoFiltro) ? "activo" : "" %>">Vendedores</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=comprador" class="tab <%= "comprador".equals(tipoFiltro) ? "activo" : "" %>">Compradores</a>
  </div>

  <% if (usuarios == null || usuarios.isEmpty()) { %>
    <div class="empty-box">
      <p class="empty-eyebrow">Sin registros</p>
      <h3>No hay usuarios</h3>
      <p>No se encontraron usuarios para este filtro.</p>
    </div>
  <% } else { %>
  <div style="overflow-x:auto;">
  <table class="admin-table">
    <thead>
      <tr>
        <th>#</th><th>Nombre</th><th>Documento</th><th>Correo</th>
        <th>Celular</th><th>Tipo</th><th>Estado</th><th>Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% for (Persona u : usuarios) {
         boolean esMismo = yo != null && u.getIdPersona() == yo.getIdPersona();
    %>
      <tr>
        <td><span class="id-cell">#<%= u.getIdPersona() %></span></td>
        <td class="name-cell"><%= u.getNombre() %></td>
        <td class="small-cell"><%= u.getDocumento() %></td>
        <td class="small-cell"><%= u.getCorreo() %></td>
        <td class="small-cell"><%= u.getCelular() %></td>
        <td><span class="eb eb-<%= u.getTipo() %>"><%= u.getTipo() %></span></td>
        <td><span class="eb eb-<%= u.getEstado() %>"><%= u.getEstado() %></span></td>
        <td>
          <% if (!esMismo) { %>
          <div class="acciones">
            <%-- Cambiar tipo --%>
            <form action="<%= ctx %>/admin" method="get" class="mini-form">
              <input type="hidden" name="accion" value="cambiarTipo"/>
              <input type="hidden" name="id" value="<%= u.getIdPersona() %>"/>
              <select name="tipo" class="mini-sel" title="Tipo de usuario">
                <option value="comprador" <%= "comprador".equals(u.getTipo()) ? "selected" : "" %>>Comprador</option>
                <option value="vendedor"  <%= "vendedor" .equals(u.getTipo()) ? "selected" : "" %>>Vendedor</option>
                <option value="admin"     <%= "admin"    .equals(u.getTipo()) ? "selected" : "" %>>Admin</option>
              </select>
              <button type="submit" class="mini-ok" title="Guardar tipo">✓</button>
            </form>
            <%-- Cambiar estado --%>
            <form action="<%= ctx %>/admin" method="get" class="mini-form">
              <input type="hidden" name="accion" value="cambiarEstado"/>
              <input type="hidden" name="id" value="<%= u.getIdPersona() %>"/>
              <select name="estado" class="mini-sel" title="Estado de la cuenta">
                <option value="activo"     <%= "activo"    .equals(u.getEstado()) ? "selected" : "" %>>Activo</option>
                <option value="inactivo"   <%= "inactivo"  .equals(u.getEstado()) ? "selected" : "" %>>Inactivo</option>
                <option value="sancionado" <%= "sancionado".equals(u.getEstado()) ? "selected" : "" %>>Sancionado</option>
              </select>
              <button type="submit" class="mini-ok" title="Guardar estado">✓</button>
            </form>
            <%-- Eliminar --%>
            <a href="<%= ctx %>/admin?accion=eliminarUsuario&id=<%= u.getIdPersona() %>"
               class="r-btn r-btn-danger"
               onclick="return confirm('¿Eliminar a <%= u.getNombre() %>? Esta acción no se puede deshacer.')">Eliminar</a>
          </div>
          <% } else { %>
            <span class="muted">Tu cuenta</span>
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
