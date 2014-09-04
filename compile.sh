#!/bin/bash

cp gui/index.html compiled/gui/
cp -r gui/img compiled/gui/

jade gui/views/*.jade -D -o compiled/gui/views
coffee -c -b -o compiled/gui/js gui/coffee
coffee -c -b -o compiled/client client/*.coffee
coffee -c -b -o compiled/server server/*.coffee
coffee -c -b -o compiled/common common/*.coffee
coffee -c -b -o compiled/ Symbiose.coffee
