
**Question 1-1 :**
 Il vaut mieux passer les variables avec -e au docker run plutôt que les mettre dans le Dockerfile, car le Dockerfile est souvent versionné sur Git → les mots de passe seraient exposés publiquement. Avec -e, les secrets restent hors du code source.

**Question 1-2 :**
Sans volume, les données sont dans le container. Si on le supprime, tout est perdu. Un volume monte un dossier de la machine hôte dans le container, les données survivent à la destruction du container.

**Question 1-3 :**
Dockerfile — L'image de la base de données est construite à partir de postgres:17.2-alpine. Elle copie les scripts SQL d'initialisation dans /docker-entrypoint-initdb.d/ afin qu'ils soient exécutés automatiquement au premier démarrage :
dockerfileFROM postgres:17.2-alpine
COPY sql/ /docker-entrypoint-initdb.d/
Commandes essentielles — On commence par créer un réseau Docker dédié, puis on build l'image et on lance le container en passant les credentials via -e (et non dans le Dockerfile pour des raisons de sécurité), et en attachant un volume pour persister les données :
bashdocker network create app-network

docker build -t my-database ./database

docker run -d \
  --name my-postgres \
  --net=app-network \
  -e POSTGRES_DB=db \
  -e POSTGRES_USER=usr \
  -e POSTGRES_PASSWORD=pwd \
  -v ./data:/var/lib/postgresql/data \
  my-database
Le flag -d fait tourner le container en arrière-plan, --name lui donne un nom identifiable sur le réseau, et le volume -v garantit que les données survivent à la suppression du container.

**Question 1-4 :** 
Le multistage build permet d'avoir une image finale légère : le 1er stage utilise le JDK + Maven pour compiler et packager l'application, mais ces outils lourds ne sont pas nécessaires à l'exécution. Seul le .jar produit est copié dans le 2ème stage qui utilise uniquement le JRE, beaucoup plus léger. Chaque instruction du Dockerfile :

**Question 1-5 :** 
Un reverse proxy est un serveur intermédiaire qui reçoit les requêtes des clients et les redirige vers les services internes. Dans notre cas, Apache joue ce rôle en exposant uniquement le port 80 vers l'extérieur, tandis que le backend Spring Boot reste inaccessible directement depuis l'extérieur du réseau Docker. Cela apporte plusieurs avantages : la sécurité (on ne expose pas directement le backend), un point d'entrée unique pour toutes les requêtes, la possibilité de gérer le SSL/TLS en un seul endroit, et à terme de faire du load balancing en répartissant le trafic sur plusieurs instances du backend. C'est une bonne pratique standard en production.

**Question 1-6 :** 
Docker Compose est essentiel car il permet d'orchestrer plusieurs containers en une seule commande. Sans lui, il faudrait démarrer chaque container manuellement dans le bon ordre, créer les réseaux, attacher les volumes... ce qui est long et source d'erreurs. Avec un simple docker compose up, tous les services démarrent automatiquement dans le bon ordre, avec leurs configurations, réseaux et volumes. C'est aussi un fichier versionnable sur Git, ce qui rend le projet reproductible sur n'importe quelle machine par n'importe quel membre de l'équipe.

**Question 1-7 :**   

| Commande | Description |
|---|---|
| `docker compose up -d` | Démarre tous les services en arrière-plan |
| `docker compose down` | Arrête et supprime les containers |
| `docker compose build` | Rebuild les images sans démarrer les services |
| `docker compose up --build` | Rebuild les images et démarre les services |
| `docker compose logs -f` | Affiche les logs en temps réel |
| `docker compose ps` | Affiche l'état de tous les services |
| `docker compose restart` | Redémarre tous les services |
| `docker compose stop` | Arrête les services sans les supprimer |
| `docker compose exec <service> sh` | Ouvre un terminal dans un service |

**Question 1-8 :** 
Notre docker-compose.yml définit trois services : 

- Database qui build l'image PostgreSQL, monte un volume nommé postgres-data pour persister les données et charge ses credentials depuis le .env 

- Backend qui build l'image Spring Boot, dépend de database pour démarrer après elle et reçoit ses variables de connexion à la DB via l'environnement 

- httpd qui build l'image Apache, est le seul service à exposer un port vers l'extérieur (port 80) et dépend du backend. 

Les trois services partagent le même réseau app-network pour communiquer entre eux, tandis que la DB et le backend ne sont pas accessibles depuis l'extérieur, ce qui est une bonne pratique de sécurité.

test
