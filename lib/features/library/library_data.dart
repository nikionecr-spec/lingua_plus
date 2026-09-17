/// Static bilingual library content: stories + grammar lessons + vocabulary.
/// All English text lives in [BookPage.en] (rendered LTR via `En`),
/// all Persian text in [BookPage.fa] (rendered RTL via the theme).
class BookPage {
  const BookPage(this.en, this.fa);

  final String en;
  final String fa;
}

class BookMeta {
  const BookMeta({
    required this.id,
    required this.titleFa,
    required this.titleEn,
    required this.emoji,
    required this.pages,
  });

  final String id;
  final String titleFa;
  final String titleEn;
  final String emoji;
  final List<BookPage> pages;
}

const kLibraryBooks = <BookMeta>[
  BookMeta(
    id: 'story_star',
    titleFa: 'ستاره کوچک',
    titleEn: 'The Little Star',
    emoji: '⭐',
    pages: [
      BookPage(
        'High in the night sky lived a little star named Lulu. Every '
            'evening, she watched the sun go down. And every evening, she '
            'felt a little afraid.',
        'در آسمانِ شب، ستاره‌ای کوچک به نام لولو زندگی می‌کرد. هر غروب، '
            'غروب‌کردنِ خورشید را تماشا می‌کرد. و هر غروب، کمی می‌ترسید.',
      ),
      BookPage(
        '"Mama, the sky is so dark," Lulu whispered one night. "What if '
            'the dark eats me?" Mama smiled and pointed at Lulu\'s own heart.',
        'یک شب لولو زمزمه کرد: «مامان، آسمان خیلی تاریک است. اگر تاریکی '
            'من را بخورد چه؟» مامان لبخندی زد و به قلب خودِ لولو اشاره کرد.',
      ),
      BookPage(
        '"Look closely, little one. You are full of light. The dark is '
            'not your enemy — it is your canvas." Lulu took a deep breath '
            'and began to glow.',
        '«خوب نگاه کن، کوچولو. تو پر از نوری. تاریکی دشمنِ تو نیست — '
            'بومِ نقاشیِ توست.» لولو نفس عمیقی کشید و شروع به درخشیدن کرد.',
      ),
      BookPage(
        'The more she shone, the more beautiful the night became. Down '
            'below, a lost firefly saw her glow and followed it all the way '
            'home.',
        'هرچه بیشتر می‌درخشید، شب زیباتر می‌شد. پایین، کرم‌شب‌تابیِ '
            'گم‌شده نورِ او را دید و تا خانه‌اش دنبالش رفت.',
      ),
      BookPage(
        '"Thank you, little star!" said the firefly. "Your light showed '
            'me the way." Lulu felt warm and brave, and she shone brighter '
            'than ever before.',
        'کرم‌شب‌تاب گفت: «متشکرم، ستاره‌ی کوچولو! نورِ تو راه را به من '
            'نشان داد.» لولو گرم و شجاع احساس شد و از همیشه درخشان‌تر شد.',
      ),
      BookPage(
        'From that night on, Lulu was never afraid of the dark again. '
            'She knew a beautiful secret: even the smallest light can '
            'change the whole night.',
        'از آن شب به بعد، لولو دیگر هرگز از تاریکی نترسید. او رازیِ '
            'زیبا می‌دانست: حتی کوچک‌ترین نور هم می‌تواند تمامِ شب را '
            'تغییر دهد.',
      ),
    ],
  ),
  BookMeta(
    id: 'story_city',
    titleFa: 'یک روز در شهر',
    titleEn: 'A Day in the City',
    emoji: '🚌',
    pages: [
      BookPage(
        'Ali wakes up early and drinks his tea. Today is a special day: '
            'he wants to visit the big city. He takes his bag and runs to '
            'the bus stop.',
        'علی صبح زود بیدار می‌شود و چایش را می‌نوشد. امروز روزِ خاصی است: '
            'می‌خواهد به شهرِ بزرگ سر بزند. کیفش را برمی‌دارد و به سمتِ '
            'ایستگاه اتوبوس می‌دود.',
      ),
      BookPage(
        'The bus arrives at eight o\'clock. Ali gets on and sits near '
            'the window. The city is busy, and the streets are full of '
            'people.',
        'اتوبوس ساعت هشت می‌رسد. علی سوار می‌شود و کنارِ پنجره '
            'می‌نشیند. شهر شلوغ است و خیابان‌ها پر از آدم‌ها.',
      ),
      BookPage(
        'First, he walked around the old market. He bought fresh bread, '
            'sweet dates, and a small blue notebook.',
        'اول، به بازارِ قدیمی سر زد. نانِ تازه، خرمای شیرین و یک '
            'دفترچه‌ی آبیِ کوچک خرید.',
      ),
      BookPage(
        'At noon, he was hungry. He ate a kebab sandwich in a small '
            'restaurant and drank a cold glass of doogh.',
        'ظهر، گرسنه شد. در یک رستورانِ کوچک ساندویچِ کباب خورد و یک '
            'لیوان دوغِ سرد نوشید.',
      ),
      BookPage(
        'In the afternoon, Ali went to the big park. Children played '
            'football, and old men played chess under the trees.',
        'بعدازظهر، علی به پارکِ بزرگ رفت. بچه‌ها فوتبال بازی می‌کردند و '
            'پیرمردها زیرِ درخت‌ها شطرنج بازی می‌کردند.',
      ),
      BookPage(
        'In the evening, he sat on a bench and watched the city lights. '
            '"What a wonderful day," he said. Then he took the bus home and '
            'slept with a smile.',
        'عصر، روی نیمکتی نشست و چراغ‌های شهر را تماشا کرد. گفت: «چه روز '
            'قشنگی!» بعد سوارِ اتوبوس شد و با لبخند خوابید.',
      ),
    ],
  ),
  BookMeta(
    id: 'story_friend',
    titleFa: 'دوستی',
    titleEn: 'A True Friend',
    emoji: '💙',
    pages: [
      BookPage(
        'Sara was the new girl at school. She did not know anyone, and '
            'she ate her lunch alone. Then a girl with curly hair sat next '
            'to her.',
        'سارا دانش‌آموزِ تازه‌ی مدرسه بود. هیچ‌کس را نمی‌شناخت و تنهایی '
            'ناهار می‌خورد. بعد، دختری با موهای فرفری کنارش نشست.',
      ),
      BookPage(
        '"My name is Neda," the girl said with a warm smile. "Do you '
            'like drawing? I have two pencils — one is for you."',
        'دختر با لبخندی گرم گفت: «اسم من ندا است. نقاشی دوست داری؟ من '
            'دو تا مداد دارم — یکی‌اش مالِ تو.»',
      ),
      BookPage(
        'Every day, they drew pictures together and shared their '
            'snacks. When Sara fell, Neda helped her up. When Neda was sad, '
            'Sara told her funny stories.',
        'هر روز با هم نقاشی می‌کشیدند و خوراکی‌هایشان را قسمت '
            'می‌کردند. وقتی سارا زمین خورد، ندا بلندش کرد. وقتی ندا '
            'ناراحت بود، سارا برایش قصه‌های خنده‌دار تعریف می‌کرد.',
      ),
      BookPage(
        'One rainy day, Sara forgot her umbrella. Neda opened hers and '
            'said, "There is always room for a friend." They walked home '
            'under one small umbrella.',
        'یک روز بارانی، سارا چترش را جا گذاشته بود. ندا چترش را باز کرد '
            'و گفت: «همیشه جا برای یک دوست هست.» زیرِ یک چترِ کوچک به '
            'خانه رفتند.',
      ),
      BookPage(
        'Years later, Sara still keeps that blue umbrella. She learned '
            'that friendship is not one big thing — it is a million small '
            'kindnesses, every day.',
        'سال‌ها بعد، سارا هنوز آن چترِ آبی را نگه داشته است. او یاد '
            'گرفت که دوستی یک چیزِ بزرگ نیست — میلیون‌ها مهربانیِ کوچک '
            'است، هر روز.',
      ),
    ],
  ),
  BookMeta(
    id: 'gram_present',
    titleFa: 'گرامر: زمان حال ساده',
    titleEn: 'Grammar: Present Simple',
    emoji: '📘',
    pages: [
      BookPage(
        'Present Simple — When do we use it?\n'
            '1) Habits: I drink tea every morning.\n'
            '2) Facts: The sun rises in the east.\n'
            '3) Timetables: The bus leaves at 8:00.',
        'زمان حال ساده — چه وقت استفاده می‌کنیم؟\n'
            '۱) عادت‌ها: من هر صبح چای می‌نوشم.\n'
            '۲) حقایق: خورشید از مشرق طلوع می‌کند.\n'
            '۳) برنامه‌های منظم: اتوبوس ساعت ۸ حرکت می‌کند.',
      ),
      BookPage(
        'Structure: subject + verb (+s/es for he/she/it).\n'
            'I work • You work • He works • She works • We work • They work\n'
            'Remember: he, she, it → add -s or -es (watch → watches, '
            'go → goes).',
        'ساختار: فاعل + فعل (برای سوم‌شخصِ مفرد s/es اضافه می‌شود).\n'
            'I work • You work • He works • She works • We work • They work\n'
            'یادت باشد: برای he, she, it باید s/es اضافه کنی '
            '(watch → watches، go → goes).',
      ),
      BookPage(
        'Negative: do not (don\'t) / does not (doesn\'t) + base verb.\n'
            'I don\'t like coffee. • She doesn\'t watch TV.\n'
            'After "doesn\'t" the verb has no -s:\n'
            'She doesn\'t works ✗ → She doesn\'t work ✓.',
        'منفی: do not (don\'t) / does not (doesn\'t) + فعلِ ساده.\n'
            'I don\'t like coffee. • She doesn\'t watch TV.\n'
            'بعد از doesn\'t فعل، s نمی‌گیرد:\n'
            'She doesn\'t works ✗ → درست: She doesn\'t work ✓.',
      ),
      BookPage(
        'Questions: Do/Does + subject + base verb?\n'
            'Do you speak English? — Yes, I do. / No, I don\'t.\n'
            'Does he live here? — Yes, he does. / No, he doesn\'t.\n'
            'Wh-words come first: Where do you work?',
        'سؤالی: Do/Does + فاعل + فعلِ ساده؟\n'
            'Do you speak English? — بله: Yes, I do. / نه: No, I don\'t.\n'
            'Does he live here? — Yes, he does. / No, he doesn\'t.\n'
            'کلماتِ پرسشی اول می‌آیند: Where do you work?',
      ),
      BookPage(
        'Common mistakes ✗ → ✓\n'
            'He go to school. → He goes to school.\n'
            'I am agree. → I agree.\n'
            'She don\'t know. → She doesn\'t know.\n'
            'Do he play? → Does he play?\n'
            'Signal words: always, usually, often, sometimes, never, '
            'every day.',
        'اشتباه‌های رایج ✗ → درست ✓\n'
            'He go to school. → He goes to school.\n'
            'I am agree. → I agree. (فعلِ agree خودش «موافقم» است.)\n'
            'She don\'t know. → She doesn\'t know.\n'
            'Do he play? → Does he play?\n'
            'نشانه‌های این زمان: always، usually، often، sometimes، '
            'never، every day.',
      ),
    ],
  ),
  BookMeta(
    id: 'gram_past',
    titleFa: 'گرامر: زمان گذشته ساده',
    titleEn: 'Grammar: Past Simple',
    emoji: '⏳',
    pages: [
      BookPage(
        'Past Simple — When do we use it?\n'
            'For finished actions in a finished time:\n'
            'I visited Rome last year. • She called me yesterday. • We '
            'watched a movie two days ago.',
        'زمان گذشته ساده — چه وقت استفاده می‌کنیم؟\n'
            'برای کارهای تمام‌شده در زمانیِ تمام‌شده:\n'
            'I visited Rome last year. • دیروز به من زنگ زد. • We watched '
            'a movie two days ago.',
      ),
      BookPage(
        'Regular verbs take -ed: work → worked, play → played, study → '
            'studied.\n'
            'Spelling: stop → stopped (double the last letter), study → '
            'studied (y → ied).\n'
            'Irregular verbs change: go → went, see → saw, buy → bought, '
            'eat → ate.',
        'فعل‌های باقاعده ed می‌گیرند: work → worked، play → played، '
            'study → studied.\n'
            'املاء: stop → stopped (حرفِ آخر دوبرابر می‌شود)، study → '
            'studied (y → ied).\n'
            'فعل‌های بی‌قاعده تغییر می‌کنند: go → went، see → saw، '
            'buy → bought، eat → ate.',
      ),
      BookPage(
        'Negative: did not (didn\'t) + base verb — for every subject.\n'
            'I didn\'t sleep well. • They didn\'t come to the party.\n'
            'After "didn\'t" never use the past form:\n'
            'I didn\'t went ✗ → I didn\'t go ✓.',
        'منفی: did not (didn\'t) + شکلِ ساده‌ی فعل — برای همه‌ی '
            'فاعل‌ها.\n'
            'I didn\'t sleep well. • They didn\'t come to the party.\n'
            'بعد از didn\'t هرگز شکلِ گذشته‌ی فعل را نگذار:\n'
            'I didn\'t went ✗ → درست: I didn\'t go ✓.',
      ),
      BookPage(
        'Questions: Did + subject + base verb?\n'
            'Did you see the message? — Yes, I did. / No, I didn\'t.\n'
            'Where did she go? — She went to the bank.\n'
            'Time words: yesterday, last week, in 2019, two days ago.',
        'سؤالی: Did + فاعل + شکلِ ساده‌ی فعل؟\n'
            'Did you see the message? — Yes, I did. / No, I didn\'t.\n'
            'Where did she go? — به بانک رفت.\n'
            'قیدهای زمان: yesterday، last week، in 2019، two days ago.',
      ),
      BookPage(
        'Common mistakes ✗ → ✓\n'
            'I did went home. → I went home.\n'
            'Did she called you? → Did she call you?\n'
            'He writed a letter. → He wrote a letter.\n'
            'We was tired. → We were tired.\n'
            'Tip: in questions and negatives, the past lives in "did", not '
            'in the main verb.',
        'اشتباه‌های رایج ✗ → درست ✓\n'
            'I did went home. → I went home.\n'
            'Did she called you? → Did she call you?\n'
            'He writed a letter. → He wrote a letter.\n'
            'We was tired. → We were tired.\n'
            'نکته: در سؤال و منفی، «گذشته» در did است، نه در فعلِ اصلی.',
      ),
    ],
  ),
  BookMeta(
    id: 'vocab_travel',
    titleFa: 'واژگان سفر',
    titleEn: 'Travel Vocabulary',
    emoji: '✈️',
    pages: [
      BookPage(
        'At the Airport ✈️\n'
            'boarding pass • passport • luggage\n'
            'check-in desk • security check • gate\n'
            'flight • departure / arrival',
        'در فرودگاه ✈️\n'
            'کارت پرواز • گذرنامه • چمدان\n'
            'پیشخوان پذیرش • بازرسی امنیتی • دروازه پرواز\n'
            'پرواز • عزیمت / ورود',
      ),
      BookPage(
        'At the Hotel 🏨\n'
            'reception • room key / key card • reservation\n'
            'single room / double room • check in • check out\n'
            'luggage cart • tip',
        'در هتل 🏨\n'
            'پذیرش • کلید اتاق / کارت کلید • رزرو\n'
            'اتاق یک‌نفره / اتاق دونفره • تحویل گرفتن اتاق • تخلیه اتاق\n'
            'چرخ دستی بار • انعام',
      ),
      BookPage(
        'Asking for Directions 🗺️\n'
            'turn left • turn right • go straight\n'
            'next to • across from • between\n'
            'intersection • crosswalk',
        'پرسیدن آدرس 🗺️\n'
            'به چپ بپیچ • به راست بپیچ • مستقیم برو\n'
            'کنارِ • روبرویِ • بینِ\n'
            'چهارراه • خط عابر پیاده',
      ),
      BookPage(
        'Food & Restaurant 🍽️\n'
            'menu • waiter / waitress • order\n'
            'bill / check • starter • main course\n'
            'dessert • still water / sparkling water',
        'غذا و رستوران 🍽️\n'
            'منو • گارسون • سفارش دادن\n'
            'صورت‌حساب • پیش‌غذا • غذای اصلی\n'
            'دسر • آب بی‌گاز / آب گازدار',
      ),
      BookPage(
        'Emergency 🚨\n'
            'help! • call the police • ambulance\n'
            'hospital • pharmacy • embassy\n'
            'I lost my passport. • I need a doctor.',
        'اضطراری 🚨\n'
            'کمک! • به پلیس زنگ بزن • آمبولانس\n'
            'بیمارستان • داروخانه • سفارت\n'
            'گذرنامه‌ام را گم کرده‌ام. • دکتر لازم دارم.',
      ),
    ],
  ),
];
