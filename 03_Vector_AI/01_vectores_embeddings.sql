/* ====================================================================
   📚 TEMA 3: Bases de Datos Vectoriales e IA
   ====================================================================
   Oracle 23ai introduce el tipo de dato VECTOR para almacenar embeddings.
   Permite realizar búsquedas por similitud semántica.
*/
CREATE TABLE documentos_ia (
    id_doc      NUMBER PRIMARY KEY,
    contenido   VARCHAR2(1000),
    embedding   VECTOR(3, FLOAT32) -- Define la dimensión y precisión del vector
);

-- Inserción simulando el resultado (array numérico) de un modelo de lenguaje
INSERT INTO documentos_ia (id_doc, contenido, embedding)
VALUES (1, 'Configuración de laboratorios en OCI', '[0.14, 0.98, -0.45]');

-- Cálculo de similitud utilizando distancia vectorial
SELECT contenido, VECTOR_DISTANCE(embedding, '[0.15, 0.95, -0.42]') AS distancia
FROM documentos_ia
ORDER BY distancia ASC;