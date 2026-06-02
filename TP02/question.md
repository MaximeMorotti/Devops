**Question 2-1 :**
Les Testcontainers sont des bibliothèques Java open-source qui permettent d'instancier et de gérer des conteneurs Docker (comme des bases de données, des brokers de messages, etc.) directement depuis le code des tests.

Dans notre cas, au lieu d'avoir besoin d'une base de données PostgreSQL installée et configurée manuellement sur la machine qui exécute les tests (ou sur la machine GitHub Actions), Testcontainers va :

Démarrer automatiquement un conteneur PostgreSQL éphémère au lancement des tests d'intégration.

Connecter l'application Java à ce conteneur.

Détruire le conteneur proprement une fois les tests terminés.

Cela garantit un environnement de test fiable, isolé et reproductible à 100%, que ce soit en local ou sur une pipeline CI.

**Question 2-2 :**


**Question 2-3 :**


**Question 2-4 :** 
