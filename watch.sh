#!/bin/bash

cp gui/index.html compiled/gui/
cp -r gui/img compiled/gui/

jade gui/views/*.jade -w -D -o compiled/gui/views&
coffee -w -c -b -o compiled/gui/js gui/coffee&
coffee -w -c -b -o compiled/client client/*.coffee&
coffee -w -c -b -o compiled/server server/*.coffee&
coffee -w -c -b -o compiled/common common/*.coffee&
coffee -w -c -b -o compiled/ Symbiose.coffee
