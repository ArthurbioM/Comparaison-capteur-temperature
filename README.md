# Comparaison-capteur-temperature
Ce script R vise à comparer deux capteurs sous-marin de température et d'évaluer leurs écarts de mesure. Les capteurs doivent impérativement être à la même profondeur (vérifiable avec les données de pression) et dans un rayon voisin.

Le chemin d'accès au dataset est à rentrer manuellement ligne 6. Le dataset doit présenter 5 colonnes : 
-une première avec les heures et dates des mesures,
-puis les mesures du capteur de référence "T10m", 
-celles du capteur qu'on souhaite comparer "P10m", 
-l'écart entre les deux "deltaT",
et la classe de température qui est un arrondi à l'entier de la température du capteur de référence. 

La première filtration des dates est facultative, elle permet de comparer sur une période précise.
