OS=$(lsb_release -si);
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";
DIST="";
VSCODE_VERSION="$(code -v | head -1)"

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

# check latest version 
wget --spider --output-file=wget.log $URLBASE;

if grep -q ${VSCODE_VERSION} wget.log; then
    echo "You already have the latest version - ${VSCODE_VERSION}"
    exit;
fi


if test -e "$FILENAME"; then
    rm $FILENAME;
    echo "Removed last downloaded version.";
else
    echo "{$FILENAME} not exist"
fi

echo "Downloading latest version of vscode is starting...";
wget --show-progress -O $FILENAME $URLBASE;
printf "Downloading finished.\n\n";

echo "Closing vscode...";
for pid in $(pidof code); do kill -9 $pid; done
echo "vscode instance(s) closed.";

echo "Installing latest version...";
if [ "$DIST" = "deb" ]; then
    sudo dpkg -i $FILENAME;
else
    sudo rpm -i $FILENAME;
fi
echo "Installation finished.";

echo "Starting new version of vscode...";
code . &
exit;
