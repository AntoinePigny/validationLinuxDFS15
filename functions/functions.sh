#!/bin/bash


#Fonction Menu Principal
displayMenu() {
    printf "                   \n"
    printf '***     Menu     ***\n'
    printf "                   \n"
    PS3=$'\e[94mQue désirez vous faire ? \e[0m\n'
    operations=('Initialiser une vagrant' '' 'Gérer les boxes' 'Quitter')
    select mainMenu in "${operations[@]}"
    do
        case $mainMenu in
            ${operations[0]} ) checkVagrant
                              checkSoftwareInstall 'vagrant'
                              vagrantInit;;
            ${operations[1]} ) displayPWD
                              printf 'Repertoire de la Vagrant ?'$clrs$'\n'
                              read vagrantDir
                              cd $vagrantDir
                              packagesMenu
                              displayMenu;;
            ${operations[2]} ) handleVagrant;;
            ${operations[3]} ) printf 'Au revoir !'$clrs$'\n'exit 0;;
            * ) printf 'Veuillez entrer une des options disponibles\n';;
        esac
    done
}


checkVagrant() {
    printf 'Scan du système à la recherche de Vagrant...'
    findVag=$(dpkg-query -W -f='${Status}' vagrant | grep 'install ok installed')
    if  [ findVag = "" ]
    then
        printf "Vagrant n'est pas installé, lancement de l'installation"
        wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
        sudo dpkg -i vagrant_2.1.1_x86_64.deb
    else
        printf "Vagrant est installé, voulez vous le désinstaller puis le réinstaller ? [y/n]"
        read -rsn1 choicePackage

        while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ] 
        do
            printf "Voulez-vous désinstaller Vagrant pour le réinstaller ? (y/n)"
            read -rsn1 choicePackage
        done

        if [ "$choicePackage" == "y" ]
        then
            printf "Désinstallation de Vagrant..."
            sudo apt-get remove --auto-remove vagrant
            rm -r ~/.vagrant.d

            printf "Installation de Vagrant..."
            wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
            sudo dpkg -i vagrant_2.1.1_x86_64.deb
            printf "Version de Vagrant :"
            vagrant version
        elif [ "$choicePackage" == "n" ]
        then
            displayMenu
        fi
    fi
    
}

checkVBox() {
    printf 'Scan du système à la recherche de VirtualBox...'
    findVB=$(dpkg-query -W --showformat='${Status}\n' virtualbox|grep "install ok installed")
    if  [ findVB = "" ]
    then
        printf "Virtualbox n'est pas installé, lancement de l'installation"
        sudo apt-install virtualbox -y || echo "Error : Retour au menu principal, retentez l'installation" && displayMenu;
        sudo apt-install virtualbox-qt -y || echo "Error : Retour au menu principal, pensez à vérifier l'état de votre connection Internet" && displayMenu;
    else 
        printf "Virtualbox est installé, voulez vous le désinstaller puis le réinstaller ? [y/n]"
        read -rsn1 choicePackage

        while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; 
        do
            printf "Voulez-vous désinstaller Virtualbox pour le réinstaller ? (y/n)"
            read -rsn1 choicePackage
        done

        if [ "$choicePackage" == "y" ]
        then
            echo "${magenta}Désinstallation de VirtualBox...${noColor}";
            sudo apt-get remove --purge virtualbox;
            sudo rm ~/"VirtualBox VMs" -Rf;
            sudo rm ~/.config/VirtualBox/ -Rf;
            echo "${magenta}Installation de VirtualBox...${noColor}";
            sudo apt-install virtualbox -y || echo "Error : Retour au menu principal, retentez l'installation" && displayMenu;
            sudo apt-install virtualbox-qt -y || echo "Error : Retour au menu principal, pensez à vérifier l'état de votre connection Internet" && displayMenu;
        elif [ "$choicePackage" == "n" ]
        then
            displayMenu
        fi
    fi
    
}

#dpkg-query -W -f='${Status}' vagrant ==> pour verifier si un paquet existe