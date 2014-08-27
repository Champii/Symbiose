#!/bin/bash

jade gui/views/*.jade -D -o gui/views/compiled
coffee -c -b -o gui/js/compiled gui/coffee
coffee -c -b -o client/compiled client/*.coffee
coffee -c -b -o server/compiled server/*.coffee
coffee -c -b -o common/compiled common/*.coffee
