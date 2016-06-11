FROM r8kr/syntaxnet

EXPOSE 80

RUN apt-get update && apt-get install -y netcat
COPY selector-server.sh /syntaxnet/models/syntaxnet

ENTRYPOINT [ "bash", "/syntaxnet/models/syntaxnet/selector-server.sh" ]
