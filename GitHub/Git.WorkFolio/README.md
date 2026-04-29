# Git.WorkFolio -Finance Analysis Module

Este componente del repositorio Git.WorkFolio está dedicado a la automatización de reportes financieros. El objetivo principal es transformar datos crudos de mercado en archivos estructurados listos para la toma de decisiones.

🎯 Alcance Educativo
Este script demuestra la capacidad de integrar múltiples flujos de trabajo en Python:

Data Sourcing: Extracción dinámica desde Yahoo Finance.

Data Cleaning: Eliminación de zonas horarias y manejo de valores nulos (Forward Fill).

File Management: Creación automatizada de directorios y nombrado dinámico de archivos basado en timestamps.

Multi-Format Export: Generación simultánea de reportes en Excel (análisis profundo) y CSV (portabilidad).

📋 Requisitos de Instalación
Para que el sistema funcione, instala las dependencias necesarias:

Bash
pip install yfinance pandas openpyxl
🛠️ Guía de Uso
Ejecuta el archivo: python finance.py.

Ingresa el Ticker deseado (ej: AAPL, MSFT, BTC-USD, ETH-EUR).

El sistema procesará el último mes de datos y generará un resumen ejecutivo en la terminal con alertas visuales:

♻️ (Subió): El precio de cierre es mayor al anterior.

❗️ (Bajó): El precio de cierre es menor al anterior.

📁 Gestión de Salida (Output)
Todos los archivos se organizan automáticamente en la carpeta /outputs:

TICKER_YYYY-MM-DD.xlsx: Reporte detallado con formato de celdas optimizado.

TICKER_YYYY-MM-DD.csv: Versión ligera para integración rápida.

# Git.WorkFolio - Asistente de Retroalimentación IA (2026)

Este repositorio es un proyecto educativo diseñado para explorar la integración de **Vision Computacional** y **Modelos de Lenguaje (LLM)** en flujos de trabajo de aprendizaje y ciberseguridad.

## 🚀 Funcionalidades

- **Captura Global:** Análisis de pantalla completa mediante la biblioteca `mss`.
- **Motor Gemini 3:** Uso del modelo `gemini-3-flash-preview` para procesamiento de texto e imagen.
- **Filtro de Contenido:** Algoritmo de prompt-engineering para ignorar publicidad y ruido visual.
- **Historial de Repaso:** Guardado automático de capturas y explicaciones en la carpeta `/output` para estudio posterior.

## 🛠️ Requisitos

- Python 3.x (Probado en Mac Intel/Silicon)
- API Key de Google Generative AI (Proyecto habilitado en Google Cloud).

## ⚠️ Nota Educativa

Este código ha sido desarrollado para comprender las limitaciones de los sistemas de proctoring y la potencia de las APIs de IA modernas. No se fomenta su uso para violar términos de servicio de plataformas de evaluación.

📝 Nota sobre el Repositorio
Este archivo finance.py convive con el sistema de asistencia CiberAssesment.py, demostrando una versatilidad en el uso de Python: desde la ciberseguridad y visión artificial hasta el análisis cuantitativo de mercados.
