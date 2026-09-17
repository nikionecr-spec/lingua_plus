# راهنمای ساخت و انتشار

## پیش‌نیازها

- Flutter **3.27.4** (stable) — `flutter --version`
- Java **17** (Temurin توصیه می‌شود)
- Android SDK (فقط برای ساخت محلی؛ در CI از runner آماده استفاده می‌شود)

## ساخت با GitHub Actions (توصیه‌شده)

پوش به `main` کافی است. workflow در `.github/workflows/build.yml`:

1. **Trigger**: push به main، تگ `v*`، یا اجرای دستی (`workflow_dispatch`)
2. **Steps**: setup Java 17 + Flutter 3.27.4 (با cache) → `pub get` → `analyze` → `build apk` → `build appbundle`
3. **خروجی**:
   - Artifact به نام `lingua-plus-android` شامل `LinguaPlus-v1.0.0.apk` و `.aab` (نگهداری ۳۰ روز)
   - روی تگ `v*`: **GitHub Release** با فایل‌های APK/AAB و release notes خودکار

ساخت یک Release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## ساخت محلی

```bash
flutter pub get
flutter analyze                 # باید No issues باشد
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
flutter build appbundle --release
```

APK خروجی universal است (همه ABIها). برای خروجی کوچک‌تر per-ABI:
```bash
flutter build apk --release --split-per-abi
```

## امضا (Signing)

به‌صورت پیش‌فرض release با **debug key** امضا می‌شود (قابل نصب روی دستگاه، مناسب تست). برای انتشار در Google Play:

1. ساخت keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA \
           -keysize 2048 -validity 10000 -alias upload
   ```
2. فایل `android/key.properties` (هرگز commit نشود — در `.gitignore` است):
   ```properties
   storePassword=***
   keyPassword=***
   keyAlias=upload
   storeFile=/absolute/path/upload-keystore.jks
   ```
3. در `android/app/build.gradle` داخل `buildTypes.release`:
   ```groovy
   def keystoreProperties = new Properties()
   def keystorePropertiesFile = rootProject.file('key.properties')
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
   }
   signingConfig = signingConfigs.create {
       keyAlias keystoreProperties['keyAlias']
       keyPassword keystoreProperties['keyPassword']
       storeFile file(keystoreProperties['storeFile'])
       storePassword keystoreProperties['storePassword']
   }
   ```

برای امضا در CI، keystore را به‌صورت base64 در **GitHub Secrets** بگذارید و در workflow دیکود کنید — هرگز داخل ریپو قرار ندهید.

## نصب مستقیم APK

APK release (حتی با debug signing) قابل نصب است:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```
یا کپی روی گوشی و نصب با فعال بودن «نصب از منابع ناشناس».
