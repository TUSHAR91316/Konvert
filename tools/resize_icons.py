from PIL import Image
import os

def resize_icons():
    input_path = "assets/images/final_logo.png"
    
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found.")
        return

    try:
        img = Image.open(input_path)
        
        # 512x512
        img512 = img.resize((512, 512), Image.LANCZOS)
        img512.save("assets/images/512.png")
        print("Created assets/images/512.png")
        
        # 114x114
        img114 = img.resize((114, 114), Image.LANCZOS)
        img114.save("assets/images/114.png")
        print("Created assets/images/114.png")
        
    except Exception as e:
        print(f"Error processing icons: {e}")

if __name__ == "__main__":
    resize_icons()
