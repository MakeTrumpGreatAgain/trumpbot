FROM python:2

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY ./ ./

ENTRYPOINT ["python"]

CMD ["getTrumpQuote.py"]


