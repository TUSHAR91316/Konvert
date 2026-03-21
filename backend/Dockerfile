FROM python:3.12-slim

# Install LibreOffice and dependencies
RUN apt-get update && apt-get install -y \
    libreoffice \
    default-jre \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps
RUN pip install fastapi uvicorn python-multipart

COPY . /app

# Expose port (Cloud Run sets PORT env var, defaults to 8080 usually)
EXPOSE 8080

# Use shell form to expand variables
CMD sh -c "uvicorn main:app --host 0.0.0.0 --port \${PORT:-8080}"
