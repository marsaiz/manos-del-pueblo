#!/usr/bin/env python3
"""
Script para crear variantes del Feature Graphic (1024x500px)
Requiere: pip install Pillow
"""

from PIL import Image, ImageDraw, ImageFont
import os

def crear_variante_1():
    """Variante 1: Logo centrado con texto abajo"""
    width, height = 1024, 500
    bg_color = (245, 245, 220)
    text_color = (93, 64, 55)
    
    img = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Logo centrado
    logo_path = "assets/logo.png"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path)
        logo_size = 280
        logo = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        
        if logo.mode == 'RGBA':
            bg = Image.new('RGB', logo.size, bg_color)
            bg.paste(logo, mask=logo.split()[3])
            logo = bg
        
        logo_x = (width - logo_size) // 2
        logo_y = 60
        img.paste(logo, (logo_x, logo_y))
    
    # Texto centrado abajo
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 42)
    except:
        font = ImageFont.load_default()
    
    text = "Manos del Pueblo - Artesanías Únicas"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (width - text_width) // 2
    text_y = 390
    draw.text((text_x, text_y), text, fill=text_color, font=font)
    
    output = "assets/feature_graphic_v1.png"
    img.save(output, "PNG", optimize=True)
    print(f"✓ Variante 1 creada: {output}")
    return output

def crear_variante_2():
    """Variante 2: Fondo marrón con logo y texto en blanco"""
    width, height = 1024, 500
    bg_color = (93, 64, 55)  # Marrón
    text_color = (255, 255, 255)  # Blanco
    
    img = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(img)
    
    # Logo a la izquierda
    logo_path = "assets/logo.png"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path)
        logo_height = 350
        logo_width = int(logo.size[0] * (logo_height / logo.size[1]))
        logo = logo.resize((logo_width, logo_height), Image.Resampling.LANCZOS)
        
        if logo.mode == 'RGBA':
            bg = Image.new('RGB', logo.size, bg_color)
            bg.paste(logo, mask=logo.split()[3])
            logo = bg
        
        logo_x = 80
        logo_y = (height - logo_height) // 2
        img.paste(logo, (logo_x, logo_y))
        text_x = logo_x + logo_width + 60
    else:
        text_x = 100
    
    # Texto en blanco
    try:
        font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 52)
        font_subtitle = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 28)
    except:
        font_title = ImageFont.load_default()
        font_subtitle = ImageFont.load_default()
    
    title_y = height // 2 - 50
    draw.text((text_x, title_y), "Manos del Pueblo", fill=text_color, font=font_title)
    
    subtitle_y = title_y + 70
    draw.text((text_x, subtitle_y), "Artesanías Únicas", fill=text_color, font=font_subtitle)
    
    output = "assets/feature_graphic_v2.png"
    img.save(output, "PNG", optimize=True)
    print(f"✓ Variante 2 creada: {output}")
    return output

def crear_variante_3():
    """Variante 3: Gradiente con logo centrado"""
    width, height = 1024, 500
    
    # Crear gradiente de beige a marrón
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    # Gradiente vertical
    color_top = (245, 245, 220)  # Beige
    color_bottom = (93, 64, 55)  # Marrón
    
    for y in range(height):
        ratio = y / height
        r = int(color_top[0] * (1 - ratio) + color_bottom[0] * ratio)
        g = int(color_top[1] * (1 - ratio) + color_bottom[1] * ratio)
        b = int(color_top[2] * (1 - ratio) + color_bottom[2] * ratio)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Logo centrado
    logo_path = "assets/logo.png"
    if os.path.exists(logo_path):
        logo = Image.open(logo_path)
        logo_size = 300
        logo = logo.resize((logo_size, logo_size), Image.Resampling.LANCZOS)
        
        # Para gradiente, mantener transparencia si existe
        logo_x = (width - logo_size) // 2
        logo_y = 50
        
        if logo.mode == 'RGBA':
            img.paste(logo, (logo_x, logo_y), logo)
        else:
            img.paste(logo, (logo_x, logo_y))
    
    # Texto centrado abajo en blanco
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 42)
    except:
        font = ImageFont.load_default()
    
    text = "Manos del Pueblo"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_x = (width - text_width) // 2
    text_y = 410
    draw.text((text_x, text_y), text, fill=(255, 255, 255), font=font)
    
    output = "assets/feature_graphic_v3.png"
    img.save(output, "PNG", optimize=True)
    print(f"✓ Variante 3 creada: {output}")
    return output

def main():
    print("Creando variantes del Feature Graphic...\n")
    
    variantes = []
    
    try:
        v1 = crear_variante_1()
        variantes.append(v1)
    except Exception as e:
        print(f"❌ Error en variante 1: {e}")
    
    try:
        v2 = crear_variante_2()
        variantes.append(v2)
    except Exception as e:
        print(f"❌ Error en variante 2: {e}")
    
    try:
        v3 = crear_variante_3()
        variantes.append(v3)
    except Exception as e:
        print(f"❌ Error en variante 3: {e}")
    
    print(f"\n✓ {len(variantes)} variantes creadas exitosamente")
    print("\nVariantes disponibles:")
    print("- feature_graphic.png (original)")
    print("- feature_graphic_v1.png (logo centrado)")
    print("- feature_graphic_v2.png (fondo marrón)")
    print("- feature_graphic_v3.png (gradiente)")
    print("\nElige la que más te guste para subir a Google Play Console")

if __name__ == "__main__":
    main()
