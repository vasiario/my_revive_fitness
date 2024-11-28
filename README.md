# my_revive_fitness

## Getting Started
Note: These instructions are for building a release version of your Flutter app for publishing on the Android Store (Google Play Store).
1. Check for Existing Keystore and Key
   Ensure you have the following files:

Keystore (key.jks): Contains your app's signing key.
keystore.properties: Holds configurations and passwords for signing.
If these files already exist in your project, you can skip to Step 3.

2. Generate a Keystore and Key (if necessary)
   Skip this step if you already have key.jks.

Open a terminal in the root directory of your Flutter project.

Run the following command to generate a new keystore:

keytool -genkeypair -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
You'll be prompted to enter a keystore password, key password (can be the same), and some personal information.
Move the generated key.jks file to the android/app directory:

mv key.jks android/app/
3. Create or Update keystore.properties
   Check if the keystore.properties file exists in the android directory:

If it exists, ensure it contains the correct information.

If not, create it:

touch android/keystore.properties
Open android/keystore.properties and add or update the following:

properties
storePassword=your_keystore_password
keyPassword=your_key_password
keyAlias=key
storeFile=key.jks
Replace your_keystore_password and your_key_password with the passwords you set during keystore creation.
Add keystore.properties to .gitignore to prevent sensitive data from being committed:

Open .gitignore in the root of your project.

Add:
/android/keystore.properties

Clean the project:
flutter clean

Get dependencies:
flutter pub get

The generated file will be located at:
flutter build appbundle --release