import yfinance as yf
import pandas as pd
import os
from datetime import datetime

# 1. Configuración de estética para los datos
pd.options.display.float_format = "{:,.2f}".format


def generar_reporte_total(ticker):
    # Crear la carpeta de salida si no existe
    if not os.path.exists("outputs"):
        os.makedirs("outputs")

    # --- PASO 1: Obtención y Limpieza ---
    print(f"🌀Obteniendo datos de {ticker}...")
    stock = yf.Ticker(ticker)
    df = stock.history(period="1mo")

    # Convertimos el índice de fechas a "timezone naive" (quitar la zona horaria)
    if df.index.tz is not None:
        df.index = df.index.tz_localize(None)

    if df.empty:
        print("💢Error: No hay datos para ese símbolo.")
        return

    # Limpieza rápida: quitamos nulos y columnas irrelevantes
    df = df.ffill()
    df = df[["Open", "High", "Low", "Close", "Volume"]]

    # --- PASO 2: Nombre Dinámico con Fecha ---
    # Obtenemos la fecha de hoy en formato AÑO-MES-DÍA
    hoy = datetime.now().strftime("%Y-%m-%d")
    nombre_base = f"{ticker}_{hoy}"

    # --- PASO 3: Exportación múltiple ---
    # Guardar Excel
    ruta_excel = os.path.join("outputs", f"{nombre_base}.xlsx")
    df.to_excel(ruta_excel)

    # --- PASO 4: Cálculo de Variación ---
    # Obtenemos los dos últimos precios de cierre
    ultimo_cierre = df["Close"].iloc[-1]
    cierre_anterior = df["Close"].iloc[-2]

    # Calculamos el porcentaje
    variacion = ((ultimo_cierre - cierre_anterior) / cierre_anterior) * 100

    # Determinamos el icono y el color visual
    if variacion > 0:
        alerta = "♻️(Subió)"
    elif variacion < 0:
        alerta = "❗️(Bajó)"
    else:
        alerta = "❕(Sin cambios)"

    # --- PASO 5: Mostrar el Resumen en Consola ---
    print("\n" + "💹 RESUMEN DE MERCADO " + "=" * 20)
    print(f"🛂 Ticker: {ticker}")
    print(f"♿️ Último Cierre: {ultimo_cierre:,.2f} USD")
    print(f"🏧 Variación: {variacion:,.2f}% {alerta}")
    print("=" * 41 + "\n")

    # Guardar una vista rápida en CSV por si acaso
    ruta_csv = os.path.join("outputs", f"{nombre_base}.csv")
    df.to_csv(ruta_csv)

    print(
        f"✅ Éxito: Se han generado los archivos para {ticker} en la carpeta 'outputs'."
    )
    print(f"Localización: {ruta_excel}")


if __name__ == "__main__":
    empresa = input(
        "Introduzca el ticker para el reporte (ej: AAPL, BTC-USD): "
    ).upper()
    generar_reporte_total(empresa)
