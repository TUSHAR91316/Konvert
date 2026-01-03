import os
from PIL import Image

def process_image():
    input_path = r"C:/Users/tusha/.gemini/antigravity/brain/f9502c96-360c-476e-bc1b-50e08c8baa7a/uploaded_image_1767424271206.jpg"
    output_path = r"g:/Projects/converter_app/assets/images/icon_background_final.png"

    try:
        img = Image.open(input_path).convert("RGBA")
        
        # Resize to standard icon size (1024x1024)
        img_resized = img.resize((1024, 1024), Image.LANCZOS)
        
        img_resized.save(output_path)
        print(f"Successfully processed and saved to {output_path}")
        
    except Exception as e:
        print(f"Error processing image: {e}")

if __name__ == "__main__":
    process_image()
