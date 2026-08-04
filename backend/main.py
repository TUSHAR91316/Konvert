import os
import re
import shutil
import asyncio
import psutil
import subprocess
import uuid
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pypdf import PdfWriter, PdfReader

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Directories ─────────────────────────────────────────────────────────────
UPLOAD_DIR = "/tmp/uploads"
OUTPUT_DIR = "/tmp/outputs"

os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ── Health Endpoints ────────────────────────────────────────────────────────
@app.get("/health")
async def health_check():
    return {"status": "ok"}

@app.get("/health/details")
async def health_details():
    cpu_percent = psutil.cpu_percent(interval=0.1)
    memory = psutil.virtual_memory()
    disk = psutil.disk_usage('/')
    return {
        "status": "ok",
        "cpu_percent": cpu_percent,
        "memory_used_mb": memory.used // (1024 * 1024),
        "memory_total_mb": memory.total // (1024 * 1024),
        "disk_free_gb": disk.free // (1024 * 1024 * 1024)
    }

# ── PDF Merging Endpoint ───────────────────────────────────────────────────
@app.post("/merge-pdfs")
async def merge_pdfs(files: list[UploadFile] = File(...)):
    """Merge multiple PDF files into a single PDF, returned in upload order."""
    if len(files) < 2:
        return JSONResponse(
            status_code=400,
            content={
                "error_code": "4002_ERR_TOO_FEW_FILES",
                "message": "At least 2 PDF files are required for merging.",
                "resolution": "Select 2 or more PDF files and try again."
            }
        )

    saved_paths = []
    output_path = None
    try:
        writer = PdfWriter()

        for upload in files:
            file_id = str(uuid.uuid4())
            safe_name = re.sub(r'[^a-zA-Z0-9.-]', '_', os.path.basename(upload.filename or "file.pdf"))
            input_path = os.path.join(UPLOAD_DIR, f"{file_id}_{safe_name}")
            with open(input_path, "wb") as f:
                shutil.copyfileobj(upload.file, f)
            saved_paths.append(input_path)

            reader = PdfReader(input_path)
            for page in reader.pages:
                writer.add_page(page)

        output_id = str(uuid.uuid4())
        output_path = os.path.join(OUTPUT_DIR, f"{output_id}_merged.pdf")
        with open(output_path, "wb") as out:
            writer.write(out)

        from starlette.background import BackgroundTask

        def cleanup_merge():
            if output_path and os.path.exists(output_path):
                os.remove(output_path)

        return FileResponse(
            output_path,
            filename="merged.pdf",
            background=BackgroundTask(cleanup_merge)
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={
                "error_code": "5003_ERR_MERGE_FAILED",
                "message": "Failed to merge the PDF files.",
                "resolution": str(e)
            }
        )
    finally:
        for p in saved_paths:
            if os.path.exists(p):
                os.remove(p)

# ── Document Conversion Endpoint ─────────────────────────────────────────────
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
        cmd = [
            "libreoffice",
            "--headless",
            "--convert-to", target_format,
            "--outdir", OUTPUT_DIR,
            "--",
            input_path
        ]
        
        process = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        
        if process.returncode != 0:
            print(f"Conversion failed: {stderr.decode()}")
            return JSONResponse(
                status_code=500,
                content={
                    "error_code": "5001_ERR_CONVERSION_CRASH",
                    "message": "The document processor crashed while attempting to convert your file.",
                    "resolution": "Your document may be corrupted, encrypted with a password, or contain unsupported macros."
                }
            )
            
        # 4. Find output file
        base_name = os.path.splitext(input_filename)[0]
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
