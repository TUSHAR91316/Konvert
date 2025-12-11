FROM python:3.9-slim

# Install LibreOffice and dependencies
RUN apt-get update && apt-get install -y \
    libreoffice \
    default-jre \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps
RUN pip install fastapi uvicorn python-multipart

COPY . /app

# Expose port
EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
