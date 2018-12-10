# crax-helper
Crax helper, simple as that!

# Usage

## Key generation

Keygen flag helps generating a new keystore to sign the apk with.

```bash
$ crax-helper.sh --keygen mykeystore.keystore
```

## Signing

Sign flag helps signing the modified apk.

Just give the zip file as is after alteration. It handles renaming, signing and aligning process

```bash
$ crax-helper.sh --sign mykeystore.keystore cracked.zip
```

