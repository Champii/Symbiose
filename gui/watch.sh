#!/bin/bash

coffee -w -c -b -o js/compiled coffee&
jade views/*.jade -w -D -o views/compiled
