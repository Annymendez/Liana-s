-- Liana's — asigna las imágenes subidas por Lina a cada producto
-- Ejecutar en MySQL Workbench sobre la base mercadored
USE mercadored;
SET SQL_SAFE_UPDATES = 0;

UPDATE producto SET imagen_url = 'img/productos/abrigo-max-mara-de-lana-y-cachemir.jpg' WHERE TRIM(titulo) = 'Abrigo Max Mara de lana y cachemir';
UPDATE producto SET imagen_url = 'img/productos/abrigo-de-piel-sintetica-estampado-leopardo.jpg' WHERE TRIM(titulo) = 'Abrigo de piel sintética estampado leopardo';
UPDATE producto SET imagen_url = 'img/productos/abrigo-largo-aquascutum-de-lana.jpg' WHERE TRIM(titulo) = 'Abrigo largo Aquascutum de lana';
UPDATE producto SET imagen_url = 'img/productos/blazer-christian-dior-boutique.jpg' WHERE TRIM(titulo) = 'Blazer Christian Dior Boutique';
UPDATE producto SET imagen_url = 'img/productos/blazer-escada-con-botones-dorados.jpg' WHERE TRIM(titulo) = 'Blazer Escada con botones dorados';
UPDATE producto SET imagen_url = 'img/productos/blusa-de-encaje-victoriano.jpg' WHERE TRIM(titulo) = 'Blusa de encaje victoriano';
UPDATE producto SET imagen_url = 'img/productos/bolso-coach-de-cuero-tabaco.jpg' WHERE TRIM(titulo) = 'Bolso Coach de cuero tabaco';
UPDATE producto SET imagen_url = 'img/productos/bolso-fendi-baguette-de-lentejuelas.jpg' WHERE TRIM(titulo) = 'Bolso Fendi Baguette de lentejuelas';
UPDATE producto SET imagen_url = 'img/productos/bolso-gucci-bamboo-de-mano.jpg' WHERE TRIM(titulo) = 'Bolso Gucci Bamboo de mano';
UPDATE producto SET imagen_url = 'img/productos/bolso-louis-vuitton-speedy-30-monograma.jpg' WHERE TRIM(titulo) = 'Bolso Louis Vuitton Speedy 30 monograma';
UPDATE producto SET imagen_url = 'img/productos/camisa-versace-de-seda-medusa.jpg' WHERE TRIM(titulo) = 'Camisa Versace de seda Medusa';
UPDATE producto SET imagen_url = 'img/productos/carre-de-seda-hermes-90-cm.jpg' WHERE TRIM(titulo) = 'Carré de seda Hermès 90 cm';
UPDATE producto SET imagen_url = 'img/productos/chaqueta-moschino-cheap-and-chic.jpg' WHERE TRIM(titulo) = 'Chaqueta Moschino Cheap and Chic';
UPDATE producto SET imagen_url = 'img/productos/chaqueta-pendleton-de-lana-a-cuadros.jpg' WHERE TRIM(titulo) = 'Chaqueta Pendleton de lana a cuadros';
UPDATE producto SET imagen_url = 'img/productos/chaqueta-yves-saint-laurent-rive-gauche.jpg' WHERE TRIM(titulo) = 'Chaqueta Yves Saint Laurent Rive Gauche';
UPDATE producto SET imagen_url = 'img/productos/chaqueta-de-cuero-estilo-aviador.jpg' WHERE TRIM(titulo) = 'Chaqueta de cuero estilo aviador';
UPDATE producto SET imagen_url = 'img/productos/falda-midi-plisada-de-lana.jpg' WHERE TRIM(titulo) = 'Falda midi plisada de lana';
UPDATE producto SET imagen_url = 'img/productos/mochila-prada-de-nailon-negro.jpg' WHERE TRIM(titulo) = 'Mochila Prada de nailon negro';
UPDATE producto SET imagen_url = 'img/productos/polo-lacoste-con-cocodrilo-bordado.jpg' WHERE TRIM(titulo) = 'Polo Lacoste con cocodrilo bordado';
UPDATE producto SET imagen_url = 'img/productos/slingback-chanel-bicolor.jpg' WHERE TRIM(titulo) = 'Slingback Chanel bicolor';
UPDATE producto SET imagen_url = 'img/productos/sueter-polo-ralph-lauren-trenzado.jpg' WHERE TRIM(titulo) = 'Suéter Polo Ralph Lauren trenzado';
UPDATE producto SET imagen_url = 'img/productos/sueter-united-colors-of-benetton.jpg' WHERE TRIM(titulo) = 'Suéter United Colors of Benetton';
UPDATE producto SET imagen_url = 'img/productos/trench-burberry-clasico-de-gabardina.jpg' WHERE TRIM(titulo) = 'Trench Burberry clásico de gabardina';
UPDATE producto SET imagen_url = 'img/productos/vestido-pierre-cardin-geometrico.jpg' WHERE TRIM(titulo) = 'Vestido Pierre Cardin geométrico';
UPDATE producto SET imagen_url = 'img/productos/vestido-valentino-de-seda.jpg' WHERE TRIM(titulo) = 'Vestido Valentino de seda';
UPDATE producto SET imagen_url = 'img/productos/vestido-camisero-floral-anos-70.jpg' WHERE TRIM(titulo) = 'Vestido camisero floral años 70';
UPDATE producto SET imagen_url = 'img/productos/vestido-de-coctel-anos-50-con-falda-circular.jpg' WHERE TRIM(titulo) = 'Vestido de coctel años 50 con falda circular';
UPDATE producto SET imagen_url = 'img/productos/vestido-de-tweed-chanel-boutique.jpg' WHERE TRIM(titulo) = 'Vestido de tweed Chanel Boutique';
UPDATE producto SET imagen_url = 'img/productos/vestido-envolvente-diane-von-furstenberg.jpg' WHERE TRIM(titulo) = 'Vestido envolvente Diane von Furstenberg';
UPDATE producto SET imagen_url = 'img/productos/zapatos-salvatore-ferragamo-vara.jpg' WHERE TRIM(titulo) = 'Zapatos Salvatore Ferragamo Vara';

SET SQL_SAFE_UPDATES = 1;

-- Verificación: productos que quedaron SIN imagen local
SELECT id_producto, titulo, imagen_url FROM producto
WHERE imagen_url IS NULL OR imagen_url = '' OR imagen_url NOT LIKE 'img/productos/%'
ORDER BY titulo;
