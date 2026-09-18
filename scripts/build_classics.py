#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fetches ~55 public-domain classics from Project Gutenberg, cleans them
and emits: assets/books/<slug>.txt + lib/features/library/classics.dart."""
import json
import os
import re
import sys
import urllib.request

ROOT = "/home/z/my-project/lingua_plus"
OUT_TXT = os.path.join(ROOT, "assets", "books")
OUT_DART = os.path.join(ROOT, "lib", "features", "library", "classics.dart")
os.makedirs(OUT_TXT, exist_ok=True)

# id, slug, level, titleEn, titleFa, authorEn, authorFa, synopsisFa
BOOKS = [
    (11, "alice_wonderland", "A2", "Alice's Adventures in Wonderland", "آلیس در سرزمین عجایب", "Lewis Carroll", "لوئیس کارول",
     "دختری کنجکاو از یک لانه خرگوش به دنیایی عجیب سقوط می‌کند و با شخصیت‌های عجیب‌وغریب روبه‌رو می‌شود."),
    (55, "wizard_oz", "A2", "The Wonderful Wizard of Oz", "جادوگر شهر از", "L. Frank Baum", "اف. رام باوم",
     "دوروتی با توفان به سرزمین از برده می‌شود و برای بازگشت به خانه باید با جادوگر شهر از دیدار کند."),
    (21, "aesop_fables", "A2", "Aesop's Fables", "حکایت‌های ازوپ", "Aesop", "ازوپ",
     "گردآوری‌ای از کوتاه‌ترین حکایت‌های اخلاقی جهان؛ هر حکایت یک درس ماندگار دارد."),
    (902, "happy_prince", "A2", "The Happy Prince and Other Tales", "شاهزاده خوشحال", "Oscar Wilde", "اسکار وایلد",
     "پنج قصه‌ی لطیف و اندوهناک از اسکار وایلد درباره‌ی مهربانی، فداکاری و عشق."),
    (2591, "grimms_fairy_tales", "A2", "Grimms' Fairy Tales", "قصه‌های برادران گریم", "Brothers Grimm", "برادران گریم",
     "مجموعه‌ی جاودانه‌ی قصه‌های پریان؛ سفیدبرفی، سیندرلا و ده‌ها داستان دیگر."),
    (1597, "andersen_fairy_tales", "A2", "Andersen's Fairy Tales", "قصه‌های هانس کریستین آندرسن", "H. C. Andersen", "هانس کریستین آندرسن",
     "قصه‌های محبوب آندرسن؛ جوجه‌اردک زشت، پری‌دریایی کوچک و مورچه‌ی سرخ‌پوش."),
    (16, "peter_pan", "B1", "Peter Pan", "پیتر پن", "J. M. Barrie", "ج. م. بری",
     "پسری که هرگز بزرگ نمی‌شود، وندی و برادرانش را به جزیره‌ی هرگزبیز می‌برد."),
    (74, "tom_sawyer", "B1", "The Adventures of Tom Sawyer", "ماجراهای تام سایر", "Mark Twain", "مارک تواین",
     "ماجراجویی‌های پسری شیطون در شهر کوچکی کنار رودخانه‌ی میسیسیپی."),
    (120, "treasure_island", "B1", "Treasure Island", "جزیره‌ی گنج", "Robert Louis Stevenson", "رابرت لویی استیونسون",
     "نقشه‌ی یک گنج پنهان، کشتی دزدان دریایی و مرد تک‌پای ملقب به لانگ جان سیلور."),
    (236, "jungle_book", "B1", "The Jungle Book", "کتاب جنگل", "Rudyard Kipling", "رادیارد کیپلینگ",
     "ماورا، پسربچه‌ای که میان گرگ‌ها بزرگ شد و قوانین جنگل را آموخت."),
    (45, "anne_green_gables", "B1", "Anne of Green Gables", "آن در گرین گیبلز", "L. M. Montgomery", "ال. ام. مونتگومری",
     "دختری سرخ‌مو و پرحرف، دل دوستان و دشمنانش را در دهکده‌ی آوونلی فتح می‌کند."),
    (289, "wind_willows", "B1", "The Wind in the Willows", "باد در میان بیدها", "Kenneth Grahame", "کنت گراهام",
     "دوستی مول، موش آبی، قورباغه‌ی مغرور و بادگر در کنار رودخانه‌ای آرام."),
    (271, "black_beauty", "B1", "Black Beauty", "زیبای سیاه", "Anna Sewell", "آنا سوئل",
     "سرگذشت یک اسب؛ از چمن‌زارهای آرام تا خیابان‌های سرد لندن، روایت‌شده به زبان خودش."),
    (113, "secret_garden", "B1", "The Secret Garden", "باغ مخفی", "Frances Hodgson Burnett", "فرانسیس هاجسون برنت",
     "دختری یتیم، عمارتی متروک و باغی جادویی که با بهار جان می‌گیرد."),
    (2781, "just_so_stories", "B1", "Just So Stories", "قصه‌های این‌طور شد", "Rudyard Kipling", "رادیارد کیپلینگ",
     "افسانه‌های خلاقانه‌ی کیپلینگ درباره‌ی اینکه چطور فیل خرطومش، شتر کوهانش و پلنگ لکه‌هایش را گرفت."),
    (35, "time_machine", "B2", "The Time Machine", "ماشین زمان", "H. G. Wells", "اچ. جی. ولز",
     "مخترعی عجیب به سال ۸۰۲,۷۰۱ سفر می‌کند و آینده‌ی بشریت را می‌بیند."),
    (36, "war_of_worlds", "B2", "The War of the Worlds", "جنگ دنیاها", "H. G. Wells", "اچ. جی. ولز",
     "مریخی‌ها به انگلستان حمله می‌کنند؛ نخستین و ترسناک‌ترین روایت برخورد با بیگانگان."),
    (5230, "invisible_man", "B2", "The Invisible Man", "مرد نامرئی", "H. G. Wells", "اچ. جی. ولز",
     "غریبه‌ای پوشیده در باند به دهکده‌ای می‌آید؛ راز او فرمول نامرئی‌شدن است."),
    (139, "lost_world", "B2", "The Lost World", "دنیای گمشده", "Arthur Conan Doyle", "آرتور کونان دویل",
     "اعضای یک اکتشاف علمی به فلاتی دور می‌روند که دایناسورها در آن هنوز زنده‌اند."),
    (84, "frankenstein", "B2", "Frankenstein", "فرانکنشتاین", "Mary Shelley", "مری شلی",
     "دانشمندی جاه‌طلب موجودی زنده می‌کند و پس از آن هر دو تا پایان تعقیب می‌شوند."),
    (43, "dr_jekyll_mr_hyde", "B2", "The Strange Case of Dr Jekyll and Mr Hyde", "دکتر جکیل و آقای هاید", "Robert Louis Stevenson", "رابرت لویی استیونسون",
     "پزشکی محترم با نوشیدنی عجیب، روژه‌ی تاریک خود را رها می‌کند."),
    (174, "dorian_gray", "B2", "The Picture of Dorian Gray", "تصویر دوریان گری", "Oscar Wilde", "اسکار وایلد",
     "پورتِ جوانی جاودانه می‌شود؛ اما پرتره‌اش راز تاریک او را نگه می‌دارد."),
    (46, "christmas_carol", "B2", "A Christmas Carol", "سرود کریسمس", "Charles Dickens", "چارلز دیکنز",
     "خسیس‌ترین مرد لندن با سه روح کریسمس سفری به گذشته، حال و آینده می‌رود."),
    (215, "call_of_the_wild", "B2", "The Call of the Wild", "آوای جنگل", "Jack London", "جک لندن",
     "سگ اهلی باک از جلد آلاسکا برده می‌شود و صدای وحشی اجدادش را می‌شنود."),
    (910, "white_fang", "B2", "White Fang", "دندان‌سفید", "Jack London", "جک لندن",
     "گرگ‌سگ وحشی سرزمین‌های یخ‌زده شمال، میان ظلم و مهربانی، راهش را پیدا می‌کند."),
    (76, "huckleberry_finn", "B2", "Adventures of Huckleberry Finn", "ماجراهای هاکلبری فین", "Mark Twain", "مارک تواین",
     "پسری و سگی برده به قایقی سوار می‌شوند و رود میسیسیپی را به سوی آزادی می‌پیمایند."),
    (41, "sleepy_hollow", "B2", "The Legend of Sleepy Hollow", "افسانه دره‌ی آرام", "Washington Irving", "واشنگتن اروینگ",
     "معلم مدرسه با شوالیه‌ای بی‌سر روبه‌رو می‌شود؛ کلاسیک ترسناک آمریکایی."),
    (244, "study_in_scarlet", "B2", "A Study in Scarlet", "اتود در قرمز", "Arthur Conan Doyle", "آرتور کونان دویل",
     "نخستین ملاقات شرلوک هلمز و دکتر واتسون و حل اولین پرونده‌ی مشترکشان."),
    (1661, "adventures_sherlock_holmes", "B2", "The Adventures of Sherlock Holmes", "ماجراهای شرلوک هلمز", "Arthur Conan Doyle", "آرتور کونان دویل",
     "دوازده پرونده‌ی مشهور، از راز نوار خال‌دار تا مردی که چهره‌اش را عوض می‌کند."),
    (2852, "hound_baskervilles", "B2", "The Hound of the Baskervilles", "سگ شکاری باسکرویل", "Arthur Conan Doyle", "آرتور کونان دویل",
     "سگی شیطانی در باتلاق‌های دارتمور، و هلمز در پی فروپاشی یک افسانه‌ی خانوادگی."),
    (863, "styles_affair", "B2", "The Mysterious Affair at Styles", "ماجرای مرموز در استایلز", "Agatha Christie", "آگاتا کریستی",
     "نخستین پرونده‌ی پوارو؛ قتل زنی ثروتمند در عمارت استایلز."),
    (1342, "pride_prejudice", "B2", "Pride and Prejudice", "غرور و تعصب", "Jane Austen", "جین آستین",
     "الیزابت بنت و آقای دارسی در میان ابهت، پیش‌داوری و عشق به هم می‌رسند."),
    (161, "sense_sensibility", "B2", "Sense and Sensibility", "عقل و احساس", "Jane Austen", "جین آستین",
     "دو خواهر با دو نگاه به عشق؛ یکی با عقل، دیگری با احساس."),
    (158, "emma", "B2", "Emma", "اِما", "Jane Austen", "جین آستین",
     "دختری ثروتمند و باهوش، خیال می‌کند همتارسازی می‌کند؛ اما خودش عاشق می‌شود."),
    (1260, "jane_eyre", "B2", "Jane Eyre", "جین ایر", "Charlotte Brontë", "شارلوت برونته",
     "معلمی مستقل، عمارتی متروک در یورکشایر و رازی پشت در اتاق بالایی."),
    (768, "wuthering_heights", "B2", "Wuthering Heights", "بلندی‌های بادخیز", "Emily Brontë", "امیلی برونته",
     "عشق توفانی هث‌کلیف و کاترین در میان تپه‌های وحشی یورکشایر."),
    (1400, "great_expectations", "B2", "Great Expectations", "آرزوهای بزرگ", "Charles Dickens", "چارلز دیکنز",
     "پسری روستایی ناگهان ثروتمند می‌شود و راز حامی ناشناسش زندگی‌اش را دگرگون می‌کند."),
    (514, "little_women", "B2", "Little Women", "زنان کوچک", "Louisa May Alcott", "لوییزا می آلکات",
     "چهار خواهر در دوران جنگ داخلی آمریکا، با رؤیاها، شکست‌ها و عشق‌هایشان."),
    (844, "being_earnest", "B2", "The Importance of Being Earnest", "اهمیت جدی‌بودن", "Oscar Wilde", "اسکار وایلد",
     "کمدی وایلد درباره‌ی دو جوان که هویت‌های ساختگی می‌سازند؛ بامزه‌ترین نمایشنامه‌ی انگلیسی."),
    (103, "around_world_80_days", "B2", "Around the World in Eighty Days", "دور دنیا در هشتاد روز", "Jules Verne", "ژول ورن",
     "آقای فاگ با شرط‌بندی ۲۰,۰۰۰ پوندی، دور دنیا را در هشتاد روز می‌چرخد."),
    (164, "twenty_thousand_leagues", "B2", "Twenty Thousand Leagues Under the Seas", "بیست هزار فرسنگ زیر دریا", "Jules Verne", "ژول ورن",
     "سفر با زیردریایی ناتیلوس و کاپیتان نِمو در اعماق اقیانوس‌ها."),
    (521, "robinson_crusoe", "B2", "Robinson Crusoe", "رابینسون کروزوئه", "Daniel Defoe", "دانیل دفو",
     "کشتی‌شکسته‌ای بیست‌وهشت سال در جزیره‌ای خالی زندگی می‌کند و تمدنی کوچک می‌سازد."),
    (829, "gulliver_travels", "B2", "Gulliver's Travels", "سفرهای گالیور", "Jonathan Swift", "جاناتان سوییفت",
     "کشتی‌بان انگلیسی به سرزمین کوتوله‌ها و غول‌ها سفر می‌کند؛ طنزی جاودانه."),
    (1257, "three_musketeers", "B2", "The Three Musketeers", "سه تفنگدار", "Alexandre Dumas", "الکساندر دوما",
     "دآرتانیان جوان به پاریس می‌آید و با سه تفنگدار پادشاه، «یکی برای همه» می‌شود."),
    (60, "scarlet_pimpernel", "B2", "The Scarlet Pimpernel", "لادن سرخ", "Baroness Orczy", "بارونس اورچی",
     "نجیب‌زاده‌ای مرموز، اشراف فرانسوی را از چنگ ترور می‌رهاند؛ کهن‌الگوی ماجراجوی نقاب‌دار."),
    (95, "prisoner_zenda", "B2", "The Prisoner of Zenda", "اسیر زندا", "Anthony Hope", "آنتونی هوپ",
     "دوقلویی شبیه پادشاه باید جانش را به خطر بیندازد تا تاج و تخت را نجات دهد."),
    (2166, "king_solomons_mines", "B2", "King Solomon's Mines", "معادن سلیمان", "H. Rider Haggard", "اچ. رایدر هاگارد",
     "سه ماجراجو در پی گنجی افسانه‌ای به قلب آفریقای ناشناخته می‌روند."),
    (558, "thirty_nine_steps", "B2", "The Thirty-Nine Steps", "سی‌ونه پله", "John Buchan", "جان بوکان",
     "مردی به اشتباه متهم به قتل، باید هم پلیس و هم جاسوسان را فریب دهد."),
    (64317, "great_gatsby", "B2", "The Great Gatsby", "گتسبی بزرگ", "F. Scott Fitzgerald", "اف. اسکات فیتزجرالد",
     "مهمانی‌های باشکوه لانگ‌آیلند و عشق قدیمی گتسبی به دیسی؛ روایت عصر جاز."),
    (209, "turn_of_the_screw", "B2", "The Turn of the Screw", "پیچ مارپیچ", "Henry James", "هنری جیمز",
     "معلم سرخانه‌ای در عمارتی روستایی، با حضورهایی شوم روبه‌رو می‌شود."),
    (5200, "metamorphosis", "C1", "Metamorphosis", "مسخ", "Franz Kafka", "فرانتس کافکا",
     "گرگور سامسا صبح از خواب بیدار می‌شود و می‌بیند که به حشره‌ای عظیم تبدیل شده است."),
    (219, "heart_of_darkness", "C1", "Heart of Darkness", "قلب تاریکی", "Joseph Conrad", "جوزف کنراد",
     "سفری رودخانه‌ای به قلب کنگو و مواجهه با کورتز؛ روایت تاریک امپراتوری."),
    (2814, "dubliners", "C1", "Dubliners", "دوبلینی‌ها", "James Joyce", "جیمز جویس",
     "پانزده روایت از زندگی معمولی مردم دوبلین؛ شاهکار سبک واقع‌گرایانه‌ی جویس."),
    (205, "walden", "C1", "Walden", "والدن", "Henry David Thoreau", "هنری دیوید ثورو",
     "دو سال زندگی در کلبه‌ای کنار دریاچه؛ دفترچه‌ی آزمودن زندگی ساده."),
    (2554, "crime_and_punishment", "C1", "Crime and Punishment", "جنایت و مکافات", "Fyodor Dostoevsky", "فیودور داستایوسکی",
     "دانشجویی فقیر در پترزبورگ دست به قتل می‌زند و سپس با وجدانش جنگیده می‌شود."),
    (730, "oliver_twist", "B2", "Oliver Twist", "الیور توئیست", "Charles Dickens", "چارلز دیکنز",
     "یتیمی از کارخانه‌ی کار به لندن می‌رسد و میان دزدان و گدایان، مهربانی را پیدا می‌کند."),
    (246, "rubaiyat_omar", "C1", "The Rubaiyat of Omar Khayyam", "رباعیات عمر خیام", "Omar Khayyam (tr. FitzGerald)", "عمر خیام",
     "ترجمه‌ی فیتزجرالد از رباعیات خیام؛ شعر زندگی، شراب و لحظه‌ی اکنون."),
    (203, "uncle_toms_cabin", "B2", "Uncle Tom's Cabin", "کلبه‌ی عمو تم", "Harriet Beecher Stowe", "هریت بیچر استو",
     "روایتی تکان‌دهنده از بردگی در آمریکا که بر تاریخ آن کشور اثر گذاشت."),
    (33, "scarlet_letter", "B2", "The Scarlet Letter", "حرف سرخ", "Nathaniel Hawthorne", "ناتانیل هاوثورن",
     "زنی در بوستون پوریتنی، با حرف «A» سوزن‌دوزی‌شده بر سینه، گناه و شجاعت را می‌آزماید."),
]

HEADERS = {"User-Agent": "LinguaPlus/1.2 (educational reader)"}


def fetch(url: str) -> bytes:
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req, timeout=45) as r:
        return r.read()


def fetch_text(gid: int) -> str:
    for url in (
        f"https://www.gutenberg.org/cache/epub/{gid}/pg{gid}.txt",
        f"https://www.gutenberg.org/files/{gid}/{gid}-0.txt",
        f"https://www.gutenberg.org/files/{gid}/{gid}.txt",
    ):
        try:
            raw = fetch(url)
            for enc in ("utf-8-sig", "utf-8", "latin-1"):
                try:
                    return raw.decode(enc)
                except UnicodeDecodeError:
                    continue
        except Exception as e:
            print(f"   miss {url}: {e}", flush=True)
    raise RuntimeError(f"could not download {gid}")


START_RE = re.compile(r"\*\*\*\s*START OF (?:THE|THIS) PROJECT GUTENBERG EBOOK.*?\*\*\*", re.I)
END_RE = re.compile(r"\*\*\*\s*END OF (?:THE|THIS) PROJECT GUTENBERG EBOOK.*?\*\*\*", re.I)


def clean(text: str) -> str:
    m = START_RE.search(text)
    if m:
        text = text[m.end():]
    m = END_RE.search(text)
    if m:
        text = text[:m.start()]
    # unify line endings, strip weird control chars
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = re.sub(r"[\x00-\x08\x0b\x0c\x0e-\x1f]", "", text)
    # collapse 3+ blank lines
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def main() -> None:
    ok, failed = [], []
    for gid, slug, level, ten, tfa, aen, afa, syn in BOOKS:
        out_path = os.path.join(OUT_TXT, f"{slug}.txt")
        if os.path.exists(out_path) and os.path.getsize(out_path) > 10000:
            print(f"[skip] {slug} ({gid})")
            ok.append((gid, slug, level, ten, tfa, aen, afa, syn,
                       os.path.getsize(out_path)))
            continue
        try:
            print(f"[get ] {slug} ({gid}) …", flush=True)
            text = clean(fetch_text(gid))
            if len(text) < 3000:
                raise RuntimeError(f"too short: {len(text)}")
            with open(out_path, "w", encoding="utf-8") as f:
                f.write(text)
            ok.append((gid, slug, level, ten, tfa, aen, afa, syn, len(text.encode())))
            print(f"   ok {len(text)//1024} KB")
        except Exception as e:
            print(f"   FAIL {e}")
            failed.append((gid, slug))

    # Dart manifest
    lines = [
        "// GENERATED by scripts/build_classics.py — do not edit by hand.",
        "// Public-domain texts from Project Gutenberg (Cleaned & re-paginated).",
        "",
        "/// A public-domain classic bundled as a text asset.",
        "class ClassicBook {",
        "  const ClassicBook(",
        "    this.id,",
        "    this.level,",
        "    this.titleEn,",
        "    this.titleFa,",
        "    this.authorEn,",
        "    this.authorFa,",
        "    this.synopsisFa,",
        "    this.asset,",
        "    this.sizeKb,",
        "  );",
        "",
        "  final String id;",
        "  final String level;",
        "  final String titleEn;",
        "  final String titleFa;",
        "  final String authorEn;",
        "  final String authorFa;",
        "  final String synopsisFa;",
        "  final String asset;",
        "  final int sizeKb;",
        "",
        "  String get cover => 'assets/covers/cl_${id}.jpg';",
        "}",
        "",
        "const kClassicBooks = <ClassicBook>[",
    ]
    for gid, slug, level, ten, tfa, aen, afa, syn, size in ok:
        lines.append(
            "  ClassicBook(\n"
            f"    id: '{slug}',\n"
            f"    level: '{level}',\n"
            f"    titleEn: {json.dumps(ten, ensure_ascii=False)},\n"
            f"    titleFa: {json.dumps(tfa, ensure_ascii=False)},\n"
            f"    authorEn: {json.dumps(aen, ensure_ascii=False)},\n"
            f"    authorFa: {json.dumps(afa, ensure_ascii=False)},\n"
            f"    synopsisFa: {json.dumps(syn, ensure_ascii=False)},\n"
            f"    asset: 'assets/books/{slug}.txt',\n"
            f"    sizeKb: {size // 1024},\n"
            "  ),"
        )
    lines.append("];")
    lines.append("")
    with open(OUT_DART, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    total = sum(s for *_x, s in ok)
    print(f"\n=== {len(ok)} books, {total/1048576:.1f} MB total ===")
    if failed:
        print("FAILED:", failed)
        sys.exit(1)


if __name__ == "__main__":
    main()
