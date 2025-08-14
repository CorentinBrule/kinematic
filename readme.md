# Kinématique

*testé avec Godot 4.5*

Boite à outils pour prototyper un jeu-vidéo de plateforme en 2D avec le moteur et dans l’interface de [Godot](https://godotengine.org/download/).

![Capture d’écran du logiciel Godot avec le projet Kinématique importé et prêt à l’usage](documents/Capture_écran.png)

Ce projet propose de se concentrer sur des notions de *game design* et surtout de *level design* en éloignant — peut-être dans un premier temps — le code pour cell·eux qui souhaitent prototyper ou encadrer des ateliers et cours.

Beaucoup de choix qui structurent le projet sont fait pour faciliter la manipulation lors d’un atelier par une personne qui ne connaît pas forcément Godot et ne sait pas coder.

Mais comme tout se passe dans l’interface d’un véritable moteur de jeu-vidéo, tout est augmentable, paramétrable et reprogrammable.

Testez [ici](https://brulé.net/kinématique/) les niveaux créés dans des ateliers (groupes d'environ 5 enfants de 6 à 12 ans) !

Un wiki permet d’explorer [l’installation](https://github.com/CorentinBrule/kinematic/wiki/1.-Installation) et [la prise en main](https://github.com/CorentinBrule/kinematic/wiki/2.-Prise-en-main) ; les [ressources pédagogiques (déroulement d’ateliers)](https://github.com/CorentinBrule/kinematic/wiki/Ressources-p%C3%A9dagogiques) et les [aspects techniques pour adapter l’outil en mettant les mains dans le cambouis](https://github.com/CorentinBrule/kinematic/wiki/Aller-plus-loin-(dev)).

## Principes généraux du jeu

*Kinématique* permet de prototyper un niveau de jeu de plateforme en 2D. Il met donc en place un certain nombre de principes de base de *gameplay* :

- on contrôle un **carré / personnage / avatar**
- l’**avatar** est soumis à des règles qui ressemblent à la gravité (attiré par le bas, retenu par d’autres objets physiques)
- il se déplace et interagit avec l’environnement grâce à des **capacités / équipements / items**
- le joueur ou la joueuse doit atteindre une zone pour compléter le niveau
- l’environnement se construit sur une grille de 20 carrés par 20 (400 carrés)
- l’**avatar** que l’on contrôle fait la taille d’un carré

- il existe une dynamique entre 3 couleurs qui forme "un jeu à somme nulle" comme le pierre/feuille/ciseaux ou le poule/renard/vipère :
<img align="right" style="width:10rem;margin:0;" src="documents/icon.svg">

    - le **rouge** bat le **vert** mais est battu par le **bleu**
    - le **bleu** bat le **rouge** mais est battu par le **vert**
    - le **vert** bat le **bleu** mais est battu par le **rouge**
  
> ou sinon les trois types principaux des jeux Pokémon avec leurs forces et faiblesses **feu / eau / plante**... Salamèche, Carapuce, Bulbizar.... tmtc.

**Ainsi, la couleur de l’avatar détermine ce qui est négatif pour lui (ennemies, malus, pièges...) et ce qui est positif (alliés, bonus, nourriture...)**

- sans interaction particulière ou modification des règles du jeu, l’avatar qui touche un carré de la couleur malus, disparaît et réapparaît au point de départ (**perds/meurs**), laissant une petite croix pour que l’on se rappelle là où le⋅a joueur⋅euse a raté.

- les éléments de couleur **noire** sont neutres (**plateformes**)
- les carrés aux **contours blancs** sont des checkpoints

Certaines de ces règles peuvent être ignorées/désactivées ou peuvent être adaptées selon les besoins.

## Crédits

Merci à Marine Bourlet-Simon pour son apport à la dimension pédagogique du projet

[Licence Art Libre 1.3](https://artlibre.org/) + [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode)

* [Departure_Mono](https://departuremono.com/) by Helena Zhang : [SIL Open Font License](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)
* [FT88](https://velvetyne.fr/fonts/degheest/) by Ange Degheest + Oriane Charvieux + Mandy Elbé : [SIL Open Font License](http://scripts.sil.org/cms/scripts/page.php?site_id=nrsi&id=OFL)

* Code et assets de [Godot](https://github.com/godotengine/godot/blob/master/LICENSE.txt) et de [2D Kinematic Character Demo](https://github.com/godotengine/godot-demo-projects/blob/master/LICENSE.md) : MIT Licence.

Merci à toute la communauté de Godot !