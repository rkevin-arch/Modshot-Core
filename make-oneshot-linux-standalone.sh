#!/bin/sh
set -e

cd `dirname $0`

# User-configurable variables.
linux_version="0.1.0"
make_threads=8
ONESHOT_PATH=/work/build

# Colors.
white="\033[0;37m"      # White - Regular
bold="\033[1;37m"       # White - Bold
cyan="\033[1;36m"       # Cyan - Bold
green="\033[1;32m"      # Green - Bold
color_reset="\033[0m"   # Reset Colors

echo -e "${white}Compiling ${bold}SyngleChance v${linux_version} ${white}engine for Linux...${color_reset}\n"

# Generate makefile.
echo -e "-> ${cyan}Generate makefile...${color_reset}"
export MRIVERSION=$(echo "puts RUBY_VERSION.split('.').slice(0, 2).join('.')" | ruby)
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
qmake mkxp.pro > oneshot.qmake.out

# this is horrible, but making the linker use runpath instead of rpath will screw things up due to ld preferring user libraries
sed -i 's/-Wl,-rpath,\/usr\/local\/lib //g' Makefile
sed -i 's/-Wl,--enable-new-dtags /-Wl,--disable-new-dtags /g' Makefile

# Compile OneShot.
echo -e "-> ${cyan}Compile engine...${color_reset}"
make -j${make_threads} > oneshot.make.out

# Compile Journal.
# TODO: get this working
# echo -e "-> ${cyan}Compile journal...${color_reset}"
# pyinstaller journal/unix/journal.spec --windowed

# Compile scripts.
echo -e "-> ${cyan}Compile xScripts.rxdata...${color_reset}"
ruby rpgscript.rb ./scripts "$ONESHOT_PATH" > rpgscript.out

# Copy results.
echo -e "-> ${cyan}Install OneShot apps to Steam directory...${color_reset}"
# No journal, so don't copy it over
# yes | cp -r dist/_______/* "$ONESHOT_PATH"
yes | cp oneshot "$ONESHOT_PATH"

# Copy libraries.
echo -e "-> ${cyan}Copying files to output folder...${color_reset}"
mkdir libs
ldd oneshot | ruby libraries.rb
yes | cp libs/* "$ONESHOT_PATH"

# Cleanup.
# No need for cleanup, this is a throwaway docker container anyway

echo -e "\n${green}Complete!  ${white}Please report any issues to https://github.com/GooborgStudios/synglechance/issues${color_reset}"
