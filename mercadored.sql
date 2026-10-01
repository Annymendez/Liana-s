-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: mercadored
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `calificacion`
--

DROP TABLE IF EXISTS `calificacion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `calificacion` (
  `id_calificacion` int NOT NULL AUTO_INCREMENT,
  `id_orden` int NOT NULL,
  `id_evaluador` int NOT NULL,
  `id_evaluado` int NOT NULL,
  `puntaje` int NOT NULL,
  `comentario` text COLLATE utf8mb4_unicode_ci,
  `tipo` enum('comprador_a_vendedor','vendedor_a_comprador') COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_calificacion`),
  UNIQUE KEY `uk_orden_tipo` (`id_orden`,`tipo`),
  KEY `id_evaluador` (`id_evaluador`),
  KEY `id_evaluado` (`id_evaluado`),
  CONSTRAINT `calificacion_ibfk_1` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id_orden`),
  CONSTRAINT `calificacion_ibfk_2` FOREIGN KEY (`id_evaluador`) REFERENCES `persona` (`id_persona`),
  CONSTRAINT `calificacion_ibfk_3` FOREIGN KEY (`id_evaluado`) REFERENCES `persona` (`id_persona`),
  CONSTRAINT `calificacion_chk_1` CHECK ((`puntaje` between 1 and 5))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `calificacion`
--

LOCK TABLES `calificacion` WRITE;
/*!40000 ALTER TABLE `calificacion` DISABLE KEYS */;
/*!40000 ALTER TABLE `calificacion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orden`
--

DROP TABLE IF EXISTS `orden`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orden` (
  `id_orden` int NOT NULL AUTO_INCREMENT,
  `id_comprador` int NOT NULL,
  `total` decimal(15,2) NOT NULL,
  `estado_orden` enum('pendiente','pagado','enviado','entregado','cancelado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `fondos_retenidos` tinyint(1) NOT NULL DEFAULT '1',
  `metodo_pago` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'CA029',
  `direccion_envio` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'CA027',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_orden`),
  KEY `id_comprador` (`id_comprador`),
  CONSTRAINT `orden_ibfk_1` FOREIGN KEY (`id_comprador`) REFERENCES `persona` (`id_persona`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orden`
--

LOCK TABLES `orden` WRITE;
/*!40000 ALTER TABLE `orden` DISABLE KEYS */;
/*!40000 ALTER TABLE `orden` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persona` (
  `id_persona` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `documento` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `celular` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `contrasena` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` enum('activo','inactivo','sancionado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'inactivo',
  `tipo` enum('comprador','vendedor','admin') COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `documento` (`documento`),
  UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `persona`
--

LOCK TABLES `persona` WRITE;
/*!40000 ALTER TABLE `persona` DISABLE KEYS */;
INSERT INTO `persona` VALUES (1,'Anamaría Méndez','1111111111','annymendez2005@gmail.com','3209876543','Bogotá','123456','activo','admin','2026-09-24 18:40:13'),(2,'Ana María Méndez','2222222222','anamamendez2005@gmail.com','3109876543','Bogotá','123456','activo','vendedor','2026-09-24 18:40:13'),(3,'Sandra Saavedra','3333333333','sandralilianasaavedraquevedo@gmail.com','3001234567','Bogotá','123456','activo','comprador','2026-09-24 18:40:13'),(4,'Ana Forigua','4444444444','anaforigua02@gmail.com','3151234567','Bogotá','123456','activo','admin','2026-09-24 18:40:13'),(5,'Juan Figueroa','5555555555','juanesf6126@hotmail.com','3001234567','Bogotá','123456','activo','vendedor','2026-09-24 18:40:14'),(6,'Lina Parra','34567890','linapa2000@gmail.com','3456789','TRansversal 475f-04','123456','activo','comprador','2026-09-24 20:00:55');
/*!40000 ALTER TABLE `persona` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `id_vendedor` int NOT NULL,
  `titulo` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(15,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `categoria` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `imagen_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_producto` enum('nuevo','usado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'nuevo',
  `visibilidad` enum('activo','oculto','eliminado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'activo',
  `politica_devolucion` text COLLATE utf8mb4_unicode_ci COMMENT 'CA018',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_producto`),
  KEY `id_vendedor` (`id_vendedor`),
  CONSTRAINT `producto_ibfk_1` FOREIGN KEY (`id_vendedor`) REFERENCES `vendedor` (`id_vendedor`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,1,'Laptop HP 15','Core i5, 8GB RAM, 256GB SSD',2500000.00,5,'Tecnología','https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(2,1,'Teclado mecánico RGB','Switches azules, retroiluminación RGB',350000.00,12,'Tecnología','https://images.unsplash.com/photo-1618384887929-16ec33fab9ef?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(3,1,'Monitor Samsung 24\"','LED 24\" Full HD, 75Hz',650000.00,10,'Tecnología','https://images.unsplash.com/photo-1527443224154-c4a573d5f6b4?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(4,1,'Mouse inalámbrico Logitech','Ergonómico, sensor alta precisión',120000.00,25,'Tecnología','https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(5,1,'Audífonos Bluetooth Sony','Cancelación de ruido activa',550000.00,15,'Tecnología','https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(6,1,'Disco duro externo 1TB','USB 3.0, portátil',280000.00,20,'Tecnología','https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(7,1,'Cámara Web HD','1080p con micrófono integrado',190000.00,30,'Tecnología','https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(8,1,'Router Wi-Fi 6','Alta velocidad, doble banda',310000.00,7,'Tecnología','https://images.unsplash.com/photo-1606904825846-647eb07f5be2?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(9,1,'Memoria USB 64GB','Metálica, alta velocidad',45000.00,50,'Tecnología','https://images.unsplash.com/photo-1618410320928-25228d811631?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(10,1,'Soporte para laptop','Aluminio ajustable',110000.00,15,'Tecnología','https://images.unsplash.com/photo-1527443195645-1133f7f28990?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(11,1,'Mousepad XL','Antideslizante, 80x40cm',75000.00,25,'Tecnología','https://images.unsplash.com/photo-1615751072497-5f5169febe17?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(12,1,'Cargador USB-C 65W','Carga rápida universal',95000.00,22,'Tecnología','https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(13,1,'Tablet Samsung Galaxy A8','10.5\" Full HD, 3GB RAM',890000.00,8,'Tecnología','https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(14,1,'Smartphone Xiaomi Redmi Note 12','AMOLED 6.67\", 128GB, 50MP',1100000.00,15,'Tecnología','https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(15,1,'Apple AirPods Pro 2da Gen','ANC, audio espacial, IPX4',1350000.00,10,'Tecnología','https://images.unsplash.com/photo-1588423771073-b8903fead714?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(16,1,'SSD Externo Kingston 500GB','1000MB/s, USB 3.2',310000.00,20,'Tecnología','https://images.unsplash.com/photo-1597347316205-36f6c451902a?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(17,1,'Teclado Logitech MX Keys','Retroiluminado, multi-dispositivo',480000.00,12,'Tecnología','https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(18,1,'Proyector Xiaomi Mi','1080p, 500 lúmenes, Android',1200000.00,4,'Tecnología','https://images.unsplash.com/photo-1478778751076-53714b756d3f?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(19,1,'Smartwatch Amazfit GTR 4','GPS, 150 modos deporte, 14 días',750000.00,9,'Tecnología','https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(20,1,'Impresora HP Laser','Multifuncional monocromática',780000.00,5,'Tecnología','https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(21,2,'Silla gamer ergonómica','Soporte lumbar ajustable, reclinable',850000.00,3,'Muebles','https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(22,2,'Escritorio de oficina','Madera con estructura metálica',450000.00,8,'Muebles','https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(23,2,'Estantería metálica','5 niveles, 180cm altura',320000.00,12,'Muebles','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(24,2,'Silla de oficina ejecutiva','Malla transpirable, ergonómica',520000.00,6,'Muebles','https://images.unsplash.com/photo-1592078615290-033ee584e267?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(25,2,'Mesa de centro moderna','Diseño minimalista, madera y vidrio',290000.00,4,'Muebles','https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(26,2,'Armario pequeño','Organizador de dos puertas',680000.00,3,'Muebles','https://images.unsplash.com/photo-1558997519-83ea9252edf8?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(27,2,'Lámpara de escritorio LED','Brazo flexible, ajuste de tono',85000.00,18,'Muebles','https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(28,2,'Sofá de 3 puestos','Madera maciza, espuma alta densidad, gris',1850000.00,3,'Muebles','https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(29,2,'Cama doble con cabecero','Pino, tapizado, somier láminas, 140x190cm',1250000.00,4,'Muebles','https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(30,2,'Mesa de comedor 6 puestos','MDF lacado blanco, patas acero',980000.00,3,'Muebles','https://images.unsplash.com/photo-1617806118233-18e1de247200?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(31,2,'Biblioteca modular 5 niveles','Roble, estructura metálica negra',650000.00,5,'Muebles','https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(32,2,'Silla de comedor tapizada x4','Patas madera, tapizado gris antracita',480000.00,6,'Muebles','https://images.unsplash.com/photo-1551298370-9d3d53740c72?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(33,2,'Cómoda 6 cajones','MDF blanco, tiradores dorados, 90x80cm',620000.00,4,'Muebles','https://images.unsplash.com/photo-1594737626072-90dc274bc2bd?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(34,2,'Escritorio esquinero','Melamina blanca, soporte monitor, 140x120cm',750000.00,5,'Muebles','https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(35,2,'Chaqueta impermeable North Face','Gore-Tex, capucha ajustable, S-XL',580000.00,10,'Ropa','https://images.unsplash.com/photo-1551488831-00ddcb6c6bd3?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(36,2,'Jeans Levi\'s 501 Original','Recto clásico, 100% algodón, 28-36',320000.00,20,'Ropa','https://images.unsplash.com/photo-1542272604-787c3835535d?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(37,2,'Camiseta básica premium x3','Algodón pima, cuello redondo, XS-XXL',150000.00,35,'Ropa','https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(38,2,'Tenis Nike Air Max 270','Cámara de aire visible, 36-44',450000.00,15,'Ropa','https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(39,2,'Sudadera Adidas con capucha','Fleece suave, bolsillo canguro, S-XL',210000.00,18,'Ropa','https://images.unsplash.com/photo-1556821840-3a63f15732ce?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(40,2,'Vestido floral verano','Viscosa, escote V, largo midi, XS-L',185000.00,12,'Ropa','https://images.unsplash.com/photo-1585487000160-6ebcfceb0d03?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(41,2,'Blazer ejecutivo unisex','Stretch anti-arrugas, S-XL',390000.00,8,'Ropa','https://images.unsplash.com/photo-1594938298603-c8148c4b4a80?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(42,2,'Parka acolchada invierno','Plumas sintéticas, capucha desmontable',520000.00,6,'Ropa','https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(43,1,'Set de ollas Tefal 5 piezas','Antiadherente titanio, apto lavavajillas',420000.00,10,'Hogar','https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(44,1,'Aspiradora Xiaomi Mi Robot','Láser LDS, 2500Pa, 150 min',1150000.00,6,'Hogar','https://images.unsplash.com/photo-1563453392212-326f5e854473?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(45,1,'Cafetera Nespresso','19 bares, calentamiento 25 seg, 0.7L',480000.00,12,'Hogar','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(46,1,'Freidora de aire Philips 5.5L','AirFryer, 200°C, 1750W',520000.00,8,'Hogar','https://images.unsplash.com/photo-1585515320310-259814833e62?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(47,1,'Licuadora Oster 1200W','Vaso cristal 1.5L, 10 velocidades',220000.00,15,'Hogar','https://images.unsplash.com/photo-1570197788417-0e82375c9371?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(48,1,'Set sábanas king size','Algodón egipcio 400 hilos, nórdica + 2 fundas',280000.00,20,'Hogar','https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(49,1,'Purificador Levoit','HEPA H13, 60m², Wi-Fi',680000.00,7,'Hogar','https://images.unsplash.com/photo-1585771724684-38269d6639fd?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(50,1,'Plancha vapor Rowenta','Cerámica, 2600W, 350ml',245000.00,18,'Hogar','https://images.unsplash.com/photo-1582735689369-4fe89db7114c?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(51,1,'Microondas Samsung 28L','Grill, 900W, panel táctil',380000.00,9,'Hogar','https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(52,2,'Bicicleta Trek 26\"','Aluminio, 21 vel Shimano, frenos disco',1650000.00,5,'Deportes','https://images.unsplash.com/photo-1485965120184-e220f721d03e?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(53,2,'Mancuernas ajustables 20kg','Set x2, ajuste rápido 2-20kg',680000.00,8,'Deportes','https://images.unsplash.com/photo-1584735935682-2f2b69dff9d2?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(54,2,'Colchoneta yoga 6mm','TPE ecológico, bolsa de transporte',95000.00,25,'Deportes','https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(55,2,'Cuerda de saltar profesional','Cable acero, mangos aluminio',75000.00,30,'Deportes','https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(56,2,'Balón de fútbol Adidas','Talla 5, cuero sintético',180000.00,20,'Deportes','https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(57,2,'Trotadora eléctrica plegable','1-12 km/h, LCD, motor 1.5HP',1350000.00,4,'Deportes','https://images.unsplash.com/photo-1596357395217-80de13130e92?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(58,2,'Kit natación Speedo','Gafas, gorro silicona, tapones, clip',120000.00,15,'Deportes','https://images.unsplash.com/photo-1530549387789-4c1017266635?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(59,2,'Guantes boxeo Everlast 12oz','Cuero sintético, triple densidad',210000.00,12,'Deportes','https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(60,2,'Hábitos Atómicos - James Clear','Construye buenos hábitos. Bestseller',72000.00,30,'Libros','https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(61,2,'El Poder del Ahora - Tolle','Guía espiritual, vivir en el presente',68000.00,25,'Libros','https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(62,2,'Padre Rico Padre Pobre','Educación financiera, Kiyosaki',65000.00,40,'Libros','https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(63,2,'Cien Años de Soledad','Edición especial, García Márquez',85000.00,20,'Libros','https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(64,2,'Sapiens - Harari','Historia breve de la humanidad',78000.00,22,'Libros','https://images.unsplash.com/photo-1491841651911-c44484e7c32a?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(65,2,'El Principito - Edición lujo','Tapa dura, 25x25cm, papel couché',55000.00,35,'Libros','https://images.unsplash.com/photo-1519791883288-dc8bd696e667?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(66,2,'Aprende Python en 30 días','Desde cero, ejercicios y proyectos',95000.00,18,'Libros','https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(67,2,'Pack 5 libros desarrollo personal','Piense y Hágase Rico + 4 más',220000.00,10,'Libros','https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(68,2,'LEGO Ciudad 500 piezas','Ciudad Espacial, +8 años, minifiguras',280000.00,12,'Juguetes','https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(69,2,'Muñeca Baby Alive interactiva','Come, bebe, habla español',195000.00,10,'Juguetes','https://images.unsplash.com/photo-1561702930-f8b724e33c7c?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(70,2,'Auto control remoto 1:12','25km/h, batería recargable',240000.00,8,'Juguetes','https://images.unsplash.com/photo-1594736797933-d0501ba2fe65?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(71,2,'Puzzle 1000 piezas','Fotográfico, 68x48cm',85000.00,20,'Juguetes','https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(72,2,'Kit ciencia para niños','30+ experimentos, microscopio',175000.00,15,'Juguetes','https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(73,2,'Monopoly Clásico','Español, 2-8 jugadores, +8 años',120000.00,18,'Juguetes','https://images.unsplash.com/photo-1610890716171-6b1bb98ffd09?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(74,2,'Drone starter kit','720p, 20 min, radio 100m',850000.00,5,'Juguetes','https://images.unsplash.com/photo-1473968512647-3e447244af8f?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(75,2,'Set arte y pintura infantil','120 piezas, acuarelas y lápices',95000.00,22,'Juguetes','https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(76,2,'Perfume Acqua di Gio 100ml','Giorgio Armani, frasco original',420000.00,10,'Otro','https://images.unsplash.com/photo-1541643600914-78b084683702?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(77,2,'Mochila Samsonite 30L','Compartimento laptop 15.6\", USB',380000.00,14,'Otro','https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(78,2,'Set maletas viaje 3 piezas','Policarbonato, llantas 360°, TSA',850000.00,6,'Otro','https://images.unsplash.com/photo-1565026057447-bc90a3dceb87?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(79,2,'Guitarra Yamaha F310','Abeto, acero, incluye funda',550000.00,7,'Otro','https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(80,2,'Cámara Canon Rebel T7','24.1MP, FullHD, lente 18-55mm',1850000.00,4,'Otro','https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(81,2,'Herramientas Stanley 92 pzas','Destornilladores, llaves, maletín',320000.00,10,'Otro','https://images.unsplash.com/photo-1504148455328-c376907d081c?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(82,2,'Suculentas colección x6','Macetas cerámica, guía de cuidado',85000.00,25,'Otro','https://images.unsplash.com/photo-1459156212016-c812468e2115?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13'),(83,2,'Cartera cuero genuino','Vacuno colombiano, 8 ranuras',145000.00,20,'Otro','https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=500','nuevo','activo',NULL,'2026-09-24 18:40:13');
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reclamo`
--

DROP TABLE IF EXISTS `reclamo`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reclamo` (
  `id_reclamo` int NOT NULL AUTO_INCREMENT,
  `id_orden` int NOT NULL,
  `id_comprador` int NOT NULL,
  `id_admin` int DEFAULT NULL,
  `motivo` enum('producto_diferente','defectuoso','no_llego','retraso') COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado_reclamo` enum('abierto','en_revision','resuelto','cerrado') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'abierto',
  `resolucion` enum('reembolso','pago_vendedor','acuerdo') COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_apertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_cierre` datetime DEFAULT NULL,
  PRIMARY KEY (`id_reclamo`),
  KEY `id_orden` (`id_orden`),
  KEY `id_comprador` (`id_comprador`),
  KEY `id_admin` (`id_admin`),
  CONSTRAINT `reclamo_ibfk_1` FOREIGN KEY (`id_orden`) REFERENCES `orden` (`id_orden`),
  CONSTRAINT `reclamo_ibfk_2` FOREIGN KEY (`id_comprador`) REFERENCES `persona` (`id_persona`),
  CONSTRAINT `reclamo_ibfk_3` FOREIGN KEY (`id_admin`) REFERENCES `persona` (`id_persona`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reclamo`
--

LOCK TABLES `reclamo` WRITE;
/*!40000 ALTER TABLE `reclamo` DISABLE KEYS */;
/*!40000 ALTER TABLE `reclamo` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vendedor`
--

DROP TABLE IF EXISTS `vendedor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `vendedor` (
  `id_vendedor` int NOT NULL AUTO_INCREMENT,
  `id_persona` int NOT NULL,
  `cuenta_bancaria` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `banco` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `identidad_validada` tinyint(1) NOT NULL DEFAULT '0',
  `reputacion` decimal(3,2) NOT NULL DEFAULT '0.00',
  `documento_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'CA011 - Documento digital',
  PRIMARY KEY (`id_vendedor`),
  UNIQUE KEY `id_persona` (`id_persona`),
  CONSTRAINT `vendedor_ibfk_1` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vendedor`
--

LOCK TABLES `vendedor` WRITE;
/*!40000 ALTER TABLE `vendedor` DISABLE KEYS */;
INSERT INTO `vendedor` VALUES (1,2,NULL,NULL,1,0.00,NULL),(2,5,NULL,NULL,1,0.00,NULL);
/*!40000 ALTER TABLE `vendedor` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-01 10:55:47
