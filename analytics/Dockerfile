FROM python:3.10-slim-buster

USER root

# Dependencies required for psycopg2 (used for Postgres client)
RUN apt update -y && apt install -y build-essential libpq-dev

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY . /app

CMD  ["python", "app.py"]