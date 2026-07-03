import os
import re
import shutil
import subprocess
import uuid
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health_check():
    return {"status": "ok"}

UPLOAD_DIR = "/tmp/uploads"
OUTPUT_DIR = "/tmp/outputs"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

@app.post("/convert")
async def convert_file(file: UploadFile = File(...), target_format: str = "pdf"):
    # 1. Save uploaded file
    file_id = str(uuid.uuid4())
    
    # Sanitize filename to prevent path traversal
    safe_filename = os.path.basename(file.filename) if file.filename else "upload"
    safe_filename = re.sub(r'[^a-zA-Z0-9.-]', '_', safe_filename)
    
    input_filename = f"{file_id}_{safe_filename}"
    input_path = os.path.join(UPLOAD_DIR, input_filename)
    
    with open(input_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # 2. Determine conversion command
    # Simple LibreOffice conversion: --convert-to pdf
    
    # Validation: valid formats?
    valid_targets = ["pdf", "docx", "doc", "odt", "jpg", "png"]
    if target_format not in valid_targets:
        return JSONResponse(
            status_code=400,
            content={
                "error_code": "4001_ERR_INVALID_FORMAT",
                "message": "The requested format is unsupported.",
                "resolution": f"Please choose from: {', '.join(valid_targets)}"
            }
        )

    success = False
    try:
        # 3. Run LibreOffice (headless)
        # unoconv or libreoffice directly
        cmd = [
            "libreoffice",
            "--headless",
            "--convert-to", target_format,
            "--outdir", OUTPUT_DIR,
            input_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode != 0:
            print(f"Conversion failed: {result.stderr}")
            return JSONResponse(
                status_code=500,
                content={
                    "error_code": "5001_ERR_CONVERSION_CRASH",
                    "message": "The document processor crashed while attempting to convert your file.",
                    "resolution": "Your document may be corrupted, encrypted with a password, or contain unsupported macros."
                }
            )
            
        # 4. Find output file
        # LibreOffice typically keeps the basename and changes extension
        base_name = os.path.splitext(input_filename)[0]
        # output filename might vary slightly depending on LibreOffice version/format
        # e.g. input.docx -> input.pdf
        
        # We need to find the file in OUTPUT_DIR that matches the pattern
        expected_output_filename = f"{base_name}.{target_format}"
        output_path = os.path.join(OUTPUT_DIR, expected_output_filename)
        
        if not os.path.exists(output_path):
             return JSONResponse(
                status_code=500,
                content={
                    "error_code": "5002_ERR_OUTPUT_MISSING",
                    "message": "The conversion completed, but the output file could not be located.",
                    "resolution": "Please try converting the file again or contact support."
                }
            )

        # 5. Return file
        from starlette.background import BackgroundTask
        
        def cleanup_output():
            if os.path.exists(output_path):
                os.remove(output_path)
                
        success = True
        return FileResponse(
            output_path, 
            filename=f"converted.{target_format}",
            background=BackgroundTask(cleanup_output)
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "error_code": "5000_ERR_INTERNAL_SERVER",
                "message": "An unexpected server error occurred during conversion.",
                "resolution": str(e)
            }
        )
    finally:
        # Cleanup input
        if os.path.exists(input_path):
            os.remove(input_path)
        # Cleanup leaked output on crash
        if not success and 'output_path' in locals() and os.path.exists(output_path):
            os.remove(output_path)
