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
export AMBULANCE_API_MONGODB_USERNAME="root"
export AMBULANCE_API_MONGODB_PASSWORD="neUhaDnes"

# Function for docker-compose operations
mongo() {
    docker compose --file ${ProjectRoot}/deployments/docker-compose/compose.yaml "$@"
}

case "$command" in
    "openapi")
        # Assuming generator-cfg.yaml is in the same folder as the script
        docker run --rm -ti \
          -v ${ProjectRoot}:/local \
          -v ${ScriptDir}/generator-cfg.yaml:/local/scripts/generator-cfg.yaml \
          openapitools/openapi-generator-cli generate -c /local/scripts/generator-cfg.yaml
        ;;
    "start")
        # Start MongoDB and run the service, ensure MongoDB is stopped after
        mongo up --detach
        {
            go run ${ProjectRoot}/cmd/ambulance-api-service
        } always {
            mongo down
        }
        ;;
    "mongo")
        mongo up
        ;;
    *)
        echo "Unknown command: $command" >&2
        exit 1
        ;;
esac