**Question 2-1 :**
Les Testcontainers sont des bibliothèques Java open-source qui permettent d'instancier et de gérer des conteneurs Docker (comme des bases de données, des brokers de messages, etc.) directement depuis le code des tests.

Dans notre cas, au lieu d'avoir besoin d'une base de données PostgreSQL installée et configurée manuellement sur la machine qui exécute les tests (ou sur la machine GitHub Actions), Testcontainers va :

Démarrer automatiquement un conteneur PostgreSQL éphémère au lancement des tests d'intégration.

Connecter l'application Java à ce conteneur.

Détruire le conteneur proprement une fois les tests terminés.

Cela garantit un environnement de test fiable, isolé et reproductible à 100%, que ce soit en local ou sur une pipeline CI.

**Question 2-2 :**
Il est indispensable de sécuriser le stockage de nos identifiants pour éviter qu'ils ne soient poussés par erreur en clair dans notre code source (sur un dépôt public ou privé), ce qui exposerait nos infrastructures à des piratages.

Les GitHub Secrets sont des variables d'environnement chiffrées créées au niveau d'un dépôt GitHub. Ils permettent de masquer des informations sensibles (mots de passe, tokens, clés API) :

Ils sont chiffrés dès leur saisie et ne peuvent plus être relus en clair sur l'interface GitHub.

GitHub Actions peut les injecter de manière sécurisée au moment de l'exécution du pipeline (${{ secrets.NOM_DU_SECRET }}).

GitHub masque automatiquement leur valeur (avec des astérisques ***) s'ils apparaissent par mégarde dans les journaux de logs de la console.

**Question 2-3 :**
 Par défaut, GitHub Actions exécute tous les jobs d'un workflow en parallèle pour optimiser le temps de calcul. L'utilisation du paramètre needs: test-backend permet de briser ce parallélisme en créant une dépendance séquentielle indispensable entre la CI (intégration continue) et la CD (déploiement continu).

Sans ce paramètre, le build Docker et le push sur Docker Hub démarreraient en même temps que les tests unitaires. Si le code Java contenait une erreur provoquant l'échec des tests, GitHub Actions packagerait et publierait quand même une image Docker défectueuse. Le needs agit donc comme une barrière de sécurité : il garantit qu'aucune image n'est envoyée sur Docker Hub si le code n'a pas validé 100 % des tests automatisés au préalable.

**Question 2-4 :** 
La condition push: ${{ github.ref == 'refs/heads/main' }} sert à restreindre la publication finale des images Docker à la seule branche de production (main). Dans un flux de travail Git classique (comme GitFlow), les branches secondaires comme develop ou les branches de fonctionnalités (feature branches) contiennent du code en cours de construction, potentiellement instable.

Grâce à cette condition, le pipeline adopte un comportement intelligent selon le contexte :

Sur develop : Il télécharge le code, lance les tests et vérifie simplement que les images Docker se compilent correctement (build), sans rien envoyer en ligne.

Sur main : Il valide les étapes précédentes et valide l'envoi (push) sur Docker Hub. Cela évite d'encombrer le registre Docker Hub avec des dizaines d'images intermédiaires ou non finalisées à chaque petit commit de développement.