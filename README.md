# Material Browser
A minimalistic material design web browser written for Papyros (https://github.com/papyros/)

[![Join the chat at https://gitter.im/tim-sueberkrueb/material-browser](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/tim-sueberkrueb/material-browser?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Screenshots
![Screenshot](screenshots/screenshot_01.png)
![Screenshot](screenshots/screenshot_03.png)

## Translations
Please help us translating this application! Read this guide to get started:
https://github.com/tim-sueberkrueb/material-browser/wiki/Translations

## Installation

### Dependencies
* Qt 5.5 and QtWebEngine 1.1 (http://qt.io)
  * *Note:* Qt 5.5 is currently beta. You can grap it here: http://download.qt.io/development_releases/qt/5.5/5.5.0-beta/ 
* qml-material (https://github.com/papyros/qml-material)
* qml-extras (https://github.com/papyros/qml-extras)

### Instructions
* Install Qt 5.5 (https://www.qt.io)
* Install qml-material
  * git clone https://github.com/papyros/qml-material.git
  * cd qml-material
  * qmake
  * make
  * make check # Optional, make sure everything is working correctly
  * sudo make install
* Install qml-extras
  * git clone https://github.com/papyros/qml-extras.git
  * cd qml-extras
  * qmake
  * make
  * make check # Optional, make sure everything is working correctly
  * sudo make install

### Build and Run
  * git clone https://github.com/tim-sueberkrueb/material-browser.git
  * cd material-browser
  * qmake
  * make
  * run material-browser executable

## Copyright and License
(C) Copyright 2015 by Tim Süberkrüb and contributors

See CONTRIBUTORS.md for a full list of contributors.

This application is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

See LICENSE for more information.
