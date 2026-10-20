#!/bin/sh
# Builds boot-rearm.apk with plain SDK tools (no Gradle). Needs: a JDK 17, Android build-tools (d8/aapt2/zipalign/apksigner),
# platforms/android-3x/android.jar, and the jars in libs/ (dadb 2.0.0, okio 2.10.0, kotlin-stdlib 1.9.20 + jdk7/jdk8).
set -e
cd "$(dirname "$0")"
SDK="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"
BT="${BUILD_TOOLS:-$(ls -d "$SDK"/build-tools/* | sort -V | tail -1)}"
PLATFORM="${ANDROID_JAR:-$(ls -d "$SDK"/platforms/android-* | sort -V | tail -1)/android.jar}"
JAVA_HOME="${JAVA_HOME:-$(ls -d "$HOME"/.gradle/jdks/*/*/Contents/Home 2>/dev/null | head -1)}"
KS="${KEYSTORE:-debug.keystore}"; KS_PASS="${KEYSTORE_PASS:-android}"; KS_ALIAS="${KEYSTORE_ALIAS:-tvrearm}"
echo "java=$JAVA_HOME build-tools=$BT platform=$PLATFORM"
rm -rf build && mkdir -p build/classes build/dex
CP=$(ls libs/*.jar | tr '\n' ':')
"$JAVA_HOME/bin/javac" -source 1.8 -target 1.8 -nowarn -encoding UTF-8 -cp "$PLATFORM:$CP" -d build/classes $(find src -name '*.java')
"$BT/d8" --release --min-api 31 --lib "$PLATFORM" --output build/dex $(find build/classes -name '*.class') libs/*.jar
"$BT/aapt2" compile --dir res -o build/res.zip
"$BT/aapt2" link -o build/unsigned.apk -I "$PLATFORM" --manifest AndroidManifest.xml -R build/res.zip --min-sdk-version 31 --target-sdk-version 31 --auto-add-overlay
(cd build/dex && zip -q -u ../unsigned.apk classes*.dex)
"$BT/zipalign" -f -p 4 build/unsigned.apk build/aligned.apk
[ -f "$KS" ] || "$JAVA_HOME/bin/keytool" -genkeypair -keystore "$KS" -storepass "$KS_PASS" -keypass "$KS_PASS" -alias "$KS_ALIAS" -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=TV Rearm" >/dev/null 2>&1
"$BT/apksigner" sign --ks "$KS" --ks-pass "pass:$KS_PASS" --key-pass "pass:$KS_PASS" --ks-key-alias "$KS_ALIAS" --out boot-rearm.apk build/aligned.apk
"$BT/apksigner" verify --print-certs boot-rearm.apk | head -2
ls -la boot-rearm.apk
