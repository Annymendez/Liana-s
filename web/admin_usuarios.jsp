<%-- 
    Document   : admin_usuarios
    Created on : 6/05/2026, 11:04:11 p. m.
    Author     : annym
--%>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List, model.Persona" %>
<%
    List<Persona> usuarios = (List<Persona>) request.getAttribute("usuarios");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
    Persona yo   = (Persona) session.getAttribute("usuario");
    String nombre = yo != null ? yo.getNombre() : "";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>MercadoRed — Gestión de Usuarios</title>
  <link rel="stylesheet" href="<%= ctx %>/estilo.css">
  <style>
.tabla{width:100%;border-collapse:collapse;background:var(--white);border-radius:12px;overflow:hidden;box-shadow:var(--shadow-sm);margin-bottom:60px;}
    .tabla thead th{background:var(--dark);color:var(--cream);padding:13px 18px;text-align:left;font-size:.78rem;letter-spacing:1px;text-transform:uppercase;}
    .tabla tbody td{padding:12px 18px;border-bottom:1px solid var(--sand);font-size:.88rem;vertical-align:middle;}
    .tabla tbody tr:hover{background:var(--cream);}
    .eb{padding:3px 10px;border-radius:20px;font-size:.72rem;font-weight:700;}
    .eb-activo{background:#e8f5e9;color:#2e7d32;}
    .eb-inactivo{background:#f5f5f5;color:#888;}
    .eb-sancionado{background:#fce4ec;color:#880e4f;}
    .eb-admin{background:#2c2217;color:#f5f0e8;}
    .eb-vendedor{background:#8b6247;color:#fff;}
    .eb-comprador{background:#c8a882;color:#2c2217;}
    .acciones{display:flex;gap:6px;flex-wrap:wrap;align-items:center;}
    .tab-btns{display:flex;gap:8px;margin-bottom:24px;}
    .tab-btn{padding:8px 18px;border-radius:8px;font-size:.8rem;font-weight:600;text-decoration:none;border:1.5px solid var(--sand);color:var(--muted);background:var(--white);}
    .tab-btn.activo{background:var(--dark);color:var(--cream);border-color:var(--dark);}
  </style>
</head>
<body>

<%@ include file="/navbar.jsp" %>

<div class="container">

  <div class="section-header">
    <div>
      <p class="sub">Panel de administración</p>
      <h2>👥 Gestión de Usuarios</h2>
    </div>
    <a href="<%= ctx %>/admin?accion=vendedores" class="btn btn-outline">🔍 Validar Vendedores</a>
  </div>

  <% if ("eliminado".equals(msg)) { %><div class="alert alert-success">🗑️ Usuario eliminado.</div><% } %>
  <% if ("actualizado".equals(msg)) { %><div class="alert alert-success">✅ Usuario actualizado.</div><% } %>

  <%-- Filtro por tipo --%>
  <div class="tab-btns">
    <a href="<%= ctx %>/admin?accion=usuarios" class="tab-btn <%= request.getParameter("tipo")==null?"activo":"" %>">Todos</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=admin"      class="tab-btn <%= "admin"     .equals(request.getParameter("tipo"))?"activo":"" %>">Admins</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=vendedor"   class="tab-btn <%= "vendedor"  .equals(request.getParameter("tipo"))?"activo":"" %>">Vendedores</a>
    <a href="<%= ctx %>/admin?accion=usuarios&tipo=comprador"  class="tab-btn <%= "comprador" .equals(request.getParameter("tipo"))?"activo":"" %>">Compradores</a>
  </div>

  <% if (usuarios == null || usuarios.isEmpty()) { %>
    <div class="empty-state"><div class="icon">👤</div><h3>No hay usuarios</h3></div>
  <% } else { %>
  <div style="overflow-x:auto;">
  <table class="tabla">
    <thead>
      <tr>
        <th>#</th><th>Nombre</th><th>Documento</th><th>Correo</th>
        <th>Celular</th><th>Tipo</th><th>Estado</th><th>Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% for (Persona u : usuarios) {
         boolean esMismo = u.getIdPersona() == yo.getIdPersona();
    %>
      <tr>
        <td><strong><%= u.getIdPersona() %></strong></td>
        <td><strong><%= u.getNombre() %></strong></td>
        <td style="font-size:.82rem;"><%= u.getDocumento() %></td>
        <td style="font-size:.8rem;"><%= u.getCorreo() %></td>
        <td style="font-size:.82rem;"><%= u.getCelular() %></td>
        <td><span class="eb eb-<%= u.getTipo() %>"><%= u.getTipo() %></span></td>
        <td><span class="eb eb-<%= u.getEstado() %>"><%= u.getEstado() %></span></td>
        <td>
          <div class="acciones">
            <% if (!esMismo) { %>
              <%-- Cambiar tipo --%>
              <form action="<%= ctx %>/admin" method="get" style="display:flex;gap:4px;align-items:center;">
                <input type="hidden" name="accion" value="cambiarTipo"/>
                <input type="hidden" name="id" value="<%= u.getIdPersona() %>"/>
                <select name="tipo" style="padding:4px 6px;border:1.5px solid var(--sand);border-radius:4px;font-size:.75rem;background:var(--cream);">
                  <option value="comprador" <%= "comprador".equals(u.getTipo())?"selected":"" %>>Comprador</option>
                  <option value="vendedor"  <%= "vendedor" .equals(u.getTipo())?"selected":"" %>>Vendedor</option>
                  <option value="admin"     <%= "admin"    .equals(u.getTipo())?"selected":"" %>>Admin</option>
                </select>
                <button type="submit" class="btn btn-sm btn-edit" title="Cambiar tipo">✔</button>
              </form>
              <%-- Cambiar estado --%>
              <form action="<%= ctx %>/admin" method="get" style="display:flex;gap:4px;align-items:center;">
                <input type="hidden" name="accion" value="cambiarEstado"/>
                <input type="hidden" name="id" value="<%= u.getIdPersona() %>"/>
                <select name="estado" style="padding:4px 6px;border:1.5px solid var(--sand);border-radius:4px;font-size:.75rem;background:var(--cream);">
                  <option value="activo"     <%= "activo"    .equals(u.getEstado())?"selected":"" %>>Activo</option>
                  <option value="inactivo"   <%= "inactivo"  .equals(u.getEstado())?"selected":"" %>>Inactivo</option>
                  <option value="sancionado" <%= "sancionado".equals(u.getEstado())?"selected":"" %>>Sancionado</option>
                </select>
                <button type="submit" class="btn btn-sm btn-edit" title="Cambiar estado">✔</button>
              </form>
              <%-- Eliminar --%>
              <a href="<%= ctx %>/admin?accion=eliminarUsuario&id=<%= u.getIdPersona() %>"
                 class="btn btn-sm btn-delete"
                 onclick="return confirm('¿Eliminar a <%= u.getNombre() %>? Esta acción no se puede deshacer.')">
                 🗑️
              </a>
            <% } else { %>
              <span style="color:var(--muted);font-size:.78rem;">Tu cuenta</span>
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
