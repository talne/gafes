# gafes

Le programme ts c récupère les occurences des tweets par semaines et affiche la classificatiuon hiérarchique calculé grâce aux corrélations entre les mots.On a ainsi des rapprochements temporrels. Trois méthodes de classifications hiérarchiques sont proposées. 
Le programme affiche ensuite une analyse en composantes principale des mots choisi ainsi qu'une autre par classes. On a donc possibilité de choisir le nombre de classes voulu. La coupe sera représentée sur la cah.
On a ensuite les boxplots des effectifs par classes qui sont repréqentés.
Les mots de bases sont dans YSM4.csv, et les mots rejoutés par les utilisateurs sont dans dfa.csv.

Le programme w2v récupère lui les vecteurs grâce a la méthode word2vec pour chaque mot et affiche ainsi la cah et l'ACP grâce au cosinus calculé entre chaque vecteurs. 
On a ainsi des rapprochements par contexte dans les phrases.
Ainsi la dépendance aux appels python ainsi que les récupérations vectorielles ne sont pas nécessaires pour le programme ts c.

Enfin, Ts w2v est un programme qui comprend pareil que w2v mais avec en plus des classification qui sont fait par regroupement vectoriel et qui ensuite somme les effectifs de chaque classe créée. On obtient ainsi une ACP par classes ain si que les boxplot des effectifs sommés.

Voir interface : https://mc2.talne.eu/shiny/gafes/


bibliothèques utiles pour les script :
- shiny (https://cran.r-project.org/web/packages/shiny/index.html)
- DBI (https://cran.r-project.org/web/packages/DBI/index.html)
- RMySQL (https://cran.r-project.org/web/packages/RMySQL/index.html)
- sparcl (https://cran.r-project.org/web/packages/sparcl/index.html)
- ggplot2 (https://cran.r-project.org/web/packages/ggplot2/index.html)
- Cairo (https://cran.r-project.org/web/packages/Cairo/index.html)
- ggrepel (https://cran.r-project.org/web/packages/ggrepel/index.html)

fonction "fest.tag3" d'appel a la base de donnée clef_microblogs_tbl sur mysql.
Base de données de tweets. Pour chaque tweet il faut les champs suivant :
  - From_user (varchar)
  - From_user_id (varchar)
  - Source (varchar)
  - Profile_image_url (varchar)
  - Date (date)
  - Day (enum)
  - Seconds (int)
  - CONTENT (text) avec Index FULLTEXT obligatoire

DATE et CONTENT sont les champs indispensables a l'appel "fest.tag3".


"fest.tag3" calcule et récupère les effectifs de tweetes content un mot "w" pour chacune des 78 semaines. Toute les valeurs sont également
lissées par moyenne mobile d'ordre deux.


Appel system de programmes python pour appliquer le code "extractVectors.py" aux mots récupérés dans "liste_rajout.txt" et récupérer leur représentation vectorielles dans "extract_rajout.csv" : 
system("./Gafes/extractVectors.py -i ./Gafes/clef_microblogs_tbl_full.vector.bin -o ./Gafes/wordextract/extract_rajout.csv -w ./Gafes/wordlist/liste_rajout.txt")

"extractVectors.py" appel les fonctions :
- pprint (https://pypi.python.org/pypi/pprintpp)
- nltk (https://pypi.python.org/pypi/nltk)
- gensim (https://pypi.python.org/pypi/gensim)
- collections (https://pypi.python.org/pypi/collections-extended/0.9.0)
- csv (https://pypi.python.org/pypi/csv)
- sys (https://pypi.python.org/pypi/sys)
- getopt (https://pypi.python.org/pypi/micropython-getopt)
- re (https://pypi.python.org/pypi/RE)
