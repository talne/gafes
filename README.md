# gafes
bibliothèques utiles pour les script :
library(shiny)
library("DBI")
library("RMySQL")
library("sparcl")
library("ggplot2")
library("Cairo")
library("ggrepel")

fonction "fest.tag3" d'appel a la base de donnée clef_microblogs_tbl du compte miner sur phpmyadmin.
Base de données contenant 80 millions de tweets. Pour chaque tweet on a :
  - From_user (varchar)
  - From_user_id (varchar)
  - Source (varchar)
  - Profile_image_url (varchar)
  - Date (date)
  - Day (enum)
  - Seconds (int)
  - CONTENT (text) avec Index FULLTEXT

"fest.tag3" calcule et récupère les effectifs de tweetes content un mot "w" pour chacune des 78 semaines. Toute les valeurs sont également
lissées par moyenne mobile d'ordre deux.


Appel system de programmes python pour appliquer le code "extractVectors.py" aux mots récupérés dans "liste_rajout.txt" et récupérer leur représentation vectorielles dans "extract_rajout.csv" : 
system("./Gafes/extractVectors.py -i ./Gafes/clef_microblogs_tbl_full.vector.bin -o ./Gafes/wordextract/extract_rajout.csv -w ./Gafes/wordlist/liste_rajout.txt")

