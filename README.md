# Liana's 🌿
### Marketplace de moda vintage y segunda mano · Colombia

> Plataforma de comercio electrónico especializada en la compraventa de ropa vintage, piezas de archivo y prendas de segunda mano. Desarrollada como proyecto académico para la materia **Nuevas Tecnologías de Desarrollo** — Fundación Universitaria Konrad Lorenz.

---

## 👥 Equipo

| Nombre | Rol |
|---|---|
| Anamaría Méndez Saavedra | Desarrollo full-stack |
| Ana María Forigua Valderrama | Desarrollo full-stack |
| Lina María Parra Torrijos | Desarrollo full-stack |

**Docente:** Ibáñez Olaya Engelberth  
**Materia:** Nuevas Tecnologías de Desarrollo — Facultad de Matemáticas e Ingeniería

---

## 🛠️ Stack tecnológico

- **Backend:** Java 23 · Servlets · Patrón MVC · Patrón DAO
- **Frontend:** JSP · CSS3 · HTML5
- **Base de datos:** MySQL / MariaDB 10.4 (XAMPP)
- **Servidor:** Apache Tomcat 10.x
- **IDE:** Apache NetBeans
- **Autenticación:** Login en 2 pasos con verificación por correo (Gmail SMTP)
- **Seguridad:** Contraseñas encriptadas con SHA-256

---

## Funcionalidades

### Roles de usuario
- **Comprador** — Navega el catálogo, agrega al carrito, realiza compras y califica vendedores
- **Vendedor** — Publica productos, gestiona inventario y ve sus reseñas
- **Admin** — Valida identidades de vendedores, gestiona usuarios y revisa auditoría

### Módulos implementados
- **Módulo 1 — Usuarios:** Registro con verificación por correo, login en 2 pasos, roles diferenciados
- **Módulo 2 — Publicaciones:** CRUD de productos con imágenes, descripción y política de devolución
- **Módulo 3 — Catálogo:** Búsqueda y filtros por categoría, precio, estado y ordenamiento
- **Módulo 4 — Compras:** Carrito de compras, dirección de envío y 6 métodos de pago
- **Calificaciones:** Sistema de reseñas y reputación de vendedores
- **Auditoría:** Registro automático de acciones mediante triggers PL/SQL

---

## Instalación local

### Requisitos previos
- JDK 21+
- Apache NetBeans
- XAMPP (MySQL/MariaDB)
- Apache Tomcat 10.x

### Pasos

**1. Clonar el repositorio**
```bash
git clone https://github.com/Annymendez/Liana-s.git
```

**2. Crear la base de datos**

Abre MySQL Workbench y ejecuta el archivo:
```
mercadored.sql
```

**3. Configurar la conexión**

Edita `src/java/util/DBConexion.java`:
```java
private static final String USUARIO  = "root";
private static final String PASSWORD = ""; // tu contraseña de MySQL
```

**4. Configurar el correo (opcional)**

Edita `src/java/util/EmailService.java` con tu App Password de Gmail:
```java
private static final String CONTRASENA = "tu_app_password";
```

**5. Abrir en NetBeans**
- `File → Open Project` selecciona la carpeta del proyecto
- Agrega los JARs en Libraries: `mysql-connector-j-9.1.0.jar`, `javax.mail-1.6.2.jar`, `activation-1.1.1.jar`
- `Clean and Build → F6`

**6. Acceder a la aplicación**
```
http://localhost:8080/Liana_s
```

---

## Usuarios de prueba

| Correo | Contraseña | Rol |
|---|---|---|
| annymendez2005@gmail.com | 123456 | Admin |
| anaforigua02@gmail.com | 123456 | Admin |
| anamamendez2005@gmail.com | 123456 | Vendedor (Hogar + Tecnología) |
| juanesf6126@hotmail.com | 123456 | Vendedor (resto de categorías) |
| sandralilianasaavedraquevedo@gmail.com | 123456 | Comprador |

---

## Estructura del proyecto

```
Liana/
├── src/
│   └── java/
│       ├── controller/     # Servlets (AuthFilter, LoginServlet, ProductoServlet...)
│       ├── dao/            # Capa de acceso a datos
│       ├── model/          # Modelos (Persona, Producto, Orden...)
│       └── util/           # Utilidades (DBConexion, EmailService, HashUtil...)
├── web/
│   ├── *.jsp               # Vistas JSP
│   ├── estilo.css          # Estilos globales
│   └── index.jsp           # Landing page
└── mercadored.sql          # Script de base de datos
```

---

## Licencia

Proyecto académico — Fundación Universitaria Konrad Lorenz · 2026
