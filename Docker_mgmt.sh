#!/bin/bash
PS3='Please enter your choice: '

MAINMENU () {
options=("Quit" "Configure" "Deploy" "Option 3")
select opt in "${options[@]}"
do
    case $opt in
        "Quit")
            exit
            ;;
        "Configure")
            echo "Configuration choice"
            CONFIG
            SUBMENU
            ;;
        "Deploy")
            echo "Deploy choice"
            ;;
        "Download")
            echo "Download choice"
            ;;
        *) echo invalid option;;
    esac
    counter=1
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for i in ${options[@]};
    do
        echo $counter')' $i
        let 'counter+=1'
    done
    IFS=$SAVEIFS
done
}


SUBMENU () {
select opt in "${options[@]}"
do
    case $opt in
        "Quit")
            exit
            ;;
        "Main Menu")
            MAINMENU
            ;;
        "Option 1")
            echo "Configuration choice"

            ;;
        "Deploy")
            echo "Deploy choice"
            ;;
        "Download")
            echo "Download choice"
            ;;
        *) echo invalid option;;
    esac
    counter=1
    SAVEIFS=$IFS
    IFS=$(echo -en "\n\b")
    for i in ${options[@]};
    do
        echo $counter')' $i
        let 'counter+=1'
    done
    IFS=$SAVEIFS
done
}

CONFIG () {
options=("Quit" "Main Menu" "Option 1" "Deploy" "Option 3")
return $options
}

while :
do
MAINMENU
done
