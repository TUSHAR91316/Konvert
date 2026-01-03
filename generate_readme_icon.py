import os
from PIL import Image

def generate_readme_icon():
    bg_path = r"g:/Projects/converter_app/assets/images/icon_background_final.png"
    fg_path = r"g:/Projects/converter_app/assets/images/icon_foreground.png"
    output_path = r"g:/Projects/converter_app/assets/images/readme_icon.png"

    try:
        # Load images
        bg = Image.open(bg_path).convert("RGBA")
        fg = Image.open(fg_path).convert("RGBA")
        
        # Resize foreground if needed to match background (standard adaptive icon sizing)
        # Usually foreground is 108x108 viewport within the asset, but let's just composite them directly
        # assuming they are generated to match (1024x1024).
        
        bg = bg.resize((512, 512), Image.LANCZOS)
        fg = fg.resize((512, 512), Image.LANCZOS) # Resize both for a reasonable readme size

        # Composite: Paste foreground onto background
        # Use alpha channel of foreground as mask
        final_icon = Image.alpha_composite(bg, fg)
        
        final_icon.save(output_path)
        print(f"Successfully created readme icon at {output_path}")

    except Exception as e:
        print(f"Error generating icon: {e}")

if __name__ == "__main__":
    generate_readme_icon()
