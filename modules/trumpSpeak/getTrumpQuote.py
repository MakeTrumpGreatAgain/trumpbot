import urllib2
import base64
import numpy as np
from numpy import exp, dot, zeros, outer, random, dtype, get_include, float32 as REAL,\
     uint32, seterr, array, uint8, vstack, argsort, fromstring, sqrt, newaxis, ndarray, empty, sum as np_sum
import json
from numpy import random,argsort,sqrt
from pylab import plot,show

from flask import Flask, request
app = Flask(__name__)

import socket
from time import sleep

import string


json_data = open('../../json/vectorized.json').read()

data = json.loads(json_data)

all_vectors = array(map(lambda pair: np.frombuffer(base64.decodestring(pair[u'question_vector']), dtype=np.float64), data))

def getVectorForWord(word):
	word = word.encode('ascii').lower()
	word = word.translate(string.maketrans("",""), string.punctuation)
	vector_string = urllib2.urlopen("http://192.168.99.101:8803/word2vec/model?word="+word).read()
	if vector_string == "null":
		return None
	vector_string = vector_string[1:-1]
	if len(vector_string):
		r = base64.b64decode(vector_string)
		q = np.frombuffer(r, dtype=np.float32)
		return q
	return None

def getVectorForWords(words):
	final_vector = np.zeros(50)
	nwords = 0
	for word in words:
		vector = getVectorForWord(word)
		if vector is not None: 
			nwords += 1
			final_vector = np.add(final_vector, vector)
	if nwords > 0:
		final_vector = final_vector/nwords
	return final_vector


def knn_search(x, D, K):
	""" find K nearest neighbours of data among D """
	ndata = D.shape[0]
	K = K if K < ndata else ndata
	# euclidean distances from the other points
	sqd = sqrt(((D - x)**2).sum(axis=1))
	idx = argsort(sqd) # sorting
	# return the indexes of K nearest neighbours
	return idx[:K]

def get_important_words(sentence):
    sentence = sentence.encode('ascii', 'ignore') +'.'

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("192.168.99.101", 8800))
    s.send("\n\n" + sentence + "\n")
    data = s.recv(2048)
    s.close()
    return [w for w in data.split(' ') if len(w) > 0]


print all_vectors

@app.route('/', methods=['POST'])
def hello_world():
	content = request.get_json(force=True)
	sentence = content["sentence"]
	important_words = get_important_words(sentence)
	target_v = array([getVectorForWords(important_words)])
	print target_v
	index = knn_search(target_v, all_vectors, 1)[0]
	return data[index][u'answer'] + '\n\n'

