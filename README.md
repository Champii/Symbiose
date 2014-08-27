#Symbiose

Symbiose is an app to share mouse, keyboard, and windows between different OS

## Install

### Linux

```bash
sudo apt-get install xautomation # apt-get on debian-like, use your own
git clone git@github.com:Champii/Symbiose.git
cd Symbiose
npm install
npm install -g coffee-script
npm install -g jade
./compile.sh
./common/nodewebkit/nw .
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

* Catch keyboard events
* Better mouse integration
* Multi client
* Choose where to place clients screens
* Window creation
