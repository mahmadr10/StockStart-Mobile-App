// lib/screens/learn_screen.dart
import 'package:flutter/material.dart';
import '../models/stock.dart';
import '../services/database_service.dart';
import '../utils/app_theme.dart';
import 'demo_trading_screen.dart';

// ─────────────────────────────────────────────────────────────
//  STATIC LESSON DATA
// ─────────────────────────────────────────────────────────────
class _Question {
  final String question;
  final List<String> options;
  final int correctIndex;
  const _Question({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class _Lesson {
  final String id;
  final String title;
  final String category;
  final String body;
  final int xp;
  final List<_Question> questions;
  const _Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.body,
    required this.xp,
    required this.questions,
  });
}

const _lessons = <_Lesson>[
  // ── BASICS ──────────────────────────────────────────────────
  _Lesson(
    id: 'basics_1', title: 'What Is a Stock?', category: 'BASICS',
    xp: 30,
    body: 'A stock represents a share of ownership in a company. '
        'When you buy a stock, you become a part-owner (shareholder) '
        'of that company and are entitled to a portion of its profits '
        'and assets. Companies issue stocks to raise capital for growth.',
    questions: [
      _Question(
        question: 'What does owning a stock mean?',
        options: ['You lent money to a company', 'You own a small piece of a company',
          'You are guaranteed profits', 'You manage the company'],
        correctIndex: 1,
      ),
      _Question(
        question: 'Why do companies issue stocks?',
        options: ['To pay employees', 'To raise capital for growth',
          'To reduce taxes', 'To buy competitors'],
        correctIndex: 1,
      ),
    ],
  ),
  _Lesson(
    id: 'basics_2', title: 'Reading Stock Prices', category: 'BASICS',
    xp: 30,
    body: 'Stock prices change constantly during market hours. '
        'The key figures are: Open (price at market open), Close '
        '(price at market close), High/Low (range for the day), and '
        'Volume (number of shares traded). The % change shows how '
        'much the price moved from the previous close.',
    questions: [
      _Question(
        question: 'What does "Volume" mean for a stock?',
        options: ['The company\'s total revenue', 'Number of shares traded in a period',
          'The highest price today', 'The market cap'],
        correctIndex: 1,
      ),
    ],
  ),

  // ── RISK MANAGEMENT ─────────────────────────────────────────
  _Lesson(
    id: 'risk_1', title: 'Risk and Volatility', category: 'RISK MANAGEMENT',
    xp: 40,
    body: 'Volatility measures how much a stock\'s price fluctuates. '
        'High-volatility stocks can give large gains but also large losses. '
        'Risk is the chance that an investment loses value. Always consider '
        'your risk tolerance — how much loss you can emotionally and '
        'financially handle — before investing.',
    questions: [
      _Question(
        question: 'A stock with HIGH volatility means:',
        options: ['It never loses value', 'Its price fluctuates a lot',
          'It pays regular dividends', 'It is a government bond'],
        correctIndex: 1,
      ),
      _Question(
        question: 'Risk tolerance refers to:',
        options: ['How fast you can trade', 'How much loss you can handle',
          'Your broker\'s fee', 'The stock\'s P/E ratio'],
        correctIndex: 1,
      ),
    ],
  ),
  _Lesson(
    id: 'risk_2', title: 'Diversification', category: 'RISK MANAGEMENT',
    xp: 40,
    body: 'Diversification means spreading investments across different '
        'assets, sectors, or geographies to reduce risk. If one investment '
        'falls, others may rise or hold steady, cushioning your overall '
        'portfolio. The saying "don\'t put all your eggs in one basket" '
        'perfectly captures this principle.',
    questions: [
      _Question(
        question: 'Diversification helps to:',
        options: ['Maximise short-term gains', 'Reduce overall portfolio risk',
          'Guarantee profits', 'Avoid paying taxes'],
        correctIndex: 1,
      ),
    ],
  ),

  // ── TECHNICAL ANALYSIS ──────────────────────────────────────
  _Lesson(
    id: 'tech_1', title: 'Understanding RSI', category: 'TECHNICAL ANALYSIS',
    xp: 50,
    body: 'The Relative Strength Index (RSI) is a momentum indicator '
        'ranging from 0 to 100. RSI above 70 suggests a stock is '
        'overbought (may fall soon). RSI below 30 suggests it is '
        'oversold (may rise soon). A neutral RSI is around 50.',
    questions: [
      _Question(
        question: 'An RSI of 80 suggests the stock is:',
        options: ['Oversold — likely to rise', 'Overbought — may fall soon',
          'At fair value', 'Highly volatile'],
        correctIndex: 1,
      ),
      _Question(
        question: 'What RSI range is considered neutral?',
        options: ['0–30', '30–50', 'Around 50', '70–100'],
        correctIndex: 2,
      ),
    ],
  ),
  _Lesson(
    id: 'tech_2', title: 'MACD Indicator', category: 'TECHNICAL ANALYSIS',
    xp: 50,
    body: 'MACD (Moving Average Convergence Divergence) measures the '
        'relationship between two EMAs (12-day and 26-day). When the '
        'MACD line crosses above the signal line, it is a bullish signal. '
        'When it crosses below, it is bearish. A positive MACD diff '
        'means upward momentum.',
    questions: [
      _Question(
        question: 'MACD crossing ABOVE the signal line means:',
        options: ['Bearish — sell signal', 'Bullish — buy signal',
          'No change expected', 'Stock is overbought'],
        correctIndex: 1,
      ),
    ],
  ),
  _Lesson(
    id: 'tech_3', title: 'Moving Averages', category: 'TECHNICAL ANALYSIS',
    xp: 50,
    body: 'A Moving Average (MA) smooths price data over a set period. '
        'The 50-day MA and 200-day MA are most common. When price is '
        'above the MA, the trend is bullish. When price crosses below '
        'the MA, it can signal a downtrend. A "Golden Cross" (50MA '
        'crossing above 200MA) is a strong buy signal.',
    questions: [
      _Question(
        question: 'A "Golden Cross" occurs when:',
        options: ['50-day MA crosses above 200-day MA',
          '200-day MA crosses above 50-day MA',
          'Price drops below all MAs', 'RSI reaches 100'],
        correctIndex: 0,
      ),
    ],
  ),
  _Lesson(
    id: 'tech_4', title: 'Bollinger Bands', category: 'TECHNICAL ANALYSIS',
    xp: 50,
    body: 'Bollinger Bands consist of a middle SMA and two bands '
        '2 standard deviations above and below. When price touches '
        'the upper band, the stock may be overbought. When it touches '
        'the lower band, it may be oversold. A narrow band width '
        'signals low volatility; a wide band signals high volatility.',
    questions: [
      _Question(
        question: 'Price touching the UPPER Bollinger Band suggests:',
        options: ['Strong buy signal', 'Stock may be overbought',
          'Low volatility period', 'Stock will definitely rise'],
        correctIndex: 1,
      ),
    ],
  ),

  // ── FUNDAMENTAL ANALYSIS ────────────────────────────────────
  _Lesson(
    id: 'fund_1', title: 'P/E Ratio Explained', category: 'FUNDAMENTAL ANALYSIS',
    xp: 45,
    body: 'The Price-to-Earnings (P/E) ratio compares a company\'s '
        'stock price to its earnings per share. A high P/E may mean '
        'the stock is overvalued or investors expect high growth. '
        'A low P/E can mean the stock is undervalued or the company '
        'is struggling. Context matters — compare P/E to industry peers.',
    questions: [
      _Question(
        question: 'A very high P/E ratio compared to peers suggests:',
        options: ['Stock is definitely cheap', 'Stock may be overvalued or high-growth expected',
          'Company has no debt', 'Strong dividend payments'],
        correctIndex: 1,
      ),
    ],
  ),
  _Lesson(
    id: 'fund_2', title: 'Market Capitalisation', category: 'FUNDAMENTAL ANALYSIS',
    xp: 35,
    body: 'Market cap = Share Price × Total Shares Outstanding. '
        'Large-cap (>\$10B) companies are usually stable. Mid-cap '
        '(\$2B–\$10B) offer growth potential. Small-cap (<\$2B) are '
        'riskier but can grow fast. Market cap helps classify a '
        'company\'s size and risk level.',
    questions: [
      _Question(
        question: 'How is market capitalisation calculated?',
        options: ['Revenue × Profit margin', 'Share price × Total shares outstanding',
          'Debt / Equity', 'Annual earnings × P/E'],
        correctIndex: 1,
      ),
    ],
  ),
];

// ─────────────────────────────────────────────────────────────
//  XP / LEVEL HELPERS
// ─────────────────────────────────────────────────────────────
const _levelNames = ['Beginner', 'Beginner', 'Beginner',
  'Apprentice', 'Apprentice', 'Intermediate',
  'Intermediate', 'Intermediate', 'Expert', 'Expert'];

String _rankName(int level) =>
    level < _levelNames.length ? _levelNames[level] : 'Expert';

int _xpForLevel(int level) => level * 100;

int _quizXp(int lessonXp, int totalQ) =>
    ((lessonXp * 0.5) / totalQ).round().clamp(10, 35);

// ─────────────────────────────────────────────────────────────
//  LEARN SCREEN
// ─────────────────────────────────────────────────────────────
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});
  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  int          _totalXp     = 0;
  int          _level       = 1;
  Set<String>  _doneLessons = {};

  final List<String> _quickPicks = ['AAPL', 'TSLA', 'NVDA', 'MSFT', 'AMZN'];
  final TextEditingController _searchCtrl = TextEditingController();
  String? _selectedTicker;
  List<Map<String, dynamic>> _recentTrades = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadProgress();
  }

  @override
  void dispose() {
    _tab.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    setState(() => _loading = true);
    try {
      final xp     = await DatabaseService.getLearnXp();
      final done   = await DatabaseService.getDoneLessons();
      final trades = await DatabaseService.getRecentDemoTrades();
      if (!mounted) return;
      setState(() {
        _totalXp     = xp;
        _doneLessons = done;
        _level       = _calcLevel(xp);
        _recentTrades = trades;
        _loading     = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addXp(int amount) async {
    final newXp = _totalXp + amount;
    await DatabaseService.setLearnXp(newXp);
    if (!mounted) return;
    setState(() {
      _totalXp = newXp;
      _level   = _calcLevel(newXp);
    });
  }

  Future<void> _markLessonDone(String id) async {
    if (_doneLessons.contains(id)) return;
    final updated = {..._doneLessons, id};
    await DatabaseService.setDoneLessons(updated);
    if (mounted) setState(() => _doneLessons = updated);
  }

  int _calcLevel(int xp) => (xp ~/ 100).clamp(1, 9);

  Future<void> _onReturnFromDemo() async {
    final trades = await DatabaseService.getRecentDemoTrades();
    if (!mounted) return;

    final prevCount = _recentTrades.length;
    final newCount  = trades.length;

    int award = 0;
    final tickers     = trades.map((t) => t['ticker'] as String).toSet();
    final prevTickers = _recentTrades.map((t) => t['ticker'] as String).toSet();

    if (prevCount == 0 && newCount > 0) award += 20;
    if (newCount >= 2 && prevCount < 2) {
      final types = trades.map((t) => t['type'] as String).toSet();
      if (types.contains('BUY') && types.contains('SELL')) award += 20;
    }
    if (tickers.length >= 2 && prevTickers.length < 2) award += 30;
    if (newCount >= 5  && prevCount < 5)  award += 25;
    if (newCount >= 10 && prevCount < 10) award += 40;

    setState(() => _recentTrades = trades);
    if (award > 0) {
      await _addXp(award);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('🏆 +$award XP earned from trading!'),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: const Text('Learn', style: TextStyle(
            color: AppTheme.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          tabs: const [Tab(text: 'Lessons'), Tab(text: 'Practice Trading')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : TabBarView(
        controller: _tab,
        children: [_buildLessonsTab(), _buildPracticeTab()],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  //  TAB 1 — LESSONS
  // ════════════════════════════════════════════════════════════
  Widget _buildLessonsTab() {
    final categories = _lessons.map((l) => l.category).toSet().toList();
    final xpToNext   = _xpForLevel(_level + 1) - _totalXp;
    final lvlProgress = (_totalXp % 100) / 100.0;
    final courseProgress = _doneLessons.length / _lessons.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ── LEVEL CARD ─────────────────────────────────────────
        _card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded,
                    color: AppTheme.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Level $_level — ${_rankName(_level)}',
                        style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800, fontSize: 18)),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lvlProgress,
                        backgroundColor: AppTheme.border,
                        color: AppTheme.primary, minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Level $_level',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                        Text('Level ${_level + 1}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$_totalXp XP',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800, fontSize: 20)),
                  Text('$xpToNext XP to next level',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),

        // ── COURSE PROGRESS ────────────────────────────────────
        _card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Course Progress',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                  Text('${_doneLessons.length} / ${_lessons.length} lessons',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: courseProgress,
                  backgroundColor: AppTheme.border,
                  color: AppTheme.primary, minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(courseProgress * 100).toInt()}% complete',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_rankName(_level),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
        ),

        // ── HOW TO EARN XP ─────────────────────────────────────
        _card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How to Earn XP',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 12),
              _xpRow(Icons.menu_book_rounded,   'Read a lesson',            '+15 XP base'),
              _xpRow(Icons.quiz_rounded,         'Pass lesson quiz',         '+15 to +35 XP'),
              _xpRow(Icons.show_chart_rounded,   'First demo trade',         '+20 XP'),
              _xpRow(Icons.swap_horiz_rounded,   'Buy AND sell once',        '+20 XP'),
              _xpRow(Icons.bar_chart_rounded,    'Trade 2 different stocks', '+30 XP'),
              _xpRow(Icons.trending_up_rounded,  '100 XP',                   '= Level Up'),
              const SizedBox(height: 8),
              const Text(
                'Rank: Beginner → Apprentice (Lvl 3) → '
                    'Intermediate (Lvl 5) → Expert (Lvl 8)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),

        // ── LESSONS BY CATEGORY ────────────────────────────────
        ...categories.map((cat) {
          final catLessons =
          _lessons.where((l) => l.category == cat).toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(cat,
                    style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2)),
              ),
              ...catLessons.map((lesson) => _LessonCard(
                lesson: lesson,
                isDone: _doneLessons.contains(lesson.id),
                onComplete: (xpEarned) async {
                  await _markLessonDone(lesson.id);
                  await _addXp(xpEarned);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('🎓 +$xpEarned XP earned!'),
                      backgroundColor: AppTheme.primary,
                      duration: const Duration(seconds: 2),
                    ));
                  }
                },
              )),
            ],
          );
        }),
      ],
    );
  }

  Widget _xpRow(IconData icon, String label, String xp) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13))),
        Text(xp,
            style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    ),
  );

  // ════════════════════════════════════════════════════════════
  //  TAB 2 — PRACTICE TRADING
  // ════════════════════════════════════════════════════════════
  Widget _buildPracticeTab() {
    final tradeCount = _recentTrades.length;
    final tickers = _recentTrades.map((t) => t['ticker'] as String).toSet();
    final types   = _recentTrades.map((t) => t['type'] as String).toSet();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // ── XP MILESTONES ──────────────────────────────────────
        _card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppTheme.primary, size: 22),
                const SizedBox(width: 8),
                const Text('Earn XP by Practice Trading',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ]),
              const SizedBox(height: 12),
              _milestoneRow(Icons.flag_rounded,
                  'Make your first trade', '+20 XP',
                  done: tradeCount >= 1),
              _milestoneRow(Icons.swap_horiz_rounded,
                  'Both BUY and SELL once', '+20 XP',
                  done: types.contains('BUY') && types.contains('SELL')),
              _milestoneRow(Icons.bar_chart_rounded,
                  'Trade 2 different stocks', '+30 XP',
                  done: tickers.length >= 2),
              _milestoneRow(Icons.emoji_events_rounded,
                  'Complete 5 trades', '+25 XP',
                  done: tradeCount >= 5),
              _milestoneRow(Icons.diamond_rounded,
                  'Complete 10 trades', '+40 XP',
                  done: tradeCount >= 10),
            ],
          ),
        ),

        // ── VIRTUAL BALANCE CARD ───────────────────────────────
        _card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          gradient: LinearGradient(
            colors: [AppTheme.primary.withOpacity(0.35), AppTheme.surface],
            begin: Alignment.centerLeft, end: Alignment.centerRight,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Virtual Balance',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                const Text('\$10,000.00',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800, fontSize: 26)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('Trading XP',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 4),
                Text('+$_totalXp XP',
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800, fontSize: 22)),
              ]),
            ],
          ),
        ),

        // ── QUICK PICK ─────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text('Quick Pick',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _quickPicks.length,
            itemBuilder: (_, i) {
              final t        = _quickPicks[i];
              final selected = _selectedTicker == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedTicker = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: selected ? AppTheme.primary : AppTheme.border,
                    ),
                  ),
                  child: Text(t,
                      style: TextStyle(
                          color: selected ? Colors.black : AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              );
            },
          ),
        ),

        // ── SEARCH ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.search,
            onSubmitted: (v) {
              if (v.trim().isNotEmpty) {
                setState(() => _selectedTicker = v.trim().toUpperCase());
              }
            },
            decoration: const InputDecoration(
              hintText: 'Search ticker (e.g. GOOGL) and press Enter',
              prefixIcon: Icon(Icons.search_rounded,
                  color: AppTheme.textSecondary),
            ),
          ),
        ),

        // ── TRADE PANEL ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: _selectedTicker == null
              ? _card(
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16),
                Icon(Icons.touch_app_rounded,
                    color: AppTheme.textSecondary, size: 36),
                SizedBox(height: 8),
                Text('Pick a stock above to start trading',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14)),
                SizedBox(height: 16),
              ],
            ),
          )
              : _TradePanelCard(
            ticker: _selectedTicker!,
            onTradeComplete: _onReturnFromDemo,
          ),
        ),

        // ── RECENT TRADES ──────────────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 8),
          child: Text('Recent Trades',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        if (_recentTrades.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No trades yet — pick a stock above!',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          )
        else
          ..._recentTrades.take(8).map((t) => _TradeRow(trade: t)),
      ],
    );
  }

  Widget _milestoneRow(IconData icon, String label, String xp,
      {required bool done}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon,
                color: done ? AppTheme.primary : AppTheme.textSecondary,
                size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: done
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                      fontSize: 14,
                      decoration:
                      done ? TextDecoration.lineThrough : null)),
            ),
            Text(xp,
                style: TextStyle(
                    color: done
                        ? AppTheme.textSecondary
                        : AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      );

  Widget _card({
    required Widget child,
    EdgeInsets margin = EdgeInsets.zero,
    Gradient? gradient,
  }) =>
      Container(
        margin: margin,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? AppTheme.surface : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: child,
      );
}

// ─────────────────────────────────────────────────────────────
//  LESSON CARD
// ─────────────────────────────────────────────────────────────
class _LessonCard extends StatelessWidget {
  final _Lesson lesson;
  final bool isDone;
  final Future<void> Function(int xpEarned) onComplete;

  const _LessonCard({
    required this.lesson,
    required this.isDone,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => _LessonDetailScreen(
            lesson: lesson,
            isDone: isDone,
            onComplete: onComplete,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDone
                ? AppTheme.primary.withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? AppTheme.primary.withOpacity(0.15)
                    : AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDone
                    ? Icons.check_circle_rounded
                    : Icons.menu_book_rounded,
                color: isDone ? AppTheme.primary : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      style: TextStyle(
                        color: isDone
                            ? AppTheme.primary
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      )),
                  const SizedBox(height: 3),
                  Text(
                    '${lesson.questions.length} '
                        '${lesson.questions.length == 1 ? 'question' : 'questions'}'
                        ' · ${lesson.xp} XP',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            isDone
                ? Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Done',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            )
                : Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('+${lesson.xp} XP',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  LESSON DETAIL + QUIZ SCREEN
// ─────────────────────────────────────────────────────────────
class _LessonDetailScreen extends StatefulWidget {
  final _Lesson lesson;
  final bool isDone;
  final Future<void> Function(int xpEarned) onComplete;

  const _LessonDetailScreen({
    required this.lesson,
    required this.isDone,
    required this.onComplete,
  });

  @override
  State<_LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<_LessonDetailScreen> {
  int  _phase      = -1;
  int? _selected;
  bool _answered   = false;
  int  _correct    = 0;
  bool _submitting = false;

  int get _totalQ => widget.lesson.questions.length;
  bool get _onQuiz => _phase >= 0 && _phase < _totalQ;
  _Question? get _currentQ =>
      _onQuiz ? widget.lesson.questions[_phase] : null;

  void _startQuiz() =>
      setState(() { _phase = 0; _selected = null; _answered = false; });

  void _checkAnswer() {
    if (_selected == null) return;
    setState(() {
      _answered = true;
      if (_selected == _currentQ!.correctIndex) _correct++;
    });
  }

  void _next() {
    if (_phase + 1 >= _totalQ) {
      _finish();
    } else {
      setState(() { _phase++; _selected = null; _answered = false; });
    }
  }

  Future<void> _finish() async {
    setState(() { _phase = _totalQ; _submitting = true; });
    final quizXpPer = _quizXp(widget.lesson.xp, _totalQ);
    final total = 15 + _correct * quizXpPer;
    await widget.onComplete(total);
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text(widget.lesson.title,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _phase == -1
              ? _buildReadingPhase()
              : _phase < _totalQ
              ? _buildQuizPhase()
              : _buildFinishPhase(),
        ),
      ),
    );
  }

  Widget _buildReadingPhase() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(widget.lesson.category,
            style: const TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w700, fontSize: 12)),
      ),
      const SizedBox(height: 16),
      Text(widget.lesson.title,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w800, fontSize: 22)),
      const SizedBox(height: 6),
      Text(
        '${_totalQ} ${_totalQ == 1 ? 'question' : 'questions'}'
            ' · ${widget.lesson.xp} XP',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
      ),
      const SizedBox(height: 24),
      Expanded(
        child: SingleChildScrollView(
          child: Text(widget.lesson.body,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 15, height: 1.7)),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _startQuiz,
        child: Text(
          widget.isDone ? 'Retake Quiz' : 'Start Quiz →',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );

  Widget _buildQuizPhase() {
    final q = _currentQ!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${_phase + 1} of $_totalQ',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          children: List.generate(_totalQ, (i) => Container(
            width: 28, height: 5,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: i <= _phase ? AppTheme.primary : AppTheme.border,
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
        const SizedBox(height: 24),
        Text(q.question,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 18, height: 1.4)),
        const SizedBox(height: 24),
        ...List.generate(q.options.length, (i) {
          Color borderColor = AppTheme.border;
          Color bgColor     = AppTheme.surface;
          Color textColor   = AppTheme.textPrimary;

          if (_answered) {
            if (i == q.correctIndex) {
              borderColor = AppTheme.primary;
              bgColor     = AppTheme.primary.withOpacity(0.12);
              textColor   = AppTheme.primary;
            } else if (i == _selected && i != q.correctIndex) {
              borderColor = AppTheme.danger;
              bgColor     = AppTheme.danger.withOpacity(0.10);
              textColor   = AppTheme.danger;
            }
          } else if (_selected == i) {
            borderColor = AppTheme.primary;
            bgColor     = AppTheme.primary.withOpacity(0.08);
          }

          return GestureDetector(
            onTap: _answered ? null : () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor, width: 1.5),
                      color: _selected == i && !_answered
                          ? AppTheme.primary
                          : Colors.transparent,
                    ),
                    child: _answered && i == q.correctIndex
                        ? const Icon(Icons.check_rounded,
                        color: AppTheme.primary, size: 16)
                        : _answered && i == _selected && i != q.correctIndex
                        ? const Icon(Icons.close_rounded,
                        color: AppTheme.danger, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(q.options[i],
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 15)),
                  ),
                ],
              ),
            ),
          );
        }),
        const Spacer(),
        if (!_answered)
          ElevatedButton(
            onPressed: _selected != null ? _checkAnswer : null,
            child: const Text('Submit Answer'),
          )
        else
          ElevatedButton(
            onPressed: _next,
            child: Text(_phase + 1 < _totalQ
                ? 'Next Question →'
                : 'See Results →'),
          ),
      ],
    );
  }

  Widget _buildFinishPhase() {
    final quizXpPer = _quizXp(widget.lesson.xp, _totalQ);
    final earned    = 15 + _correct * quizXpPer;
    final perfect   = _correct == _totalQ;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              perfect
                  ? Icons.emoji_events_rounded
                  : Icons.check_circle_rounded,
              color: AppTheme.primary,
              size: 72),
          const SizedBox(height: 16),
          Text(perfect ? 'Perfect Score! 🎉' : 'Lesson Complete!',
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w800, fontSize: 24)),
          const SizedBox(height: 8),
          Text('$_correct / $_totalQ correct',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: _submitting
                ? const CircularProgressIndicator(color: AppTheme.primary)
                : Text('+$earned XP Earned',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w800, fontSize: 22)),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Lessons'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TRADE PANEL CARD
// ─────────────────────────────────────────────────────────────
class _TradePanelCard extends StatelessWidget {
  final String ticker;
  final VoidCallback onTradeComplete;

  const _TradePanelCard({
    required this.ticker,
    required this.onTradeComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(ticker,
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              const Spacer(),
              const Text('Virtual Portfolio',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_upward_rounded,
                      size: 18, color: Colors.black),
                  label: const Text('BUY',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary),
                  onPressed: () => _openDemo(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_downward_rounded,
                      size: 18, color: Colors.white),
                  label: const Text('SELL',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.danger,
                  ),
                  onPressed: () => _openDemo(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openDemo(BuildContext context) async {
    final stock = Stock(
      ticker: ticker,
      name: ticker,
      price: 0,
      change: 0,
      riskLevel: 'Medium',
      status: 'Stable',
    );
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DemoTradingScreen(stock: stock),
      ),
    );
    onTradeComplete();
  }
}

// ─────────────────────────────────────────────────────────────
//  RECENT TRADE ROW
// ─────────────────────────────────────────────────────────────
class _TradeRow extends StatelessWidget {
  final Map<String, dynamic> trade;
  const _TradeRow({required this.trade});

  @override
  Widget build(BuildContext context) {
    final isBuy = (trade['type'] as String?) == 'BUY';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isBuy ? AppTheme.primary : AppTheme.danger)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBuy
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: isBuy ? AppTheme.primary : AppTheme.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trade['ticker'] as String? ?? '',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  '${trade['type']} · ${trade['shares']} shares',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '\$${(trade['price'] as num?)?.toStringAsFixed(2) ?? '--'}',
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ],
      ),
    );
  }
}