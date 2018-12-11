#! /bin/bash

# This script is written by Riza DOGAN on 10 Dec 2018 for MobGe TM

# Keygen flag helps generating a new keystore to sign the apk with.
# Example : crax-helper.sh --keygen mykeystore

# Sign flag helps signing the fresh created(cracked, hehe) apk.
# Just give the zip file as is after alteration. It handles renaming, signing and aligning process
# Example : crax-helper.sh --sign mykeystore.keystore cracked.zip

# Install flag helps easy install.
# Example : crax-helper.sh --install cracked.apk

# Do not change these variables, related to verbose info messages.
NORMAL=$(tput sgr0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
FINE=${GREEN}+${NORMAL}
BAD=${RED}-${NORMAL}
WHAT=${YELLOW}\?${NORMAL}
INFO=${YELLOW}\*${NORMAL}


case "$1" in
    --keygen)
        if [[ -n $(which keytool) ]]; then
            echo "[$FINE] keytool found, generating new keystore."
            # Generate key with following parameters
            keytool -genkey -v -keystore "$2".keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
        else
            echo "[$BAD] Could not find keytool."
            echo "[$WHAT] Make sure keytool is installed and the install path is added to the PATH."
        fi
        ;;
    --sign)
        FILENAME="$3"
        ZIPNAME=${FILENAME%.*} # Get the prefix of the file
        if [ ! -f "$ZIPNAME.zip" ]; then
            echo "[$BAD] $ZIPNAME.zip not found!\n"
            exit 1
        else
            mv "$ZIPNAME"".zip" "$ZIPNAME".apk # Rename file suffix from zip to apk
        fi
        
        echo "[$WHAT] Which signing tool do you want to use: jarsigner or apksigner."
        echo "[$INFO] For jarsigner enter js or jarsigner"
        echo "[$INFO] For apksigner enter as or apksigner"
        read -r SIGNINGTOOL

        case "$SIGNINGTOOL" in
            --jarsigner | -jarsigner | jarsigner | -js | js)
                if [[ -n $(which jarsigner) ]]; then
                    echo "[$FINE] jarsigner found, signing..."
                    jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$2" "$ZIPNAME".apk alias_name
                else
                    echo "[$BAD] Could not find jarsigner."
                    echo "[$WHAT] Make sure jarsigner is installed and the install path is added to the PATH."
                    exit 1
                fi

            --apksigner | -apksigner | apksigner | -as | as)
                if [[ -n $(which jarsigner) ]]; then
                    echo "[$FINE] apksigner found, signing..."
                    apksigner sign --ks "$2" "$ZIPNAME".apk
                else
                    echo "[$BAD] Could not find apksigner."
                    echo "[$WHAT] Make sure apksigner is installed and the install path is added to the PATH."
                    exit 1
                fi
            *)
                echo "[$BAD] Please give correct input."
                echo "[$INFO] To utilize jarsigner enter: jarsigner or the short form js"
                echo "[$INFO] To uilize apksigner enter: apksigner or the short form as"
                exit 1
                
        if [[ -n $(which zipalign) ]]; then
            echo "[$FINE] zipalign found, aligning the apk..."
            zipalign -v 4 "$ZIPNAME".apk "$ZIPNAME"-aligned.apk
        else
            echo "[$BAD] Could not find zipalign."
            echo "[$WHAT] Make sure zipalign is installed and the install path is added to the PATH."
            exit 1
        fi
        ;;
    --install)
        if [[ -n $(which adb) ]]; then
            echo "[$FINE] adb found, installing the apk..."
            adb devices
            adb uninstall com.mobge.Oddmar
            adb install "$2"
        else
            echo "[$BAD] Could not find adb."
            echo "[$WHAT] Make sure adb is installed and the install path is added to the PATH."
            exit 1
        fi
        ;;
    *)
        echo "[$INFO] Usage: $0 --keygen [KEYNAME]"
        printf "\t$0 --sign [KEYNAME] [ZIPFILE]\n"
        printf "\t$0 --install [APKFILE]\n"
        exit 1
esac

exit 0

