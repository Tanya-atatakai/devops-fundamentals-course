#!/usr/bin/env bash

PATH_TO_APP="/Users/Tatiana_Priemova/Documents/Projects/learn/fe-app"

BUILD_OUTPUT_PATH="dist"
BUILD_FILE=$BUILD_OUTPUT_PATH/client-app.zip

cd $PATH_TO_APP

if [[ ! "$(node -v)" =~ ^v14.20.*|^v16.13.*|^18.10.* ]]; then
    echo "Error. Node.js version $(node -v) detected.";  
    echo "The Angular CLI requires a minimum Node.js version of either v14.20, v16.13 or v18.10.";
    exit;
fi

# exporting env variables
export $(grep -v '^#' .env | xargs)

echo 'Installing dependencies'
npm i


echo 'Building app'
npm run build -- --configuration=$ENV_CONFIGURATION --output-path=$BUILD_OUTPUT_PATH/static/
echo "Client app was built with $ENV_CONFIGURATION configuration."

echo 'Zipping built files'
[ -f "$BUILD_FILE" ] && rm $BUILD_FILE
zip -r -j $BUILD_FILE $BUILD_OUTPUT_PATH/*