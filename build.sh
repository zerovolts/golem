#!/bin/bash

mkdir build
mkdir build/styles
elm-make src/Main.elm --output  build/index.html
cp -R src/styles build/
gh-pages -d build