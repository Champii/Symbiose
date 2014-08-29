#!/bin/bash

cd ..
zip -r build/app.nw ./*
cd build/
cat ../../nodewebkit/nw ../../nodewebkit/icudtl.dat app.nw > Symbiose && chmod +x Symbiose
rm app.nw
