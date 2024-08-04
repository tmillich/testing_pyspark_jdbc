#!/bin/sh

BASEDIR=$(dirname $0)

mkdir "$BASEDIR"/build

wget -O ./build/ojdbc10.jar https://repo1.maven.org/maven2/com/oracle/database/jdbc/ojdbc10/19.21.0.0/ojdbc10-19.21.0.0.jar

apt update -y
apt upgrade -y
apt install -y default-jre


pip install --upgrade pip
pip install -r requirements.txt
