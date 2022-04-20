FROM gcr.io/kaniko-project/executor:debug

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O /bin/jq -q \
    && chmod +x /bin/jq /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
