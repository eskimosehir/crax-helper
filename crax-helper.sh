#! /bin/bash

# This script is written by Riza DOGAN on 10 Dec 2018 for MobGe TM

# Keygen flag helps generating a new keystore to sign the apk with.
# Example : crax-helper.sh --keygen mykeystore

# Sign flag helps signing the fresh created(cracked, hehe) apk.
# Just give the zip file as is after alteration. It handles renaming, signing and aligning process
# Example : crax-helper.sh --sign mykeystore.keystore cracked.zip

# Install flag helps easy install.
# Example : crax-helper.sh --install cracked.apk

case "$1" in
	--keygen)
		# Generate key with following parameters
		keytool -genkey -v -keystore "$2".keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000
		;;
	--sign)
		FILENAME="$3"
		ZIPNAME=${FILENAME%.*} # Get the prefix of the file
		mv "$ZIPNAME"".zip" "$ZIPNAME".apk # Rename file to zip suffix

		# Sign apk with the key.
		jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$2" "$ZIPNAME".apk alias_name
		
		# Align the apk.
		zipalign -v 4 "$ZIPNAME".apk "$ZIPNAME"-aligned.apk
        ;;
    --install)
		adb devices
		adb uninstall com.mobge.Oddmar
		adb install "$2"
		;;
	*)
        echo "Usage: $0 --keygen [KEYNAME]"
        printf "\t$0 --sign [KEYNAME] [ZIPFILE]\n"
        printf "\t$0 --install [APKFILE]\n"
        exit 1
esac

exit 0
