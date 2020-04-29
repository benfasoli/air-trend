FROM python:3.8.0-buster

WORKDIR /src

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONUNBUFFERED=1

COPY main.py .
CMD ["python", "main.py"]
