<%-- 
    Document   : index
    Created on : 4/04/2026, 11:24:40 p. m.
    Author     : annym
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    jakarta.servlet.http.HttpSession s = request.getSession(false);
    if (s != null && s.getAttribute("usuario") != null) {
        response.sendRedirect(request.getContextPath() + "/producto?accion=listar");
        return;
    }
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Liana's — Moda Vintage &amp; Segunda Mano</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { scroll-behavior: smooth; }
    body { font-family: 'Arial', 'Helvetica Neue', sans-serif; background: #fff; color: #0A0A0A; overflow-x: hidden; }
    a { text-decoration: none; color: inherit; }

    /* ── BARRA SUPERIOR ── */
    .top-bar {
      background: #0A0A0A; color: rgba(255,255,255,.75);
      font-size: .62rem; letter-spacing: 2px; text-transform: uppercase;
      padding: 9px 48px; display: flex; justify-content: space-between; align-items: center;
    }
    .top-bar-right { display: flex; gap: 24px; }
    .top-bar-right a { color: rgba(255,255,255,.75); transition: color .15s; }
    .top-bar-right a:hover { color: #C8A45A; }

    /* ── NAVBAR ── */
    .nav {
      background: #fff; border-bottom: 1px solid #EDE5D8;
      padding: 0 48px;
      display: flex; flex-direction: column; align-items: center;
      position: sticky; top: 0; z-index: 100;
    }
    .nav-logo {
      font-family: Georgia, serif;
      font-size: 2.4rem; font-weight: 700; font-style: italic;
      color: #8B1A1A; letter-spacing: -2px;
      padding: 18px 0 6px; text-align: center;
    }
    .nav-logo span { color: #C8A45A; font-style: normal; }
    .nav-links {
      display: flex; gap: 0; padding-bottom: 0;
      border-top: 1px solid #EDE5D8; width: 100%;
      justify-content: center;
    }
    .nav-links a {
      padding: 12px 20px;
      font-size: .65rem; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; color: #0A0A0A;
      transition: color .15s; white-space: nowrap;
      border-bottom: 2px solid transparent;
    }
    .nav-links a:hover { color: #8B1A1A; border-bottom-color: #C8A45A; }
    .nav-links a.highlight {
      background: #8B1A1A; color: #fff; margin-left: 8px;
      padding: 10px 20px;
    }
    .nav-links a.highlight:hover { background: #6B1313; border-bottom-color: transparent; }

    /* ── HERO — 2 columnas como Rewind ── */
    .hero {
      display: grid; grid-template-columns: 1fr 1fr;
      height: 90vh; position: relative; overflow: hidden;
    }
    .hero-col { position: relative; overflow: hidden; }
    .hero-col img {
      width: 100%; height: 100%; object-fit: cover;
      transition: transform .5s ease;
    }
    .hero-col:hover img { transform: scale(1.03); }
    .hero-overlay {
      position: absolute; inset: 0;
      background: linear-gradient(to top, rgba(10,10,10,.75) 0%, rgba(10,10,10,.1) 50%, transparent 100%);
    }
    .hero-text {
      position: absolute; bottom: 48px; left: 48px; right: 48px;
      z-index: 2; color: #fff;
    }
    .hero-text h1 {
      font-family: Georgia, serif;
      font-size: clamp(1.8rem, 3.5vw, 3rem);
      font-weight: 700; font-style: italic;
      line-height: 1.1; margin-bottom: 24px;
      letter-spacing: -1px;
    }
    .btn-hero {
      display: inline-block;
      background: #0A0A0A; color: #fff;
      padding: 14px 32px;
      font-size: .65rem; font-weight: 700; letter-spacing: 2.5px;
      text-transform: uppercase; border: 2px solid #0A0A0A;
      transition: all .18s;
    }
    .btn-hero:hover { background: #8B1A1A; border-color: #8B1A1A; }
    .btn-hero-out {
      display: inline-block;
      background: transparent; color: #fff;
      padding: 14px 32px;
      font-size: .65rem; font-weight: 700; letter-spacing: 2.5px;
      text-transform: uppercase; border: 2px solid rgba(255,255,255,.7);
      margin-left: 10px; transition: all .18s;
    }
    .btn-hero-out:hover { background: rgba(255,255,255,.15); }

    /* ── TICKER — texto que corre ── */
    .ticker-wrap {
      background: #fff; border-top: 1px solid #EDE5D8;
      border-bottom: 1px solid #EDE5D8;
      padding: 16px 0; overflow: hidden; white-space: nowrap;
    }
    .ticker {
      display: inline-block;
      animation: ticker 25s linear infinite;
      font-size: 1.1rem; font-weight: 700; letter-spacing: 1px;
      text-transform: uppercase;
    }
    .ticker span { margin: 0 24px; color: #8B1A1A; }
    @keyframes ticker { 0% { transform: translateX(0); } 100% { transform: translateX(-50%); } }

    /* ── SECCIÓN: NUEVA COLECCIÓN ── */
    .section { padding: 72px 48px; }
    .section-title {
      font-size: .7rem; font-weight: 700; letter-spacing: 3px;
      text-transform: uppercase; text-align: center;
      margin-bottom: 48px; color: #0A0A0A;
    }
    .section-title::after {
      content: ''; display: block; width: 40px; height: 2px;
      background: #8B1A1A; margin: 12px auto 0;
    }

    /* Grid de productos Rewind — imagen limpia sobre blanco */
    .productos-grid {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 24px; margin-bottom: 48px;
    }
    .prod-card { text-align: center; }
    .prod-card-img {
      width: 100%; aspect-ratio: 3/4;
      object-fit: contain; object-position: center;
      background: #F8F6F3;
      margin-bottom: 14px;
      transition: transform .3s;
    }
    .prod-card:hover .prod-card-img { transform: scale(1.03); }
    .prod-cat {
      font-size: .62rem; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; color: #0A0A0A; margin-bottom: 4px;
    }
    .prod-name { font-size: .82rem; color: #555; margin-bottom: 8px; line-height: 1.3; }
    .prod-price { font-size: .88rem; font-weight: 700; color: #0A0A0A; }

    .btn-shop {
      display: block; width: fit-content; margin: 0 auto;
      padding: 13px 36px;
      font-size: .62rem; font-weight: 700; letter-spacing: 2.5px;
      text-transform: uppercase; color: #0A0A0A;
      border: 1.5px solid #0A0A0A; transition: all .18s;
    }
    .btn-shop:hover { background: #0A0A0A; color: #fff; }

    /* ── TICKER MARCAS ── */
    .marcas-ticker {
      border-top: 1px solid #EDE5D8; border-bottom: 1px solid #EDE5D8;
      padding: 20px 0; overflow: hidden; white-space: nowrap;
      margin: 0;
    }
    .marcas-inner {
      display: inline-block;
      animation: ticker 30s linear infinite;
      font-size: 1.6rem; font-weight: 900; letter-spacing: -1px;
      text-transform: uppercase; color: #0A0A0A;
    }
    .marcas-inner span { margin: 0 20px; color: #EDE5D8; }

    /* ── STATS + PRODUCTOS ── */
    .stats-section {
      padding: 72px 48px; background: #fff;
      display: grid; grid-template-columns: 220px 1fr;
      gap: 48px; align-items: start;
    }
    .stats-left h2 {
      font-size: 5rem; font-weight: 900; line-height: 1;
      color: #0A0A0A; margin-bottom: 8px;
    }
    .stats-left p {
      font-size: 1rem; font-weight: 700; color: #0A0A0A;
      line-height: 1.3;
    }
    .stats-grid {
      display: grid;
      grid-template-columns: repeat(5, 1fr);
      gap: 24px;
    }

    /* ── EDITORIAL 3 COLS ── */
    .editorial-section { padding: 72px 48px; background: #fff; }
    .editorial-grid {
      display: grid; grid-template-columns: repeat(3, 1fr);
      gap: 32px; margin-bottom: 48px;
    }
    .editorial-card img {
      width: 100%; aspect-ratio: 4/5;
      object-fit: cover; margin-bottom: 16px;
      transition: transform .4s;
    }
    .editorial-card:hover img { transform: scale(1.02); }
    .editorial-card h3 {
      font-size: .88rem; font-weight: 900;
      text-transform: uppercase; margin-bottom: 8px;
      letter-spacing: .5px;
    }
    .editorial-card p { font-size: .82rem; color: #555; line-height: 1.5; margin-bottom: 14px; }
    .link-more {
      font-size: .62rem; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; color: #0A0A0A;
      border-bottom: 1px solid #0A0A0A; padding-bottom: 2px;
      transition: color .15s;
    }
    .link-more:hover { color: #8B1A1A; border-bottom-color: #8B1A1A; }

    /* ── WHO ARE WE ── */
    .who-section {
      display: grid; grid-template-columns: 1fr 1fr 1fr;
      gap: 0; background: #EDE5D8;
      min-height: 500px;
    }
    .who-img { position: relative; overflow: hidden; }
    .who-img img { width: 100%; height: 100%; object-fit: cover; }
    .who-text {
      padding: 60px 48px;
      display: flex; flex-direction: column; justify-content: flex-end;
      background: #fff;
    }
    .who-text h2 {
      font-size: 3.5rem; font-weight: 900;
      text-transform: uppercase; line-height: .9;
      margin-bottom: 20px; letter-spacing: -2px;
    }
    .who-text h2 em { color: #8B1A1A; font-style: normal; }
    .who-text p { font-size: .88rem; color: #555; line-height: 1.7; margin-bottom: 20px; }

    /* ── GALERÍA INSTAGRAM ── */
    .gram-section { padding: 0; overflow: hidden; }
    .gram-ticker {
      display: flex; overflow: hidden; border-top: 1px solid #EDE5D8;
    }
    .gram-ticker img {
      width: calc(100% / 6); flex-shrink: 0;
      aspect-ratio: 1; object-fit: cover;
      border-right: 1px solid #EDE5D8; transition: opacity .2s;
    }
    .gram-ticker img:hover { opacity: .8; }
    .gram-text {
      padding: 48px;
      font-size: 1.8rem; font-weight: 900;
      text-transform: uppercase; letter-spacing: -1px;
      overflow: hidden; white-space: nowrap;
      border-top: 1px solid #EDE5D8; border-bottom: 1px solid #EDE5D8;
    }
    .gram-text span { color: #8B1A1A; }

    /* ── NEWSLETTER ── */
    .newsletter {
      padding: 80px 48px; text-align: center;
      background: #fff; border-top: 1px solid #EDE5D8;
    }
    .newsletter h2 {
      font-size: 1.4rem; font-weight: 900;
      text-transform: uppercase; letter-spacing: 1px; margin-bottom: 12px;
    }
    .newsletter p { font-size: .85rem; color: #555; margin-bottom: 32px; }
    .newsletter-form {
      display: flex; gap: 0; max-width: 500px; margin: 0 auto;
    }
    .newsletter-form input {
      flex: 1; padding: 14px 18px;
      border: 1.5px solid #0A0A0A; border-right: none;
      font-size: .85rem; outline: none; font-family: Arial, sans-serif;
    }
    .newsletter-form input::placeholder { color: #AAA; }
    .newsletter-form button {
      padding: 14px 28px;
      background: #0A0A0A; color: #fff; border: 1.5px solid #0A0A0A;
      font-size: .62rem; font-weight: 700; letter-spacing: 2px;
      text-transform: uppercase; cursor: pointer; transition: background .18s;
    }
    .newsletter-form button:hover { background: #8B1A1A; border-color: #8B1A1A; }

    /* ── FOOTER ── */
    .footer {
      background: #8B1A1A; color: rgba(255,255,255,.6);
      padding: 40px 48px;
      display: flex; justify-content: space-between; align-items: center;
      font-size: .62rem; letter-spacing: 2px; text-transform: uppercase;
    }
    .footer-logo {
      font-family: Georgia, serif;
      font-size: 1.6rem; color: #C8A45A; font-style: italic;
      font-weight: 700; letter-spacing: -1px;
    }
    .footer a { color: rgba(255,255,255,.6); margin-left: 20px; transition: color .15s; }
    .footer a:hover { color: #C8A45A; }
  </style>
</head>
<body>

<!-- BARRA SUPERIOR -->
<div class="top-bar">
  <span>Moda vintage &amp; segunda mano · Colombia</span>
  <div class="top-bar-right">
    <a href="<%= ctx %>/registro">Vender</a>
    <a href="<%= ctx %>/login">Iniciar sesion</a>
    <a href="<%= ctx %>/registro">Registrarse</a>
  </div>
</div>

<!-- NAVBAR -->
<nav class="nav">
  <div class="nav-logo">Liana's<span>.</span></div>
  <div class="nav-links">
    <a href="#nueva-coleccion">Nueva coleccion</a>
    <a href="#categorias">Categorias</a>
    <a href="<%= ctx %>/login">Explorar</a>
    <a href="#nosotras">Nosotras</a>
    <a href="<%= ctx %>/registro" class="highlight">Vender mis prendas</a>
  </div>
</nav>

<!-- HERO 2 COLUMNAS -->
<section class="hero">
  <div class="hero-col">
    <img src="https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=900&auto=format"
         alt="Liana's moda"
         onerror="this.src='https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=900'"/>
    <div class="hero-overlay"></div>
    <div class="hero-text">
      <h1>Prendas unicas que no encontraras en otro lugar.</h1>
      <a href="<%= ctx %>/login" class="btn-hero">Ver coleccion</a>
    </div>
  </div>
  <div class="hero-col">
    <img src="https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=900&auto=format"
         alt="Liana's accesorios"
         onerror="this.src='https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=900'"/>
    <div class="hero-overlay"></div>
    <div class="hero-text">
      <h1>Ropa vintage y de archivo con historia.</h1>
      <a href="<%= ctx %>/registro" class="btn-hero">Vender aqui</a>
      <a href="<%= ctx %>/login" class="btn-hero-out">Explorar</a>
    </div>
  </div>
</section>

<!-- TICKER -->
<div class="ticker-wrap">
  <div class="ticker">
    Ropa vintage <span>·</span> Prendas de archivo <span>·</span>
    Segunda mano <span>·</span> Moda sostenible <span>·</span>
    Piezas exclusivas <span>·</span> Colombia <span>·</span>
    Ropa vintage <span>·</span> Prendas de archivo <span>·</span>
    Segunda mano <span>·</span> Moda sostenible <span>·</span>
    Piezas exclusivas <span>·</span> Colombia <span>·</span>
  </div>
</div>

<!-- NUEVA COLECCIÓN -->
<section class="section" id="nueva-coleccion">
  <p class="section-title">Nueva coleccion</p>
  <div class="productos-grid">
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=400&auto=format" alt="Ropa"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Chaqueta vintage de abrigo</p>
      <p class="prod-price">$ 580.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1542272604-787c3835535d?w=400&auto=format" alt="Jeans"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Jeans de corte recto clasico</p>
      <p class="prod-price">$ 320.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format" alt="Tenis"/>
      <p class="prod-cat">Calzado</p>
      <p class="prod-name">Tenis vintage de coleccion</p>
      <p class="prod-price">$ 450.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=400&auto=format" alt="Cartera"/>
      <p class="prod-cat">Accesorios</p>
      <p class="prod-name">Cartera de cuero genuino</p>
      <p class="prod-price">$ 145.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=400&auto=format" alt="Vestido"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Vestido floral de verano</p>
      <p class="prod-price">$ 185.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1594938298603-c8148c4b4a80?w=400&auto=format" alt="Blazer"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Blazer ejecutivo vintage</p>
      <p class="prod-price">$ 390.000</p>
    </div>
  </div>
  <a href="<%= ctx %>/login" class="btn-shop">Ver todo el catalogo</a>
</section>

<!-- TICKER CATEGORÍAS -->
<div class="marcas-ticker">
  <div class="marcas-inner">
    Ropa <span>·</span> Calzado <span>·</span> Accesorios <span>·</span>
    Hogar <span>·</span> Deportes <span>·</span> Libros <span>·</span>
    Juguetes <span>·</span> Tecnologia <span>·</span> Muebles <span>·</span>
    Ropa <span>·</span> Calzado <span>·</span> Accesorios <span>·</span>
    Hogar <span>·</span> Deportes <span>·</span> Libros <span>·</span>
    Juguetes <span>·</span> Tecnologia <span>·</span> Muebles <span>·</span>
  </div>
</div>

<!-- STATS + MÁS PRODUCTOS -->
<section class="stats-section" id="categorias">
  <div class="stats-left">
    <h2>+83</h2>
    <p>Prendas disponibles ahora mismo</p>
  </div>
  <div class="stats-grid">
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=400&auto=format" alt="Parka"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Parka acolchada de temporada</p>
      <p class="prod-price">$ 520.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&auto=format" alt="Mochila"/>
      <p class="prod-cat">Accesorios</p>
      <p class="prod-name">Mochila de viaje premium</p>
      <p class="prod-price">$ 380.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=400&auto=format" alt="Sudadera"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Sudadera vintage con capucha</p>
      <p class="prod-price">$ 210.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1594938298603-c8148c4b4a80?w=400&auto=format" alt="Blazer"/>
      <p class="prod-cat">Ropa</p>
      <p class="prod-name">Traje ejecutivo unisex</p>
      <p class="prod-price">$ 650.000</p>
    </div>
    <div class="prod-card">
      <img class="prod-card-img" src="https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400&auto=format" alt="Guitarra"/>
      <p class="prod-cat">Otro</p>
      <p class="prod-name">Guitarra acustica vintage</p>
      <p class="prod-price">$ 550.000</p>
    </div>
  </div>
</section>
<div style="text-align:center;padding:0 0 72px;">
  <a href="<%= ctx %>/login" class="btn-shop">Ver todo</a>
</div>

<!-- EDITORIAL 3 COLS -->
<section class="editorial-section" id="nosotras">
  <p class="section-title">Colecciones destacadas</p>
  <div class="editorial-grid">
    <div class="editorial-card">
      <img src="https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=600&auto=format" alt="Ropa vintage"/>
      <h3>Ropa vintage</h3>
      <p>Piezas con historia y personalidad que no encontraras en tiendas convencionales.</p>
      <a href="<%= ctx %>/login" class="link-more">Ver coleccion</a>
    </div>
    <div class="editorial-card">
      <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format" alt="Calzado"/>
      <h3>Calzado de coleccion</h3>
      <p>Zapatos y tenis de edicion limitada y segunda mano en excelente estado.</p>
      <a href="<%= ctx %>/login" class="link-more">Ver coleccion</a>
    </div>
    <div class="editorial-card">
      <img src="https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=600&auto=format" alt="Accesorios"/>
      <h3>Accesorios exclusivos</h3>
      <p>Carteras, cinturones y accesorios curados con criterio editorial.</p>
      <a href="<%= ctx %>/login" class="link-more">Ver coleccion</a>
    </div>
  </div>
</section>

<!-- WHO ARE WE -->
<section class="who-section">
  <div class="who-img">
    <img src="https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=700&auto=format" alt="Liana's"/>
  </div>
  <div class="who-text">
    <h2>QUIENES <em>SOMOS</em></h2>
    <p>Liana's nacio de la conviccion de que la moda sostenible y la historia de las prendas merecen un espacio propio. Conectamos a vendedores verificados con compradores que valoran lo unico.</p>
    <a href="<%= ctx %>/registro" class="link-more">Unirme a Liana's</a>
  </div>
  <div class="who-img">
    <img src="https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=700&auto=format" alt="Moda"/>
  </div>
</section>

<!-- GALERÍA -->
<div class="gram-text">
  Siguenos en Instagram <span>@lianasco</span> &nbsp;&nbsp;&nbsp;
  Siguenos en Instagram <span>@lianasco</span> &nbsp;&nbsp;&nbsp;
  Siguenos en Instagram <span>@lianasco</span>
</div>
<div class="gram-ticker">
  <img src="https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=300&auto=format" alt=""/>
  <img src="https://images.unsplash.com/photo-1542272604-787c3835535d?w=300&auto=format" alt=""/>
  <img src="https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=300&auto=format" alt=""/>
  <img src="https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=300&auto=format" alt=""/>
  <img src="https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=300&auto=format" alt=""/>
  <img src="https://images.unsplash.com/photo-1594938298603-c8148c4b4a80?w=300&auto=format" alt=""/>
</div>

<!-- NEWSLETTER -->
<section class="newsletter">
  <h2>Unete a la comunidad Liana's</h2>
  <p>Registrate y descubre prendas unicas antes que nadie.</p>
  <div class="newsletter-form">
    <input type="text" placeholder="Tu nombre"/>
    <button onclick="window.location='<%= ctx %>/registro'">Registrarse</button>
  </div>
</section>

<!-- FOOTER -->
<footer class="footer">
  <div class="footer-logo">Liana's.</div>
  <div>
    <span>&copy; 2026 Liana's &mdash; Bogota, Colombia</span>
    <a href="<%= ctx %>/login">Ingresar</a>
    <a href="<%= ctx %>/registro">Registrarse</a>
  </div>
</footer>

</body>
</html>
