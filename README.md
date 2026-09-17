# Lingua+

**دیکشنری، کتابخانه دوزبانه، مترجم هوشمند و یادگیری انگلیسی — همه در یک اپ فارسی‌محور.**

Lingua+ یک اپلیکیشن آموزش زبان انگلیسی با رابط فارسی (RTL-first) است که با Flutter ساخته شده و طراحی آن در سطح محصولات پرمیوم مثل Duolingo و ELSA است: پالت سرمه‌ای شبانه، گرادیان آبی→بنفش، Material Design 3 و فونت‌های Vazirmatn/Poppins.

## ✨ امکانات

### 📖 دیکشنری آفلاین
- بیش از **۳٬۴۰۰ واژه** با تلفظ IPA بریتیش و آمریکایی
- معنی فارسی، مثال‌های دوزبانه، سطح‌بندی CEFR (A1…C2)
- موتور جستجوی ۴ مرحله‌ای (دقیق → پیشوند → شامل → جستجوی فارسی)
- علاقه‌مندی‌ها، تاریخچه جستجو و واژه روز
- **کاملاً آفلاین** — دیتابیس Isar روی خود دستگاه

### 📚 کتابخانه دوزبانه
- ۶ کتاب: داستان‌های کوتاه، درس‌های گرامر (حال/گذشته ساده) و واژگان موضوعی
- خواننده صفحه‌ای با ذخیره خودکار محل مطالعه
- نشانک‌گذاری، تغییر اندازه فونت، خواندن با TTS
- ترجمه فارسی سطر‌به‌سطر متن انگلیسی

### 🌐 مترجم آنلاین
- ترجمه با APIهای **رایگان بدون کلید** (MyMemory → LibreTranslate fallback)
- تشخیص خودکار زبان (فارسی/انگلیسی)
- گفتار‌به‌متن (میکروفن) و متن‌به‌گفتار
- کپی و اشتراک‌گذاری سریع

### 🧠 یادگیری هوشمند
- فلش‌کارت با **مرور فاصله‌دار جعبه لایتنر** (۶ باکس)
- آزمون واژگان چهارگزینه‌ای با امتیازدهی
- XP، روزهای پیاپی (Streak)، نشان‌ها و چالش روزانه
- واژه روز با تلفظ

## 🏗 معماری و فناوری

| لایه | فناوری |
|---|---|
| فریم‌ورک | Flutter 3.27.4 • Dart 3.6 • Material 3 |
| مدیریت حالت | Riverpod 2.x |
| ناوبری | GoRouter 14 (`StatefulShellRoute.indexedStack`) |
| دیتابیس | Isar 3.1 (آفلاین، ایندکس‌دار) |
| شبکه | Dio (مترجم) |
| مدل‌ها | Freezed (entities) + Isar Generator |
| ساختار | Feature-first: `lib/features/{dictionary,library,translator,learning,home,onboarding,settings}` |

```
lib/
├── main.dart                 # bootstrap: Isar + seed + router + ProviderScope
├── core/                     # theme, strings, errors, providers, router
├── data/
│   ├── models/               # WordRow, FavoriteWord, FlashcardState, ...
│   ├── datasources/
│   │   ├── local/            # Isar DB, dictionary/learning/library DS
│   │   └── remote/           # TranslatorRemoteDs (MyMemory→Libre)
│   └── ...                   # mappers
├── domain/entities/          # WordEntity (freezed)
└── features/                 # UI + providers هر بخش
```

## 🚀 ساخت

### با GitHub Actions (توصیه‌شده)
پوش به `main` → اکشن **Android Build & Release** به‌طور خودکار:
1. `flutter pub get` → `flutter analyze`
2. `flutter build apk --release` + `flutter build appbundle --release`
3. آپلود Artifact (APK + AAB) — روی تگ `v*` علاوه بر آن **GitHub Release** ساخته می‌شود.

### ساخت محلی
```bash
flutter pub get
flutter build apk --release      # خروجی: build/app/outputs/flutter-apk/
flutter build appbundle --release
```
> جزئیات امضا و انتشار: [docs/BUILD.md](docs/BUILD.md)

## 📦 داده دیکشنری

- دیتاست seed باندل‌شده: `assets/data/dictionary.json` (از منابع باز: Wiktionary/Kaikki، ipa-dict، wordfreq)
- توسعه به دیکشنری کامل (ده‌ها هزار واژه):
  ```bash
  python3 scripts/import_kaikki.py --input kaikki.org-dictionary-English.jsonl \
      --output assets/data/dictionary_full.json --max-words 50000
  ```
- جزئیات: [docs/DATA_IMPORT.md](docs/DATA_IMPORT.md)

## 🔒 امنیت

- هیچ Secret یا API key در سورس وجود ندارد (مترجم از APIهای بدون‌کلید استفاده می‌کند).
- Keystore امضا هرگز commit نمی‌شود (به `.gitignore` اضافه شده).
- راهنما: [docs/SECURITY.md](docs/SECURITY.md)

## 🗺 نقشه راه

- [ ] ایمپورت کامل Kaikki داخل خود اپ (انتخاب فایل + پس‌زمینه)
- [ ] نسخه iOS
- [ ] سینک ابری اختیاری پیشرفت یادگیری
- [ ] گیمیفیکیشن بیشتر (لیگ‌ها و مسابقات)

## مجوزها

کد: MIT — داده‌های دیکشنری: مطابق مجوز منابع باز (Wiktionary CC-BY-SA، ipa-dict، wordfreq).
