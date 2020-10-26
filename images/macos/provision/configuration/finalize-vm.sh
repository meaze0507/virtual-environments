#!/bin/bash -e -o pipefail

source ~/utils/utils.sh

# Close all finder windows because they can interfere with UI tests
osascript -e 'tell application "Finder" to close windows'

if is_Less_BigSur; then
    # Ignore available updates to prevent system pop-ups
    updateName=$(softwareupdate -l | grep "Title: " | awk -F[:,] '{print $2}' | awk '{$1=$1};1') || true
    if [ ! -z "$updateName" ]; then
        sudo softwareupdate --ignore "$updateName"
    fi
fi

# Put documentation to $HOME root
cp $HOME/image-generation/output/software-report/systeminfo.txt $HOME/image-generation/output/software-report/systeminfo.md $HOME/

# Put build vm assets scripts to proper directory
sudo mkdir -p /usr/local/opt/$USER/scripts
sudo chmod ugo+rwx /usr/local/opt/$USER/scripts
sudo chown $USER:admin /usr/local/opt/$USER
mv $HOME/image-generation/assets/* /usr/local/opt/$USER/scripts

find /usr/local/opt/$USER/scripts -type f -name "*\.sh" -exec chmod +x {} \;

# Clean up npm cache which collected during image-generation
# we have to do that here because `npm install` is run in a few different places during image-generation
npm cache clean --force

# Clean up temporary directories
rm -rf ~/utils ~/image-generation