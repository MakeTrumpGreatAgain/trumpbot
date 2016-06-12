import urllib2
import base64
import numpy as np
from numpy import exp, dot, zeros, outer, random, dtype, get_include, float32 as REAL,\
     uint32, seterr, array, uint8, vstack, argsort, fromstring, sqrt, newaxis, ndarray, empty, sum as np_sum
import json
import string

json_data = open('../json/parsed.json').read()

data = json.loads(json_data)

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


for sentences in data:
	for wtype,words in [('question',sentences[u'important_question'])]:
		sentences[wtype+'_vector'] = base64.b64encode(getVectorForWords(words))

with open('../json/vectorized.json', 'w') as outfile:
    json.dump(data, outfile)

