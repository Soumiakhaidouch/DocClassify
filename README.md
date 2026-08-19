# DocClassify

Système de classification automatique de documents textuels bilingues (arabe / français), développé dans le cadre du Master D3SI (Data Science et Sécurité des Systèmes d'Information) — Faculté Polydisciplinaire de Béni Mellal, Université Sultan Moulay Slimane.



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

4. **Lancer l'application**

   ```bash
   cd App
   python app.py
   ```

   L'application est ensuite accessible à l'adresse `http://localhost:5000`.

## Utilisation du notebook

Le notebook présent dans `Notebook/` peut être exécuté avec Jupyter pour reproduire l'exploration des données, l'entraînement des deux modèles et leur évaluation comparative.

### Données

Le corpus utilisé pour l'entraînement et l'évaluation des modèles se trouve dans le répertoire `Notebook/Data/`.
