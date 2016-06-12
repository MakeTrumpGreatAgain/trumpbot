FROM python:2

WORKDIR /app
COPY app/requirements.txt .
RUN pip install -r requirements.txt
ADD ./data/glove.6B.50d.txt /model/

COPY ./app/ ./

ENTRYPOINT ["python"]

CMD ["word2vec-api.py","--model","/model/glove.6B.50d.txt","--port","80","--host","0.0.0.0"]



