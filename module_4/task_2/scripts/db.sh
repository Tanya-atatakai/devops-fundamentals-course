dir="../data"
path="$dir/users.db"


function checkDbExist {
    if [[ ! -f "$path" ]]; then
        return 0
    else 
        return 1
    fi
}

# INIT
if [[ ! $1 ]]; then

    checkDbExist

    if [[ "$?" == 0 ]]; then
        echo "Data base does not exist Do you want to create one?"
        select yn in "Yes" "No"; do
        case $yn in
            Yes )
                if [[ ! -d "$dir" ]]; then
                    mkdir $dir
                fi
                
                touch $path
                echo "${path} created successfuly"
                break;;
            No )
                echo "You need to create a DB to continue"
                exit 1;;
        esac
    done
    else 
        echo 'DB already exists. See all commands by "'$0' --help"'
    fi

    exit 1
fi

function isLatinLetters {
    if [[ $1 =~ [^a-zA-Z] ]]; then
        return 1
    else 
        return 0
    fi
}

function add {
    # TODO: check if DB exists

    read -p "Please type a name: " username

    isLatinLetters $username

    if [[ "$?" == 1 ]]; then
        echo "Username must contains only latin letters"
        return
    fi

    read -p "Please type a role: " role

    isLatinLetters $username

    if [[ "$?" == 1 ]]; then
        echo "Role must contains only latin letters"
        return
    fi

    echo "${username}, ${role}" >> "${path}"
}


function find {
    # TODO: check if DB exists
    
    read -p "Type a user name you want to find: " username

    result=$(awk -F, -v x=$username '$1 ~ x' $path)

    if [[ $result ]]; then
        echo $result
    else
        echo "User not found."
    fi
}

function help() {
   echo "'$0' is intended for process operations with users database and supports next commands:"
   echo -e "\tadd -> add new entity to database;"
   echo -e "\thelp -> provide list of all available commands;"
   echo -e "\tfind -> found all entries in database by username;"
   exit 0
}


export $1
case $1 in
  add)      add ;;
  find)     find ;;
  help)     help;;
  *)        echo '"'$1'"' is not a ''$0'' command. See '"'$0' --help"'.
esac