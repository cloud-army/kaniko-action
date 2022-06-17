#!/bin/sh

set -e


KANIKO_CONTEXT="/github/workspace"
COMMAND="/kaniko/executor --context $KANIKO_CONTEXT"
RED='\033[0;31m' # Red color for warning messages
NC='\033[0m' # No Color

ln -s $HOME/.docker /kaniko/.docker

if [ -n "$FILE" ]; then  
    KANIKO_FILE=${FILE}
elif [ -n "$INPUT_FILE" ]; then  
    KANIKO_FILE=${INPUT_FILE}
else
    KANIKO_FILE="Dockerfile"
fi

if [ -n "$CONTEXT" ]; then  
    KANIKO_CONTEXT="${KANIKO_CONTEXT}/${CONTEXT}"
elif [ -n "$INPUT_CONTEXT" ]; then  
    KANIKO_CONTEXT="${KANIKO_CONTEXT}/${INPUT_CONTEXT}"
fi

if [ "$PUSH" == "false" ] || [ "$INPUT_PUSH" == "false" ]; then  
    COMMAND="${COMMAND} --no-push"
fi

COMMAND="${COMMAND} --dockerfile ${KANIKO_CONTEXT}/${KANIKO_FILE}"

if [ -n "$TAGS" ]; then
    LOCAL_TAGS=$TAGS
elif [ -n "$INPUT_TAGS" ]; then  
    LOCAL_TAGS=$INPUT_TAGS
fi

for TAG in ${LOCAL_TAGS}; do
   COMMAND="${COMMAND} --destination ${TAG}"
done

if [ -n "$LABELS" ]; then
    LOCAL_LABELS=$LABELS
elif [ -n "$INPUT_LABELS" ]; then  
    LOCAL_LABELS=$INPUT_LABELS
fi

if [ -n "$BUILD_ARGS" ]; then
    LOCAL_BUILD_ARGS=$BUILD_ARGS
elif [ -n "$INPUT_BUILD_ARGS" ]; then  
    LOCAL_BUILD_ARGS=$INPUT_BUILD_ARGS
fi

for ARG in $LOCAL_BUILD_ARGS; do
    KEY=$(echo $ARG | cut -d "=" -f 1)
    VALUE=$(echo $ARG | cut -d "=" -f 2)
    COMMAND="${COMMAND} --build-arg ${KEY}=\"${VALUE}\""
done

OLDIFS="$IFS"
IFS=$'\n' # to iterate over labels

for LABEL in $LOCAL_LABELS; do
    KEY=$(echo $LABEL | cut -d "=" -f 1)
    VALUE=$(echo $LABEL | cut -d "=" -f 2)
    COMMAND="${COMMAND} --label ${KEY}=\"${VALUE}\""
done

IFS="$OLDIFS"

if [ -n "$TAR_FILE" ]; then  
    KANIKO_TARFILE="${KANIKO_CONTEXT}/$TAR_FILE"
elif [ -n "$INPUT_TAR_FILE" ]; then  
    KANIKO_TARFILE="${KANIKO_CONTEXT}/$INPUT_TAR_FILE"
fi

if [ -n "$KANIKO_TARFILE" ]; then
    COMMAND="${COMMAND} --tarPath ${KANIKO_TARFILE}"
fi

if [ -n "$CACHE_TTL" ]; then
    KANIKO_CACHE_TTL=$CACHE_TTL
elif [ -n "$INPUT_CACHE_TTL" ]; then 
    KANIKO_CACHE_TTL=$INPUT_CACHE_TTL
else
    KANIKO_CACHE_TTL="12h"
fi

if [ "$CACHE" == "true" ] || [ "$INPUT_CACHE" == "true" ]; then  
    COMMAND="${COMMAND} --cache=true --cache-ttl=${KANIKO_CACHE_TTL}"
fi

if [ -n "$SNAPSHOT_MODE" ]; then
    KANIKO_SNAPSHOT_MODE=$SNAPSHOT_MODE
elif [ -n "$INPUT_SNAPSHOT_MODE" ]; then 
    KANIKO_SNAPSHOT_MODE=$INPUT_SNAPSHOT_MODE
else
    KANIKO_SNAPSHOT_MODE="full"
fi

if [ -n "$KANIKO_SNAPSHOT_MODE" ]; then
    COMMAND="${COMMAND} --snapshotMode=${KANIKO_SNAPSHOT_MODE}"
fi

if [ "$DEBUG_MODE" == "true" ] || [ "$INPUT_DEBUG_MODE" == "true" ]; then
    echo -e "${RED}WARNING!!${NC} Debug mode has been set to true, some sensitive data used to build the image may will be exposed!!"
    echo "Launching kaniko with the following parameters:"
    echo "${COMMAND}"
else
    echo "Launching kaniko..."
fi

alias kaniko_build="$COMMAND" # Workaroud to handle possible labels with white spaces

kaniko_build