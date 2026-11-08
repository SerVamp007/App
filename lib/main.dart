import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

final FlutterTts tts = FlutterTts();
String gLang = 'ru';
bool get uz => gLang == 'uz';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  tts.setLanguage('en-US');
  runApp(const WordTenApp());
}

// ───────────── Язык интерфейса ─────────────

const Map<String, String> uzMap = {
  'Давай выучим пару новых слов': 'Keling, yangi soʻzlarni oʻrganamiz',
  'Впиши английские слова. Перевод и картинки найдутся сами.':
      'Inglizcha soʻzlarni yozing. Tarjima va rasmlar oʻzi topiladi.',
  'Прогресс этого урока не сохранится.': 'Bu darsdagi natija saqlanmaydi.',
  'Выбери правильный перевод': 'Toʻgʻri tarjimani tanlang',
  'Найди картинку к слову': 'Soʻzga mos rasmni toping',
  'Скажи слово вслух': 'Soʻzni ovoz chiqarib ayting',
  'Повторение завершено!': 'Takrorlash tugadi!',
  'Повторить слова': 'Soʻzlarni takrorlash',
  'Рейтинг учеников': 'Oʻquvchilar reytingi',
  'Сбросить прогресс': 'Natijani tozalash',
  'Добавить слово': 'Soʻz qoʻshish',
  'Нажми на микрофон': 'Mikrofonni bosing',
  'Ничего не найдено': 'Hech narsa topilmadi',
  'Урок завершён!': 'Dars tugadi!',
  'Выйти из урока?': 'Darsdan chiqasizmi?',
  'Как переводится?': 'Qanday tarjima qilinadi?',
  'Запомни слово': 'Soʻzni eslab qoling',
  'Пора повторить': 'Takrorlash vaqti',
  'Произнеси слово': 'Soʻzni ayting',
  'Выбери картинку': 'Rasmni tanlang',
  'Выбери перевод': 'Tarjimani tanlang',
  'Напиши перевод': 'Tarjimasini yozing',
  'слов в словаре': 'lugʻatdagi soʻzlar',
  'слов выучено': 'oʻrganilgan soʻzlar',
  'дня подряд': 'kun ketma-ket',
  'Первый урок': 'Birinchi dars',
  '3 дня подряд': '3 kun ketma-ket',
  'Достижения': 'Yutuqlar',
  'Язык перевода': 'Tarjima tili',
  'Твой прогресс': 'Sizning natijangiz',
  'Новый урок': 'Yangi dars',
  'Начать урок': 'Darsni boshlash',
  'Мои слова': 'Mening soʻzlarim',
  'Знакомство': 'Tanishuv',
  'Пропустить': 'Oʻtkazib yuborish',
  'Проверить': 'Tekshirish',
  'Послушать': 'Tinglash',
  'Цель на сегодня': 'Bugungi maqsad',
  'Повторить': 'Takrorlash',
  'Остаться': 'Qolish',
  'Удалить': 'Oʻchirish',
  'Привет 👋': 'Salom 👋',
  'Профиль': 'Profil',
  'Перевод': 'Tarjima',
  'Дальше': 'Keyingi',
  'Готово': 'Tayyor',
  'Скоро': 'Tez orada',
  'Выйти': 'Chiqish',
  'Учить': 'Oʻrganish',
  'Слова': 'Soʻzlar',
  'Поиск': 'Qidirish',
  'Отмена': 'Bekor qilish',
  'Сбросить': 'Tozalash',
  'Все': 'Hammasi',
  'Учу': 'Oʻrganyapman',
  'Знаю': 'Bilaman',
  'Отлично!': 'Ajoyib!',
  'Верно!': 'Toʻgʻri!',
  'Слушаю…': 'Tinglayapman…',
  'Удалить слово?': 'Soʻz oʻchirilsinmi?',
  'Сбросить прогресс?': 'Natija tozalansinmi?',
  'Все слова, монеты и серия дней будут удалены.':
      'Barcha soʻzlar, tangalar va kunlar seriyasi oʻchiriladi.',
  'Для повторения нужно минимум 2 выученных слова':
      'Takrorlash uchun kamida 2 ta oʻrganilgan soʻz kerak',
  'Нужно хотя бы 2 слова. Добавь ещё одно.':
      'Kamida 2 ta soʻz kerak. Yana bittasini qoʻshing.',
  'Впиши хотя бы одно слово': 'Kamida bitta soʻz yozing',
  'Не получилось найти переводы. Проверь интернет.':
      'Tarjima topilmadi. Internetni tekshiring.',
  'Нет доступа к микрофону. Разреши его в настройках.':
      'Mikrofonga ruxsat yoʻq. Sozlamalarda ruxsat bering.',
  'Не расслышал. Попробуй ещё': 'Eshitilmadi. Qayta urinib koʻring',
  'Нажми на картинку, чтобы показать другую': 'Boshqa rasm uchun rasmni bosing',
  'Ищу переводы и картинки…': 'Tarjima va rasmlar qidirilmoqda…',
  'Здесь появятся слова, которые ты выучишь. Пройди первый урок!':
      'Oʻrganilgan soʻzlar shu yerda paydo boʻladi. Birinchi darsni oʻting!',
  'Слов в уроке': 'Darsdagi soʻzlar',
  'Ошибок': 'Xatolar',
  'Сложные': 'Qiyin soʻzlar',
  'монет': 'tanga',
  'Сегодня выучено': 'Bugun oʻrganildi',
};

String t(String s) => uz ? (uzMap[s] ?? s) : s;

String ruPl(int n) {
  if (n % 10 == 1 && n % 100 != 11) return 'слово';
  if ([2, 3, 4].contains(n % 10) && ![12, 13, 14].contains(n % 100)) return 'слова';
  return 'слов';
}

// ───────────── Данные ─────────────

const List<int> kIntervalMin = [10, 1440, 4320, 10080, 20160, 43200];

String norm(String s) =>
    s.trim().toLowerCase().replaceAll('ё', 'е').replaceAll(RegExp(r"[ʻ’'`]"), '');

const LinearGradient kAccent = LinearGradient(
    colors: [Color(0xFF0A84FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight);

const List<List<int>> kGrads = [
  [0xFFFFD86F, 0xFFFC6262],
  [0xFFA8EDEA, 0xFFFED6E3],
  [0xFF84FAB0, 0xFF8FD3F4],
  [0xFFFBC2EB, 0xFFA6C1ED],
  [0xFFF6D365, 0xFFFDA085],
  [0xFF89F7FE, 0xFF66A6FF],
];

LinearGradient wordGrad(String en) {
  final i = en.codeUnits.fold<int>(0, (a, c) => a + c) % kGrads.length;
  return LinearGradient(
      colors: [Color(kGrads[i][0]), Color(kGrads[i][1])],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight);
}

class Word {
  String en, ru, uzTr;
  List<String> imgs;
  int box, due, added;
  Word(this.en, this.ru, this.uzTr, this.imgs,
      {this.box = 0, this.due = 0, this.added = 0});
  String get tr => uz ? uzTr : ru;
  String? get img => imgs.isEmpty ? null : imgs.first;
  bool get known => box >= 4;
  Map<String, dynamic> toJson() => {
        'en': en,
        'ru': ru,
        'uz': uzTr,
        'imgs': imgs,
        'box': box,
        'due': due,
        'added': added
      };
  factory Word.fromJson(Map<String, dynamic> j) {
    final old = j['tr'] ?? '';
    return Word(j['en'], j['ru'] ?? old, j['uz'] ?? old, List<String>.from(j['imgs']),
        box: j['box'] ?? 0, due: j['due'] ?? 0, added: j['added'] ?? 0);
  }
}

String dueText(Word w) {
  final diff = w.due - DateTime.now().millisecondsSinceEpoch;
  if (diff <= 0) return t('Пора повторить');
  final m = (diff / 60000).ceil();
  final n = m < 60 ? m : (m < 1440 ? (m / 60).round() : (m / 1440).round());
  final i = m < 60 ? 0 : (m < 1440 ? 1 : 2);
  if (uz) return '$n ${['daqiqadan', 'soatdan', 'kundan'][i]} keyin';
  return 'Повтор через $n ${['мин', 'ч', 'дн'][i]}';
}

class Store {
  late SharedPreferences p;
  List<Word> words = [];
  int coins = 0, streak = 0, todayCount = 0;
  String lang = 'ru', lastDay = '';

  Future<void> load() async {
    p = await SharedPreferences.getInstance();
    final s = p.getString('words');
    if (s != null) {
      words = (jsonDecode(s) as List)
          .map((e) => Word.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    coins = p.getInt('coins') ?? 0;
    streak = p.getInt('streak') ?? 0;
    todayCount = p.getInt('todayCount') ?? 0;
    lang = p.getString('lang') ?? 'ru';
    lastDay = p.getString('lastDay') ?? '';
    gLang = lang;
  }

  Future<void> save() async {
    await p.setString('words', jsonEncode(words.map((w) => w.toJson()).toList()));
    await p.setInt('coins', coins);
    await p.setInt('streak', streak);
    await p.setInt('todayCount', todayCount);
    await p.setString('lang', lang);
    await p.setString('lastDay', lastDay);
  }

  Future<void> reset() async {
    words = [];
    coins = 0;
    streak = 0;
    todayCount = 0;
    lastDay = '';
    await save();
  }

  String _day(DateTime d) => '${d.year}-${d.month}-${d.day}';

  void touchDay(int learned) {
    final now = DateTime.now();
    final today = _day(now);
    if (lastDay != today) {
      final y = _day(now.subtract(const Duration(days: 1)));
      streak = lastDay == y ? streak + 1 : 1;
      lastDay = today;
      todayCount = 0;
    }
    todayCount += learned;
  }

  int get todayShown => lastDay == _day(DateTime.now()) ? todayCount : 0;

  int get streakShown {
    final now = DateTime.now();
    if (lastDay == _day(now) || lastDay == _day(now.subtract(const Duration(days: 1)))) {
      return streak;
    }
    return 0;
  }

  int get dueCount {
    final n = DateTime.now().millisecondsSinceEpoch;
    return words.where((w) => w.due <= n).length;
  }

  int get knownCount => words.where((w) => w.known).length;

  /// Только те слова, которым пора (до 10 за раз).
  List<Word> get due {
    final n = DateTime.now().millisecondsSinceEpoch;
    final d = words.where((w) => w.due <= n).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    return d.take(10).toList();
  }

  /// Для кнопки на вкладке «Слова»: слова к повторению, а если их нет, любые.
  List<Word> practiceSet() {
    final d = due;
    if (d.isNotEmpty) return d;
    final all = List<Word>.of(words)..shuffle();
    return all.take(10).toList();
  }
}

class Api {
  static Future<String?> translate(String w, String lang) async {
    try {
      final u = Uri.parse(
          'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=$lang&dt=t&q=${Uri.encodeQueryComponent(w)}');
      final r = await http.get(u).timeout(const Duration(seconds: 10));
      final j = jsonDecode(r.body);
      final t = j[0][0][0] as String;
      if (t.trim().isNotEmpty) return t;
    } catch (_) {}
    try {
      final u = Uri.parse(
          'https://api.mymemory.translated.net/get?q=${Uri.encodeQueryComponent(w)}&langpair=en|$lang');
      final r = await http.get(u).timeout(const Duration(seconds: 10));
      final t = jsonDecode(r.body)['responseData']['translatedText'] as String;
      if (t.trim().isNotEmpty) return t;
    } catch (_) {}
    return null;
  }

  static Future<List<String>> images(String w) async {
    try {
      final u = Uri.parse(
          'https://api.openverse.org/v1/images/?q=${Uri.encodeQueryComponent(w)}&page_size=6&mature=false');
      final r = await http
          .get(u, headers: {'User-Agent': 'WordTen/1.0'})
          .timeout(const Duration(seconds: 12));
      final j = jsonDecode(r.body);
      return (j['results'] as List)
          .map((e) => (e['thumbnail'] ?? e['url']) as String?)
          .whereType<String>()
          .where((s) => s.startsWith('http'))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

// ───────────── Стеклянные виджеты ─────────────

class AppBackground extends StatefulWidget {
  const AppBackground({super.key});
  @override
  State<AppBackground> createState() => _BgState();
}

class _BgState extends State<AppBackground> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(seconds: 18))
        ..repeat(reverse: true);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Widget orb(double l, double tp, double size, Color col, bool dark) => Positioned(
      left: l,
      top: tp,
      child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                col.withOpacity(dark ? 0.5 : 0.65),
                col.withOpacity(0)
              ]))));

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final size = MediaQuery.of(context).size;
    return IgnorePointer(
        child: Stack(children: [
      Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: dark
                      ? const [Color(0xFF0D0B1C), Color(0xFF1A0F2E)]
                      : const [Color(0xFFE9E4FF), Color(0xFFFFE3F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight))),
      AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            final v = c.value;
            return Stack(children: [
              orb(-120 + 80 * v, -100 + 90 * v, 420, const Color(0xFF8B7BFF), dark),
              orb(size.width - 260 - 60 * v, size.height * 0.32 + 50 * v, 400,
                  const Color(0xFFFF8AC4), dark),
              orb(size.width * 0.1 + 70 * v, size.height - 330 - 60 * v, 400,
                  const Color(0xFF52D0FF), dark),
            ]);
          }),
    ]));
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final bool blur;
  final VoidCallback? onTap;
  final Color? tint;
  final BorderRadius? borderRadius;
  const Glass(
      {super.key,
      required this.child,
      this.radius = 24,
      this.padding = const EdgeInsets.all(16),
      this.blur = true,
      this.onTap,
      this.tint,
      this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final br = borderRadius ?? BorderRadius.circular(radius);
    Widget box = Container(
        padding: padding,
        decoration: BoxDecoration(
            color: tint ??
                (dark ? const Color(0x8A242040) : const Color(0x8CFFFFFF)),
            borderRadius: br,
            border: Border.all(
                color: dark ? const Color(0x26FFFFFF) : const Color(0xCCFFFFFF))),
        child: child);
    if (blur) {
      box = BackdropFilter(filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22), child: box);
    }
    Widget w = ClipRRect(borderRadius: br, child: box);
    if (onTap != null) {
      w = GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: w);
    }
    return w;
  }
}

class GBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool glass, expand;
  final IconData? icon;
  final double height;
  const GBtn(this.label,
      {super.key,
      this.onTap,
      this.glass = false,
      this.expand = false,
      this.icon,
      this.height = 52});

  @override
  Widget build(BuildContext context) {
    final fg = glass ? Theme.of(context).colorScheme.onSurface : Colors.white;
    return Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: GestureDetector(
            onTap: onTap,
            child: Container(
                height: height,
                width: expand ? double.infinity : null,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                    gradient: glass ? null : kAccent,
                    color: glass ? const Color(0x33808080) : null,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: glass
                        ? null
                        : const [
                            BoxShadow(
                                color: Color(0x590A84FF),
                                blurRadius: 18,
                                offset: Offset(0, 8))
                          ]),
                child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (icon != null) ...[Icon(icon, color: fg, size: 20), const SizedBox(width: 8)],
                  Flexible(
                      child: Text(label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: fg, fontWeight: FontWeight.w700, fontSize: 16))),
                ]))));
  }
}

class GlassSeg extends StatelessWidget {
  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;
  const GlassSeg(
      {super.key, required this.labels, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    final n = labels.length;
    return Glass(
        radius: 999,
        padding: const EdgeInsets.all(3),
        child: SizedBox(
            height: 40,
            child: Stack(children: [
              AnimatedAlign(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  alignment: Alignment(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
                  child: FractionallySizedBox(
                      widthFactor: 1 / n,
                      child: Container(
                          decoration: BoxDecoration(
                              gradient: kAccent,
                              borderRadius: BorderRadius.circular(999))))),
              Row(children: [
                for (int i = 0; i < n; i++)
                  Expanded(
                      child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(i),
                          child: Center(
                              child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: i == index ? Colors.white : fg),
                                  child: Text(labels[i]))))),
              ]),
            ])));
  }
}

Widget bigTitle(String title, [String? sub]) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 14),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title,
          style: const TextStyle(
              fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      if (sub != null)
        Text(sub, style: const TextStyle(fontSize: 15, color: Color(0xFF8E8CA0))),
    ]));

Color muted(BuildContext c) => Theme.of(c).colorScheme.onSurface.withOpacity(0.6);

Widget picFill(Word w, {double radius = 20}) {
  Widget letter = Center(
      child: Text(w.en.isEmpty ? '?' : w.en[0].toUpperCase(),
          style: const TextStyle(
              fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white)));
  return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
          decoration: BoxDecoration(gradient: wordGrad(w.en)),
          child: w.img == null
              ? letter
              : Image.network(w.img!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => letter,
                  loadingBuilder: (c, child, p) => p == null ? child : letter)));
}

Widget thumb(Word w, double size, {double radius = 16}) =>
    SizedBox(width: size, height: size, child: picFill(w, radius: radius));

Widget statChip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
        color: const Color(0x26808080), borderRadius: BorderRadius.circular(14)),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)));

Future<bool?> confirmSheet(BuildContext context, String title, String msg, String ok) {
  return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (c) => Padding(
          padding: const EdgeInsets.all(12),
          child: Glass(
              radius: 32,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(msg, textAlign: TextAlign.center, style: TextStyle(color: muted(c))),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: GBtn(t('Отмена'), glass: true, onTap: () => Navigator.pop(c, false))),
                  const SizedBox(width: 12),
                  Expanded(child: GBtn(ok, onTap: () => Navigator.pop(c, true))),
                ]),
              ]))));
}

// ───────────── Приложение ─────────────

class WordTenApp extends StatelessWidget {
  const WordTenApp({super.key});

  ThemeData _theme(Brightness b) {
    final cs = ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BDB), brightness: b);
    return ThemeData(
        useMaterial3: true,
        colorScheme: cs,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'WordTen',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        builder: (c, child) => Stack(children: [const AppBackground(), child!]),
        home: const Loader(),
      );
}

class Loader extends StatefulWidget {
  const Loader({super.key});
  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {
  late final Future<Store> f;
  @override
  void initState() {
    super.initState();
    f = () async {
      final s = Store();
      await s.load();
      return s;
    }();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Store>(
        future: f,
        builder: (c, snap) => snap.hasData
            ? Shell(store: snap.data!)
            : const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
}

class Shell extends StatefulWidget {
  final Store store;
  const Shell({super.key, required this.store});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  Store get s => widget.store;

  void refresh() => setState(() {});

  void toast(String m) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(t(m)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100)));
  }

  Future<bool> lesson(List<Word> ws, {required bool review}) async {
    final done = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => LessonPage(store: s, words: ws, review: review)));
    if (mounted) setState(() {});
    return done == true;
  }

  Future<void> startReview(List<Word> ws) async {
    if (ws.isEmpty) return;
    if (s.words.length < 2) {
      toast('Для повторения нужно минимум 2 выученных слова');
      return;
    }
    await lesson(ws, review: true);
  }

  @override
  Widget build(BuildContext context) {
    const icons = [Icons.school_outlined, Icons.menu_book_outlined, Icons.person_outline];
    const sel = [Icons.school, Icons.menu_book, Icons.person];
    const names = ['Учить', 'Слова', 'Профиль'];
    final accent = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: Stack(children: [
        SafeArea(
            bottom: false,
            child: IndexedStack(index: tab, children: [
              HomeTab(shell: this),
              WordsTab(shell: this),
              ProfileTab(shell: this),
            ])),
        Positioned(
            left: 18,
            right: 18,
            bottom: 14 + MediaQuery.of(context).padding.bottom,
            child: Glass(
                radius: 40,
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                    height: 56,
                    child: Stack(children: [
                      AnimatedAlign(
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutBack,
                          alignment: Alignment(tab - 1.0, 0),
                          child: FractionallySizedBox(
                              widthFactor: 1 / 3,
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0x33808080),
                                      borderRadius: BorderRadius.circular(999))))),
                      Row(children: [
                        for (int i = 0; i < 3; i++)
                          Expanded(
                              child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => setState(() => tab = i),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(tab == i ? sel[i] : icons[i],
                                            size: 24, color: tab == i ? accent : muted(context)),
                                        Text(t(names[i]),
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: tab == i ? accent : muted(context))),
                                      ]))),
                      ]),
                    ])))),
      ]),
    );
  }
}

// ───────────── Вкладка «Учить» ─────────────

class RingPainter extends CustomPainter {
  final double p;
  RingPainter(this.p);
  @override
  void paint(Canvas c, Size s) {
    final r = Rect.fromLTWH(5, 5, s.width - 10, s.height - 10);
    c.drawArc(
        r,
        0,
        2 * pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..color = const Color(0x33808080));
    c.drawArc(
        r,
        -pi / 2,
        2 * pi * p,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2)],
                  transform: GradientRotation(-pi / 2))
              .createShader(r));
  }

  @override
  bool shouldRepaint(RingPainter old) => old.p != p;
}

class HomeTab extends StatefulWidget {
  final _ShellState shell;
  const HomeTab({super.key, required this.shell});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Store get s => widget.shell.s;
  final List<TextEditingController> cs =
      List.generate(4, (_) => TextEditingController());
  bool busy = false;

  Future<void> start() async {
    final list = cs
        .map((c) => c.text.trim().toLowerCase())
        .where((x) => x.isNotEmpty)
        .toSet()
        .toList();
    if (list.isEmpty) {
      widget.shell.toast('Впиши хотя бы одно слово');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => busy = true);
    final ws = <Word>[];
    await Future.wait(list.map((w) async {
      final r = await Future.wait([
        Api.translate(w, 'ru'),
        Api.translate(w, 'uz'),
        Api.images(w),
      ]);
      final ru = r[0] as String?;
      final uzT = r[1] as String?;
      if (ru != null || uzT != null) {
        ws.add(Word(w, (ru ?? uzT!).toLowerCase(), (uzT ?? ru!).toLowerCase(),
            r[2] as List<String>));
      }
    }));
    if (!mounted) return;
    setState(() => busy = false);
    if (ws.isEmpty) {
      widget.shell.toast('Не получилось найти переводы. Проверь интернет.');
      return;
    }
    ws.sort((a, b) => list.indexOf(a.en).compareTo(list.indexOf(b.en)));
    final pool = ws.length + s.words.where((w) => !list.contains(w.en)).length;
    if (pool < 2) {
      widget.shell.toast('Нужно хотя бы 2 слова. Добавь ещё одно.');
      return;
    }
    final done = await widget.shell.lesson(ws, review: false);
    if (done && mounted) {
      for (final c in cs) {
        c.clear();
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = s.todayShown;
    final due = s.dueCount;
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 130), children: [
      bigTitle(t('Привет 👋'), t('Давай выучим пару новых слов')),
      Glass(
          radius: 28,
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(
                    painter: RingPainter((today / 10).clamp(0.0, 1.0).toDouble()),
                    child: Center(
                        child: Text('${min(today, 10)}/10',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))))),
            const SizedBox(width: 18),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t('Цель на сегодня'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(uz ? 'bugun $today ta soʻz' : 'выучено слов: $today',
                  style: TextStyle(color: muted(context))),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                statChip('🪙 ${s.coins}'),
                statChip('🔥 ${s.streakShown} ${uz ? 'kun' : 'дн.'}'),
                statChip('📚 ${s.words.length}'),
              ]),
            ])),
          ])),
      const SizedBox(height: 14),
      if (due > 0 && s.words.length >= 2)
        Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Glass(
                radius: 24,
                padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
                child: Row(children: [
                  Expanded(
                      child: Text(
                          uz
                              ? '⏰ Takrorlash vaqti: $due ta soʻz'
                              : '⏰ Пора повторить: $due ${ruPl(due)}',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                  GBtn(t('Повторить'),
                      height: 40, onTap: () => widget.shell.startReview(s.due)),
                ]))),
      Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Text(t('Новый урок'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(t('Впиши английские слова. Перевод и картинки найдутся сами.'),
              style: TextStyle(color: muted(context)))),
      const SizedBox(height: 10),
      GlassSeg(
          labels: const ['Русский', 'Oʻzbekcha'],
          index: uz ? 1 : 0,
          onChanged: (i) {
            s.lang = i == 0 ? 'ru' : 'uz';
            gLang = s.lang;
            s.save();
            widget.shell.refresh();
          }),
      const SizedBox(height: 12),
      for (int i = 0; i < cs.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(
                child: Glass(
                    radius: 999,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: cs[i],
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(fontSize: 17),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '${uz ? 'Soʻz' : 'Слово'} ${i + 1}',
                          icon: const Icon(Icons.edit_outlined, size: 20)),
                    ))),
            if (cs.length > 2)
              IconButton(
                  onPressed: () => setState(() => cs.removeAt(i)),
                  icon: const Icon(Icons.close)),
          ]),
        ),
      if (cs.length < 10)
        Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
                onPressed: () => setState(() => cs.add(TextEditingController())),
                icon: const Icon(Icons.add),
                label: Text(t('Добавить слово')))),
      const SizedBox(height: 8),
      GBtn(busy ? t('Ищу переводы и картинки…') : t('Начать урок'),
          expand: true, height: 56, onTap: busy ? null : start),
    ]);
  }
}

// ───────────── Вкладка «Мои слова» ─────────────

class WordsTab extends StatefulWidget {
  final _ShellState shell;
  const WordsTab({super.key, required this.shell});
  @override
  State<WordsTab> createState() => _WordsTabState();
}

class _WordsTabState extends State<WordsTab> {
  Store get s => widget.shell.s;
  String q = '';
  int filter = 0;

  void removeWord(Word w) {
    final i = s.words.indexOf(w);
    s.words.remove(w);
    s.save();
    widget.shell.refresh();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
          content: Text('«${w.en}»'),
          action: SnackBarAction(
              label: uz ? 'Bekor qilish' : 'Отменить',
              onPressed: () {
                s.words.insert(min(i < 0 ? 0 : i, s.words.length), w);
                s.save();
                widget.shell.refresh();
              })));
  }

  void detail(Word w) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setSheet) => Glass(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                child: SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                          color: const Color(0x66808080),
                          borderRadius: BorderRadius.circular(3))),
                  const SizedBox(height: 16),
                  GestureDetector(
                      onTap: () {
                        if (w.imgs.length > 1) {
                          setSheet(() => w.imgs.add(w.imgs.removeAt(0)));
                          s.save();
                          widget.shell.refresh();
                        }
                      },
                      child: thumb(w, 160, radius: 36)),
                  const SizedBox(height: 12),
                  Text(w.en,
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
                  Text(w.tr,
                      style: TextStyle(
                          fontSize: 22, color: Theme.of(ctx).colorScheme.primary)),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    for (int k = 1; k <= 5; k++)
                      Container(
                          width: 26,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                              color: k <= w.box ? Colors.green : const Color(0x44808080),
                              borderRadius: BorderRadius.circular(2))),
                  ]),
                  const SizedBox(height: 6),
                  Text(dueText(w), style: TextStyle(color: muted(ctx))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: GBtn(t('Послушать'),
                            glass: true,
                            icon: Icons.volume_up,
                            onTap: () => tts.speak(w.en))),
                    const SizedBox(width: 12),
                    Expanded(
                        child: GBtn(t('Повторить'),
                            icon: Icons.replay,
                            onTap: () {
                              Navigator.pop(ctx);
                              widget.shell.startReview([w]);
                            })),
                  ]),
                  TextButton(
                      onPressed: () async {
                        final ok = await confirmSheet(ctx, t('Удалить слово?'),
                            '«${w.en}»', t('Удалить'));
                        if (ok == true) {
                          if (ctx.mounted) Navigator.pop(ctx);
                          removeWord(w);
                        }
                      },
                      child: Text(t('Удалить'),
                          style: const TextStyle(
                              color: Colors.red, fontWeight: FontWeight.w600))),
                ])))));
  }

  @override
  Widget build(BuildContext context) {
    final ql = q.toLowerCase();
    final due = s.dueCount;
    final list = s.words.where((w) {
      final okQ = ql.isEmpty || w.en.contains(ql) || w.tr.toLowerCase().contains(ql);
      final okF = filter == 0 || (filter == 1 && !w.known) || (filter == 2 && w.known);
      return okQ && okF;
    }).toList().reversed.toList();

    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 130), children: [
      bigTitle(
          t('Мои слова'),
          uz
              ? 'Jami ${s.words.length} · Bilaman ${s.knownCount} · Takrorlash uchun $due'
              : 'Всего ${s.words.length} · Знаю ${s.knownCount} · К повторению $due'),
      GBtn(due > 0 ? '${t('Повторить')} ($due)' : t('Повторить слова'),
          icon: Icons.replay,
          expand: true,
          height: 54,
          onTap: s.words.isEmpty ? null : () => widget.shell.startReview(s.practiceSet())),
      const SizedBox(height: 12),
      Glass(
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: t('Поиск'),
                  icon: const Icon(Icons.search)))),
      const SizedBox(height: 10),
      GlassSeg(
          labels: [t('Все'), t('Учу'), t('Знаю')],
          index: filter,
          onChanged: (i) => setState(() => filter = i)),
      const SizedBox(height: 10),
      if (list.isEmpty)
        Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              Icon(Icons.menu_book_outlined, size: 56, color: muted(context)),
              const SizedBox(height: 12),
              Text(
                  s.words.isEmpty
                      ? t('Здесь появятся слова, которые ты выучишь. Пройди первый урок!')
                      : t('Ничего не найдено'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted(context))),
            ]))
      else
        for (final w in list)
          Dismissible(
            key: ValueKey(w.en),
            direction: DismissDirection.endToStart,
            background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                margin: const EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.red.shade400, borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => removeWord(w),
            child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Glass(
                    radius: 22,
                    blur: false,
                    padding: const EdgeInsets.all(10),
                    onTap: () => detail(w),
                    child: Row(children: [
                      thumb(w, 56),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(w.en,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(w.tr, style: TextStyle(color: muted(context))),
                        const SizedBox(height: 6),
                        Row(children: [
                          for (int k = 1; k <= 5; k++)
                            Container(
                                width: 14,
                                height: 4,
                                margin: const EdgeInsets.only(right: 3),
                                decoration: BoxDecoration(
                                    color: k <= w.box
                                        ? Colors.green
                                        : const Color(0x44808080),
                                    borderRadius: BorderRadius.circular(2))),
                        ]),
                      ])),
                      IconButton(
                          onPressed: () => tts.speak(w.en),
                          icon: const Icon(Icons.volume_up_outlined)),
                    ]))),
          ),
    ]);
  }
}

// ───────────── Вкладка «Профиль» ─────────────

class ProfileTab extends StatelessWidget {
  final _ShellState shell;
  const ProfileTab({super.key, required this.shell});
  Store get s => shell.s;

  Widget stat(BuildContext c, String emoji, String value, String label) => Expanded(
      child: Glass(
          radius: 24,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: muted(c), fontSize: 13)),
          ])));

  Widget ach(BuildContext c, String emoji, String label, bool on) => Opacity(
      opacity: on ? 1 : 0.45,
      child: SizedBox(
          width: 100,
          child: Glass(
              radius: 22,
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                Text(emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 4),
                Text(label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ]))));

  Widget lbRow(String m, String n, String p) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(children: [
        Text(m, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(n, style: const TextStyle(fontWeight: FontWeight.w600))),
        Text(p, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]));

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 130), children: [
      bigTitle(t('Профиль'), t('Твой прогресс')),
      Row(children: [
        stat(context, '🪙', '${s.coins}', t('монет')),
        const SizedBox(width: 12),
        stat(context, '🔥', '${s.streakShown}', t('дня подряд')),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        stat(context, '📚', '${s.words.length}', t('слов в словаре')),
        const SizedBox(width: 12),
        stat(context, '🏆', '${s.knownCount}', t('слов выучено')),
      ]),
      Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
          child: Text(t('Достижения'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            ach(context, '🌱', t('Первый урок'), s.words.isNotEmpty),
            const SizedBox(width: 10),
            ach(context, '🔥', t('3 дня подряд'), s.streakShown >= 3),
            const SizedBox(width: 10),
            ach(context, '⭐', uz ? '10 ta soʻz' : '10 слов', s.words.length >= 10),
            const SizedBox(width: 10),
            ach(context, '💎', uz ? '100 tanga' : '100 монет', s.coins >= 100),
          ])),
      Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
          child: Text(t('Язык перевода'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      GlassSeg(
          labels: const ['Русский', 'Oʻzbekcha'],
          index: uz ? 1 : 0,
          onChanged: (i) {
            s.lang = i == 0 ? 'ru' : 'uz';
            gLang = s.lang;
            s.save();
            shell.refresh();
          }),
      Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
          child: Text(t('Рейтинг учеников'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
      Glass(
          radius: 26,
          child: Stack(alignment: Alignment.center, children: [
            ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
                child: Column(children: [
                  lbRow('🥇', 'Аня', '1240'),
                  lbRow('🥈', 'Тимур', '980'),
                  lbRow('🥉', 'Мади', '760'),
                ])),
            Text('🔒 ${t('Скоро')}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ])),
      const SizedBox(height: 20),
      Center(
          child: TextButton(
              onPressed: () async {
                final ok = await confirmSheet(
                    context,
                    t('Сбросить прогресс?'),
                    t('Все слова, монеты и серия дней будут удалены.'),
                    t('Сбросить'));
                if (ok == true) {
                  await s.reset();
                  shell.refresh();
                }
              },
              child: Text(t('Сбросить прогресс'),
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)))),
    ]);
  }
}

// ───────────── Конфетти ─────────────

class _P {
  final double x, speed, delay, rot;
  final Color color;
  _P(this.x, this.speed, this.delay, this.rot, this.color);
}

class Confetti extends StatefulWidget {
  const Confetti({super.key});
  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
        ..forward();
  final rnd = Random();
  late final List<_P> ps = List.generate(
      40,
      (_) => _P(rnd.nextDouble(), 0.7 + rnd.nextDouble() * 0.6, rnd.nextDouble() * 0.4,
          rnd.nextDouble() * 6,
          HSVColor.fromAHSV(1, rnd.nextDouble() * 360, 0.85, 0.95).toColor()));

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
      child: AnimatedBuilder(
          animation: c,
          builder: (_, __) => CustomPaint(painter: _CP(ps, c.value), size: Size.infinite)));
}

class _CP extends CustomPainter {
  final List<_P> ps;
  final double v;
  _CP(this.ps, this.v);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in ps) {
      final tt = ((v - p.delay) / (1 - p.delay)).clamp(0.0, 1.0).toDouble();
      if (tt <= 0 || tt >= 1) continue;
      final y = -20 + tt * p.speed * (size.height + 40);
      final x = p.x * size.width + sin(tt * 6 + p.rot) * 20;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(tt * p.rot * 3);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: 9, height: 14),
          Paint()..color = p.color);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CP old) => old.v != v;
}

// ───────────── Урок ─────────────

enum Stage { intro, write, choose, speak, pic }

const stageNames = {
  Stage.intro: 'Знакомство',
  Stage.write: 'Напиши перевод',
  Stage.choose: 'Выбери перевод',
  Stage.speak: 'Произнеси слово',
  Stage.pic: 'Выбери картинку',
};

const stagePrompts = {
  Stage.intro: 'Запомни слово',
  Stage.write: 'Как переводится?',
  Stage.choose: 'Выбери правильный перевод',
  Stage.speak: 'Скажи слово вслух',
  Stage.pic: 'Найди картинку к слову',
};

class _Snap {
  final int st, total, earned;
  final List<int> queue;
  final Set<String> missed;
  _Snap(this.st, this.queue, this.total, this.earned, this.missed);
}

class LessonPage extends StatefulWidget {
  final Store store;
  final List<Word> words;
  final bool review;
  const LessonPage(
      {super.key, required this.store, required this.words, required this.review});
  @override
  State<LessonPage> createState() => _LessonState();
}

class _LessonState extends State<LessonPage> {
  late final List<Stage> stages;
  int st = 0, total = 1, earned = 0, stepId = 0;
  List<int> queue = [];
  List<Word> opts = [];
  final Set<String> missed = {};
  final List<_Snap> hist = [];
  final ctrl = TextEditingController();
  final stt = SpeechToText();
  bool answered = false, listening = false, finished = false, speechOk = false;
  bool? ok;
  String msg = '';
  Word? picked;

  Word get cur => widget.words[queue.first];

  @override
  void initState() {
    super.initState();
    stages = widget.review
        ? [Stage.choose, Stage.write, Stage.pic]
        : [Stage.intro, Stage.write, Stage.choose, Stage.speak, Stage.pic];
    startStage();
  }

  @override
  void dispose() {
    ctrl.dispose();
    tts.stop();
    stt.cancel();
    super.dispose();
  }

  void startStage() {
    if (st >= stages.length) {
      finish();
      return;
    }
    final idx = List.generate(widget.words.length, (i) => i);
    if (stages[st] != Stage.intro) idx.shuffle();
    queue = idx;
    total = idx.length;
    prepare();
  }

  void prepare() {
    hist.add(_Snap(st, List.of(queue), total, earned, Set.of(missed)));
    stepId++;
    answered = false;
    ok = null;
    msg = '';
    picked = null;
    listening = false;
    ctrl.clear();
    final w = cur;
    final stage = stages[st];
    if (stage == Stage.choose || stage == Stage.pic) {
      final pool = [
        ...widget.words,
        ...widget.store.words.where((x) => !widget.words.any((y) => y.en == x.en))
      ].where((x) => x.en != w.en && (stage == Stage.choose ? norm(x.tr) != norm(w.tr) : true));
      final cand = pool.toList()..shuffle();
      opts = [w, ...cand.take(3)]..shuffle();
    }
    if (stage == Stage.intro) tts.speak(w.en);
  }

  void back() {
    if (hist.length < 2) return;
    hist.removeLast();
    final p = hist.removeLast();
    setState(() {
      st = p.st;
      queue = List.of(p.queue);
      total = p.total;
      earned = p.earned;
      missed
        ..clear()
        ..addAll(p.missed);
      prepare();
    });
  }

  void mark(bool good, String m) {
    if (good) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
    }
    setState(() {
      answered = true;
      ok = good;
      msg = m;
      if (good) {
        if (!missed.contains(cur.en)) earned += 5;
      } else {
        missed.add(cur.en);
      }
    });
  }

  void advance(bool good) {
    if (!mounted) return;
    setState(() {
      final i = queue.removeAt(0);
      if (!good) queue.add(i);
      if (queue.isEmpty) {
        st++;
        startStage();
      } else {
        prepare();
      }
    });
  }

  void advanceLater(bool good, int ms) {
    final id = stepId;
    Future.delayed(Duration(milliseconds: ms), () {
      if (mounted && id == stepId) advance(good);
    });
  }

  Future<void> finish() async {
    final s = widget.store;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final w in widget.words) {
      final bad = missed.contains(w.en);
      if (widget.review) {
        w.box = bad ? 0 : min(w.box + 1, 5);
      } else {
        w.box = bad ? 0 : 1;
        w.added = now;
      }
      w.due = now + kIntervalMin[w.box] * 60000;
      if (!widget.review) {
        s.words.removeWhere((x) => x.en == w.en);
        s.words.add(w);
      }
    }
    earned += widget.review ? 10 : 20;
    s.coins += earned;
    s.touchDay(widget.review ? 0 : widget.words.length);
    finished = true;
    await s.save();
    if (mounted) setState(() {});
  }

  Future<void> askExit() async {
    final leave = await confirmSheet(context, t('Выйти из урока?'),
        t('Прогресс этого урока не сохранится.'), t('Выйти'));
    if (leave == true && mounted) Navigator.pop(context, false);
  }

  void checkWrite(Word w) {
    if (answered) return;
    final a = norm(ctrl.text);
    if (a.isEmpty) return;
    final good = norm(w.tr) == a || w.tr.split(RegExp(r'[,;]')).map(norm).contains(a);
    mark(good, good ? t('Верно!') : '${uz ? 'Toʻgʻri javob' : 'Правильно'}: ${w.tr}');
  }

  void pick(Word o) {
    if (answered) return;
    final good = o.en == cur.en;
    picked = o;
    mark(good, '');
    advanceLater(good, 1000);
  }

  Future<void> listen() async {
    if (!speechOk) {
      speechOk = await stt.initialize(onStatus: (s) {
        if ((s == 'done' || s == 'notListening') && mounted) {
          setState(() => listening = false);
        }
      }, onError: (_) {
        if (mounted) setState(() => listening = false);
      });
    }
    if (!speechOk) {
      setState(() => msg = t('Нет доступа к микрофону. Разреши его в настройках.'));
      return;
    }
    final target = norm(cur.en);
    setState(() {
      listening = true;
      msg = t('Слушаю…');
      ok = null;
    });
    await stt.listen(
        localeId: 'en_US',
        onResult: (r) {
          if (answered) return;
          final x = norm(r.recognizedWords);
          if (x.contains(target)) {
            stt.stop();
            mark(true, t('Отлично!'));
            advanceLater(true, 900);
          } else if (r.finalResult) {
            setState(() {
              listening = false;
              ok = false;
              msg = x.isEmpty
                  ? t('Не расслышал. Попробуй ещё')
                  : '${uz ? 'Eshitildi' : 'Услышал'}: «$x»';
            });
          }
        });
  }

  Widget feedback() => SizedBox(
      height: 34,
      child: Text(msg,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: ok == null ? null : (ok! ? Colors.green : Colors.red))));

  Widget speaker(Word w) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Glass(
          radius: 999,
          padding: EdgeInsets.zero,
          onTap: () => tts.speak(w.en),
          child: const SizedBox(
              width: 54, height: 54, child: Icon(Icons.volume_up_rounded, size: 26))));

  Widget optionTile({required Widget child, required VoidCallback onTap, int state = 0}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Glass(
              radius: 22,
              padding: const EdgeInsets.all(18),
              tint: state == 1
                  ? const Color(0xD925B660)
                  : state == 2
                      ? const Color(0xD9FF4D5E)
                      : null,
              onTap: onTap,
              child: SizedBox(
                  width: double.infinity,
                  child: Center(
                      child: DefaultTextStyle.merge(
                          style: TextStyle(color: state == 0 ? null : Colors.white),
                          child: child)))));

  int stateOf(Word o) {
    if (!answered) return 0;
    if (o.en == cur.en) return 1;
    if (identical(o, picked)) return 2;
    return 0;
  }

  Widget bodyFor(Stage stage, Word w) {
    final primary = Theme.of(context).colorScheme.primary;
    const big = TextStyle(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -0.5);
    switch (stage) {
      case Stage.intro:
        return Column(children: [
          GestureDetector(
              onTap: () => setState(() {
                    if (w.imgs.length > 1) w.imgs.add(w.imgs.removeAt(0));
                  }),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(44),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 16))
                      ]),
                  child: thumb(w, 210, radius: 44))),
          const SizedBox(height: 6),
          Text(t('Нажми на картинку, чтобы показать другую'),
              style: TextStyle(fontSize: 12, color: muted(context))),
          const SizedBox(height: 14),
          Text(w.en, style: big),
          ShaderMask(
              shaderCallback: (r) => kAccent.createShader(r),
              child: Text(w.tr,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white))),
          speaker(w),
          const Spacer(),
          GBtn(t('Дальше'), expand: true, height: 56, onTap: () => advance(true)),
        ]);
      case Stage.write:
        return SingleChildScrollView(
            child: Column(children: [
          const SizedBox(height: 16),
          Text(w.en, style: big),
          speaker(w),
          const SizedBox(height: 8),
          Glass(
              radius: 24,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                  controller: ctrl,
                  enabled: !answered,
                  autofocus: true,
                  autocorrect: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: t('Перевод')),
                  onSubmitted: (_) => checkWrite(w))),
          const SizedBox(height: 12),
          feedback(),
          const SizedBox(height: 12),
          GBtn(answered ? t('Дальше') : t('Проверить'),
              expand: true,
              height: 56,
              onTap: answered ? () => advance(ok == true) : () => checkWrite(w)),
        ]));
      case Stage.choose:
        return Column(children: [
          const SizedBox(height: 16),
          Text(w.en, style: big),
          speaker(w),
          const SizedBox(height: 4),
          for (final o in opts)
            optionTile(
                state: stateOf(o),
                onTap: () => pick(o),
                child: Text(o.tr,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700))),
        ]);
      case Stage.speak:
        return Column(children: [
          thumb(w, 170, radius: 40),
          const SizedBox(height: 12),
          Text(w.en, style: big),
          speaker(w),
          const Spacer(),
          GestureDetector(
              onTap: listening || answered ? null : listen,
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kAccent,
                      boxShadow: [
                        BoxShadow(
                            color: primary.withOpacity(listening ? 0.7 : 0.4),
                            blurRadius: listening ? 50 : 30,
                            spreadRadius: listening ? 10 : 0,
                            offset: const Offset(0, 12))
                      ]),
                  child: Icon(listening ? Icons.mic : Icons.mic_none,
                      color: Colors.white, size: 44))),
          const SizedBox(height: 16),
          feedback(),
          TextButton(onPressed: () => advance(true), child: Text(t('Пропустить'))),
        ]);
      case Stage.pic:
        return Column(children: [
          const SizedBox(height: 8),
          Text(w.en, style: big),
          const SizedBox(height: 12),
          Expanded(
              child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                for (final o in opts)
                  GestureDetector(
                      onTap: () => pick(o),
                      child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                  width: 4,
                                  color: stateOf(o) == 1
                                      ? Colors.green
                                      : stateOf(o) == 2
                                          ? Colors.red
                                          : Colors.transparent)),
                          child: picFill(o, radius: 24))),
              ])),
        ]);
    }
  }

  Widget resultScreen() {
    final m = missed.length;
    final stars = m == 0 ? 3 : (m <= 2 ? 2 : 1);
    return Scaffold(
        body: Stack(children: [
      const Positioned.fill(child: Confetti()),
      SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🎉', style: TextStyle(fontSize: 76)),
                const SizedBox(height: 8),
                Text(widget.review ? t('Повторение завершено!') : t('Урок завершён!'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (int i = 0; i < 3; i++)
                    TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: Duration(milliseconds: 500 + i * 250),
                        curve: Curves.elasticOut,
                        builder: (c, v, _) => Transform.scale(
                            scale: v,
                            child: Icon(
                                i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 52,
                                color: Colors.amber))),
                ]),
                const SizedBox(height: 20),
                Glass(
                    radius: 26,
                    child: SizedBox(
                        width: double.infinity,
                        child: Column(children: [
                          Text('+$earned ${t('монет')} 🪙',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('${t('Слов в уроке')}: ${widget.words.length} · ${t('Ошибок')}: $m',
                              style: TextStyle(color: muted(context))),
                          if (m > 0)
                            Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('${t('Сложные')}: ${missed.join(', ')}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: muted(context)))),
                        ]))),
                const SizedBox(height: 28),
                GBtn(t('Готово'),
                    expand: true, height: 56, onTap: () => Navigator.pop(context, true)),
              ]))),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    if (finished) return resultScreen();
    final stage = stages[st];
    final w = cur;
    final progress =
        ((st + (total - queue.length).clamp(0, total) / total) / stages.length)
            .clamp(0.0, 1.0)
            .toDouble();
    final canBack = hist.length >= 2;
    Widget circle(IconData i, VoidCallback? f) => Opacity(
        opacity: f == null ? 0.3 : 1,
        child: Glass(
            radius: 999,
            padding: EdgeInsets.zero,
            onTap: f,
            child: SizedBox(width: 42, height: 42, child: Icon(i, size: 22))));
    return Scaffold(
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(children: [
                Row(children: [
                  circle(Icons.chevron_left, canBack ? back : null),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: progress),
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                          builder: (c, v, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Stack(children: [
                                Container(height: 10, color: const Color(0x33808080)),
                                FractionallySizedBox(
                                    widthFactor: v,
                                    child: Container(
                                        height: 10,
                                        decoration: const BoxDecoration(gradient: kAccent))),
                              ])))),
                  const SizedBox(width: 10),
                  Glass(
                      radius: 999,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      child: Text('+$earned 🪙',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  const SizedBox(width: 10),
                  circle(Icons.close, askExit),
                ]),
                const SizedBox(height: 16),
                Text(t(stagePrompts[stage]!).toUpperCase(),
                    style: TextStyle(
                        color: muted(context),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6)),
                const SizedBox(height: 6),
                Expanded(
                    child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: KeyedSubtree(
                            key: ValueKey(stepId), child: bodyFor(stage, w)))),
              ]))),
    );
  }
}
