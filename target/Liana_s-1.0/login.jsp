<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String error = (String) request.getAttribute("error");
    String msg   = request.getParameter("msg");
    String ctx   = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Iniciar sesión — Liana's</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=IM+Fell+English:ital@0;1&family=Inter:wght@300;400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= ctx %>/estilo.css">
    <style>
        body { background: #fff; }

        .login-page {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* mini header */
        .login-header {
            border-bottom: 1px solid #ddd;
            padding: 16px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .login-brand {
            font-family: 'IM Fell English', serif;
            font-size: 1.3rem;
            font-style: italic;
            color: #111;
            text-decoration: none;
        }
        .login-header-links {
            font-size: 11px;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: #888;
        }
        .login-header-links a { color: #888; margin-left: 20px; text-decoration: none; }
        .login-header-links a:hover { color: #111; }

        /* contenido */
        .login-body {
            flex: 1;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding: 72px 20px 80px;
        }
        .login-box { width: 100%; max-width: 480px; }

        .login-title {
            font-family: 'IM Fell English', serif;
            font-size: 2rem;
            font-weight: 400;
            font-style: italic;
            margin-bottom: 6px;
        }
        .login-sub {
            font-size: 13px;
            color: #888;
            margin-bottom: 36px;
        }
        .login-sub a {
            color: #111;
            font-weight: 500;
            letter-spacing: .06em;
            text-transform: uppercase;
            font-size: 11px;
            border-bottom: 1px solid #111;
            padding-bottom: 1px;
            margin-left: 8px;
        }

        .form-group { margin-bottom: 16px; }
        .form-group input {
            width: 100%;
            border: 1px solid #bbb;
            border-radius: 0;
            padding: 13px 14px;
            font-family: 'Inter', sans-serif;
            font-size: 14px;
            font-weight: 300;
            color: #111;
            background: #fff;
            outline: none;
            transition: border-color .15s;
        }
        .form-group input:focus { border-color: #111; }

        .login-btn-row {
            display: flex;
            gap: 12px;
            margin-top: 24px;
        }
        .btn-signin {
            flex: 1;
            padding: 14px 20px;
            background: #111;
            color: #fff;
            border: 1px solid #111;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .12em;
            text-transform: uppercase;
            cursor: pointer;
            transition: background .15s;
        }
        .btn-signin:hover { background: #333; }

        .btn-back {
            padding: 14px 20px;
            background: #fff;
            color: #111;
            border: 1px solid #111;
            font-family: 'Inter', sans-serif;
            font-size: 11px;
            font-weight: 500;
            letter-spacing: .12em;
            text-transform: uppercase;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            transition: background .15s;
        }
        .btn-back:hover { background: #f5f5f5; text-decoration: none; }

        .login-divider {
            border: none;
            border-top: 1px solid #eee;
            margin: 32px 0 24px;
        }
        .login-registro {
            font-size: 13px;
            color: #888;
        }
        .login-registro a {
            color: #111;
            font-weight: 500;
            border-bottom: 1px solid #111;
            padding-bottom: 1px;
        }
    </style>
</head>
<body>

<div class="login-page">
  <header class="login-header">
    <a href="<%= ctx %>/producto?accion=listar" class="login-brand">Liana's</a>
    <div class="login-header-links">
      <a href="<%= ctx %>/registro">Registrarse</a>
    </div>
  </header>

  <div class="login-body">
    <div class="login-box">

      <h1 class="login-title">Iniciar sesión</h1>
      <p class="login-sub">
        ¿No tienes cuenta?
        <a href="<%= ctx %>/registro">Crear cuenta</a>
      </p>

      <% if ("logout".equals(msg)) { %>
        <div class="alert alert-success">Sesión cerrada correctamente.</div>
      <% } %>
      <% if ("registrado".equals(msg)) { %>
        <div class="alert alert-success">¡Cuenta activada! Ya puedes iniciar sesión.</div>
      <% } %>
      <% if (error != null) { %>
        <div class="alert alert-error"><%= error %></div>
      <% } %>

      <form action="<%= ctx %>/login" method="post">
        <div class="form-group">
          <input type="email" name="correo" required placeholder="Correo electrónico" autocomplete="email">
        </div>
        <div class="form-group">
          <input type="password" name="contrasena" required placeholder="Contraseña" autocomplete="current-password">
        </div>

        <div class="login-btn-row">
          <button type="submit" class="btn-signin">Iniciar sesión</button>
          <a href="<%= ctx %>/producto?accion=listar" class="btn-back">Volver</a>
        </div>
      </form>

      <hr class="login-divider">

      <p class="login-registro">
        ¿No tienes cuenta? <a href="<%= ctx %>/registro">Regístrate gratis</a>
      </p>

    </div>
  </div>
</div>

</body>
</html>
