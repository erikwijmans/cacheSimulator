#!/usr/bin/env python3

from flask import Flask, url_for, redirect, request
from backend.trace import Tracer
from backend.csim import CSim
from json import dumps

application = Flask(__name__, static_url_path='')

@application.route("/")
def index():
  return redirect(url_for('static', filename='index.html'))

@application.route("/trace", methods=['POST'])
def trace():
  code = request.json
  tracer = Tracer(code)
  return dumps(tracer.get_res())

@application.route("/simulate", methods=['POST'])
def simulate():
  req = request.json
  sim = CSim(req['s'], req['E'], req['b'], req['memSize'], req['trace'])

  return dumps(sim.get_res())


if __name__ == '__main__':
  application.debug = True
  application.run()