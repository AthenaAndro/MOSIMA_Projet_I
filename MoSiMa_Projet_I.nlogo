turtles-own [
  ;; Variables des agents
  ;; ---
  ;; • agent-type       : Type de l'agent
  ;; • direction        : Direction vers laquelle l'agent regarde
  ;; • step             : "allowed motion"
  ;; • color-effort     : Couleur de l'effort
  ;; • evol             : Type d'évolution que l'agent à atteint (?)
  ;; • numinc           : nombre d'itérations
  ;;
  ;; • effort           : L'effort de l'agent
  ;; • cumeffort        : L'effort cumulé du partenaire
  ;; • leffort      : Dernier effort fourni par l'agent
  ;; • aeffort         : Dernier effort fourni par le partenaire de l'agent
  ;; • neffort         : L'effort moyen fourni par les voisins de l'agent
  ;;
  ;; • profit           : Le profit de l'agent
  ;; • cumprof          : Le perofit cumulé du partenaire
  ;; • lprofit      : Dernier profit de l'agent
  ;; • aprofit         : Dernier profit du partenaire de l'agent
  ;; • nprofit         : Le profit moyen des voisins de l'agent

  agent-type
  direction
  step
  color-effort
  evol
  numinc

  effort
  cumeffort
  leffort
  aeffort
  neffort

  profit
  cumprof
  lprofit
  aprofit
  nprofit
]

;; Variables globales
globals [
  effort-min
  effort-max
  agent-types
  agent-colors
  agent-numbers
  nb-type-agents

  ranking
]

to setup
  clear-turtles
  clear-patches
  clear-all-plots

  setup-globals
  setup-agents

  display-color

  reset-ticks
end

;; setup-globals
;; ---
;; Assigne les variables globales à leur valeur correcte
to setup-globals
  set effort-min 0.0001
  set effort-max 2.001

  set nb-type-agents 10

  set agent-types [ 0 1 2 3 4 5 6 7 8 9 ]
  set agent-colors [ gray red orange brown yellow green cyan blue magenta pink ]
  set agent-numbers (list nb-agents-0 nb-agents-1 nb-agents-2 nb-agents-3 nb-agents-4 nb-agents-5 nb-agents-6 nb-agents-7 nb-agents-8 nb-agents-9 )

  ;; Classement des agents en fonction de leur capacité de travail (arbitraire)
  set ranking [0 1 2 7 9 8 4 6 3 5]
end

;; setup-agents
;; ---
;; Crée les agents selon les variables globales
to setup-agents
  foreach agent-types
  [
    RandAgent ? item ? agent-numbers
  ]
end

to go
  ask turtles [ RandMove ]

  ask turtles
  [
    let partenaire partner
    if partenaire != nobody [
      WorkAgent [leffort] of partenaire
    ]
    ;update-color-effort
  ]

  ask turtles [set leffort effort]

  ;display-color

  if ameliorations?
  [
    renouvellement
    change-poste
  ]

  if display-effort [ ask turtles [ update-color-effort ] ]
  display-color

  tick
end

;; display-color
;; ---
;; Affiche la couleur en fonction de l'effort fourni
;; ou en fonction du type des agents
to display-color
  if display-effort
  [
    ask patches
    [
      ifelse any? turtles-here
      [
        set pcolor [color-effort] of one-of turtles-here
      ]
      [
        set pcolor black
      ]
    ]
  ]
end

;; RandAgent
;; ---
;; Crée autant d'agents du type passé en argument que demandé
;; • type-agent    : Type de l'agent
;; • nb-agents     : Nombre d'agents de ce type à créer
to RandAgent [type-agent nb-agents]
  ;; on cherche le min pour créer exactement ce qu'il faut
  let temp (count patches with [not any? turtles-on self]) - nb-agents
  if temp < 0 [ show (word "Trop d'agents, " (abs temp) " agent(s) de type " type-agent " n'ont pas été créés pour rester dans la limite des places disponibles") ]
  create-turtles min (list (count patches with [not any? turtles-on self]) nb-agents )
  [
    set agent-type type-agent
    ;;set shape "square"

    ;; Placement sur un patch non-occupé sur lequel positionner la turtle
    let place one-of patches with [not any? turtles-on self]
    if place != nobody [move-to place]

    ;; Choix de la direction et positionnement en conséquence
    RandDir
    set heading direction * 90

    set step allowed-step
    set numinc 0
    set profit 0
    set cumprof 0
    set cumeffort 0

    setup-color-agent
    setup-effort-agent
    update-color-effort
  ]
end

;; setup-color-agent
;; ---
;; set la couleur de l'agent à la couleur qui lui correspond
to setup-color-agent
  set color item agent-type agent-colors
end

;; setup-effort-agent
;; ---
;; set de départ de l'effort de l'agent selon son type
to setup-effort-agent
  if agent-type = 0 [set effort effort-min]
  if agent-type = 1 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 2 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 3 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 4 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 5 [set effort effort-max]
  if agent-type = 6 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 7 [set effort effort-max]
  if agent-type = 8 [set effort random-float (effort-max - effort-min) + effort-min]
  if agent-type = 9 [set effort random-float (effort-max - effort-min) + effort-min]

  ;; On règle arbitrairement l'effort précédent sur l'effort courant à l'initialisation...
  set leffort effort
end

;; update-color-effort
;; ---
;; Met à jour la couleur de l'effort de l'agent
to update-color-effort
  let temp leffort * 100 / effort-max
  set color-effort floor ((100 - temp) / 10) * 10 + 15
end

;; RandMove
;; ---
;; Fait bouger un agent d'une case dans une direction aléatoire,
;; seulement si la case est libre
to RandMove
  RandDir
  set heading direction * 90

  if not any? turtles-on patch-ahead step [ fd step ]
end

;; partner
;; ---
;; Renvoie l'agent qui lui fait face, s'il y en a un
;; Sinon renvoie nobody
to-report partner
  let part one-of turtles-on patch-ahead 1

  if part = nobody [report nobody]

  let other-direction [direction] of part
  if other-direction != direction and other-direction mod 2 = direction mod 2
  [
    report part
  ]

  report nobody
end

;; WorkAgent
;; ---
;; Détermine l'effort et la réaction d'un agent lorsqu'il rencontre un autre agent
;; • parteff : effort fourni par le partenaire
to WorkAgent [parteff]
  ;; Incrément du nombre d'intéraction
  set numinc (numinc + 1)

  ;; Mise à jour des variables en fonction de l'effort du partenaire
  set-aeffort parteff
  set neffort mean [ leffort ] of turtles in-radius neighborhood-radius
  if neighborhood? [ set-aeffort neffort ]
  set profit calculate-profit leffort aeffort
  set cumprof (cumprof + profit)
  set cumeffort cumeffort + aeffort
  set aprofit calculate-profit aeffort leffort

  ;; Mise à jour de l'effort selon le type d'agent
  ;; ---

  ;; Shrinking Effort
  if agent-type = 1 [ set effort aeffort / 2 ]

  ;; Replicator
  if agent-type = 2 [ set effort aeffort ]

  ;; Rational
  if agent-type = 3
  [
    set effort best-reply-cardan aeffort
  ]

  ;; Profit Comparator
  if agent-type = 4 [
    ifelse profit > aprofit [ set effort min (list (leffort * 1.1) effort-max) ] ; set effort leffort * 1.1 ]
    [ set effort max (list (leffort * 0.9) effort-min) ] ; set effort leffort * 0.9
  ]

  ;; Average Rational
  if agent-type = 6 [ set effort best-reply-cardan (cumeffort / numinc) ]

  ;; Winner Imitator
  if agent-type = 7 [
    if profit < aprofit [ set effort aeffort ]
  ]

  ;; Effort Comparator
  if agent-type = 8 [
    ifelse leffort < aeffort [ set effort min (list (leffort * 1.1) effort-max) ] ; set effort leffort * 1.1 ]
    [ set effort max (list (leffort * 0.9) effort-min) ] ; set effort leffort * 0.9
  ]

  ;; Averager
  if agent-type = 9 [ set effort ((leffort + aeffort) / 2) ]


end

;; set-aeffort
;; ---
;; Met à jour la valeur de l'effort du partenaire perçue par l'agent en prenant en compte le bruit éventuel
;; • parteff : effort fourni par le partenaire
to set-aeffort [parteff]
  ifelse noise?
  [
    let temp parteff - (((parteff * random-float (noise-value + 1)) / 100) * one-of [-1 1])
    set temp min list temp effort-max
    set temp max list temp effort-min
    set aeffort temp
  ]
  [ set aeffort parteff ]
end

;; calculate-profit
;; ---
;; Calcule le profit d'un agent selon son effort et celui du partenaire
;; • self-effort : effort fourni par l'agent dont on veut le profit
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report calculate-profit [self-effort parteff]
  report (5 * sqrt (self-effort + parteff) - self-effort ^ 2)
end

;; RandDir
;; ---
;; Renvoie une direction aléatoire à suivre
to RandDir
  set direction random 4
end

;; Pose problème pour certaines valeurs de parteff à cause de la racine cubique. Dommage...
;; best-reply-cardan
;; ---
;; Utilise la méthode de résolution des équations cubiques de Cardan
;; Renvoie la meilleure réponse (i.e. qui maximise le profit) à l'effort passé en paramètres
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report best-reply-cardan [parteff]
  ;; Initialisation des variables nécessaires au calcul
  let q ((parteff ^ 3) * 2 / 27 - 25 / 16)
  let delta (625 / 1024 - 25 / 432 * parteff ^ 3)
  let q1 (- q / 2 + (sqrt delta))
  let q2 (- q / 2 - (sqrt delta))

  ;; Prise en compte de l'erreur rendue en cas de calcul de racine cubique de nombre négatif
  ifelse q1 < 0
  [ set q1 (- ((- q1) ^ (1 / 3))) ]
  [ set q1 q1 ^ ( 1 / 3 ) ]

  ifelse q2 < 0
  [ set q2 (- ((- q2) ^ (1 / 3))) ]
  [ set q2 q2 ^ ( 1 / 3 ) ]

  ;; On renvoie le résultat calculé
  report q1 + q2 - parteff / 3
end

;; best-reply
;; ---
;; Renvoie la meilleure réponse (i.e. qui maximise le profit) à l'effort passé en paramètres
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report best-reply [parteff]
  ;; Initialisation des variables nécessaires au calcul
  let max-profit calculate-profit leffort parteff
  let max-reply leffort
  let current leffort + effort-min
  let temp calculate-profit current parteff

  ;; Boucle qui cherche la réponse maximisant le profit en testant les efforts suppérieurs à l'effort fourni actuellement
  while [ temp >= max-profit ]
  [
    set max-reply current
    set max-profit temp
    set current current + effort-min
    set temp calculate-profit current parteff
  ]

  set current current - effort-min
  set temp calculate-profit current parteff

  ;; Boucle qui cherche la réponse maximisant le profit en testant les efforts inférieurs à l'effort fourni actuellement
  while [ current >= effort-min and temp >= max-profit ]
  [
    set max-reply current
    set max-profit temp
    set current current - effort-min
    set temp calculate-profit current parteff
  ]

  ;show bla
  report max-reply
end

;; best-reply-newton
;; ---
;; Utilise la méthode de Newton
;; Renvoie la meilleure réponse (i.e. qui maximise le profit) à l'effort passé en paramètres
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report best-reply-newton [parteff]
  let x_k-1 0
  let x_k 0.5
  let delta_k 0
  let counter 0
  while [ abs (x_k - x_k-1) > 0.0001 and counter < 10000 ]
  [
    set delta_k ((calculate-derivee x_k parteff) / (calculate-derivee-second x_k parteff))
    set x_k-1 x_k
    set x_k x_k - delta_k
    set counter counter + 1
  ]
  ;show counter
  report min (list (max (list x_k effort-min)) effort-max)
end

;; calculate-derivee
;; ---
;; Calcule la fonction que l'on essaie d'annuler, fonction obtenue
;; à partir de la dérivée de la fonction de profit
;; • effort  : effort fourni par l'agent
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report calculate-derivee [eff parteff]
  report effort ^ 3 + eff ^ 2 * parteff - 25 / 16
end

;; calculate-derivee-second
;; ---
;; Calcule la dérivée de la fonction que l'on essaie d'annuler, fonction obtenue
;; à partir de la dérivée de la fonction de profit
;; • effort  : effort fourni par l'agent
;; • parteff : effort fourni par le partenaire (ou moyenne d'efforts)
to-report calculate-derivee-second [eff parteff]
  report 3 * eff ^ 2 + 2 * eff * parteff
end

;; do-plotting
;; ---
;; Plot un graphique selon la liste fournie
;; • nom      : nom du graphe où l'on veut plot les courbes
;; • liste    : Liste des points à afficher, qui doit être sous la forme :
;;              Une liste de courbe, chacune composée :
;;              -- Du nom de la courbe et d'une liste de couple, chacun représentant
;;              -- -- x et y, les coordonnées des points à afficher, dans l'ordre
;;              ------------------------------- Exemple -------------------------
;;              ( ( "moyenne" ((x1 y1) (x2 y2)) ) ( "ecart" ((z1 t1) (z2 t2)) ) )
;;              do-plotting "test" (list (list "null effort" (list (list 1 1 ) (list 2 3 ) )))
to do-plotting [ nom liste ]
  set-current-plot nom
  clear-plot
  let counter 0
  foreach liste
  [
    create-temporary-plot-pen first ?
;    set-current-plot-pen first ?
    set-plot-pen-color 5 + counter * 10
    set counter counter + 1
    foreach last ? [ plotxy first ? last ? ]
    ;; Les points sont trop petits...
    ;set-current-plot-pen (word first ? " point")
    ;foreach last ? [ plotxy first ? last ? ]
  ]
  export-interface "interface.png"
  export-plot nom (word nom ".csv")
end

;; simulate-fig6
;; ---
;; Lance une batterie de simulation pour créer un plot des résultats similaires à la figure 6 de l'article
to simulate-fig6
  setup
  let name-of-plot "Simulation - Moyenne de l'effort, en fonction du pourcentage d'agents high effort"
  ;; Initialisation de la liste des efforts attendus (l'équilibre de Nash pour chaque pourcentage de high effort)
  let liste-plot-expected (list (list 0 0.92101) (list 0.6 0.92701) (list 5.6 0.98101)  (list 33.3 1.28100)  (list 66.7 1.64100) (list 100 2.00100) )

  ;; Initialisation de variables temporaires
  let counter 0
  let tampon []

  ;; Initialisation de la liste des pourcentages de high effort dans la population de la simulation
  let liste-pourcentages (list 0 0.6 5.6 33.3 66.7 100)

  ;; Lancement des simulations pour les types d'agents voulus (rational et average rational)
  let liste-plot-null launch-simulations-figs liste-pourcentages 0
  let liste-plot-shrinking launch-simulations-figs liste-pourcentages 1
  let liste-plot-replicator launch-simulations-figs liste-pourcentages 2
  let liste-plot-profit launch-simulations-figs liste-pourcentages 4
  let liste-plot-imitator launch-simulations-figs liste-pourcentages 7
  let liste-plot-effort launch-simulations-figs liste-pourcentages 8
  let liste-plot-averager launch-simulations-figs liste-pourcentages 9

  ;; Création de la liste à envoyer pour faire l'affichage du plot
  let liste-plot (list (list "null effort" liste-plot-null)
                       (list "shrinking effort" liste-plot-shrinking)
                       (list "replicator" liste-plot-replicator)
                       (list "profit comparator" liste-plot-profit)
                       (list "winner imitator" liste-plot-imitator)
                       (list "effort comparator" liste-plot-effort)
                       (list "averager" liste-plot-averager) )

  ;; Affiche le plot voulu
  do-plotting name-of-plot liste-plot
end


;; simulate-fig7
;; ---
;; Lance une batterie de simulation pour créer un plot des résultats similaires à la figure 7 de l'article
to simulate-fig7
  setup
  let name-of-plot "Simulation - Moyenne de l'effort, en fonction du pourcentage d'agents high effort"
  ;; Initialisation de la liste des efforts attendus (l'équilibre de Nash pour chaque pourcentage de high effort)
  let liste-plot-expected (list (list 0 0.92101) (list 0.6 0.92701) (list 5.6 0.98101)  (list 33.3 1.28100)  (list 66.7 1.64100) (list 100 2.00100) )

  ;; Initialisation de variables temporaires
  let counter 0
  let tampon []

  ;; Initialisation de la liste des pourcentages de high effort dans la population de la simulation
  let liste-pourcentages (list 0 0.6 5.6 33.3 66.7 100)

  ;; Lancement des simulations pour les types d'agents voulus (rational et average rational)
  let liste-plot-rational launch-simulations-figs liste-pourcentages 3
  let liste-plot-average-rational launch-simulations-figs liste-pourcentages 6

  ;; Création de la liste à envoyer pour faire l'affichage du plot
  let liste-plot (list (list "expected" liste-plot-expected)
                       (list "rational" liste-plot-rational)
                       (list "average-rational" liste-plot-average-rational)
                       )

  ;; Affiche le plot voulu
  do-plotting name-of-plot liste-plot
end

;; core-simulate
;; ---
;; Effectue la simulation tant que l'écart-type des 200 dernières itérations n'est pas inférieur à la précision voulue : ecart-type-max
to-report core-simulate
  let tampon (list (mean [leffort] of turtles) )
  go-simulate
  set tampon lput (mean [leffort] of turtles) tampon

  let counter 2
  ;; • Au moins min-nb-iterations itération
  ;; • Tant que la moyenne de la moyenne des efforts des agents durant min-nb-iterations dernières itérations
  ;; • est supérieure à ecart-type-max
  ;; • Au plus max-nb-iterations itérations
  while [ (counter < min-nb-iterations or standard-deviation tampon > ecart-type-max) and counter < max-nb-iterations ]
  [
    go-simulate
    ifelse counter < min-nb-iterations
      [
        set tampon lput (mean [leffort] of turtles) tampon
      ]
      [
        set tampon lput (mean [leffort] of turtles) but-first tampon
        ;set tampon remove 0 (lput (mean [leffort] of turtles) tampon)
      ]
    set counter counter + 1
  ]

  ;; Récupération de la valeur à retourner, selon si on a trouvé un équilibre ou non
  let res 0
  ifelse counter >= max-nb-iterations
  [ set res mean tampon ] ;; Si on est arrivé au nombre maximal d'itérations, il est très probable qu'on n'a pas atteint l'équilibre, on renvoie donc la moyenne des dernières itérations
  [ set res last tampon ] ;; Sinon c'est qu'on est arrivé à l'équilibre, on renvoie donc la dernière valeur obtenue

  let others turtles with [agent-type != 5]
  ifelse any? others
  [ let other-type [agent-type] of one-of others
    show (word "Simulation d'agents de type " other-type " avec " ((count turtles with [agent-type = 5] / count turtles) * 100) " % de high effort") ]
  [ show (word "Simulation avec 100 % de high effort") ]
  show (word "Nombre d'itération : " counter " avec ecart-type du tampon : " standard-deviation tampon)
  show (word "Moyenne d'effort fourni par les agents : " res)

  report res
end

;; launch-simulations-figs
;; ---
;; Fait le setup, lance la simulation, et stocke les résultats dans une liste
;; • liste-pourcentages : Liste des pourcentages de high effort à simuler
;; • type-agent : type d'agent qui complète l'environnement
to-report launch-simulations-figs [ liste-pourcentages type-agent ]
  ;; Initialisation du retour : liste-resultats étant la liste dans laquelle on va stocker les résultats
  let liste-resultats []
  ;; on effectue la simulation pour chaque pourcentage de la liste
  foreach liste-pourcentages
  [
    let pourcentage ?

    ;; setup
    let liste-nb-agents []
    ;; ajout du bon nombre d'agents voulu dans la liste
    foreach [ 0 1 2 3 4 5 6 7 8 9 ]
    [
      ifelse ? = type-agent
      [
        set liste-nb-agents lput (((max-pxcor + 1) * (max-pycor + 1)) - floor (((max-pxcor + 1) * (max-pycor + 1)) * pourcentage / 100 )) liste-nb-agents
        ;set liste-nb-agents lput (((max-pxcor) * (max-pycor)) - floor (((max-pxcor) * (max-pycor)) * pourcentage / 100 )) liste-nb-agents
      ]
      [
        ifelse ? = 5
        [
          set liste-nb-agents lput (floor (((max-pxcor + 1) * (max-pycor + 1)) * pourcentage / 100 )) liste-nb-agents
          ;set liste-nb-agents lput (floor (((max-pxcor) * (max-pycor)) * pourcentage / 100 )) liste-nb-agents
        ]
        [ set liste-nb-agents lput 0 liste-nb-agents ]
      ]
    ]



    ;; Récupération de la valeur de noise pour la mettre à false puis la remettre à sa valeur initiale en fin de simulation
    let temp-noise noise?
    set noise? false

    ;; Setup de l'environnement avec les paramètres souhaités
    setup-simulate liste-nb-agents

    ;; Lancement de la simulation
    let result core-simulate

    ;; Ajout du resultat à la liste
    set liste-resultats lput (list ? result ) liste-resultats

    ;; Réactivation du bruit
    set noise? temp-noise
  ]
  report liste-resultats
end


;; setup-simulate
;; ---
;; Fait le setup pour les simulations en rapport avec les figures 6 et 7
;; • liste : Liste du nombre d'agents de chaque type dans la simulation
to setup-simulate [ liste ]
  clear-turtles
  clear-patches

  setup-globals

  foreach liste
  [
    RandAgent (position ? liste) ?
  ]
end

;; simulate-noise
;; ---
;; Lance une batterie de simulation pour créer un plot des résultats similaires à la figure 9 de l'article
;; Cette figure donnait l'évolution de l'effort dans une population homogène de winner-imitators en fonction du bruit
to simulate-noise
  setup
  ;; Initialisation de variables
  let name-of-plot "Effet du bruit sur une population de winner-imitators"
  let counter 0
  set-current-plot name-of-plot
  clear-plot

  ;; Initialisation des listes nécessaires aux setups et calculs
  let liste-nb-agents (list 0 0 0 0 0 0 0 ((max-pxcor + 1) * (max-pycor + 1)) 0 0 )
  let liste-pourcentages (list 0 1 5 10 15 20 25 50)
  let liste-colors (list blue magenta pink green lime red yellow cyan)

  ;; Lancement de la simulation
  foreach liste-pourcentages
  [
    ;; Récupération de la valeur de noise pour la mettre à true puis la remettre à sa valeur initiale en fin de simulation
    let temp-noise noise?
    let temp-noise-value noise-value
    ifelse ? > 0
    [
      set noise? true
      set noise-value ?
    ]
    [ set noise? false ]

    set counter 0
    setup-simulate liste-nb-agents
    ; show (word "Bruit activé ? " noise?)
    ; show (word "Valeur du bruit : " noise-value)
    create-temporary-plot-pen (word "Bruit : " ? " %")
    set-plot-pen-color item (position ? liste-pourcentages) liste-colors ;; Choix de la couleur de la ligne
    while [ counter < nb-ticks ]
    [
      plot mean [effort] of turtles
      go-simulate
      set counter counter + 1
    ]
      plot mean [effort] of turtles

    ;; Réactivation du bruit
    set noise? temp-noise
    set noise-value temp-noise-value
  ]
end

;; go-simulate
;; ---
;; Procédure de lancement pour les simulations des figures 6 et 7
to go-simulate
  go
;  ask turtles
;  [
;    RandMove
;  ]
;
;  ask turtles
;  [
;    let partenaire partner
;    if partenaire != nobody [
;      WorkAgent [leffort] of partenaire ]
;    ;;update-color-effort
;  ]
;  ask turtles [set leffort effort]
end

;; renouvellement
;; ---
;; "Licencie" un certain pourcentage de la population et la remplace par de nouveaux agents
to renouvellement
  ;; Calcul du nombre d'agents à renouveler
  let nb-to-renew 0
  ;; Calcul du nombre de démission
  let nb-demission retraite

  ;; Licenciement des agents les moins bons
  if count turtles > 1 and standard-deviation [effort] of turtles > ecart-type-renouvellement
  [
    ;; Prise en compte de l'ancienneté
    ifelse anciennete? = true
    [
      set nb-to-renew min (list (floor ((count turtles) * pourcentage-renouvellement / 100)) (count turtles with [ numinc > anciennete-min and numinc < anciennete-max] with-min [ effort ]))
    ]
    [
      set nb-to-renew min (list (floor ((count turtles) * pourcentage-renouvellement / 100)) (count turtles with-min [ effort ]))
    ]

    ;; Suppression des agents les moins bons
    fire nb-to-renew
  ]

  ;; Embauche du même nombre d'agents pour remplacer ceux supprimés
  hire (nb-to-renew + nb-demission)
end

;; fire
;; ---
;; Licencie les agents les agents les moins bons selon la modalité voulue
;; • nb-to-renew : nombre d'agents à licencier
to fire [nb-to-renew]
  let temp nb-to-renew
    ;; Application du bruit de détection de l'effort sur toutes les turtles
    ask turtles [
      set effort max(list min (list ((100 - (random fire-noise) * (one-of [-1 1])) * effort / 100) effort-max) effort-min)
    ]
    ;; "while" pour licencier le bon nombre d'agents
    while [temp > 0]
    [
      ;; Sélection des agents à licencier
      let worst-agents turtles
      ifelse anciennete? = true
      [
        set worst-agents turtles with [ numinc > anciennete-min and numinc < anciennete-max] with-min [ effort ]
      ]
      [
        set worst-agents turtles with-min [ effort ]
      ]
      let nb min (list (count worst-agents) temp)

      ;; Licenciement
      ask n-of nb worst-agents [ die ]
      set temp temp - nb
    ]
end

;; hire
;; ---
;; Embauche les nouveaux agents selon la modalité voulue
;; • nb-to-renew : nombre d'agents à embaucher
to hire [nb-to-renew]
  ifelse count turtles = 0 [ hire-random nb-to-renew ]
  [
    if hire-method = "Aleatoire" [ hire-random nb-to-renew ]
    if hire-method = "Proportion des restants" [ hire-same-proportions nb-to-renew ]
  ]
end

;; hire-random
;; ---
;; Effectue une embauche aléatoire
;; • nb-to-renew : nombre d'agents à embaucher
to hire-random [nb-to-renew]
  let temp 0
  while [ temp < nb-to-renew]
  [
    let type-agent random 10
    RandAgent type-agent 1
    set temp temp + 1
  ]
end

;; hire-random
;; ---
;; Effectue une embauche dans les mêmes proportions que la population courante, avec une probabilité "hire-noise" de se tromper et d'embaucher quelqu'un aléatoirement
;; • nb-to-renew : nombre d'agents à embaucher
to hire-same-proportions [nb-to-renew]
  ;; Récupération des proportions des agents restants
  let proportions []
  let somme 0
  foreach sort remove-duplicates [agent-type] of turtles
  [
    let temp (((count turtles with [agent-type = ?]) / (count turtles)) * 100)
    set somme somme + temp
    set proportions lput (list ? somme) proportions
  ]

  ;; Embauche des agents
  ;; Aléatoirement, hire-noise% du temps, on embauche quelqu'un aléatoirement et non selon les proportions...
  let temp 0
  while [temp < nb-to-renew]
  [
    ifelse random 100 < hire-noise
    [
      ;; Embauche aléatoire
      hire-random 1
    ]
    [
      ;; Embauche selon les proportions
      let rand random 100
      let to-add item 0 filter [item 1 ? > rand] proportions
      RandAgent (item 0 to-add) 1
    ]
    set temp temp + 1
  ]
end

;; retraite
;; ---
;; Fait partir les agents à la retraite, s'il ont atteind l'âge,
;; Avec une certaine propabilité, certains agents peuvent quitter l'entreprise
;; en milieu de carrière
to-report retraite
  if not retraite? [ report 0 ]

  let liste turtles with [ numinc > age-retraite or random 100 < demission-pourcent ]
  let nb count liste

  ask liste
  [ die ]
  report nb
end

;; change-poste
;; ---
;; Fait changer le type d'un agent selon l'effort qu'il aura fourni
;; et le profit qu'il aura obtenu
to change-poste
  if not change-poste? [ stop ]

  ask turtles
  [
    ;; Trop d'effort pour moins de profit
    ;; l'agent baisse sa quantité de travail
    let tmp random 10000
    if effort > aeffort and profit < aprofit and tmp < change-poste-pourcent
    [
      ;; Version Ranking vs Aléatoire
      ifelse by-ranking?
      [
        if agent-type = item 0 ranking [ stop ] ;; Ne peut pas être moins bosseur
        set agent-type item random agent-type ranking
      ]
      [ set agent-type random nb-type-agents ]
    ]

    ;; Peu d'effort et peu de profit
    ;; l'agent augmente sa quantité de travail
    if effort < aeffort and profit < aprofit and tmp < change-poste-pourcent
    [
      ;; Version Ranking vs Aléatoire
      ifelse by-ranking?
      [
        ;; Version avec ranking
        if agent-type = item (nb-type-agents - 1) ranking [ stop ] ;; Ne peut pas être plus bosseur
        set agent-type item ((nb-type-agents - 1) - random ((nb-type-agents - 1) - item agent-type ranking)) ranking
      ]
      [ set agent-type random nb-type-agents ]
    ]
  ]
end

;; print-interface
;; ---
;; Exporte l'interface sous forme d'image png
to print-interface
  export-interface "interface.png"
end

;; print-view
;; ---
;; Exporte la vue (fenêtre des agents) sous forme d'image png
to print-view
  export-view "view.png"
end
@#$#@#$#@
GRAPHICS-WINDOW
590
519
1058
1008
-1
-1
14.8
1
10
1
1
1
0
1
1
1
0
30
0
30
1
1
1
ticks
30.0

BUTTON
19
597
247
722
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
255
596
480
722
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
367
87
498
120
display-effort
display-effort
1
1
-1000

INPUTBOX
22
132
122
192
nb-agents-0
481
1
0
Number

INPUTBOX
20
227
120
287
nb-agents-1
480
1
0
Number

INPUTBOX
19
325
119
385
nb-agents-2
0
1
0
Number

INPUTBOX
18
427
118
487
nb-agents-3
0
1
0
Number

INPUTBOX
19
529
118
589
nb-agents-4
0
1
0
Number

INPUTBOX
181
131
281
191
nb-agents-5
0
1
0
Number

INPUTBOX
179
225
279
285
nb-agents-6
0
1
0
Number

INPUTBOX
179
324
278
384
nb-agents-7
0
1
0
Number

INPUTBOX
178
426
278
486
nb-agents-8
0
1
0
Number

INPUTBOX
178
527
279
587
nb-agents-9
0
1
0
Number

PLOT
590
53
1133
203
Moyenne et Ecart-type Effort global
Time
Valeur
0.0
10.0
-0.1
2.1
true
true
"" ""
PENS
"Moyenne effort" 1.0 0 -2674135 true "" "plot mean [leffort] of turtles"
"Ecart-Type " 1.0 0 -16777216 true "" "plot standard-deviation [leffort] of turtles"

PLOT
1134
519
1511
824
Profit Moyen
time
profit
0.0
10.0
0.0
2.2
true
false
"" ""
PENS
"Profit" 1.0 0 -16777216 true "" "plot mean [profit] of turtles"

PLOT
590
211
1133
518
Moyenne effort selon type d'agent
Time
Moyenne d'Effort
0.0
10.0
-0.1
2.1
true
true
"" ""
PENS
"null effort" 1.0 0 -7500403 true "" "if (count turtles with [agent-type = 0]) > 0 [plot mean [leffort] of turtles with [agent-type = 0]]"
"shrinking effort" 1.0 0 -2674135 true "" "if (count turtles with [agent-type = 1]) > 0 [plot mean [leffort] of turtles with [agent-type = 1]]"
"replicator" 1.0 0 -955883 true "" "if (count turtles with [agent-type = 2]) > 0 [plot mean [leffort] of turtles with [agent-type = 2]]"
"rational" 1.0 0 -6459832 true "" "if (count turtles with [agent-type = 3]) > 0 [plot mean [leffort] of turtles with [agent-type = 3]]"
"profit comparator" 1.0 0 -1184463 true "" "if (count turtles with [agent-type = 4]) > 0 [plot mean [leffort] of turtles with [agent-type = 4]]"
"high effort" 1.0 0 -10899396 true "" "if (count turtles with [agent-type = 5]) > 0 [plot mean [leffort] of turtles with [agent-type = 5]]"
"average rational" 1.0 0 -11221820 true "" "if (count turtles with [agent-type = 6]) > 0 [plot mean [leffort] of turtles with [agent-type = 6]]"
"winner imitator" 1.0 0 -13345367 true "" "if (count turtles with [agent-type = 7]) > 0 [plot mean [leffort] of turtles with [agent-type = 7]]"
"effort comparator" 1.0 0 -5825686 true "" "if (count turtles with [agent-type = 8]) > 0 [plot mean [leffort] of turtles with [agent-type = 8]]"
"averager" 1.0 0 -2064490 true "" "if (count turtles with [agent-type = 9]) > 0 [plot mean [leffort] of turtles with [agent-type = 9]]"

SLIDER
367
133
539
166
allowed-step
allowed-step
0
10
1
1
1
NIL
HORIZONTAL

SWITCH
361
307
464
340
noise?
noise?
1
1
-1000

SLIDER
360
364
532
397
noise-value
noise-value
1
50
1
1
1
%
HORIZONTAL

MONITOR
1134
824
1235
869
Profit Moyen
mean [profit] of turtles
5
1
11

MONITOR
1140
53
1333
98
Moyenne Globale de l'Effort
mean [leffort] of turtles
5
1
11

PLOT
27
1534
784
1995
Simulation - Moyenne de l'effort, en fonction du pourcentage d'agents high effort
Pourcentage d'agents high effort
Effort Moyen
0.0
100.0
0.0
2.1
true
true
"" ""
PENS

BUTTON
27
1494
117
1527
Figure 6
simulate-fig6
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
33
1423
183
1445
Simulations
18
0.0
1

PLOT
1134
211
1678
518
Ecart-type effort selon type d'agent
Time
Ecart-Type de l'Effort
0.0
10.0
-0.1
2.1
true
true
"" ""
PENS
"null effort" 1.0 0 -7500403 true "" "if (count turtles with [agent-type = 0]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 0] ]"
"shrinking effort" 1.0 0 -2674135 true "" "if (count turtles with [agent-type = 1]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 1] ]"
"replicator" 1.0 0 -955883 true "" "if (count turtles with [agent-type = 2]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 2] ]"
"rational" 1.0 0 -6459832 true "" "if (count turtles with [agent-type = 3]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 3] ]"
"profit comparator" 1.0 0 -1184463 true "" "if (count turtles with [agent-type = 4]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 4] ]"
"high effort" 1.0 0 -10899396 true "" "if (count turtles with [agent-type = 5]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 5] ]"
"average rational" 1.0 0 -11221820 true "" "if (count turtles with [agent-type = 6]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 6] ]"
"winner imitator" 1.0 0 -13345367 true "" "if (count turtles with [agent-type = 7]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 7] ]"
"effort comparator" 1.0 0 -5825686 true "" "if (count turtles with [agent-type = 8]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 8] ]"
"averager" 1.0 0 -2064490 true "" "if (count turtles with [agent-type = 9]) > 1 [ plot standard-deviation [leffort] of turtles with [agent-type = 9] ]"

TEXTBOX
588
23
738
45
Statistiques
18
0.0
1

TEXTBOX
26
6
176
28
Paramètres
18
0.0
1

TEXTBOX
24
39
174
77
Nombre d'agents de chaque type
16
0.0
1

TEXTBOX
368
58
518
77
Divers
16
0.0
1

TEXTBOX
368
274
518
293
Bruit
16
0.0
1

TEXTBOX
26
109
176
127
null effort
12
0.0
1

TEXTBOX
21
209
171
227
shrinking effort
12
0.0
1

TEXTBOX
22
308
172
326
replicator
12
0.0
1

TEXTBOX
22
412
172
430
rational
12
0.0
1

TEXTBOX
25
512
175
530
profit comparator
12
0.0
1

TEXTBOX
181
109
331
127
high effort
12
0.0
1

TEXTBOX
180
206
330
224
average rational
12
0.0
1

TEXTBOX
180
306
330
324
winner imitator
12
0.0
1

TEXTBOX
181
411
331
429
effort comparator
12
0.0
1

TEXTBOX
177
508
327
526
averager
12
0.0
1

MONITOR
1141
119
1331
164
Ecart-type global de l'Effort
standard-deviation [leffort] of turtles
5
1
11

MONITOR
1239
824
1357
869
Ecart-type Profit
standard-deviation [profit] of turtles
5
1
11

SLIDER
29
1450
208
1483
min-nb-iterations
min-nb-iterations
2
10000
1000
1
1
NIL
HORIZONTAL

SLIDER
218
1450
400
1483
max-nb-iterations
max-nb-iterations
500
200000
20000
100
1
NIL
HORIZONTAL

SLIDER
409
1450
596
1483
ecart-type-max
ecart-type-max
0
0.1
0.001
0.001
1
NIL
HORIZONTAL

BUTTON
135
1494
225
1527
Figure 7
simulate-fig7
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
839
1533
1554
1994
Effet du bruit sur une population de winner-imitators
Time
Effort
0.0
10.0
0.0
2.1
true
true
"" ""
PENS

BUTTON
839
1492
929
1525
Figure 9
simulate-noise
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
363
346
513
364
Intensité du bruit :
12
0.0
1

SLIDER
838
1449
1010
1482
nb-ticks
nb-ticks
100
10000
1200
100
1
NIL
HORIZONTAL

TEXTBOX
35
1029
185
1053
Améliorations
18
0.0
1

SWITCH
34
1056
196
1089
ameliorations?
ameliorations?
0
1
-1000

SLIDER
378
1087
662
1120
pourcentage-renouvellement
pourcentage-renouvellement
0
100
12
1
1
%
HORIZONTAL

SLIDER
664
1088
911
1121
ecart-type-renouvellement
ecart-type-renouvellement
0.001
2
0.01
0.001
1
NIL
HORIZONTAL

MONITOR
35
1120
174
1165
#null effort
count turtles with [agent-type = 0]
17
1
11

MONITOR
35
1164
174
1209
#shrinking effort
count turtles with [agent-type = 1]
17
1
11

MONITOR
35
1207
174
1252
#replicator
count turtles with [agent-type = 2]
17
1
11

MONITOR
35
1251
174
1296
#rational
count turtles with [agent-type = 3]
17
1
11

MONITOR
35
1296
174
1341
#profit comparator
count turtles with [agent-type = 4]
17
1
11

MONITOR
193
1119
332
1164
#high effort
count turtles with [agent-type = 5]
17
1
11

MONITOR
193
1161
332
1206
#average rational
count turtles with [agent-type = 6]
17
1
11

MONITOR
193
1207
331
1252
#winner imitator
count turtles with [agent-type = 7]
17
1
11

MONITOR
192
1252
332
1297
#effort comparator
count turtles with [agent-type = 8]
17
1
11

MONITOR
192
1296
332
1341
#averager
count turtles with [agent-type = 9]
17
1
11

CHOOSER
556
1128
901
1173
hire-method
hire-method
"Aleatoire" "Proportion des restants"
1

SLIDER
375
1132
547
1165
hire-noise
hire-noise
0
100
18
1
1
%
HORIZONTAL

SLIDER
374
1175
546
1208
fire-noise
fire-noise
0
100
1
1
1
%
HORIZONTAL

SLIDER
379
1329
551
1362
anciennete-min
anciennete-min
0
100
10
1
1
NIL
HORIZONTAL

SLIDER
379
1364
551
1397
anciennete-max
anciennete-max
0
1000
400
1
1
NIL
HORIZONTAL

SWITCH
378
1292
507
1325
anciennete?
anciennete?
1
1
-1000

SWITCH
637
1295
740
1328
retraite?
retraite?
1
1
-1000

SLIDER
637
1330
809
1363
age-retraite
age-retraite
300
1000
1000
1
1
NIL
HORIZONTAL

SLIDER
638
1366
855
1399
demission-pourcent
demission-pourcent
0
100
63
1
1
%
HORIZONTAL

SWITCH
923
1288
1087
1321
change-poste?
change-poste?
1
1
-1000

SLIDER
923
1326
1211
1359
change-poste-pourcent
change-poste-pourcent
0
10000
0
1
1
% x 100
HORIZONTAL

SWITCH
922
1368
1042
1401
by-ranking?
by-ranking?
1
1
-1000

TEXTBOX
375
1058
689
1078
\"Renouvellement\" des moins bons éléments
14
0.0
1

TEXTBOX
378
1234
528
1268
Prise en compte de l'ancienneté
14
0.0
1

TEXTBOX
636
1233
855
1291
Prise en compte de départs à la retraites et de démissions spontanées
14
0.0
1

TEXTBOX
924
1229
1074
1280
Changement de type selon rapport profit/effort
14
0.0
1

TEXTBOX
992
1061
1142
1079
Voisinage
14
0.0
1

SWITCH
982
1087
1133
1120
neighborhood?
neighborhood?
1
1
-1000

SLIDER
983
1133
1171
1166
neighborhood-radius
neighborhood-radius
1
max (list max-pxcor max-pycor)
5
1
1
NIL
HORIZONTAL

BUTTON
20
749
246
876
Capture d'écran interface
print-interface
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
258
749
484
874
Capture d'écran de la vue
print-view
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.3.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
