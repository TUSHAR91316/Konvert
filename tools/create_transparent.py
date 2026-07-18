from PIL import Image

def create_transparent_png():
    # Create a 1024x1024 transparent image
    img = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
    img.save("assets/images/transparent_foreground.png")
    print("Created assets/images/transparent_foreground.png")

if __name__ == "__main__":
    create_transparent_png()
