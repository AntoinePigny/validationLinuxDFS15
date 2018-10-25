# Validation Linux DFS15

Voici un script permettant l'installation d'une nouvelle vagrant ainsi qe la gestion de celles ci

Il est aussi possible d'installer ou de reinstaller Vagrant et Vbox lors de l'initialisation d'une nouvelle vagrant

###Soucis
- J'ai fait un peu de gestion d'erreurs avec du while pour l'installation d'une vagrant mais je n'ai pas eu le temps de gérer les caractères invalides lors d'une confirmation dans les autres catégories
- Dans le fichier `main.sh` se trouve une regex pour injecter les informations directement dans le vagrantfile de base, mais celle ci semblait ne pas fonctionner. J'ai donc créé un fichier vagrantfile vide pour le peupler avec les lignes de code necessaire
- J'ai intégré une petite redirection pour voir si ceci etait possible, c'est le cas, mais du coup elle est quasiment inutile, je n'ai pas eu le temps de segmenter mon code comme je le voulais.