FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies required for runtime (no compiler needed now)
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Install Python dependencies
RUN python -m pip install --no-cache-dir pip==22.0.4
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Apply Django migrations
RUN python3 manage.py migrate

# Expose port and run the app
EXPOSE 8000
WORKDIR /app/pygoat/
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
