from PIL import Image

def fix_background():
    path = "assets/images/icon_background_final.png"
    try:
        img = Image.open(path).convert("RGBA")
        # Create a white background to flatten transparency if any (though it should be the full image)
        # Or just convert to RGB directly which drops alpha (replacing transparent with black usually, but we expect full bleed)
        
        bg = Image.new("RGB", img.size, (255, 255, 255))
        bg.paste(img, mask=img.split()[3]) # 3 is the alpha channel
        
        bg.save(path)
        print(f"Converted {path} to RGB (no alpha).")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    fix_background()
