#!/usr/bin/env python3
import os
import qrcode
from PIL import Image, ImageDraw

def generar_qr():
    url = "https://manos-del-pueblo.ar/descargar/"
    logo_path = "assets/logo.png"
    
    # Rutas de salida
    os.makedirs("web/descargar", exist_ok=True)
    out_web = "web/descargar/qr_descarga.png"
    out_assets = "assets/qr_descarga.png"
    
    if not os.path.exists(logo_path):
        print(f"❌ Error: No se encontró {logo_path}")
        return
        
    try:
        # 1. Configurar QR con alta tolerancia a errores (H)
        qr = qrcode.QRCode(
            version=None, # auto-detect version
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=15,
            border=4
        )
        qr.add_data(url)
        qr.make(fit=True)
        
        # Crear imagen QR
        qr_img = qr.make_image(fill_color="black", back_color="white").convert("RGBA")
        
        # 2. Cargar logo y obtener dimensiones
        logo = Image.open(logo_path).convert("RGBA")
        
        # Calcular tamaño del logo
        # El logo debe ocupar como máximo ~22% del ancho del QR
        qr_width, qr_height = qr_img.size
        logo_max_size = int(qr_width * 0.22)
        
        # Redimensionar el logo manteniendo proporción
        logo.thumbnail((logo_max_size, logo_max_size), Image.Resampling.LANCZOS)
        logo_w, logo_h = logo.size
        
        # Posición del logo en el centro
        pos_x = (qr_width - logo_w) // 2
        pos_y = (qr_height - logo_h) // 2
        
        # 3. Dibujar un recuadro blanco en el centro para tapar los módulos del QR
        # El recuadro debe ser ligeramente mayor al logo para crear un borde limpio
        padding = 10
        card_x0 = pos_x - padding
        card_y0 = pos_y - padding
        card_x1 = pos_x + logo_w + padding
        card_y1 = pos_y + logo_h + padding
        
        # Dibujar rectangulo blanco con esquinas redondeadas
        draw = ImageDraw.Draw(qr_img)
        draw.rounded_rectangle(
            [card_x0, card_y0, card_x1, card_y1],
            radius=15,
            fill="white"
        )
        
        # 4. Pegar el logo sobre el recuadro blanco usando su canal alfa
        qr_img.paste(logo, (pos_x, pos_y), logo)
        
        # 5. Guardar imágenes
        qr_img.save(out_web, "PNG", optimize=True)
        qr_img.save(out_assets, "PNG", optimize=True)
        
        print(f"✓ Código QR generado exitosamente:")
        print(f"  - Guardado en: {out_web}")
        print(f"  - Guardado en: {out_assets}")
        print(f"  - Dimensiones del QR: {qr_width}x{qr_height} px")
        print(f"  - Dimensiones del Logo: {logo_w}x{logo_h} px")
        
    except Exception as e:
        print(f"❌ Error al generar el código QR: {e}")

if __name__ == "__main__":
    generar_qr()
