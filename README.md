# gafes
bibliothèques utiles pour les script :
- shiny (https://cran.r-project.org/web/packages/shiny/index.html)
- DBI (https://cran.r-project.org/web/packages/DBI/index.html)
- RMySQL (https://cran.r-project.org/web/packages/RMySQL/index.html)
- sparcl (https://cran.r-project.org/web/packages/sparcl/index.html)
- ggplot2 (https://cran.r-project.org/web/packages/ggplot2/index.html)
- Cairo (https://cran.r-project.org/web/packages/Cairo/index.html)
- ggrepel (https://cran.r-project.org/web/packages/ggrepel/index.html)

fonction "fest.tag3" d'appel a la base de donnée clef_microblogs_tbl sur mysql.
Base de données contenant 80 millions de tweets. Pour chaque tweet il faut les champs suivant :
  - From_user (varchar)
  - From_user_id (varchar)
  - Source (varchar)
  - Profile_image_url (varchar)
  - Date (date)
  - Day (enum)
  - Seconds (int)
  - CONTENT (text) avec Index FULLTEXT

DATE et CONTENT sont les champs indispensables a l'appel "fest.tag3".


"fest.tag3" calcule et récupère les effectifs de tweetes content un mot "w" pour chacune des 78 semaines. Toute les valeurs sont également
lissées par moyenne mobile d'ordre deux.


Appel system de programmes python pour appliquer le code "extractVectors.py" aux mots récupérés dans "liste_rajout.txt" et récupérer leur représentation vectorielles dans "extract_rajout.csv" : 
system("./Gafes/extractVectors.py -i ./Gafes/clef_microblogs_tbl_full.vector.bin -o ./Gafes/wordextract/extract_rajout.csv -w ./Gafes/wordlist/liste_rajout.txt")

