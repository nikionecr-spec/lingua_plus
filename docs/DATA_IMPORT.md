# ایمپورت داده دیکشنری

دو مسیر برای داده دیکشنری Lingua+ وجود دارد.

## ۱) دیتاست Seed (باندل‌شده)

`assets/data/dictionary.json` — حدود ۳٬۴۳۰ واژه پرکاربرد که از سه منبع باز ساخته شده:

| منبع | چه چیزی می‌دهد |
|---|---|
| واژگان کیوریت‌شده (`scripts/data_work/vocab_*.txt`) | واژه + نقش دستوری + معنی فارسی |
| [ipa-dict](https://github.com/open-dict-data/ipa-dict) | IPA بریتیش (en_UK) و آمریکایی (en_US) |
| [wordfreq](https://github.com/rspeer/wordfreq) | رتبه فرکانس و سطح CEFR |

ساخت مجدد:
```bash
pip install wordfreq
python3 scripts/build_dictionary.py
```

باند CEFR بر اساس رتبه فرکانس:
`≤300 → A1` ، `≤800 → A2` ، `≤1600 → B1` ، `≤3000 → B2` ، `≤5000 → C1` ، `بقیه → C2`

## ۲) ایمپورت کامل از Kaikki (Wiktionary)

برای دیکشنری کامل (ده‌ها هزار واژه با معانی، مثال‌ها، مترادف/متضاد واقعی):

### گام ۱ — دانلود داده
فایل انگلیسی Kaikki را بگیرید (~۲GB):
```
https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl
```

### گام ۲ — تبدیل
```bash
python3 scripts/import_kaikki.py \
    --input ~/Downloads/kaikki.org-dictionary-English.jsonl \
    --output assets/data/dictionary_full.json \
    --max-words 50000
```

گزینه‌ها:
- `--max-words N` — سقف تعداد واژه‌ها (مرتب‌شده بر اساس فرکانس)
- `--keep-en` — واژه‌هایی که ترجمه فارسی ندارند را با gloss انگلیسی نگه دار

خروجی دقیقاً همان فرمت `dictionary.json` است (سازگار با `mappers.dart`) و فیلد `source` روی `kaikki` تنظیم می‌شود.

### گام ۳ — بارگذاری در اپ
دو راه:

**الف) جایگزینی seed:** فایل خروجی را روی `assets/data/dictionary.json` کپی کنید و اپ را rebuild کنید — در اولین اجرا (یا بعد از پاک کردن دیتای اپ) seed جدید ایمپورت می‌شود.

**ب) asset دوم + کد:** `dictionary_full.json` را به `pubspec.yaml` اضافه کنید و در bootstrap:
```dart
final jsonText = await rootBundle.loadString('assets/data/dictionary_full.json');
await IsarDatabase.seedDictionary(isar, jsonText);
```

### ساختار Entry (مرجع)
```json
{
  "word": "book",
  "display": "book",
  "pos": "noun",
  "meanings": [{"pos": "noun", "definitions": ["کتاب"]}],
  "examples": [{"en": "The book is very important here.", "fa": "اینجا کتاب خیلی مهم است."}],
  "synonyms": [], "antonyms": [],
  "ipaUs": "ˈbʊk", "ipaUk": "bˈʊk",
  "level": "A2", "rank": 353,
  "source": "seed"
}
```

> نکته: فیلد `rank` (۱ = پرکاربردترین) برای مرتب‌سازی نتایج جستجو و انتخاب واژه روز استفاده می‌شود؛ واژه‌های خارج از top-8000 مقدار `999999` می‌گیرند.
