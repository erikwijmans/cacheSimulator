#!/usr/bin/env python3

from flask import Flask, url_for, redirect, request
from backend.trace import Tracer
from backend.csim import CSim
from json import dumps, loads

app = Flask(__name__, static_url_path='')

@app.route("/")
def index():
  return redirect(url_for('static', filename='index.html'))

@app.route("/trace", methods=['POST'])
def trace():
  code = loads(request.data.decode("utf-8"))
  tracer = Tracer(code)
  return dumps(tracer.get_res())

@app.route("/simulate", methods=['POST'])
def simulate():
  req = loads(request.data.decode("utf-8"))
  sim = CSim(req['s'], req['E'], req['b'], req['memSize'], req['trace'], req['style'])

  return dumps(sim.get_res())


if __name__ == '__main__':
  app.debug = True
  app.run()