from PIL import Image
import os

def convert_to_png():
    input_path = "assets/images/final_combined_icon.jpg"
    output_path = "assets/images/final_combined_icon.png"
    
    try:
        img = Image.open(input_path).convert("RGBA")
        img.save(output_path, "PNG")
        print(f"Converted {input_path} to {output_path}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    convert_to_png()
