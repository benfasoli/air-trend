FROM python:3.8.0-buster

WORKDIR /src

ENV PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .
CMD ["python", "main.py"]
