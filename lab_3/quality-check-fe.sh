#!/usr/bin/env bash

CURRENT_PATH=$(pwd)
PATH_TO_APP=$(pwd)/be-app

QUALITY_CHECK_LOGS_DIR=$CURRENT_PATH/fe-quality-check-results

LINT_LOG=$QUALITY_CHECK_LOGS_DIR/lint.txt
E2E_LOG=$QUALITY_CHECK_LOGS_DIR/e2e.txt
NPM_AUDIT_LOG=$QUALITY_CHECK_LOGS_DIR/npm-audit.txt

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

cd $PATH_TO_APP

function lint () {
    npm run lint > /dev/null 2>&1 > $LINT_LOG
}

function e2e () {
   npm run test > /dev/null 2>&1 > $E2E_LOG
   npm run test:coverage
   npm run coverage:upload
   
}

function audit () {
   npm run audit > /dev/null 2>&1 > $NPM_AUDIT_LOG
}

# init log dir if it doesn't exist
if [[ ! -d "$QUALITY_CHECK_LOGS_DIR" ]]; then
    mkdir $QUALITY_CHECK_LOGS_DIR
fi

echo "Run linter check"
lint
if [ $? -eq 0 ]; then
    echo "${GREEN}Linter check passed${NC}"
else
    echo "${RED}Some problems with lint. See the output $LINT_LOG${NC}"
fi


echo "Run e2e"
e2e
if [ $? -eq 0 ]; then
    echo "${GREEN}e2e check passed{NC}"
else
    echo "${RED}Some problems with e2e. See the output $E2E_LOG${NC}"
fi


echo "Run npm audit"
audit
if [ $? -eq 0 ]; then
    echo "${GREEN}npm audit passed{NC}"
else
    echo "${RED}Some problems with npm audit. See the output $NPM_AUDIT_LOG${NC}"
fi