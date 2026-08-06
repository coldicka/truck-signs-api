# Use Python 3.6 slim image as the base
FROM python:3.12-slim

ARG _WORKDIR=/app

# Set the working directory inside the container
WORKDIR ${_WORKDIR}

# Default port for the app to start with
ENV APP_PORT=8020

# Prevents Python from writing pyc files
ENV PYTHONDONTWRITEBYTECODE=1

# Prevents Python from buffering output (important for Docker logs)
ENV PYTHONUNBUFFERED=1   

# Install system dependencies required for PostgreSQL and Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Create a system user
RUN useradd -m -r appuser

# Copy the dependencies first, then install them accordingly
COPY requirements.txt .
RUN pip install --upgrade pip && pip install --no-cache-dir -r requirements.txt

# Copy the remaining project files
COPY . ${_WORKDIR}

# Make the script executable while we're still logged in as root
RUN chmod +x ${_WORKDIR}/entrypoint.sh

# Grant the 'appuser' permissions for the entire working directory
RUN chown -R appuser:appuser ${_WORKDIR}

# Switch to a secure user
USER appuser

EXPOSE $APP_PORT

# Define container startup command
ENTRYPOINT ["/app/entrypoint.sh"]