# Liana's
### Marketplace de moda vintage, de archivo y segunda mano · Colombia

> Plataforma de comercio electrónico para comprar y vender ropa vintage, piezas de archivo y prendas de segunda mano. Proyecto académico de la materia **Nuevas Tecnologías de Desarrollo** — Fundación Universitaria Konrad Lorenz.

Liana's es la evolución de **MercadoRed**: conserva su arquitectura (Servlets, JSP, DAO, JDBC) y la adapta a un nuevo público y a una estética propia. El nombre combina los de sus tres creadoras: **Li**na María, **Ana**maría y **Ana** María.

---

## Equipo

| Nombre | Rol |
|---|---|
| Anamaría Méndez Saavedra | Desarrollo full-stack |
| Ana María Forigua Valderrama | Desarrollo full-stack |
| Lina María Parra Torrijos | Desarrollo full-stack |

**Docente:** Engelberth Ibáñez Olaya
**Materia:** Nuevas Tecnologías de Desarrollo — Facultad de Matemáticas e Ingenierías

---

## Stack tecnológico

| Capa | Tecnología |
|---|---|
| Lenguaje | Java 21 |
| Web | JSP + Servlets (Jakarta EE), patrón MVC |
| Datos | MySQL · JDBC · patrón DAO |
| Servidor | Apache Tomcat 10.1 |
| Build | Maven → `Liana_s-1.0.war` |
| Autenticación | Login en 2 pasos con verificación por correo (Gmail SMTP) |
| Seguridad | Contraseñas con SHA-256 · filtro de acceso por rol (`AuthFilter`) |

---

## Funcionalidades

### Comprador
- Catálogo con búsqueda y filtros (marca, categoría, estado, precio, orden)
- Detalle de prenda → **Comprar ahora** la agrega al carrito
- Compra en 3 pasos: carrito → dirección de envío → método de pago
- Mis pedidos: confirmar recepción (libera los fondos al vendedor) y calificar

### Vendedor
- Publicar, editar y listar productos (título, categoría, marca, precio, stock, imagen, estado nuevo/usado, política de devolución)
- Gestión de órdenes: pendiente → pagado → enviado → entregado / cancelado
- Reseñas: promedio de reputación y calificaciones recibidas

### Administrador
- Validación de identidad de vendedores con revisión del documento digital
- Gestión de usuarios: cambiar tipo, estado (activo / inactivo / sancionado) o eliminar
- Auditoría automática de acciones mediante triggers

### Flujo de compra y calificación
1. El comprador paga → se crea la **orden** (estado *pagado*, fondos retenidos) y sus productos quedan en **`orden_detalle`**
2. El vendedor la marca como **enviado**
3. El comprador **confirma la recepción** → *entregado*, fondos liberados
4. El comprador **califica** → la reseña le llega al vendedor dueño del producto

---

## Diseño — estética "Rewind"

- **Tipografía:** *IM Fell English* itálica (títulos) · *Inter 300* (texto)
- **Paleta:** `#111` · `#aaa` · `#eee` con acento dorado `#c8a46e`
- **Formas:** sin `border-radius`, líneas de 1px, etiquetas en mayúscula con espaciado

---

## Instalación local

### Requisitos
- JDK 21
- Maven 3.9+
- MySQL 8 (Workbench o XAMPP)
- Apache Tomcat 10.1

### 1. Clonar el repositorio
```bash
git clone https://github.com/Annymendez/Liana-s.git
```

### 2. Crear la base de datos
En MySQL Workbench ejecuta, **en este orden**:
1. `mercadored.sql` — crea la base `mercadored` y sus tablas
2. `orden_detalle.sql` — crea la tabla que relaciona cada orden con sus productos (necesaria para comprar y calificar)

### 3. Configurar la conexión
Edita `src/main/java/util/DBConexion.java` con tus datos de MySQL:
```java
private static final String USUARIO  = "root";
private static final String PASSWORD = "root"; // tu contraseña de MySQL
```

### 4. Configurar el correo (opcional)
Edita `src/main/java/util/EmailService.java` con una App Password de Gmail.

### 5. Compilar y desplegar
```bash
mvn clean package
```
Copia `target/Liana_s-1.0.war` a la carpeta `webapps/` de Tomcat e inicia el servidor.

### 6. Abrir la aplicación
```
http://localhost:8080/Liana_s-1.0/
```

---

## Estructura del proyecto

```
Liana/
├── src/main/java/
│   ├── controller/   # Servlets: Producto, Carrito, Orden, Calificacion, Admin, Login, AuthFilter…
│   ├── dao/          # Acceso a datos: ProductoDAO, OrdenDAO, CalificacionDAO…
│   ├── model/        # Persona, Vendedor, Producto, Orden, CarritoItem, Calificacion
│   └── util/         # DBConexion, EmailService, HashUtil, Html
├── src/main/webapp/  # Vistas JSP, navbar.jsp y hojas de estilo
├── mercadored.sql    # Script de la base de datos
├── orden_detalle.sql # Tabla de detalle de órdenes
└── pom.xml
```

---

## Licencia

Proyecto académico — Fundación Universitaria Konrad Lorenz · Bogotá, Colombia · 2026
