import shutil
import os

def clean_android_resources():
    res_path = r"g:/Projects/converter_app/android/app/src/main/res"
    
    # List of directories to remove
    targets = [
        "mipmap-hdpi",
        "mipmap-mdpi",
        "mipmap-xhdpi",
        "mipmap-xxhdpi",
        "mipmap-xxxhdpi",
        "mipmap-anydpi-v26"
    ]
    
    for target in targets:
        full_path = os.path.join(res_path, target)
        if os.path.exists(full_path):
            try:
                shutil.rmtree(full_path)
                print(f"Deleted: {full_path}")
            except Exception as e:
                print(f"Failed to delete {full_path}: {e}")
        else:
            print(f"Not found: {full_path}")

if __name__ == "__main__":
    clean_android_resources()
