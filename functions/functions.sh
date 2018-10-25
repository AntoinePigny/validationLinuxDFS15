#!/bin/bash


#Fonctions Menus
displayMenu() {
    echo "                    "
    echo '***     Menu     ***'
    echo "                    "
    echo 'Que désirez vous faire ?'
    echo '                         '
    operations=('Initialiser une vagrant' 'Gérer les Vagrant' 'Quitter')
    select mainMenu in "${operations[@]}"
    do
        case $mainMenu in
            ${operations[0]} ) checkVagrant
                               checkVBox
                               vagrantInit;;

            ${operations[1]} ) manageVagrant;;
            ${operations[2]} ) printf 'Au revoir !'$clrs$'\n'exit 0;;
            * ) printf 'Veuillez entrer une des options disponibles\n';;
        esac
    done
}

vagrantOptionsMenu() {
    echo "Que souhaitez vous faire sur cette vagrant ?"
    options=('Allumer' 'Eteindre' 'Redemarrer' 'Détruire' 'Menu Principal')
    select opt in "${options[@]}"
    do
        case $opt in 
            ${options[0]} )
                vagrant up $s1
                echo Vagrant Démarrée !
                vagrantOptionsMenu $s1
                ;;
            ${options[1]} )
                vagrant halt $s1
                echo Vagrant Arrêtée !
                vagrantOptionsMenu $s1
                ;;
            ${options[2]} )
                vagrant reload $s1 --provision
                echo Vagrant Rebootée !
                vagrantOptionsMenu $s1
                ;;
            ${options[3]} )
                vagrant destroy $s1
                echo Vagrant Détruite !
                vagrantOptionsMenu $s1
                ;;
            ${options[4]} )
                displayMenu
                ;;
            *) echo 'Erreur, veuillez entrer un choix valide'
            ;;
        esac
    done
}

#Verifie si Vagrant est installé et si besoin l'installe
checkVagrant() {
    echo 'Scan du système à la recherche de Vagrant...'
    findVag=$(dpkg-query -W -f='${Status}' vagrant | grep 'install ok installed')
    if  [ findVag = "" ]
    then
        echo "Vagrant n'est pas installé, lancement de l'installation"
        wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
        sudo dpkg -i vagrant_2.1.1_x86_64.deb
    else
        echo "Vagrant est installé, voulez vous le désinstaller puis le réinstaller ? [y/n]"
        read -rsn1 choicePackage

        while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ] 
        do
            echo "Réponse invalide.Voulez-vous désinstaller Vagrant pour le réinstaller ? (y/n)"
            read -rsn1 choicePackage
        done

        if [ "$choicePackage" == "y" ]
        then
            echo "Désinstallation de Vagrant..."
            sudo apt-get remove --auto-remove vagrant
            rm -r ~/.vagrant.d

            echo "Installation de Vagrant..."
            wget https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.deb
            sudo dpkg -i vagrant_2.1.1_x86_64.deb
            echo "Version de Vagrant :"
            vagrant version

        fi
    fi
    
}

#Verifie si VBox est installé et au besoin, l'installe
checkVBox() {
    echo 'Scan du système à la recherche de VirtualBox...'
    findVB=$(dpkg-query -W --showformat='${Status}\n' virtualbox|grep "install ok installed")
    if  [ findVB = "" ]
    then
        echo "Virtualbox n'est pas installé, lancement de l'installation"
        sudo apt-install virtualbox -y || echo "Error : Retour au menu principal, retentez l'installation" && displayMenu;
        sudo apt-install virtualbox-qt -y || echo "Error : Retour au menu principal, pensez à vérifier l'état de votre connection Internet" && displayMenu;
    else 
        echo "Virtualbox est installé, voulez vous le désinstaller puis le réinstaller ? [y/n]"
        read -rsn1 choicePackage

        while [ "$choicePackage" != "y" ] && [ "$choicePackage" != "n" ]; 
        do
            echo "Réponse invalide.Voulez-vous désinstaller Virtualbox pour le réinstaller ? (y/n)"
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
    
        fi
    fi
    
}

#Fonction pour créer une vagrant
vagrantInit() {
    ipVM='192.168.33.10'
    localFolder='data'
    distFolder='/var/www/html'
    boxName='ubuntu/xenial64'

    printf $primary"Specifiez le chemin d'installation de la Vagrant"$clrs$'\n'
    read vagrantDirectory
    mkdir $vagrantDirectory
    cd $vagrantDirectory
    printf $primary"Voulez vous changer la box par defaut ? (ubuntu/xenial64) ?"$clrs$'\n'
    answerValidation
    if [ $answer = 'yes' ]; then
        printf $primary'Specifiez une nouvelle box :'$clrs$'\n'
        read newBoxName
        boxName=$NewBoxName
    fi
    printf $primary"Changer l'ip du reseau privé par defaut (192.168.33.10) ?"$clrs$'\n'
    answerValidation
    if [ $answer = 'yes' ]; then
        printf $primary'Entrez une nouvelle ip :'$clrs$'\n'
        read newIpVM
        ipVM=$newIpVM
    fi
    printf $primary"Changer le repertoire local synchronisé avec la vagrant ? (./data) ?"$clrs$'\n'
    answerValidation
    if [ $answer = 'yes' ]; then
        printf $primary'Entrez un nouveau repertoire local :'$clrs$'\n'
        read newLocalFolder
        localFolder=$newLocalFolder
    fi
    printf $primary"Changer le repertoire distant synchronisé avec votre machine locale ? (/var/www/html) ?"$clrs$'\n'
    answerValidation
    if [ $answer = 'yes' ]; then
        printf $primary'Entrez un nouveau repertoire distant :'$clrs$'\n'
        read newdistFolder
        distFolder=$newdistFolder
    fi
    touch Vagrantfile
    cat> ./Vagrantfile << EOF
    Vagrant.configure("2") do |config|
    config.vm.box = "$boxName"
    config.vm.network "private_network", ip: "$ipVM"
    config.vm.synced_folder "$localFolder", "$distFolder"
    config.vm.provision "shell", inline: <<-SHELL
    sudo apt update
    sudo apt install -y apache2
    SHELL
    end
EOF
    printf $success"Vagrantfile créé, la vagrant va se lancer"$clrs$'\n'
    mkdir $localFolder
    vagrant up
}


manageVagrant() {
    echo "                           "
    echo "***  Liste des Vagrant  ***"
    echo "                           "
    vagrant global-status --prune
    echo $vagrantDir
    echo "Que voulez vous faire ?"
    options=('Choisissez une vagrant' 'Menu principal')
    select opt in "${options[@]}"
    do
        case $opt in
            ${options[0]} )
                echo "Entrez l'id de la vagrant"
                read vagrantId
                echo 'Veuillez recopiez le chemin de la vagrant'
                read vagrantDir
                cd $vagrantDir
                vagrantOptionsMenu $vagrantId
                ;;
            ${options[1]} )
                displayMenu
                ;;
            *) echo 'Erreur, veuillez entrer un choix valide'
            ;;
        esac
    done

}

#Fonction Yes/No

answerValidation() {
    echo "Yes/No"
    read choice
    case "$choice" in 
        y|Y|yes|Yes|YES ) answer='yes';break;;
        n|N|no|No|NO ) answer='no';break;;
        * ) echo "Reponse invalide";break;;
    esac
}