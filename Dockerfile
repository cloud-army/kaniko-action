FROM gcr.io/kaniko-project/executor:debug

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
RUN wget -o /bin/jq -f https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
