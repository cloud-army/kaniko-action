#!/bin/sh

set -e

KANIKO_CONTEXT="/github/workspace"
COMMAND="/kaniko/executor --context "$KANIKO_CONTEXT" \\"

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
    KANIKO_PUSH="--no-push"
fi

if [ -n "$TAGS" ]; then
    LOCAL_TAGS=$TAGS
elif [ -n "$INPUT_TAGS" ]; then  
    LOCAL_TAGS=$INPUT_TAGS
fi

COMMAND="${COMMAND}  --dockerfile ${KANIKO_CONTEXT}/${KANIKO_FILE} \\"

for TAG in ${LOCAL_TAGS[@]}; do
    echo $TAG
    #COMMAND="${COMMAND}  --destination ${TAG} \\"
done

# /kaniko/executor --context "$CONTEXT_PATH" \
#     --no-push \
#     --destination dummy_name \
#     --build-arg VERSION="$VERSION" \
#     --dockerfile "$CONTEXT_PATH"/Dockerfile \
#     --tarPath export.tar

#${COMMAND}