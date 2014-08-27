#!/bin/bash

jade gui/views/*.jade -w -D -o gui/views/compiled&
coffee -w -c -b -o gui/js/compiled gui/coffee&
coffee -w -c -b -o client/compiled client/*.coffee&
coffee -w -c -b -o server/compiled server/*.coffee&
coffee -w -c -b -o common/compiled common/*.coffee
