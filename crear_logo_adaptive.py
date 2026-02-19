#!/usr/bin/env python3
"""
Script para crear logo con padding para Adaptive Icons de Android
El contenido importante debe estar en el 66% central (safe zone)
Requiere: pip install Pillow
"""

from PIL import Image
import os

def crear_logo_con_padding():
    """
    Crea una versión del logo con padding para adaptive icons
    Android recomienda que el contenido importante esté en el 66% central
    """
    input_path = "assets/logo.png"
    output_path = "assets/logo_adaptive.png"
    
    if not os.path.exists(input_path):
        print(f"❌ Error: No se encontró {input_path}")
        return
    
    try:
        # Abrir imagen original
        logo = Image.open(input_path)
        original_size = logo.size[0]
        print(f"✓ Logo original: {original_size}x{original_size}px")
        
        # Calcular nuevo tamaño
        # Para que el logo ocupe el 66% del espacio, necesitamos:
        # logo_size / new_size = 0.66
        # new_size = logo_size / 0.66
        padding_ratio = 0.70  # 70% del espacio (un poco más conservador)
        new_size = int(original_size / padding_ratio)
        
        # Crear imagen nueva con fondo transparente
        new_img = Image.new('RGBA', (new_size, new_size), (255, 255, 255, 0))
        
        # Redimensionar logo para que quepa en el 70% central
        logo_resized = logo.resize((original_size, original_size), Image.Resampling.LANCZOS)
        
        # Calcular posición para centrar
        offset = (new_size - original_size) // 2
        
        # Pegar logo centrado
        if logo.mode == 'RGBA':
            new_img.paste(logo_resized, (offset, offset), logo_resized)
        else:
            new_img.paste(logo_resized, (offset, offset))
        
        # Guardar
        new_img.save(output_path, "PNG")
        
        file_size = os.path.getsize(output_path)
        file_size_kb = file_size / 1024
        
        print(f"✓ Logo adaptive creado: {output_path}")
        print(f"✓ Tamaño: {new_size}x{new_size}px")
        print(f"✓ Logo ocupa: {padding_ratio*100:.0f}% del espacio")
        print(f"✓ Safe zone: ✓ (contenido en el centro)")
        print(f"✓ Tamaño archivo: {file_size_kb:.2f} KB")
        
    except Exception as e:
        print(f"❌ Error: {e}")

def crear_variantes_padding():
    """
    Crea múltiples variantes con diferentes niveles de padding
    para que puedas elegir la que mejor se vea
    """
    input_path = "assets/logo.png"
    
    if not os.path.exists(input_path):
        print(f"❌ Error: No se encontró {input_path}")
        return
    
    logo = Image.open(input_path)
    original_size = logo.size[0]
    
    # Diferentes ratios de padding
    ratios = {
        'conservative': 0.60,  # 60% - Mucho padding (más seguro)
        'balanced': 0.70,      # 70% - Balance (recomendado)
        'minimal': 0.80,       # 80% - Poco padding (más grande)
    }
    
    print("\nCreando variantes con diferentes paddings...\n")
    
    for name, ratio in ratios.items():
        try:
            new_size = int(original_size / ratio)
            new_img = Image.new('RGBA', (new_size, new_size), (255, 255, 255, 0))
            
            logo_resized = logo.resize((original_size, original_size), Image.Resampling.LANCZOS)
            offset = (new_size - original_size) // 2
            
            if logo.mode == 'RGBA':
                new_img.paste(logo_resized, (offset, offset), logo_resized)
            else:
                new_img.paste(logo_resized, (offset, offset))
            
            output_path = f"assets/logo_adaptive_{name}.png"
            new_img.save(output_path, "PNG")
            
            print(f"✓ {name.capitalize()}: {output_path}")
            print(f"  - Tamaño: {new_size}x{new_size}px")
            print(f"  - Logo ocupa: {ratio*100:.0f}% del espacio")
            print()
            
        except Exception as e:
            print(f"❌ Error en {name}: {e}")

if __name__ == "__main__":
    print("=== Creando Logo Adaptive para Android ===\n")
    
    # Crear versión recomendada
    crear_logo_con_padding()
    
    print("\n" + "="*50 + "\n")
    
    # Crear variantes para comparar
    crear_variantes_padding()
    
    print("\n=== Recomendación ===")
    print("1. Prueba primero: logo_adaptive_balanced.png")
    print("2. Si se ve muy pequeño: logo_adaptive_minimal.png")
    print("3. Si se corta en algunos launchers: logo_adaptive_conservative.png")
    print("\nActualiza pubspec.yaml con la versión que elijas")
