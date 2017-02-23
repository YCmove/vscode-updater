#!/bin/bash
##################################################
# Name: update.sh
# Description: update vscode in linux
# Fork from @moeenz/vscode-updater
# Script Maintainer: YCmove
#
# Last Updated: Feb 23th 2017
#
# TODO:
# hide code -v information
# find the better way to check if the vscode was installed or not.
##################################################
# 

OS=$(lsb_release -si);
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DIST="";
VSCODE_VERSION="";

checkOS(){
    if [ "$OS" = "Ubuntu" ] || [ "$OS" = "Debian" ]; then
        DIST="deb";
    elif [ "$OS" = "Fedora" ] || [ "$OS" = "Red Hat" ] || [ "$OS" = "Red hat" ]; then
        DIST="rpm";
    else
        echo "Unfortunately your operating system is not supported in distributed packages.";
        exit;
    fi

    URLBASE="https://vscode-update.azurewebsites.net/latest/linux-${DIST}-x64/stable";
    FILENAME="$DIR/latest.${DIST}";
}

checkLocal(){
    code -v
    EXITCODE=$?
    if [ $EXITCODE != 0 ] ; then
        return $EXITCODE
    else
        VSCODE_VERSION="$(code -v | head -1)"
    fi
}

isLatest(){
    wget --spider --output-file=wget.log $URLBASE;

    if grep -q ${VSCODE_VERSION} wget.log; then
        echo "You already have the latest version - ${VSCODE_VERSION}"
        exit;
    fi
}

removeLastDownload(){
    if test -e "$FILENAME"; then
        rm $FILENAME;
        echo "Removed last downloaded version.";
    else
        echo "{$FILENAME} not exist"
    fi
}

downloadLatest(){
    echo "Downloading latest version of vscode is starting...";
    wget --show-progress -O $FILENAME $URLBASE;
    printf "Downloading finished.\n\n";

    echo "Closing vscode...";
    for pid in $(pidof code); do kill -9 $pid; done
    echo "vscode instance(s) closed.";
}

installLatest(){
    echo "Installing latest version...";
    if [ "$DIST" = "deb" ]; then
        sudo dpkg -i $FILENAME;
    else
        sudo rpm -i $FILENAME;
    fi
    echo "Installation finished.";
}

startVscode(){
    echo "Starting new version of vscode...";
    code . &
    exit;
}

checkOS
checkLocal
checkLocalExit=$?

if [ $checkLocalExit == 0 ]; then
    isLatest
    removeLastDownload
fi
    downloadLatest
    installLatest
    startVscode

