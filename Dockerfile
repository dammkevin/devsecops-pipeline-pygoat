FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies for psycopg2 and DNS tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
    gcc \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install specific pip version
RUN python -m pip install --no-cache-dir pip==22.0.4

# Install Python dependencies
COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Run database migrations
RUN python3 /app/manage.py migrate

# Set working directory for entry point
WORKDIR /app/pygoat/

# Expose port for Gunicorn
EXPOSE 8000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
