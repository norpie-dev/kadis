exec 3>&1
array=(desktop laptop pi)
result=$(dialog --title "Dot file installation"\
    --radiolist "Select the branch of dot files for this computer" 15 60 3\
    desktop "The branch used for desktop with nvidia card" on \
    laptop "The branch used for a laptop with amd card" off \
    pi "The branch used for a raspberry pi" off 2>&1 1>&3)
clear
echo $result
