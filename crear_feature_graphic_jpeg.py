#!/usr/bin/env python3
"""
Script para crear Feature Graphic en formato JPEG (1024x500px)
Google Play acepta JPEG y a veces funciona mejor
Requiere: pip install Pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os

def crear_feature_graphic_jpeg():
    # Dimensiones del Feature Graphic
    width = 1024
    height = 500
    
    # Colores del tema de la app
    bg_color = (245, 245, 220)  # Beige claro (#F5F5DC)
    text_color = (93, 64, 55)   # Marrón (#5D4037)
    
    # Crear imagen base
    img = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Cargar y redimensionar el logo
    logo_path = "assets/logo.png"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path)
        
        # Redimensionar logo
        logo_height = 350
        logo_width = int(logo.size[0] * (logo_height / logo.size[1]))
        logo = logo.resize((logo_width, logo_height), Image.Resampling.LANCZOS)
        
        # Posicionar logo a la izquierda
        logo_x = 80
        logo_y = (height - logo_height) // 2
        
        # Convertir a RGB si tiene transparencia
        if logo.mode == 'RGBA':
            bg = Image.new('RGB', logo.size, bg_color)
            bg.paste(logo, mask=logo.split()[3])
            logo = bg
        
        img.paste(logo, (logo_x, logo_y))
        text_x = logo_x + logo_width + 60
    else:
        text_x = 100
    
    # Agregar texto
    try:
        try:
            font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 52)
            font_subtitle = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 28)
        except:
            font_title = ImageFont.load_default()
            font_subtitle = ImageFont.load_default()
        
        title = "Manos del Pueblo"
        title_y = height // 2 - 50
        draw.text((text_x, title_y), title, fill=text_color, font=font_title)
        
        subtitle = "Artesanías Únicas"
        subtitle_y = title_y + 70
        draw.text((text_x, subtitle_y), subtitle, fill=text_color, font=font_subtitle)
        
    except Exception as e:
        print(f"⚠️  Error con fuentes: {e}")
        draw.text((text_x, height // 2 - 20), "Manos del Pueblo", fill=text_color)
        draw.text((text_x, height // 2 + 20), "Artesanías Únicas", fill=text_color)
    
    # Guardar como JPEG con alta calidad
    output_path = "assets/feature_graphic.jpg"
    img.save(output_path, "JPEG", quality=95, optimize=False)
    
    # Verificar tamaño
    file_size = os.path.getsize(output_path)
    file_size_kb = file_size / 1024
    file_size_mb = file_size / (1024 * 1024)
    
    print(f"✓ Feature Graphic JPEG creado: {output_path}")
    print(f"✓ Dimensiones: {width}x{height}px")
    print(f"✓ Tamaño del archivo: {file_size_kb:.2f} KB ({file_size_mb:.2f} MB)")
    
    if file_size_mb > 15:
        print(f"⚠️  Advertencia: El archivo excede 15MB")
    else:
        print("✓ Tamaño del archivo OK para Google Play")

if __name__ == "__main__":
    crear_feature_graphic_jpeg()
