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

 
**Question 2-4 :** 
