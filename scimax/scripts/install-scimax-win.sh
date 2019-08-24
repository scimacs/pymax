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
    echo 'Error: curl is not installed. Maybe install MSYS2 from http://www.msys2.org/.' >&2
    # http://repo.msys2.org/distrib/x86_64/msys2-x86_64-20190524.exe
  exit 1
fi

# Get an emacs
if [ ! -e "c:/Program Files/7-Zip/7z.exe" ]; then
    echo 'Error: 7-zip not found.' >&2
    exit 1
fi

if [ ! -e "emax64.7z" ]; then
    curl -L -s https://github.com/m-parashar/emax64/releases/download/emax64-26.2-20190417/emax64-bin-26.2.7z --output emax64.7z
    "c:/Program Files/7-Zip/7z.exe" x emax64.7z
fi

# These are utilities we need
if [ ! -d "emax" ]; then
    curl -L -s https://github.com/m-parashar/emax64/releases/download/emax64-26.2-20190417/emax.7z --output emax.7z
    "c:/Program Files/7-Zip/7z.exe" x emax.7z
fi

if [ ! -d "wkhtmltox" ]; then
    curl -L -s https://downloads.wkhtmltopdf.org/0.12/0.12.5/wkhtmltox-0.12.5-1.mxe-cross-win64.7z --output wkhtmltox.7z
    "c:/Program Files/7-Zip/7z.exe" x wkhtmltox.7z
fi

if [ ! -d "sox-14.4.2" ]; then
    echo "Getting sox"
    curl -L -s https://sourceforge.net/projects/sox/files/sox/14.4.2/sox-14.4.2-win32.zip/download --output sox-14.4.2-win32.zip
    unzip sox-14.4.2-win32.zip
fi


if [ -d "pandoc-2.7.3-windows-x86_64" ]; then
    curl -L -s https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-windows-x86_64.zip --output pandoc-2.7.3-windows-x86_64.zip
    unzip pandoc-2.7.3-windows-x86_64.zip
fi

# Now clone scimax
if [ ! -d "scimax" ]; then
    echo "Cloning the scimax elisp repo"
    git clone https://github.com/jkitchin/scimax.git
fi

# and the elpa
if [ ! -d "scimax/elpa" ]; then
    echo "Cloning the initial elpa repo"
    # might consider getting the zip file instead so this won't be under version control
    git clone https://github.com/scimacs/scimacs-elpa.git scimax/elpa
fi

if [ ! -e "pdf-tools.7z" ]; then
    curl -L -s https://github.com/m-parashar/emax64/releases/download/emax64-26.2-20190417/pdf-tools-20190413.2018.7z --output pdf-tools.7z
    "c:/Program Files/7-Zip/7z.exe" x pdf-tools.7z
    mv pdf-tools-20190413.2018 scimax/elpa
fi

# TODO: what to do about auctex. It is a little tricky to get
# compiled. I am not sure it can be scripted easily. I had to install
# a bunch of things like autoconf and git in msys2 to eventually get
# it built. and even then it didn't work... It seems to work fine
# installing from elpa though.

echo "Creating scimax.sh. You can move this script to any convenient location or run it from here."
cat <<EOF > scimax.sh
#!/bin/bash
export PATH=\$PATH:`pwd`/emax/bin/
export PATH=\$PATH:`pwd`/emax/bin64/
export PATH=\$PATH:`pwd`/emax/mingw64/bin/
export PATH=\$PATH:`pwd`/emax64/bin/
export PATH=\$PATH:`pwd`/wkhtmltox/bin/
export PATH=\$PATH:`pwd`/sox-14.4.2/
export PATH=\$PATH:`pwd`/pandoc-2.7.3-windows-x86_64
`pwd`/emax64/bin/runemacs.exe -q -l `pwd`/scimax/init.el
EOF

# we need to byte-compile the elpa dir
echo "Opening scimax to byte-compile the elisp files. This takes a while."
echo "You may get prompted to kill an elpa process. Type no."
echo "You will be prompted to install some binary files for emacs-jupyter."
echo "You should type y for yes for these."
./scimax.sh --eval "(byte-recompile-directory \"${pwd}scimax/elpa\" 0 t)"
