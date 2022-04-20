FROM gcr.io/kaniko-project/executor:debug

COPY LICENSE README.md /

COPY entrypoint.sh /entrypoint.sh
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /busybox/jq -q \
    && chmod +x /busybox/jq /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
