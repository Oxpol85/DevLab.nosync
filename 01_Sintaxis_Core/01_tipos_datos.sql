/* ====================================================================
   📚 TEMA 1: Tipos de Datos y Sintaxis Core en Oracle SQL
   ====================================================================
   Diferencias clave con MySQL:
   - Textos: Se usa VARCHAR2.
   - Números: Se usa NUMBER (reemplaza a INT, FLOAT, DECIMAL).
*/
CREATE TABLE perfil_estudiante (
    id_estudiante   NUMBER(5) PRIMARY KEY,
    nombre_usuario  VARCHAR2(50) NOT NULL,
    progreso_pct    NUMBER(5,2),         -- Permite hasta 999.99
    fecha_registro  DATE DEFAULT SYSDATE -- SYSDATE captura la hora del servidor
);

INSERT INTO perfil_estudiante (id_estudiante, nombre_usuario, progreso_pct)
VALUES (1, 'oxpol85', 15.50);

SELECT * FROM perfil_estudiante;