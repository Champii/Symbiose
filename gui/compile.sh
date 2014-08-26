#!/bin/bash

coffee -c -b -o js/compiled coffee
jade views/*.jade -D -o views/compiled
