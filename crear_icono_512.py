#!/usr/bin/env python3
"""
Script para crear icono de 512x512px para Google Play Console
Requiere: pip install Pillow
"""

from PIL import Image
import os

def crear_icono_512():
    input_path = "assets/logo.png"
    output_path = "assets/logo_512.png"
    
    if not os.path.exists(input_path):
        print(f"❌ Error: No se encontró {input_path}")
        return
    
    try:
        # Abrir imagen
        img = Image.open(input_path)
        print(f"✓ Imagen original: {img.size[0]}x{img.size[1]}px")
        
        # Redimensionar a 512x512
        img_512 = img.resize((512, 512), Image.Resampling.LANCZOS)
        
        # Guardar
        img_512.save(output_path, "PNG", optimize=True)
        
        # Verificar tamaño del archivo
        file_size = os.path.getsize(output_path)
        file_size_kb = file_size / 1024
        
        print(f"✓ Icono 512x512 creado: {output_path}")
        print(f"✓ Tamaño del archivo: {file_size_kb:.2f} KB")
        
        if file_size_kb > 1024:
            print(f"⚠️  Advertencia: El archivo excede 1024KB. Considera optimizarlo en https://tinypng.com/")
        else:
            print("✓ Tamaño del archivo OK para Google Play")
            
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    crear_icono_512()
