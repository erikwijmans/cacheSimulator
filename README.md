## Setup instructions

Install python3 and pip3
> sudo apt-get install python3

> curl -sS https://bootstrap.pypa.io/get-pip.py | sudo -H python3

Install clang-format
> sudo apt-get install clang-format

Install virtualenv
> sudo -H pip install virtualenv

Set-up virtualenv
> virtualenv -p python3 virtenv-cache

> source virtenv-cache/bin/activate


Install flask
> sudo -H pip install flask


##Startup

> env FLASK_APP=cacheSim.py flask run
