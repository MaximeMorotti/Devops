# Projet DevOps

Ce projet met en place une application 3-tiers dans le cadre des cours DevOps Takima. Il illustre les bonnes pratiques de conteneurisation via Docker (TP01) et la mise en place d'une intégration et d'un déploiement continus (CI/CD) automatisés avec Github Actions (TP02).

---

## Architecture de l'Application (TP01)

L'application repose sur une architecture 3-tiers classique, entièrement conteneurisée et orchestrée via `docker-compose`. Les différents composants communiquent au sein d'un réseau Docker privé (`app-network`).

### Fonctionnalités et Composants
1. **Base de données (PostgreSQL)**
   - Base de données relationnelle dont les données sont persistées sur la machine hôte via des volumes Docker.
   - Au premier démarrage, elle est automatiquement initialisée grâce à des scripts SQL (`01-CreateScheme.sql` et `02-InsertData.sql`) montés dans le conteneur, créant ainsi le schéma et insérant des données de test (départements, étudiants).

2. **Backend API (Spring Boot / Java 21)**
   - API REST développée en Java avec le framework Spring Boot.
   - L'API interroge la base de données PostgreSQL pour exposer les données (par exemple via des endpoints permettant de récupérer les étudiants d'un département).
   - **Multistage build** : L'image Docker du backend est construite en deux temps. Une première étape compile le code avec Maven (nécessite le JDK), et la seconde étape génère l'image finale d'exécution (ne contenant que l'application et le JRE). Cela rend l'image beaucoup plus légère et sécurisée.

3. **Serveur HTTP / Reverse Proxy (Apache httpd)**
   - Serveur web Apache servant de point d'entrée unique pour l'application.
   - Il agit comme un proxy inverse (reverse proxy) : il intercepte les requêtes sur le port 80 de l'hôte et les redirige de manière transparente vers le backend (qui tourne sur le port 8080 en interne).

### Comment lancer l'application
Assurez-vous d'avoir Docker et Docker Compose d'installés. Placez-vous dans le répertoire `TP01` et exécutez le script PowerShell suivant :
```powershell
.\generate-compose.ps1
```
Ce script chargera les variables d'environnement depuis le fichier `.env`, générera le fichier `docker-compose.generated.yml` et lancera automatiquement les conteneurs en arrière-plan.
L'API sera ensuite accessible via `http://localhost/` sur votre machine.

---

## Intégration et Déploiement Continus - CI/CD (TP02)

Afin d'automatiser la chaîne de développement, un pipeline complet a été mis en place avec **Github Actions**. Ce pipeline permet de tester, valider et publier l'application de façon sécurisée à chaque modification du code.

### Fonctionnalités ajoutées
1. **Intégration Continue (CI)**
   - À chaque *push* sur les branches principales ou lors d'une *pull request*, un workflow Github Actions compile le code Java et lance la suite de tests automatisés via Maven.
   - **Testcontainers** : Lors des tests d'intégration, l'outil Testcontainers est utilisé pour instancier à la volée un véritable conteneur PostgreSQL. Ainsi, l'application est testée dans des conditions presque identiques à celles de production.

2. **Contrôle Qualité (Quality Gate)**
   - Le pipeline inclut une intégration avec **SonarCloud**.
   - Après les tests, le code est audité afin de vérifier la couverture de tests, détecter la dette technique (code smells), et repérer d'éventuels bugs ou failles de sécurité. Le pipeline garantit qu'aucun code non-qualitatif n'atteint la production.

3. **Déploiement Continu (CD) et Publication**
   - L'architecture du pipeline est modulaire (`needs: test-backend`). Si et seulement si la compilation, les tests et l'analyse qualité sont concluants, le pipeline déclenche la construction des images Docker.
   - Les images (backend, base de données, httpd) sont générées, taguées et poussées automatiquement vers un registre distant (**Docker Hub**).
   - Ces images finalisées peuvent ensuite être facilement récupérées pour être déployées sur un serveur.
   - **Sécurité** : Tous les accès sensibles (les tokens SonarCloud et les identifiants Docker Hub) sont stockés de manière chiffrée en utilisant les *Secrets* de Github.