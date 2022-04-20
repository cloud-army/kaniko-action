FROM gcr.io/kaniko-project/executor:debug

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
RUN chmod /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
