Vol interactif via ox_target : Les joueurs peuvent cibler des PNJ pour tenter de les voler.
Chances de succès configurables : Ajustez les probabilités de réussir un vol d'argent ou de recevoir des objets rares dans config.lua.
Animation immersive : Le joueur effectue une animation de fouille, qui s'arrête automatiquement après un succès ou un échec.
Système de réputation : Les joueurs peuvent gagner ou perdre de la réputation selon leurs réussites ou échecs dans les vols. Cela impacte leur expérience en jeu (par exemple, PNJ plus méfiants en cas de mauvaise réputation).
Récompenses variables : Les joueurs peuvent recevoir des objets aléatoires ou des montants d'argent basés sur la zone où le vol a lieu (quartiers riches, pauvres, moyens).
Notifications modernes : Utilisation de ox_lib pour afficher des notifications claires et stylées concernant les vols, les récompenses et la réputation.
Logs Discord intégrés : Chaque vol réussi ou échoué est logué sur un serveur Discord via un webhook, avec des informations détaillées.

Télécharger et extraire ce dépôt GitHub dans le répertoire resources de votre serveur FiveM.

Assurez-vous d'avoir les dépendances suivantes :

ox_target : Pour permettre de cibler et interagir avec les PNJ.
https://github.com/overextended/ox_target
ox_lib : Pour les notifications stylées et d'autres utilitaires.
https://github.com/overextended/ox_lib
es_extended (ESX) : Pour la gestion des inventaires et de l'argent.
https://github.com/esx-framework/es_extended

server.cfg
ensure bibimodz-robbery


Config.ChanceToStealMoney = 70 -- 70% de chance de voler de l'argent
Config.ChanceToReceiveItem = 30 -- 30% de chance de recevoir un objet
Config.BadReputationThreshold = -10 -- PNJ méfiants
Config.GoodReputationThreshold = 10 -- PNJ moins méfiants

Contributeurs
Créé par BibiModz
