#!/usr/bin/env bash
set -e

echo "Waiting for postgres to connect ..."

# Wait for the database to be up and ready, if not ready, then sleep for 5 seconds
while ! nc -z db 5432; do
  sleep 0.5
done

echo "PostgreSQL is active"

cd /app/src

# Collect static files
python manage.py collectstatic --noinput

# Apply Django Database migrations
python manage.py migrate

echo "Postgresql migrations finished"

if [ -z "$DJANGO_SUPERUSER_USERNAME" ] || [ -z "$DJANGO_SUPERUSER_EMAIL" ] || [ -z "$DJANGO_SUPERUSER_PASSWORD" ]; then
  echo "Superuser data is not set. Please check the .env file."
  exit 1
fi

echo "Creating superuser ..."

python manage.py createsuperuser --no-input || echo "Superuser already exists or could not be created."

exec gunicorn tsa_app.wsgi:application --bind 0.0.0.0:${APP_PORT}