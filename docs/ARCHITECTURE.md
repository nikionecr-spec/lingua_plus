# معماری Lingua+

## نمای کلی

Lingua+ با معماری **Feature-first** و الگوی سه‌لایه ساخته شده است. هر ویژگی (dictionary / library / translator / learning / home / onboarding / settings) یک پوشه مستقل در `lib/features/` است که شامل صفحات و providers خودش می‌شود. لایه‌های data و domain مشترک هستند و از طریق Riverpod تزریق می‌شوند.

```
┌─────────────────────────────────────────────┐
│  UI (features/*)  ConsumerWidget            │
│      │ watch/read                           │
│  Providers (core/providers.dart + feature)  │
│      │                                      │
│  DataSources                                │
│   ├── local:  Isar (dictionary/SRS/library) │
│   └── remote: TranslatorRemoteDs (Dio)      │
└─────────────────────────────────────────────┘
```

## جریان Bootstrap (main.dart)

1. `SharedPreferences.getInstance()`
2. `IsarDatabase.open()` — باز کردن دیتابیس در مسیر Documents
3. اگر خالی باشد: seed از `assets/data/dictionary.json` (chunked 500 رکورد)
4. `buildAppRouter(sp:)` — مسیر اولیه بر اساس فلگ `onboarded`
5. `ProviderScope` با override سه provider اصلی (isar / sharedPrefs / router)
6. `Directionality.rtl` سراسری + `GradientBackground`

## موتور جستجوی دیکشنری (۴ مرحله‌ای)

`DictionaryLocalDs.search()` نتایج را مرحله‌به‌مرحله کامل می‌کند:

| مرحله | مکانیزم | ایندکس |
|---|---|---|
| ۱. دقیق | `wordEqualTo` (کلمات lowercase ذخیره می‌شوند) | ✅ indexed |
| ۲. پیشوند | `wordStartsWith` + مرتب‌سازی rank | ✅ indexed |
| ۳. شامل | `filter().wordContains` | scan |
| ۴. فارسی | `searchTextContains` روی متن denormalize‌شده (word + معانی + مترادف‌ها) | scan |

نتایج با id دی‌دوپلیکیت و با سقف `limit` برمی‌گردند.

## سیستم یادگیری (SRS)

- **جعبه لایتنر**: باکس ۱ تا ۶؛ فواصل `[0, 1, 2, 4, 8, 16]` روز
- پاسخ درست → باکس +۱؛ اشتباه → بازگشت به باکس ۱
- `dueAt` = اکنون + فاصله باکس (epoch ms)
- واژه «یادگرفته‌شده» = باکس ≥ ۴
- XP: مرور درست +۱۰، اشتباه +۲، پاسخ درست آزمون +۱۵
- Streak روزانه با کلید `yyyymmdd` در `UserProfile.lastActiveDay`
- نشان‌ها بر اساس XP (`first_step/spark/rising/master`)، واژه‌های یادگرفته (`scholar`) و Streak (`on_fire/unstoppable`)

## مدل‌های Isar

| کلاس | نقش | نکته |
|---|---|---|
| `WordRow` | رکورد دیکشنری | `word` lowercase ایندکس‌دار؛ `searchText` برای جستجوی فارسی |
| `FavoriteWord` | ستاره‌ها | `unique(replace)` روی word |
| `SearchLog` | تاریخچه | `unique(replace)` روی query |
| `FlashcardState` | وضعیت SRS | `unique(replace)` روی word |
| `UserProfile` | XP/Streak/Badges | سینگلتون `id = 1` |
| `Bookmark` / `ReadingState` | کتابخانه | نشانک per-page؛ ReadingState per-book |

## مترجم

`TranslatorRemoteDs` با زنجیره fallback:
1. **MyMemory** `GET api.mymemory.translated.net/get?q=&langpair=en|fa`
2. **LibreTranslate** mirrors (`translate.argosopentech.com`، `libretranslate.de`) با POST JSON
3. تشخیص زبان به‌صورت local (رنج یونیکد 0600–06FF → فارسی) — بدون round-trip

هیچ کلید API لازم نیست و چیزی در سورس هاردکد نشده است.

## ناوبری

`StatefulShellRoute.indexedStack` با ۵ شاخه (home/dictionary/library/translator/learning) — هر شاخه Navigator خودش را حفظ می‌کند. مسیرهای full-screen (word detail، reader، favorites، flashcards، quiz، settings، onboarding) بیرون شِل قرار دارند.

## Codegen

- Freezed برای entities (`word_entity.freezed.dart`)
- isar_generator برای کالکشن‌ها (`*.g.dart`)
- **فایل‌های تولیدشده در ریپو commit می‌شوند** تا CI بدون `build_runner` بیلد کند (سرعت + قطعیت بالاتر).
