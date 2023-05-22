newPipelineJson="./pipeline-$(date +'%m-%d-%Y').json"
pipelineJson=./pipeline.json

# flags default values
branch="main"
owner="$(git config user.name)"
pollForSourceChanges=false
repo="$(basename `git rev-parse --show-toplevel`)"

# Check if jq installed
type jq >/dev/null 2>&1
jqInstalledCode=$?

errorTitle="\033[0;31m Error.\033[0m"

if [ "$jqInstalledCode" -ne 0 ]; then
    echo "$errorTitle Jq not found. Install Jq to proceed. See https://stedolan.github.io/jq/";

    echo "    Ubuntu Installation: sudo apt install jq"
    echo "    MacOS Installation: brew install jq"

    exit;
fi


firstArg=$1;
argsQty=$#;

# Read flags
while [[ $# -gt 0 ]]
    do key="$1"
    case $key in
        --branch)
            branch="$2"
            shift;;
        --owner)
            owner="$2"
            shift;;
        --poll-for-source-changes)
            pollForSourceChanges="$2"
            shift;;
        --repo)
            repo="$2"
            shift;;
        --configuration)
            configuration="$2"
            shift;;
        *)
            if [ "$firstArg" = "$key" ]; then
                if [[ ! -f "$firstArg" ]]; then
                    echo "$errorTitle file $firstArg doesn't exist. Specify correct pipeline name to continue"
                    exit 1;
                else
                    pipelineJson=$key
                fi
            fi;;
    esac
    shift
done

cp $pipelineJson $newPipelineJson
jqtmp=./tmp.$$.json

# remove metadata
jq 'del(.metadata)' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson

# increment version
jq '.pipeline.version = .pipeline.version + 1' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson


# Perform additional actions if extra flags set
if [[ $argsQty -gt 1 ]]; then
    # Check necessary flags are set
    if [[ ! $configuration ]]; then
        echo "$errorTitle You didn't specify --configuration flag."
        exit 1;
    fi
    if [[ ! $owner ]]; then
        echo "$errorTitle You didn't specify --owner flag."
        exit 1;
    fi
    if [[ ! $repo ]]; then
        echo "$errorTitle You didn't specify --repo flag."
        exit 1;
    fi

    # change branch name
    jq --arg branch "$branch" '
        .pipeline.stages[0].actions[0].configuration.Branch = $branch
    ' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson

    # change owner
    jq --arg owner "$owner" '
        .pipeline.stages[0].actions[0].configuration.Owner = $owner
    ' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson

    # change repo
    jq --arg repo "$repo" '
        .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $repo
    ' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson

    # change PollForSourceChanges
    jq --arg pollForSourceChanges "$pollForSourceChanges" '
        .pipeline.stages[0].actions[0].configuration.PollForSourceChanges = $pollForSourceChanges
    ' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson

    # change BUILD_CONFIGURATION value
    jq --arg configuration "$configuration" '
        walk(if type == "object" then
            with_entries(if .key == "EnvironmentVariables" then
            .value = (.value | fromjson | map(if .name == "BUILD_CONFIGURATION" then
                .value = $configuration
            else
                .
            end) | tojson)
            else
                .
            end)
        else
            .
        end
    )' $newPipelineJson > $jqtmp && mv $jqtmp $newPipelineJson


fi
