FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV POSTGRES_HOST=db
ENV POSTGRES_PORT=5432
ENV POSTGRES_NAME=django_db
ENV POSTGRES_USER=django_user
ENV POSTGRES_PASSWORD=pass9764gd

COPY . .

EXPOSE 8000

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
