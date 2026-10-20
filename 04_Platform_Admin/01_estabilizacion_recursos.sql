/* ====================================================================
   📚 TEMA 4: Administración y Estabilización de Plataforma
   ====================================================================
   Consultas de diccionario de datos (Data Dictionary) para auditar 
   sesiones, memoria y procesos del entorno LiveLabs.
*/

-- 1. Visualizar las sesiones activas y la carga de la máquina
SELECT sid, serial#, username, status, machine
FROM v$session
WHERE type != 'BACKGROUND';

-- 2. Consultar los límites y parámetros actuales de estabilización
SELECT name, value, description
FROM v$parameter
WHERE name IN ('processes', 'sessions', 'memory_target');