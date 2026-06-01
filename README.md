# DevOps Training Repository

Ce dépôt a pour but de centraliser les exercices et projets réalisés dans le cadre de l'apprentissage des pratiques DevOps. Les exercices se basent sur le cours [Discover Docker](http://school.pages.takima.io/devops-1/devops-resources/ch1-discover-docker-tp/) proposé par Takima.

## Exercices actuels

### 1. TD01 - "flask-app"
Ce dossier contient un projet d'initiation à la conteneurisation d'une application Python avec Flask. Il comprend l'application (`app.py`), ses dépendances (`requirements.txt`), ainsi que son `Dockerfile` pour construire l'image correspondante.

### 2. TP01
Ce dossier contient le premier TP de la formation. Il s'agit d'une architecture multi-conteneurs gérée via `docker-compose`. On y retrouve :
- Une base de données (`database`)
- Un serveur backend (`backend`)
- Un serveur web/reverse proxy (`httpd`)

Pour lancer le projet, assurez-vous d'avoir configuré le fichier `.env` (en vous basant sur `.env.sample`) puis exécutez la commande depuis le dossier `TP01` :
```bash
docker-compose up -d
```

## À venir

Dans le futur, ce dépôt accueillera :
- **2 autres TP et TD** pour approfondir les concepts DevOps (orchestration, CI/CD, etc.) dans la continuité des exercices actuels.

---
*Projet réalisé dans le cadre de la formation DevOps.*