#!/usr/bin/env python3
"""
Script para redimensionar capturas de pantalla a las dimensiones requeridas por Apple Console.
Dimensiones objetivo: 1242 x 2688 píxeles
"""

from PIL import Image
import os
import sys

# Dimensiones requeridas por Apple
TARGET_WIDTH = 1242
TARGET_HEIGHT = 2688

def redimensionar_imagen(ruta_entrada, ruta_salida):
    """
    Redimensiona una imagen manteniendo la proporción y agregando padding si es necesario.
    """
    try:
        # Abrir la imagen
        img = Image.open(ruta_entrada)
        
        # Obtener dimensiones originales
        ancho_original, alto_original = img.size
        print(f"  Dimensiones originales: {ancho_original} x {alto_original}")
        
        # Calcular la proporción de aspecto
        proporcion_objetivo = TARGET_WIDTH / TARGET_HEIGHT
        proporcion_original = ancho_original / alto_original
        
        # Calcular nuevas dimensiones manteniendo la proporción
        if proporcion_original > proporcion_objetivo:
            # La imagen es más ancha, ajustar por ancho
            nuevo_ancho = TARGET_WIDTH
            nuevo_alto = int(TARGET_WIDTH / proporcion_original)
        else:
            # La imagen es más alta, ajustar por alto
            nuevo_alto = TARGET_HEIGHT
            nuevo_ancho = int(TARGET_HEIGHT * proporcion_original)
        
        # Redimensionar la imagen
        img_redimensionada = img.resize((nuevo_ancho, nuevo_alto), Image.Resampling.LANCZOS)
        
        # Crear una nueva imagen con las dimensiones objetivo y fondo blanco
        img_final = Image.new('RGB', (TARGET_WIDTH, TARGET_HEIGHT), (255, 255, 255))
        
        # Calcular la posición para centrar la imagen redimensionada
        x = (TARGET_WIDTH - nuevo_ancho) // 2
        y = (TARGET_HEIGHT - nuevo_alto) // 2
        
        # Pegar la imagen redimensionada en el centro
        if img_redimensionada.mode == 'RGBA':
            img_final.paste(img_redimensionada, (x, y), img_redimensionada)
        else:
            img_final.paste(img_redimensionada, (x, y))
        
        # Guardar la imagen
        img_final.save(ruta_salida, 'PNG', quality=95)
        print(f"  ✓ Guardada: {ruta_salida}")
        
        return True
        
    except Exception as e:
        print(f"  ✗ Error procesando {ruta_entrada}: {str(e)}")
        return False

def main():
    # Carpeta de entrada (puedes cambiarla)
    carpeta_entrada = input("Ingresa la ruta de la carpeta con las capturas (o presiona Enter para usar './capturas'): ").strip()
    if not carpeta_entrada:
        carpeta_entrada = "./capturas"
    
    # Carpeta de salida
    carpeta_salida = "./capturas_apple"
    
    # Verificar que existe la carpeta de entrada
    if not os.path.exists(carpeta_entrada):
        print(f"Error: La carpeta '{carpeta_entrada}' no existe.")
        print("Por favor, crea la carpeta y coloca tus capturas allí, o especifica otra ruta.")
        sys.exit(1)
    
    # Crear carpeta de salida si no existe
    os.makedirs(carpeta_salida, exist_ok=True)
    
    # Extensiones de imagen soportadas
    extensiones = ('.png', '.jpg', '.jpeg', '.PNG', '.JPG', '.JPEG')
    
    # Obtener lista de archivos
    archivos = [f for f in os.listdir(carpeta_entrada) if f.endswith(extensiones)]
    
    if not archivos:
        print(f"No se encontraron imágenes en '{carpeta_entrada}'")
        sys.exit(1)
    
    print(f"\nEncontradas {len(archivos)} imágenes para procesar")
    print(f"Dimensiones objetivo: {TARGET_WIDTH} x {TARGET_HEIGHT}")
    print("-" * 60)
    
    # Procesar cada imagen
    exitosos = 0
    for archivo in archivos:
        print(f"\nProcesando: {archivo}")
        ruta_entrada = os.path.join(carpeta_entrada, archivo)
        nombre_salida = os.path.splitext(archivo)[0] + '_apple.png'
        ruta_salida = os.path.join(carpeta_salida, nombre_salida)
        
        if redimensionar_imagen(ruta_entrada, ruta_salida):
            exitosos += 1
    
    print("\n" + "=" * 60)
    print(f"Proceso completado: {exitosos}/{len(archivos)} imágenes procesadas exitosamente")
    print(f"Las imágenes están en: {carpeta_salida}")

if __name__ == "__main__":
    main()
