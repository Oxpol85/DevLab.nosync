/* ====================================================================
   📚 TEMA 2: Manejo de Datos Semi-estructurados (JSON)
   ====================================================================
   Oracle permite almacenar y consultar JSON nativamente. Se utiliza la 
   restricción IS JSON para asegurar que el texto insertado sea válido.
*/
CREATE TABLE logs_plataforma (
    id_log      NUMBER GENERATED ALWAYS AS IDENTITY,
    detalles    VARCHAR2(4000) CHECK (detalles IS JSON),
    fecha       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO logs_plataforma (detalles)
VALUES ('{"usuario": "oxpol85", "modulo": "Vector_AI", "estado": "activo"}');

-- Extracción directa de valores clave-valor usando la notación de punto
SELECT l.detalles.usuario, l.detalles.modulo 
FROM logs_plataforma l;