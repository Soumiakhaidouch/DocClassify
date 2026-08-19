# DocClassify

Système de classification automatique de documents textuels bilingues (arabe / français).
**Catégories :** culture · finance · medical · politics · sports · tech.

## Prérequis

- Python 3.9+
- pip
- Git

## Installation

1. **Cloner le dépôt**

   ```bash
   git clone <url-du-depot>
   cd DocClassify
   ```

2. **Créer un environnement virtuel**

   ```bash
   python -m venv venv
   source venv/bin/activate      # Linux / macOS
   venv\Scripts\activate         # Windows
   ```

3. **Installer les dépendances**

   ```bash
   pip install -r requirements.txt
   ```
Créer la base de données PostgreSQL Créer une base de données puis importer le schéma fourni dans docclassify_db.sql :
bash
   createdb docclassify_db
   psql -d docclassify_db -f docclassify_db.sql

4. **Créer la base de données PostgreSQL**
   Créer une base de données puis importer le schéma fourni dans `App/docclassify_db.sql` :
```bash
   createdb docclassify_db
   psql -d docclassify_db -f docclassify_db.sql
```
 
   Configurer ensuite les identifiants de connexion à la base de données (variables d'environnement ou fichier de configuration de l'application, selon `App/`).

5. **Lancer l'application**

   ```bash
   cd App
   python app.py
   ```

   L'application est ensuite accessible à l'adresse `http://localhost:5000`.

## Utilisation du notebook

Le notebook présent dans `Notebook/` peut être exécuté avec Jupyter pour reproduire l'exploration des données, l'entraînement des deux modèles et leur évaluation comparative.

### Données

Le corpus utilisé pour l'entraînement et l'évaluation des modèles se trouve dans le répertoire `Notebook/Data/`.
