#!/bin/zsh

command=$1
if [[ -z "$command" ]]; then
    command="start"
fi

# Get the directory of the script and its parent
ScriptDir="$(cd "$(dirname "$0")" && pwd)"
ProjectRoot="$(dirname "$ScriptDir")"
export AMBULANCE_API_ENVIRONMENT="Development"
export AMBULANCE_API_PORT="8080"

case "$command" in
    "start")
        go run ${ProjectRoot}/cmd/ambulance-api-service
        ;;
    "openapi")
        # Assuming generator-cfg.yaml is in the same folder as the script
        docker run --rm -ti \
          -v ${ProjectRoot}:/local \
          -v ${ScriptDir}/generator-cfg.yaml:/local/scripts/generator-cfg.yaml \
          openapitools/openapi-generator-cli generate -c /local/scripts/generator-cfg.yaml
        ;;
    *)
        echo "Unknown command: $command" >&2
        exit 1
        ;;
esac