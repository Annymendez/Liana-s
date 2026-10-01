<%-- 
    Document   : formulario
    Created on : 4/04/2026, 11:40:01?p. m.
    Author     : annym
--%>

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
%>
<style>
.topbar {
    position: sticky; top: 0; z-index: 1000;
    background: #2c2217;
    box-shadow: 0 2px 12px rgba(0,0,0,.3);
}
.topbar-inner {
    max-width: 1440px; margin: 0 auto;
    display: flex; align-items: center;
    padding: 0 28px; height: 64px; gap: 6px;
}
.tb-brand {
    font-family: Georgia, serif;
    font-size: 1.3rem; color: #f5f0e8;
    text-decoration: none; margin-right: 20px; flex-shrink: 0;
}
.tb-brand em { color: #c8a882; font-style: italic; }
.tb-nav { display: flex; align-items: center; gap: 2px; flex: 1; }
.tb-link {
    padding: 8px 13px; border-radius: 8px;
    font-size: .82rem; font-weight: 500;
    color: rgba(255,255,255,.72); text-decoration: none;
    transition: background .15s, color .15s; white-space: nowrap;
    letter-spacing: .3px;
}
.tb-link:hover { background: rgba(255,255,255,.13); color: #fff; }
.tb-sep { width: 1px; height: 22px; background: rgba(255,255,255,.18); margin: 0 8px; }
.tb-badge {
    display: inline-block;
    background: #8b6247; color: #fff;
    font-size: .6rem; font-weight: 800;
    padding: 1px 6px; border-radius: 10px;
    margin-left: 4px; vertical-align: middle;
}
.tb-right { display: flex; align-items: center; gap: 10px; margin-left: auto; flex-shrink: 0; }
.tb-avatar {
    width: 34px; height: 34px; border-radius: 50%;
    background: #8b6247; color: #fff;
    display: flex; align-items: center; justify-content: center;
    font-weight: 800; font-size: .88rem; flex-shrink: 0; cursor: pointer;
}
.tb-info { display: flex; flex-direction: column; line-height: 1.25; }
.tb-name { font-size: .82rem; font-weight: 700; color: #fff; }
.tb-rol  { font-size: .6rem; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; }
.tb-rol.admin     { color: #ffd700; }
.tb-rol.vendedor  { color: #c8a882; }
.tb-rol.comprador { color: #a8d8a8; }
.tb-chevron { color: rgba(255,255,255,.4); font-size: .7rem; margin-left: 2px; }

/* Dropdown */
.tb-dropdown { position: relative; display: flex; align-items: center; gap: 8px; cursor: pointer; }
.tb-menu {
    display: none; position: absolute; right: 0; top: calc(100% + 10px);
    background: #fff; border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0,0,0,.18);
    min-width: 210px; overflow: hidden; z-index: 9999;
    border: 1px solid #ece8e1;
}
.tb-dropdown:hover .tb-menu { display: block; }
.tb-menu-header {
    padding: 14px 16px 12px;
    border-bottom: 1px solid #ece8e1;
    background: #faf8f5;
}
.tb-menu-header .mh-name { font-weight: 700; font-size: .88rem; color: #2c2217; margin: 0; }
.tb-menu-header .mh-email { font-size: .72rem; color: #8b8070; margin: 2px 0 0; }
.tb-menu a {
    display: flex; align-items: center; gap: 10px;
    padding: 10px 16px; font-size: .85rem; color: #2c2217;
    text-decoration: none; transition: background .12s;
    border: none;
}
.tb-menu a:hover { background: #f5f0e8; }
.tb-menu a.danger { color: #d93025; }
.tb-menu .tb-menu-sep { height: 1px; background: #ece8e1; }
</style>

<header class="topbar">
  <div class="topbar-inner">

    <a href="<%= __ctx %>/producto?accion=listar" class="tb-brand" style="font-style:italic;color:#8B1A1A;">
      Liana's<em>.</em>
    </a>

    <nav class="tb-nav">

      <% if ("comprador".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar" class="tb-link">Catalogo</a>
        <a href="<%= __ctx %>/orden?accion=listar"    class="tb-link">Mis Pedidos</a>
        <a href="<%= __ctx %>/carrito?accion=ver"     class="tb-link">
          Carrito<% if (__carritoSize > 0) { %><span class="tb-badge"><%= __carritoSize %></span><% } %>
        </a>
      <% } %>

      <% if ("vendedor".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar" class="tb-link">Mis Productos</a>
        <a href="<%= __ctx %>/producto?accion=nuevo"  class="tb-link">+ Publicar</a>
        <a href="<%= __ctx %>/orden?accion=listar"    class="tb-link">Pedidos</a>
        <a href="<%= __ctx %>/calificacion?accion=misCalificaciones" class="tb-link">Mis Resenas</a>
      <% } %>

      <% if ("admin".equals(__rol)) { %>
        <a href="<%= __ctx %>/producto?accion=listar"  class="tb-link">Catalogo</a>
        <a href="<%= __ctx %>/orden?accion=listar"     class="tb-link">Pedidos</a>
        <div class="tb-sep"></div>
        <a href="<%= __ctx %>/admin?accion=vendedores" class="tb-link">Validar Vendedores</a>
        <a href="<%= __ctx %>/admin?accion=usuarios"   class="tb-link">Usuarios</a>
        <a href="<%= __ctx %>/admin?accion=auditoria" class="tb-link">Auditoria</a>
      <% } %>

    </nav>

    <div class="tb-right">
      <div class="tb-dropdown">
        <div class="tb-avatar"><%= __inicial %></div>
        <div class="tb-info">
          <span class="tb-name"><%= __nombre.split(" ")[0] %></span>
          <span class="tb-rol <%= __rol %>"><%= __rol.toUpperCase() %></span>
        </div>
        <span class="tb-chevron">&#9660;</span>

        <div class="tb-menu">
          <div class="tb-menu-header">
            <p class="mh-name"><%= __nombre %></p>
            <p class="mh-email"><%= __correo %></p>
          </div>

          <% if ("comprador".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Catalogo</a>
            <a href="<%= __ctx %>/orden?accion=listar">Mis Pedidos</a>
            <a href="<%= __ctx %>/carrito?accion=ver">Mi Carrito
              <% if (__carritoSize > 0) { %><span class="tb-badge"><%= __carritoSize %></span><% } %>
            </a>
          <% } %>

          <% if ("vendedor".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Mis Productos</a>
            <a href="<%= __ctx %>/producto?accion=nuevo">Publicar Producto</a>
            <a href="<%= __ctx %>/orden?accion=listar">Pedidos</a>
            <a href="<%= __ctx %>/calificacion?accion=misCalificaciones">Mis Resenas</a>
          <% } %>

          <% if ("admin".equals(__rol)) { %>
            <a href="<%= __ctx %>/producto?accion=listar">Catalogo</a>
            <a href="<%= __ctx %>/orden?accion=listar">Pedidos</a>
            <a href="<%= __ctx %>/admin?accion=vendedores">Validar Vendedores</a>
            <a href="<%= __ctx %>/admin?accion=usuarios">Gestion Usuarios</a>
            <a href="<%= __ctx %>/admin?accion=auditoria">Auditoria</a>
          <% } %>

          <div class="tb-menu-sep"></div>
          <a href="<%= __ctx %>/logout" class="danger">Cerrar sesion</a>
        </div>
      </div>
    </div>

  </div>
</header>
