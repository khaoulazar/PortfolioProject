# Exploration des données COVID-19 (SQL Server)

Analyse SQL exploratoire des données mondiales de cas, décès et vaccination COVID-19, réalisée en T-SQL sur Microsoft SQL Server.

## Aperçu

Ce projet explore la relation entre les cas de COVID-19, les décès, la population et le déploiement de la vaccination par pays et par continent, à l'aide de jointures, fonctions de fenêtrage, CTE, vues et requêtes d'agrégation.

## Jeu de données

Deux tables sources :
- **CovidDeath** — localisation, date, cas totaux/nouveaux, décès totaux/nouveaux, population
- **CovidVaccinations** — localisation, date, nouvelles vaccinations

## Outils

- Microsoft SQL Server / T-SQL

## Analyses réalisées

- **Nettoyage des données** : correction des types de colonnes (`total_cases`, `total_deaths` en `INT`)
- **Cas vs décès** : taux de mortalité par pays, avec gestion correcte de la division entière (conversion du numérateur en `DECIMAL` pour éviter la troncature)
- **Taux d'infection** : pourcentage de population infectée, par pays
- **Taux/nombre d'infection le plus élevé** : classement des pays selon le pic d'infections et le taux relatif à la population
- **Taux/nombre de décès le plus élevé** : classement des pays selon le nombre de décès et le taux relatif à la population
- **Répartition continentale** : agrégation des décès par continent
- **Totaux mondiaux** : filtrage sur les lignes de niveau continent (`continent IS NULL`) pour des synthèses globales
- **Déploiement de la vaccination** : jointure des tables décès et vaccinations, calcul d'un cumul glissant des vaccinations par localisation via `SUM() OVER (PARTITION BY ... ORDER BY ...)`
- **CTE** : expression `PopvsVac` pour calculer le pourcentage de population vaccinée
- **Table temporaire** : table physique `POPVSVAC` stockant le même calcul cumulatif
- **Vue** : `popvaccview` créée pour réutilisation dans des outils de visualisation (Power BI, Tableau, etc.)

## Techniques SQL démontrées

- Fonctions de fenêtrage (`SUM() OVER (PARTITION BY ... ORDER BY ...)`)
- Expressions de table communes (CTE)
- Vues et tables de transit temporaires/physiques
- Conversion de type et correction de type de données (`ALTER TABLE ... ALTER COLUMN`)
- Fonctions d'agrégation (`MAX`, `SUM`) avec `GROUP BY`
- Jointures entre tables liées

## Fichiers

- `covid_exploration.sql` — script complet des requêtes, dans l'ordre d'exécution de l'analyse

## Remarques

Les requêtes incluent des commentaires expliquant le raisonnement à chaque étape, notamment la correction d'un piège classique de SQL Server : la troncature des résultats décimaux due à la division entière (résolue par conversion en `DECIMAL`/`FLOAT` avant la division).
