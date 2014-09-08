#Symbiose

Symbiose is an app to share mouse, keyboard, and windows between different OS

## Install

### Linux

```bash
git clone git@github.com:Champii/Symbiose.git
cd Symbiose
npm install
npm install -g coffee-script
npm install -g jade
./compile.sh
./common/nodewebkit/nw .
 # or for no interface
node compiled -q [-s|-c]
```

### Windows

Not working yet

### MacOS

Not working yet

## Develop


```bash
./watch.sh
```

## TODO

By order of priority:

* Catch guest windows inputs
* Optimisation of mouse tracking and events in general
* Slick Drag n Drop window between screens
* Repair glitch on window refresh
* Hide source window when dragged out of screen
