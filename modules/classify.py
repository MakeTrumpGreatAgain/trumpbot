from sknn.mlp import Classifier, Layer
import sys
import json
import requests
import socket
from time import sleep

responses = {}


def get_important_words(sentence):
    if sentence in responses:
        return responses[sentence]

    sleep(0.2)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect(("192.168.99.100", 8800))
    s.send("\n\n" + entry["answer"] + "\n")
    data = s.recv(2048)
    s.close()

    words = [w for w in data.split(' ') if len(w) > 0]

    responses[sentence] = words

    return words

if len(sys.argv) != 2:
    print "usage: classify.py input"
    sys.exit(0)

fin = open(sys.argv[1], "r")

contents = json.loads(fin.read())
new_entries = []


for entry in contents:
    valid = True

    entry["important_answer"] = get_important_words(entry["answer"])

    if len(entry["important_answer"]) == 0:
        valid = False

    entry["important_question"] = get_important_words(entry["question"])

    if len(entry["important_question"]) == 0:
        valid = False

    if valid:
        new_entries.append(entry)

    sleep(0.5)

json.dumps(new_entries)
