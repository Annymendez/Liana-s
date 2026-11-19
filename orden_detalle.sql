-- ─────────────────────────────────────────────────────────────
-- Liana's — tabla orden_detalle
-- Guarda qué productos tiene cada orden. Sin esto no se puede
-- saber a qué vendedor calificar.
-- Ejecutar UNA vez en MySQL Workbench sobre la base mercadored.
-- ─────────────────────────────────────────────────────────────
USE mercadored;

CREATE TABLE IF NOT EXISTS orden_detalle (
  id_detalle      INT NOT NULL AUTO_INCREMENT,
  id_orden        INT NOT NULL,
  id_producto     INT NOT NULL,
  cantidad        INT NOT NULL DEFAULT 1,
  precio_unitario DECIMAL(15,2) NOT NULL,
  PRIMARY KEY (id_detalle),
  KEY idx_detalle_orden (id_orden),
  KEY idx_detalle_producto (id_producto),
  CONSTRAINT fk_detalle_orden    FOREIGN KEY (id_orden)    REFERENCES orden (id_orden) ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
