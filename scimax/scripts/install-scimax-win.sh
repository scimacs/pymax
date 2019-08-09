#!/bin/bash

if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  exit 1
fi

# Setup git.
[[ -z `git config --global user.name` ]] && read -p "Full name: " name && git config --global user.name "$name"
[[ -z `git config --global user.email` ]] && read -p "Email: " email && git config --global user.email $email

# We do everthing where you run the command
if ! [ -x "$(command -v curl)" ]; then
  echo 'Error: curl is not installed. Maybe installMinGW from  http://www.mingw.org/.' >&2
  exit 1
fi

# Get an emacs
if [ ! -e "c:/Program Files/7-Zip/7z.exe" ]; then
       echo 'Error: 7-zip not found.' >&2
       exit 1
fi

if [ ! -e "emax64.7z" ]; then    
    curl -L -s https://github.com/m-parashar/emax64/releases/download/emax64-26.2-20190417/emax64-bin-26.2.7z --output emax64.7z
fi

if [ ! -d "emax64" ]; then
    "c:/Program Files/7-Zip/7z.exe" x emax64.7z
fi

# Now clone scimax
if [ ! -d "scimax" ]; then
    git clone https://github.com/jkitchin/scimax.git
fi

# and the elpa
if [ ! -d "scimax/elpa" ]; then
    # might consider getting the zip file instead so this won't be under version control
    git clone https://github.com/scimacs/scimacs-elpa.git scimax/elpa
fi

# we need to byte-compile the elpa dir
emax64/bin/emacs.exe -q -l scimax/init.el --eval "(byte-recompile-directory \"${pwd}scimax/elpa\" 0 t)"
