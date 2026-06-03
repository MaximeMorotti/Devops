**Question 3-1 :**
L'inventaire Ansible (inventories/setup.yml) permet de cartographier notre infrastructure en définissant les hôtes cibles (ici, notre serveur de production sous le groupe prod) et en centralisant les paramètres de connexion globaux, à savoir l'utilisateur SSH (admin) et le chemin vers la clé privée sécurisée (~/.ssh/id_rsa_takima). Cette centralisation évite de spécifier manuellement les accès à chaque interaction. Pour exploiter cette configuration, deux commandes de base fondamentales sont utilisées : la commande ad-hoc ansible all -i inventories/setup.yml -m ping pour valider instantanément la connectivité avec l'ensemble des machines cibles, et la commande ansible-playbook -i inventories/setup.yml playbook.yml chargée d'exécuter nos playbooks afin d'orchestrer et d'automatiser le provisionnement du serveur.

**Question 3-2 :**
La refactorisation du playbook via l'introduction de rôles Ansible permet de rompre avec l'approche monolithique en adoptant une architecture modulaire et hautement maintenable. Le fichier principal playbook.yml fait désormais office de simple orchestrateur (ou "point d'entrée"), dont le rôle unique est de cibler les hôtes et d'appeler séquentiellement les rôles dédiés (docker, network, database, app, proxy). Chaque rôle encapsule de manière isolée ses propres tâches dans son répertoire tasks/main.yml. Cette séparation des responsabilités facilite la réutilisabilité des composants, simplifie le débogage et permet d'isoler l'usage d'interpréteurs Python spécifiques (via ansible_python_interpreter) uniquement là où les modules dépendent du SDK Docker installé dans notre environnement virtuel.

**Question 3-3 :**
### Documentation technique des conteneurs

La configuration utilise le module `community.docker.docker_container` pour garantir une infrastructure reproductible.

| Service | Image | Configuration clé |
| --- | --- | --- |
| **database** | `mmorotti/my-database` | Utilise `env_file: /opt/.env` pour les credentials Postgres. Réseau : `app-network`. |
| **backend** | `mmorotti/my-backend` | `env_file: /opt/.env`. URL JDBC : `jdbc:postgresql://database:5432/...` (DNS interne). |
| **proxy** | `mmorotti/my-httpd` | Exposition port `80:80`. Connecté au réseau `app-network` pour le routage. |

#### Points techniques majeurs :

1. **Isolation réseau :** Tous les conteneurs partagent le réseau `app-network`, permettant la résolution de noms (ex: `database` est accessible directement par le `backend`).
2. **Sécurité :** Utilisation de `env_file` avec des droits `0600` pour éviter l'exposition en clair des secrets dans les logs ou fichiers de configuration Ansible.
3. **Persistance :** Les conteneurs sont configurés avec une `restart_policy: always` pour garantir la haute disponibilité du service après redémarrage du serveur.

**Question 3-4 :** 
Il est crucial de comprendre que le déploiement automatique de chaque nouvelle image poussée sur Docker Hub n'est pas une pratique sécurisée. En automatisant ce processus sans contrôle, vous exposez l'environnement de production à des risques de régression fonctionnelle, où un code non testé ou une configuration erronée pourrait entraîner une indisponibilité immédiate du service. De plus, ce type de configuration rend l'infrastructure vulnérable aux attaques sur la chaîne d'approvisionnement logicielle ; si un attaquant parvient à pousser une image malveillante sur le registre, celle-ci serait déployée instantanément sur le serveur sans aucun filtre humain ou technique pour valider sa conformité.

Pour sécuriser ce flux de travail, la solution consiste à introduire des barrières de contrôle rigoureuses au sein du pipeline CI/CD. La première étape indispensable est d'ajouter une phase de tests automatisés comprenant des tests unitaires, des tests d'intégration et des scans de vulnérabilités pour chaque image construite. Par ailleurs, il est préférable d'adopter une stratégie de déploiement en deux temps, en déployant d'abord vers un environnement de staging pour valider le comportement de l'application avant de procéder au déploiement en production, idéalement avec une validation manuelle requise via les environnements GitHub. Enfin, l'abandon du tag latest au profit d'un versionnage strict basé sur les IDs de commit ou des versions sémantiques permet une traçabilité précise et offre une capacité de retour en arrière immédiate en cas de déploiement défectueux.
