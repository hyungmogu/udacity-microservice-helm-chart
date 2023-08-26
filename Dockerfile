FROM python:3.10-slim-buster

WORKDIR /app

COPY ./analytics/requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY ./analytics /app

CMD  ["python", "app.py"]