@echo off
REM This script generates a new Android release keystore
REM Credentials: storepass=milap123, keypass=milap123, alias=release-key

cd /d "%~dp0app"

keytool -genkey -v -keystore release-keystore.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 ^
  -alias release-key ^
  -storepass milap123 ^
  -keypass milap123 ^
  -dname "CN=Milap App, OU=Development, O=Milap, L=India, S=State, C=IN"

echo.
echo Keystore generated successfully!
echo.
pause
