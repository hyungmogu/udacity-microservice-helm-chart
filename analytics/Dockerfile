FROM python:3.10-slim-buster

USER root

# Dependencies required for psycopg2 (used for Postgres client)
RUN apt update -y && apt install -y build-essential libpq-dev

WORKDIR /analytics

COPY ./requirements.txt /analytics/requirements.txt

RUN pip install -r requirements.txt

COPY . /analytics

CMD  ["python", "app.py"]