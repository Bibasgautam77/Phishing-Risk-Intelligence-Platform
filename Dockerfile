FROM python:3.12-slim
RUN useradd -m app
WORKDIR /srv
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app app
COPY static static
USER app
ENV PRP_DB_PATH=/home/app/prp.db
CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8000"]
