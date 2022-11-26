#!/bin/bash
keyVaultName=$1
input=$2
hideSecrets=$3

while read -r line; do
    # running in background since we are getting secrets one by one
    # and running in foreground will take more time
    (
        echo "::debug::$line"
        envVariableName="${line%=*}"
        secretName="${line#*=}"
        echo "Environment variable name: $envVariableName, secret name: $secretName"

        secretValue=$(az keyvault secret show --name "$secretName" --vault-name "$keyVaultName" --query value)
        if [ "$hideSecrets" = true ]; then
            echo "Secret name: $secretName value: ::add-mask::$secretValue"
        else
            echo "Config name: $secretName value: $secretValue"
        fi
        echo "$envVariableName=$secretValue" >> "$GITHUB_ENV"
    ) &
done <<< "$input"

# waiting background jobs to finish
wait