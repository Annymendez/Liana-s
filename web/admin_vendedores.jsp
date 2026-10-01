<%-- 
    Document   : admin_vendedores
    Created on : 26/04/2026, 11:24:16 p. m.
    Author     : annym
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
  <title>MercadoRed — Panel Admin</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
.tabla { width:100%; border-collapse:collapse; background:var(--white); border-radius:12px;
             overflow:hidden; box-shadow:var(--shadow-sm); margin-bottom:60px; }
    .tabla thead th { background:var(--dark); color:var(--cream); padding:14px 18px;
                      text-align:left; font-size:.78rem; letter-spacing:1px; text-transform:uppercase; }
    .tabla tbody td { padding:13px 18px; border-bottom:1px solid var(--sand);
                      font-size:.88rem; vertical-align:middle; }
    .tabla tbody tr:hover { background:var(--cream); }

    .tag-validado   { color:#2e7d32; font-weight:700; }
    .tag-pendiente  { color:#e37400; font-weight:700; }
    .tag-sancionado { color:#d93025; font-weight:700; }
    .tag-activo     { color:#2e7d32; }
    .tag-inactivo   { color:#888; }

    .doc-link { color:var(--terra); font-size:.82rem; font-weight:600;
                text-decoration:none; display:inline-flex; align-items:center; gap:4px; }
    .doc-link:hover { text-decoration:underline; }
    .sin-doc  { color:var(--muted); font-size:.8rem; font-style:italic; }

    .acciones-td { display:flex; gap:6px; flex-wrap:wrap; }
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="container">

  <div class="section-header">
    <div>
      <p class="sub">Panel de administración</p>
      <h2>🔍 Validación de Vendedores</h2>
    </div>
  </div>

  <%-- Mensajes --%>
  <% if ("validado".equals(msg)) { %>
    <div class="alert alert-success">✅ Identidad validada. El vendedor ya puede publicar productos.</div>
  <% } else if ("rechazado".equals(msg)) { %>
    <div class="alert alert-warning">⛔ Vendedor rechazado y cuenta sancionada.</div>
  <% } %>

  <% if (vendedores == null || vendedores.isEmpty()) { %>
    <div class="empty-state">
      <div class="icon">👥</div>
      <h3>No hay vendedores registrados</h3>
    </div>
  <% } else { %>
    <div style="overflow-x:auto;">
    <table class="tabla">
      <thead>
        <tr>
          <th>#</th>
          <th>Nombre</th>
          <th>Documento</th>
          <th>Correo</th>
          <th>Banco</th>
          <th>Doc. Digital</th>
          <th>Estado cuenta</th>
          <th>Identidad</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
      <% for (Vendedor v : vendedores) {
           String docPath = v.getDocumentoPath();
           // El nombre del archivo es solo el nombre sin ruta
           String nombreArchivo = "";
           if (docPath != null && !docPath.isEmpty()) {
               nombreArchivo = docPath.contains("/")
                   ? docPath.substring(docPath.lastIndexOf("/") + 1)
                   : docPath;
           }
      %>
        <tr>
          <td><strong>#<%= v.getIdVendedor() %></strong></td>
          <td><strong><%= v.getNombre() != null ? v.getNombre() : "—" %></strong></td>
          <td><%= v.getDocumento() != null ? v.getDocumento() : "—" %></td>
          <td style="font-size:.8rem;"><%= v.getCorreo() != null ? v.getCorreo() : "—" %></td>
          <td><%= v.getBanco() != null && !v.getBanco().isEmpty() ? v.getBanco() : "—" %></td>

          <%-- Columna documento digital (CA011) --%>
          <td>
            <% if (!nombreArchivo.isEmpty()) { %>
              <a href="<%= ctx %>/documento?archivo=<%= nombreArchivo %>"
                 target="_blank" class="doc-link">
                📄 Ver documento
              </a>
            <% } else { %>
              <span class="sin-doc">Sin documento</span>
            <% } %>
          </td>

          <%-- Estado de la cuenta --%>
          <td>
            <span class="tag-<%= v.getEstado() != null ? v.getEstado() : "inactivo" %>">
              <%= v.getEstado() != null ? v.getEstado() : "—" %>
            </span>
          </td>

          <%-- Identidad validada (CA012) --%>
          <td>
            <% if (v.isIdentidadValidada()) { %>
              <span class="tag-validado">✅ Validada</span>
            <% } else { %>
              <span class="tag-pendiente">⏳ Pendiente</span>
            <% } %>
          </td>

          <%-- Acciones --%>
          <td>
            <div class="acciones-td">
              <% if (!v.isIdentidadValidada()) { %>
                <a href="<%= ctx %>/admin?accion=validar&id=<%= v.getIdVendedor() %>"
                   class="btn btn-sm btn-edit"
                   onclick="return confirm('¿Validar identidad de <%= v.getNombre() %>?')">
                   ✅ Validar
                </a>
                <a href="<%= ctx %>/admin?accion=rechazar&id=<%= v.getIdVendedor() %>"
                   class="btn btn-sm btn-delete"
                   onclick="return confirm('¿Rechazar y sancionar a <%= v.getNombre() %>?')">
                   ❌ Rechazar
                </a>
              <% } else { %>
                <span style="color:var(--muted);font-size:.8rem;">Ya validado</span>
              <% } %>
            </div>
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
