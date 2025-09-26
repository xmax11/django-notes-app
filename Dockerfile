FROM python:3.9

WORKDIR /app/backend

# Copy requirements first for caching
COPY requirements.txt /app/backend

# Install system dependencies including MySQL client and netcat
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y gcc default-libmysqlclient-dev pkg-config netcat-openbsd default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir mysqlclient
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/backend

EXPOSE 8000

# Run Django migrations and Gunicorn server
CMD ["sh", "-c", "until nc -z db 3306; do echo 'Waiting for MySQL...'; sleep 2; done && python manage.py migrate --noinput && gunicorn notesapp.wsgi:application --bind 0.0.0.0:8000"]
