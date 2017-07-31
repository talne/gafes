#!/usr/bin/env python3

import pprint
import nltk 
from gensim import corpora, models, similarities;
from collections import defaultdict
import csv
import sys
import getopt
import re


# Allow to add vectors
def vectorAddition(v1, v2):
  v3 = []
  if len(v1) != len(v2):
    print("Vecteurs de tailles : [" + str(len(v1)) + ", " + str(len(v2)) + "]")  
    return v3
  for i in range(len(v1)):
    v3.append(v1[i] + v2[i])
  return v3


wordVariables = []
blackList = [] 
# Main
def main(argv):
  inputfile = ''
  outputfile = ''
  wordfile = ''

  try:
    opts, args = getopt.getopt(argv, "hi:o:w:", ["ifile=", "ofile="])
  except getopt.GetoptError:
    print('command -i <inputFile> -o <outputFile>')
    sys.exit(2)

  for opt, arg in opts:
    print("Un opt : " + opt + " | " + arg)
    if opt == '-h':
      print('test.py -i <inputFile> -o <outputFile>')
      sys.exit()
    elif opt in ("-i", "--ifile"):
      inputfile = arg
    elif opt in ("-o", "--ofile"):
      outputfile = arg
    elif opt in ("-w", "--wfile"):
      wordfile = arg
  
  #Open input model
# ESJ Modif: https://groups.google.com/forum/embed/#!topic/gensim/hlYgjqEVocw
  model = models.KeyedVectors.load_word2vec_format(inputfile, binary=True, unicode_errors='ignore')  
# model = models.Word2Vec.load_word2vec_format(inputfile, binary=True, unicode_errors='ignore')

  #Building black list
  with open(wordfile, 'r') as f:
    for line in f:
      try:
        splited = line.split("\n")[0].split(" ")
        for i, splitedWord in enumerate(splited):
          if len(splitedWord) == 0:
            splited.remove(splitedWord)
          else:
            test = model[splitedWord]
        wordVariables.append(splited)
      except Exception:
        print("Doesn't exist:" + line.split("\n")[0])
        blackList.append(line)


  #Create csv file with vector values for each word.
  with open(outputfile, 'w') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=';',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL) 
    values = []
    #Write each row
    for splitWord in wordVariables:
      values = []
#ESJ Modif 
      size = len(model[splitWord[0]])
      vectorRepresentation = [0] * size
      #Add vectors for n-grams.
      for word in splitWord:
#ESJ Modif: rm .wv
        vectorRepresentation = vectorAddition(vectorRepresentation, model[word])
      values.append(" ".join(splitWord))
      for value in vectorRepresentation: 
          values.append(value)
      spamwriter.writerow(values)
    

main(sys.argv[1:])
