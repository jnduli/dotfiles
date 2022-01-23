COMMAND="fontpreview-ueberzug"
if ! command -v $COMMAND &> /dev/null
then
    # man 5 terminfo for tput commands
    echo "$(tput setaf 1)$COMMAND could not be found, in arch you can install this with 'yay -S fontpreview-ueberzug-git'$(tput sgr 0)"
    exit
fi

$COMMAND -s 20 -b '#000000' -f '#ffffff' -t 'oO098B\n1lIi\n356\nz2\nrnh\n\nabcdefghijklmnopqrstuvwxyz\nABCDEFGHIJKLMNOPQRSTUVWXYZ\nThe quick brown fox jumped over the lazy dogs\n\n== != -> >= <='
