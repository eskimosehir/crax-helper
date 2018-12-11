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

useJarSigner(){
    if [[ -n $(which jarsigner) ]]; then
        echo "[$FINE] jarsigner found, signing..."
        jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$KEYSTORE" "$FILENAME".apk alias_name
    else
        printCantFindToolError jarsigner
    fi
}

useApkSigner(){
    if [[ -n $(which jarsigner) ]]; then
        echo "[$FINE] apksigner found, signing..."
        apksigner sign --ks "$KEYSTORE" "$FILENAME".apk
    else
        printCantFindToolError apksigner
    fi
}

useZipAlign(){
    if [[ -n $(which zipalign) ]]; then
        echo "[$FINE] zipalign found, aligning the apk..."
        zipalign -v 4 "$FILENAME".apk "$FILENAME"-aligned.apk
    else
        printCantFindToolError zipalign
    fi
}

useKeyTool(){
    if [[ -n $(which keytool) ]]; then
        echo "[$FINE] keytool found, generating new keystore."
        [[ -z "$FILENAME" ]] && echo "[$INFO] Warning! keystore name is empty.";
        # Generate key with following parameters
        keytool -genkey -v -keystore "$FILENAME".keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
    else
        printCantFindToolError keytool
    fi
}

printCantFindToolError(){
    echo "[$BAD] Could not find $1."
    echo "[$WHAT] Make sure $1 is installed and the install path is added to the PATH."
    exit 1
}

askUserForWhichSignTool(){
    echo "[$INFO] For jarsigner enter js or jarsigner"
    echo "[$INFO] For apksigner enter as or apksigner"
    printf "[$WHAT] Enter which signing tool you want to use: "
    read -r SIGNINGTOOL
}



case "$1" in
    --keygen)
        FILENAME="$2"
        useKeyTool
        ;;
    --sign)
        KEYSTORE="$2"
        ZIPFILE="$3"
        FILENAME=${ZIPFILE%.*} # Get the prefix of the file
        if [ ! -f "$ZIPFILE" ]; then
            echo "[$BAD] $ZIPFILE not found!"
            exit 1
        else
            cp "$FILENAME".zip "$FILENAME".apk # Rename file suffix from zip to apk
        fi
        
        askUserForWhichSignTool
        case "$SIGNINGTOOL" in
            --jarsigner | -jarsigner | jarsigner | -js | js)
                useJarSigner
                useZipAlign
                ;;

            --apksigner | -apksigner | apksigner | -as | as)
                useZipAlign
                useApkSigner
                ;;
            *)
                echo "[$BAD] Please give correct input."
                echo "[$INFO] To utilize jarsigner enter: jarsigner or the short form: js"
                echo "[$INFO] To uilize apksigner enter: apksigner or the short form: as"
                exit 1
        esac
        ;;
    --install)
        if [[ -n $(which adb) ]]; then
            echo "[$FINE] adb found, installing the apk..."
            adb devices
            adb uninstall com.mobge.Oddmar
            adb install "$2"
        else
            printCantFindToolError adb
        fi
        ;;
    *)
        printf "[$INFO] Usage:\t$0 --keygen [KEYNAME]\n"
        printf "\t\t$0 --sign [KEYNAME] [ZIPFILE]\n"
        printf "\t\t$0 --install [APKFILE]\n"
        exit 1
esac

exit 0