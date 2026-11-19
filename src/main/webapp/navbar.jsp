<%@ page pageEncoding="UTF-8" %>
<%@ page import="model.Persona" %>
<%
    Persona __u = (Persona) session.getAttribute("usuario");
    String __rol    = __u != null ? __u.getTipo()   : "";
    String __nombre = __u != null ? __u.getNombre()  : "";
    String __correo = __u != null ? __u.getCorreo()  : "";
    String __ctx    = request.getContextPath();
    java.util.List __carrito = (java.util.List) session.getAttribute("carrito");
    int __carritoSize = (__carrito != null) ? __carrito.size() : 0;
    String __inicial = (__nombre != null && !__nombre.isEmpty()) ? String.valueOf(__nombre.charAt(0)).toUpperCase() : "U";
    String __primerNombre = (__nombre != null && __nombre.contains(" ")) ? __nombre.split(" ")[0] : __nombre;
%>
<style>
/* ── NAVBAR ── */
.nav-rw {
    position: sticky; top: 0; z-index: 1000;
    background: #fff;
    border-bottom: 1px solid #ddd;
    font-family: 'Inter', system-ui, sans-serif;
}
.nav-rw-inner {
    max-width: 1280px; margin: 0 auto;
    display: flex; align-items: center;
    padding: 0 32px; height: 56px; gap: 0;
}
.nav-rw-brand {
    font-family: 'IM Fell English', Georgia, serif;
    font-size: 1.25rem;
    font-style: italic;
    color: #111;
    text-decoration: none;
    flex-shrink: 0;
    margin-right: 32px;
    letter-spacing: 0;
}
.nav-rw-brand:hover { text-decoration: none; }

.nav-rw-links {
    display: flex; align-items: center; gap: 0; flex: 1;
}
.nav-rw-link {
    padding: 0 14px; height: 56px;
    display: inline-flex; align-items: center;
    font-size: 11px; font-weight: 500;
    letter-spacing: .1em; text-transform: uppercase;
    color: #555; text-decoration: none;
    border-bottom: 2px solid transparent;
    transition: color .15s, border-color .15s;
    white-space: nowrap;
}
.nav-rw-link:hover { color: #111; border-bottom-color: #111; text-decoration: none; }
.nav-rw-link.active { color: #111; border-bottom-color: #111; }

.nav-rw-badge {
    display: inline-block;
    background: #111; color: #fff;
    font-size: 9px; font-weight: 700;
    padding: 1px 5px; margin-left: 5px;
    vertical-align: middle;
}

.nav-rw-right {
    display: flex; align-items: center; gap: 0; margin-left: auto; flex-shrink: 0;
}

/* Dropdown usuario */
.nav-rw-user {
    position: relative;
    display: flex; align-items: center; gap: 8px;
    padding: 0 14px; height: 56px; cursor: pointer;
    border-left: 1px solid #eee;
}
.nav-rw-user:hover .nav-rw-dropdown { display: block; }

.nav-rw-avatar {
    width: 28px; height: 28px;
    background: #111; color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-size: 11px; font-weight: 700;
    flex-shrink: 0;
}
.nav-rw-username {
    font-size: 12px; font-weight: 500; color: #111;
}
.nav-rw-role {
    font-size: 10px; letter-spacing: .08em;
    text-transform: uppercase; color: #aaa;
}
.nav-rw-chevron { font-size: 9px; color: #aaa; margin-left: 2px; }

.nav-rw-dropdown {
    display: none;
    position: absolute; right: 0; top: 100%;
    background: #fff;
    border: 1px solid #ddd;
    min-width: 200px;
    z-index: 9999;
    box-shadow: 0 4px 16px rgba(0,0,0,.08);
}
.nav-rw-dropdown-header {
    padding: 14px 16px;
    border-bottom: 1px solid #eee;
    background: #fafafa;
}
.nav-rw-dropdown-header .dh-name  { font-size: 13px; font-weight: 500; color: #111; }
.nav-rw-dropdown-header .dh-email { font-size: 11px; color: #aaa; margin-top: 2px; }
.nav-rw-dropdown a {
    display: block; padding: 10px 16px;
    font-size: 12px; font-weight: 400;
    letter-spacing: .05em; color: #111;
    text-decoration: none;
    transition: background .1s;
}
.nav-rw-dropdown a:hover { background: #f5f5f5; text-decoration: none; }
.nav-rw-dropdown a.danger { color: #c00; }
.nav-rw-dropdown-sep { height: 1px; background: #eee; }

@media (max-width: 768px) {
    .nav-rw-inner { padding: 0 16px; }
    .nav-rw-link { padding: 0 10px; font-size: 10px; }
    .nav-rw-username { display: none; }
    .nav-rw-role { display: none; }
}
</style>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">

<header class="nav-rw">
  <div class="nav-rw-inner">

    <a href="<%= __ctx %>/producto?accion=listar" class="nav-rw-brand">Liana's</a>

    <nav class="nav-rw-links">
      <% if ("comprador".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar" class="nav-rw-link">Catálogo</a>
        <a href="<%= __ctx %>/orden?accion=listar"    class="nav-rw-link">Mis pedidos</a>
        <a href="<%= __ctx %>/carrito?accion=ver"     class="nav-rw-link">
          Carrito<% if (__carritoSize > 0) { %><span class="nav-rw-badge"><%= __carritoSize %></span><% } %>
        </a>
      <% } %>

      <% if ("vendedor".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar" class="nav-rw-link">Mis productos</a>
        <a href="<%= __ctx %>/producto?accion=nuevo"  class="nav-rw-link">+ Publicar</a>
        <a href="<%= __ctx %>/orden?accion=listar"    class="nav-rw-link">Pedidos</a>
        <a href="<%= __ctx %>/calificacion?accion=misCalificaciones" class="nav-rw-link">Reseñas</a>
      <% } %>

      <% if ("admin".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar"  class="nav-rw-link">Catálogo</a>
        <a href="<%= __ctx %>/orden?accion=listar"     class="nav-rw-link">Pedidos</a>
        <a href="<%= __ctx %>/admin?accion=vendedores" class="nav-rw-link">Vendedores</a>
        <a href="<%= __ctx %>/admin?accion=usuarios"   class="nav-rw-link">Usuarios</a>
        <a href="<%= __ctx %>/admin?accion=auditoria"  class="nav-rw-link">Auditoría</a>
      <% } %>
    </nav>

    <div class="nav-rw-right">
      <div class="nav-rw-user">
        <div class="nav-rw-avatar"><%= __inicial %></div>
        <div>
          <div class="nav-rw-username"><%= __primerNombre %></div>
          <div class="nav-rw-role"><%= __rol %></div>
        </div>
        <span class="nav-rw-chevron">▾</span>

        <div class="nav-rw-dropdown">
          <div class="nav-rw-dropdown-header">
            <div class="dh-name"><%= __nombre %></div>
            <div class="dh-email"><%= __correo %></div>
          </div>

          <% if ("comprador".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Catálogo</a>
            <a href="<%= __ctx %>/orden?accion=listar">Mis pedidos</a>
            <a href="<%= __ctx %>/carrito?accion=ver">Carrito<% if (__carritoSize > 0) { %> (<%= __carritoSize %>)<% } %></a>
          <% } %>

          <% if ("vendedor".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Mis productos</a>
            <a href="<%= __ctx %>/producto?accion=nuevo">Publicar producto</a>
            <a href="<%= __ctx %>/orden?accion=listar">Pedidos</a>
            <a href="<%= __ctx %>/calificacion?accion=misCalificaciones">Mis reseñas</a>
          <% } %>

          <% if ("admin".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Catálogo</a>
            <a href="<%= __ctx %>/orden?accion=listar">Pedidos</a>
            <a href="<%= __ctx %>/admin?accion=vendedores">Validar vendedores</a>
            <a href="<%= __ctx %>/admin?accion=usuarios">Gestión usuarios</a>
            <a href="<%= __ctx %>/admin?accion=auditoria">Auditoría</a>
          <% } %>

          <div class="nav-rw-dropdown-sep"></div>
          <a href="<%= __ctx %>/logout" class="danger">Cerrar sesión</a>
        </div>
      </div>
    </div>

  </div>
</header>
