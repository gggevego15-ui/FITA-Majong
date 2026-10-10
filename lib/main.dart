import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/auth_service.dart';
import 'services/progress_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.initialize();
  runApp(const FitaMahjongApp());
}

const pine = Color(0xFF244E42);
const leaf = Color(0xFF6F9E78);
const cream = Color(0xFFFFF7E8);
const peach = Color(0xFFF2B58E);
const ink = Color(0xFF263B32);

class FitaMahjongApp extends StatelessWidget {
  const FitaMahjongApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FITA Mahjong',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: cream,
          colorScheme: ColorScheme.fromSeed(seedColor: pine, brightness: Brightness.light),
          fontFamily: 'Roboto',
        ),
        home: const WelcomeScreen(),
      );
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _busy = false;

  Future<void> _continueAsGuest() async {
    setState(() => _busy = true);
    try {
      await AuthService.instance.continueAsGuest();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (error) {
      _notice('Guest mode could not start: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          children: [
            const Positioned.fill(child: NatureBackdrop()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(.82), borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.spa_rounded, color: pine, size: 28),
                        ),
                        const SizedBox(width: 12),
                        const Text('FITA', style: TextStyle(fontSize: 19, letterSpacing: 4, fontWeight: FontWeight.w900, color: pine)),
                        const Spacer(),
                        const Text('BETA 0.1', style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const Spacer(flex: 2),
                    const Icon(Icons.wb_twilight_rounded, size: 44, color: Color(0xFFD58D59)),
                    const SizedBox(height: 12),
                    const Text('A little calm,\none tile at a time.', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 34, height: 1.12, fontWeight: FontWeight.w900, color: pine, letterSpacing: -.8)),
                    const SizedBox(height: 12),
                    Text('Find your rhythm in a garden of puzzles.', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: pine.withOpacity(.78))),
                    const Spacer(flex: 2),
                    _TileShowcase(),
                    const SizedBox(height: 28),
                    SizedBox(width: double.infinity, height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                        onPressed: _busy ? null : _continueAsGuest,
                        child: Text(_busy ? 'Please wait…' : 'Play', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      )),
                    const SizedBox(height: 10),
                    Text('No account needed. Your journey starts here.', style: TextStyle(fontSize: 11, color: pine.withOpacity(.7))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int level = 1;
  bool sound = true;
  bool haptics = true;
  int backgroundTheme = 0;
  int tileTheme = 0;
  int animationLevel = 2;

  @override
  void initState() {
    super.initState();
    _restoreProgress();
  }

  Future<void> _restoreProgress() async {
    final saved = await ProgressStore.instance.load();
    if (!mounted) return;
    setState(() {
      level = (saved['level'] as num?)?.toInt() ?? 1;
      sound = saved['sound'] as bool? ?? true;
      haptics = saved['haptics'] as bool? ?? true;
    });
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      backgroundTheme = prefs.getInt('fita.theme.background') ?? 0;
      tileTheme = prefs.getInt('fita.theme.tiles') ?? 0;
      animationLevel = prefs.getInt('fita.animation.level') ?? 2;
    });
  }

  Future<void> _saveProgress() async {
    try {
      await ProgressStore.instance.save(
        level: level,
        sound: sound,
        haptics: haptics,
      );
    } catch (error) {
      if (mounted) _message(context, 'Saved on this device; cloud sync is unavailable right now.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      const Positioned.fill(child: NatureBackdrop()),
      SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 28), sliver: SliverList(delegate: SliverChildListDelegate([
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('GOOD DAY, PLAYER', style: TextStyle(fontSize: 10, letterSpacing: 2, color: pine, fontWeight: FontWeight.w800)),
              SizedBox(height: 5),
              Text('Your quiet corner', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: pine)),
            ]),
            const Spacer(),
            IconButton.filledTonal(onPressed: () => _settings(context), icon: const Icon(Icons.tune_rounded), style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.75), foregroundColor: pine)),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF47765D), Color(0xFF8AA77B)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: pine.withOpacity(.16), blurRadius: 24, offset: const Offset(0, 12))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('THE GARDEN PATH', style: TextStyle(color: Color(0xFFDDEACB), fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
                  SizedBox(height: 8),
                  Text('A fresh puzzle\nawaits you.', style: TextStyle(color: Colors.white, fontSize: 25, height: 1.12, fontWeight: FontWeight.w900)),
                ])),
                Container(width: 88, height: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(.16), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.park_rounded, color: Color(0xFFFFE4A8), size: 62)),
              ]),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 48, child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: cream, foregroundColor: pine, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: () async {
                  final won = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GameScreen(level: level, sound: sound, haptics: haptics, backgroundTheme: backgroundTheme, tileTheme: tileTheme, animationLevel: animationLevel)));
                  if (won == true && mounted) {
                    setState(() => level = level >= 10000 ? 10000 : level + 1);
                    await _saveProgress();
                  }
                },
                child: Text('Continue  ·  Level $level', style: const TextStyle(fontWeight: FontWeight.w900)),
              )),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('YOUR JOURNEY', style: TextStyle(fontSize: 11, letterSpacing: 2, color: pine, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _ModeCard(icon: Icons.auto_awesome_rounded, title: 'Daily dew', subtitle: 'A tiny daily challenge', color: const Color(0xFFF7D6A8), onTap: () => _message(context, 'Daily challenges are planned for a future update.'))),
            const SizedBox(width: 12),
            Expanded(child: _ModeCard(icon: Icons.emoji_events_rounded, title: 'Trail ranks', subtitle: 'Climb the leaderboard', color: const Color(0xFFC8DCC1), onTap: _showLeaderboard)),
          ]),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.people_alt_rounded, title: 'Play with a friend', subtitle: 'Race through the same layout', onTap: () => _message(context, 'Online multiplayer is planned; no live matches yet.')),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.grid_view_rounded, title: 'Tile garden', subtitle: 'Explore patterns and tile sets', onTap: () => _settings(context)),
          const SizedBox(height: 18),
          Center(child: Text('Breathe in. Match two. Breathe out.', style: TextStyle(color: pine.withOpacity(.7), fontStyle: FontStyle.italic))),
        ]))),
      ])),
    ]),
  );

  Future<void> _showLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('fita.leaderboard') ?? <String>[];
    if (!mounted) return;
    showModalBottomSheet<void>(context: context, backgroundColor: cream, showDragHandle: true, builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('🏆 Trail leaderboard', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: pine)),
        const SizedBox(height: 8),
        const Text('Best completed levels on this device', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 12),
        if (scores.isEmpty) const Padding(padding: EdgeInsets.all(18), child: Text('No records yet — finish your first level!')),
        ...scores.take(10).toList().asMap().entries.map((e) => ListTile(leading: CircleAvatar(backgroundColor: const Color(0xFFFFE4B5), child: Text('${e.key + 1}')), title: Text(e.value.split('|').first), subtitle: Text(e.value.contains('|') ? 'Level ${e.value.split('|').last}' : 'Completed'), dense: true)),
      ]),
    ));
  }

  void _settings(BuildContext context) => showModalBottomSheet(context: context, backgroundColor: cream, showDragHandle: true, builder: (context) => StatefulBuilder(builder: (context, setSheet) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Little comforts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine)),
      const SizedBox(height: 12),
      SwitchListTile(value: sound, onChanged: (v) { setState(() => sound = v); setSheet(() {}); _saveProgress(); }, title: const Text('Sound effects'), secondary: const Icon(Icons.volume_up_rounded, color: pine)),
      SwitchListTile(value: haptics, onChanged: (v) { setState(() => haptics = v); setSheet(() {}); _saveProgress(); }, title: const Text('Haptic feedback'), secondary: const Icon(Icons.vibration_rounded, color: pine)),
      const Divider(height: 20),
      const Text('BACKGROUND THEME', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, children: List.generate(4, (i) => GestureDetector(
        onTap: () async { setState(() => backgroundTheme = i); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setInt('fita.theme.background', i); },
        child: Container(width: 48, height: 42, decoration: BoxDecoration(gradient: LinearGradient(colors: [[const Color(0xFFE8F0DE), const Color(0xFFFFF6E7)], [const Color(0xFFFFD6E8), const Color(0xFFFFE7A8)], [const Color(0xFFB8F2E6), const Color(0xFFCDB4DB)], [const Color(0xFF171B45), const Color(0xFF302B63)]][i]), borderRadius: BorderRadius.circular(13), border: Border.all(color: backgroundTheme == i ? pine : Colors.white, width: backgroundTheme == i ? 3 : 1))),
      ))),
      const SizedBox(height: 14),
      const Text('TILE STYLE', style: TextStyle(fontSize: 11, letterSpacing: 1.5, color: pine, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Wrap(spacing: 10, children: List.generate(4, (i) => GestureDetector(
        onTap: () async { setState(() => tileTheme = i); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setInt('fita.theme.tiles', i); },
        child: Container(width: 48, height: 42, decoration: BoxDecoration(color: [[const Color(0xFFFFFDF6)], [const Color(0xFFFFD6E8)], [const Color(0xFFB8F2E6)], [const Color(0xFF22254B)]][i][0], borderRadius: BorderRadius.circular(13), border: Border.all(color: tileTheme == i ? pine : Colors.white, width: tileTheme == i ? 3 : 1)), child: Center(child: Text(['🌿','🌈','💎','✨'][i]))),
      ))),
      const SizedBox(height: 12),
      Row(children: [const Expanded(child: Text('Animation intensity', style: TextStyle(color: pine, fontWeight: FontWeight.w700))), Text(['Low','Normal','Extra'][animationLevel], style: const TextStyle(color: pine))]),
      Slider(value: animationLevel.toDouble(), min: 0, max: 2, divisions: 2, activeColor: pine, onChanged: (v) async { setState(() => animationLevel = v.round()); setSheet(() {}); final p = await SharedPreferences.getInstance(); await p.setInt('fita.animation.level', v.round()); }),
      const SizedBox(height: 8),
      const Text('Preferences are stored locally and sync to the cloud when Firebase is configured and the network is available.', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  )));

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class GameScreen extends StatefulWidget {
  final int level;
  final bool sound;
  final bool haptics;
  final int backgroundTheme;
  final int tileTheme;
  final int animationLevel;
  const GameScreen({super.key, required this.level, this.sound = true, this.haptics = true, this.backgroundTheme = 0, this.tileTheme = 0, this.animationLevel = 2});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  static const _tileSets = [
    ['🍃','🌼','🍄','🦋','🌿','🍐','🌸','🐝','🌙','🍀','🌻','🪷'],
    ['🌈','⭐','💖','🦄','🍭','🧁','🎀','🫧','🌟','🍬','💫','🩷'],
    ['💎','🔮','🪐','☄️','🌌','🧿','🪄','✨','🌙','💠','🌀','⭐'],
    ['🔥','⚡','🌊','🌪️','☀️','🌈','💥','🌟','🪩','💫','🧨','✨'],
  ];
  static const _tileColors = [
    [Color(0xFFFFFDF6), Color(0xFFFFE4B5), Color(0xFFE3EDD9), Color(0xFFD9E8EF)],
    [Color(0xFFFFD6E8), Color(0xFFFFA6A6), Color(0xFFFFE7A8), Color(0xFFCDB4DB)],
    [Color(0xFFB8F2E6), Color(0xFFBDE0FE), Color(0xFFCDB4DB), Color(0xFFFFC8DD)],
    [Color(0xFF22254B), Color(0xFF4C3F91), Color(0xFF00C9A7), Color(0xFFFFC857)],
  ];
  late List<String> tiles;
  int burst = 0;
  final Set<int> removed = {};
  int? selected;
  int? mismatch;
  int moves = 0;
  int pairs = 8;
  bool busy = false;
  bool finished = false;
  int? hintA;
  int? hintB;
  late final AnimationController _winController;
  late final Stopwatch _clock;
  Timer? _ticker;
  String get elapsed {
    final s = _clock.elapsed.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _winController = AnimationController(vsync: this, duration: const Duration(milliseconds: 850));
    _clock = Stopwatch()..start();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !finished) setState(() {});
    });
    _newBoard();
  }

  void _newBoard() {
    final symbols = _tileSets[widget.tileTheme.clamp(0, 3)].take(8).toList();
    final rng = Random(widget.level * 19 + DateTime.now().millisecondsSinceEpoch % 997);
    tiles = [...symbols, ...symbols]..shuffle(rng);
    removed.clear();
    selected = null;
    mismatch = null;
    hintA = null;
    hintB = null;
    moves = 0;
    pairs = 8;
    busy = false;
    finished = false;
    _clock
      ..reset()
      ..start();
  }

  void _feedback({bool success = false}) {
    if (widget.haptics) {
      if (success) {
        // Two light taps communicate a successful match without being intrusive.
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
    if (widget.sound) {
      SystemSound.play(success ? SystemSoundType.alert : SystemSoundType.click);
    }
  }

  Future<void> _tap(int i) async {
    if (busy || finished || removed.contains(i)) return;
    if (selected == i) {
      setState(() => selected = null);
      return;
    }
    if (selected == null) {
      setState(() {
        selected = i;
        hintA = null;
        hintB = null;
      });
      _feedback();
      return;
    }

    final first = selected!;
    setState(() {
      moves++;
      hintA = null;
      hintB = null;
    });
    if (tiles[first] == tiles[i]) {
      _feedback(success: true);
      setState(() { burst++;
        removed.add(first);
        removed.add(i);
        selected = null;
        pairs--;
      });
      if (pairs == 0) {
        finished = true;
        _clock.stop();
        _winController.forward(from: 0);
        if (mounted) _showWin();
      }
    } else {
      _feedback();
      setState(() {
        mismatch = i;
        busy = true;
      });
      await Future.delayed(const Duration(milliseconds: 420));
      if (!mounted) return;
      setState(() {
        mismatch = null;
        selected = null;
        busy = false;
      });
    }
  }

  void _hint() {
    if (busy || finished) return;
    for (var i = 0; i < tiles.length; i++) {
      if (removed.contains(i)) continue;
      for (var j = i + 1; j < tiles.length; j++) {
        if (!removed.contains(j) && tiles[i] == tiles[j]) {
          setState(() {
            selected = null;
            hintA = i;
            hintB = j;
          });
          if (widget.haptics) HapticFeedback.selectionClick();
          return;
        }
      }
    }
  }

  void _shuffle() {
    if (busy || finished) return;
    setState(() {
      final remaining = <String>[];
      for (var i = 0; i < tiles.length; i++) {
        if (!removed.contains(i)) remaining.add(tiles[i]);
      }
      remaining.shuffle(Random(DateTime.now().millisecondsSinceEpoch));
      var cursor = 0;
      for (var i = 0; i < tiles.length; i++) {
        if (!removed.contains(i)) tiles[i] = remaining[cursor++];
      }
      selected = null;
      mismatch = null;
      hintA = null;
      hintB = null;
    });
    _feedback();
  }

  void _showWin() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final scores = prefs.getStringList('fita.leaderboard') ?? <String>[];
    final record = 'Player|Level ${widget.level}';
    if (!scores.contains(record)) {
      scores.insert(0, record);
      await prefs.setStringList('fita.leaderboard', scores.take(20).toList());
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ScaleTransition(
        scale: CurvedAnimation(parent: _winController, curve: Curves.elasticOut),
        child: AlertDialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          icon: const Icon(Icons.celebration_rounded, size: 48, color: Color(0xFFD58D59)),
          title: const Text('Garden restored!', textAlign: TextAlign.center, style: TextStyle(color: pine, fontWeight: FontWeight.w900)),
          content: Text('You matched every pair in $moves moves · $elapsed', textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop(true);
              },
              child: const Text('Next level'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _winController.dispose();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: cream,
      foregroundColor: pine,
      title: Text('Garden · Level ${widget.level}', style: const TextStyle(fontWeight: FontWeight.w900)),
      centerTitle: true,
      actions: [
        IconButton(tooltip: 'Hint', onPressed: _hint, icon: const Icon(Icons.lightbulb_outline_rounded)),
      ],
    ),
    body: Stack(children: [
      Positioned.fill(child: NatureBackdrop(theme: widget.backgroundTheme)),
      if (burst > 0) Positioned.fill(child: _BurstOverlay(key: ValueKey(burst), intense: widget.animationLevel == 2)),
      SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 16), child: Column(children: [
        Row(children: [
          _StatPill(label: 'MOVES', value: '$moves'),
          const Spacer(),
          _StatPill(label: 'TIME', value: elapsed),
          const Spacer(),
          _StatPill(label: 'PAIRS', value: '$pairs'),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(.72), borderRadius: BorderRadius.circular(14)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.spa_rounded, color: leaf, size: 18),
            const SizedBox(width: 8),
            Text(finished ? 'Beautifully done!' : 'Find two matching garden tiles', style: const TextStyle(color: pine, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 12),
        Expanded(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420, maxHeight: 500),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(5),
            itemCount: tiles.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 9,
              childAspectRatio: .78,
            ),
            itemBuilder: (context, i) {
              final gone = removed.contains(i);
              final active = selected == i;
              final hinted = hintA == i || hintB == i;
              final wrong = mismatch == i || mismatch == selected;
              return AnimatedScale(
                scale: gone ? .72 : active ? 1.04 : 1,
                duration: const Duration(milliseconds: 190),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: gone ? 0 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: gone
                      ? const SizedBox.shrink()
                      : _GardenTile(
                          symbol: tiles[i],
                          tileTheme: widget.tileTheme,
                          animationLevel: widget.animationLevel,
                          selected: active,
                          hinted: hinted,
                          wrong: wrong,
                          onTap: () => _tap(i),
                        ),
                ),
              );
            },
          ),
        ))),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: busy || finished ? null : () => setState(() { selected = null; hintA = null; hintB = null; }),
            icon: const Icon(Icons.close_rounded), label: const Text('Deselect'),
          )),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(
            onPressed: busy || finished ? null : _shuffle,
            style: FilledButton.styleFrom(backgroundColor: pine, foregroundColor: Colors.white),
            icon: const Icon(Icons.shuffle_rounded), label: const Text('Shuffle'),
          )),
        ]),
      ]))),
    ]),
  );
}

class _BurstOverlay extends StatefulWidget {
  final bool intense;
  const _BurstOverlay({super.key, this.intense = true});
  @override
  State<_BurstOverlay> createState() => _BurstOverlayState();
}
class _BurstOverlayState extends State<_BurstOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  @override
  void initState() {
    super.initState();
    final r = Random();
    _particles = List.generate(widget.intense ? 34 : 16, (_) => _Particle(
      angle: r.nextDouble() * pi * 2, distance: 55 + r.nextDouble() * 190,
      size: 5 + r.nextDouble() * 10,
      color: [const Color(0xFFFF4D8D), const Color(0xFFFFC857), const Color(0xFF00C9A7), const Color(0xFF7B61FF), Colors.white][r.nextInt(5)],
    ));
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.intense ? 850 : 500))..forward();
  }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(animation: _controller, builder: (_, __) => CustomPaint(painter: _BurstPainter(_particles, _controller.value))));
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}
class _Particle {
  final double angle, distance, size;
  final Color color;
  const _Particle({required this.angle, required this.distance, required this.size, required this.color});
}
class _BurstPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _BurstPainter(this.particles, this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (final p in particles) {
      final t = Curves.easeOutCubic.transform(progress);
      final point = center + Offset(cos(p.angle) * p.distance * t, sin(p.angle) * p.distance * t);
      canvas.drawCircle(point, p.size * (1 - progress * .35), Paint()..color = p.color.withOpacity((1 - progress).clamp(0.0, 1.0)));
    }
  }
  @override
  bool shouldRepaint(covariant _BurstPainter oldDelegate) => oldDelegate.progress != progress;
}

class _GardenTile extends StatelessWidget {
  final String symbol;
  final int tileTheme;
  final int animationLevel;
  final bool selected;
  final bool hinted;
  final bool wrong;
  final VoidCallback onTap;
  const _GardenTile({required this.symbol, this.tileTheme = 0, this.animationLevel = 2, required this.selected, required this.hinted, required this.wrong, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tileColors = _GameScreenState._tileColors[tileTheme.clamp(0, 3)];
    final borderColor = wrong
        ? const Color(0xFFD77B66)
        : selected
            ? const Color(0xFFD58D59)
            : hinted
                ? const Color(0xFF6F9E78)
                : const Color(0xFFD5DFC9);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? tileColors[1] : tileColors[0],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: selected || hinted || wrong ? 2.5 : 1),
        boxShadow: [
          BoxShadow(color: pine.withOpacity(selected ? .2 : .1), blurRadius: selected ? 13 : 6, offset: Offset(0, selected ? 6 : 3)),
          const BoxShadow(color: Colors.white, blurRadius: 0, offset: Offset(-1, -1)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(children: [
            Positioned(top: 7, left: 8, child: Icon(Icons.circle, size: 5, color: borderColor.withOpacity(.7))),
            Positioned(bottom: 7, right: 8, child: Icon(Icons.circle, size: 5, color: borderColor.withOpacity(.7))),
            Center(child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: FadeTransition(opacity: animation, child: child)),
              child: Text(symbol, key: ValueKey(symbol), style: const TextStyle(fontSize: 30)),
            )),
            if (hinted)
              const Positioned(right: 5, top: 4, child: Icon(Icons.auto_awesome_rounded, size: 14, color: leaf)),
          ]),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: Colors.white.withOpacity(.8), borderRadius: BorderRadius.circular(15)), child: Column(children: [Text(label, style: const TextStyle(fontSize: 9, letterSpacing: 1, color: pine, fontWeight: FontWeight.w800)), Text(value, style: const TextStyle(fontSize: 19, color: pine, fontWeight: FontWeight.w900))]));
}

class _ModeCard extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final Color color; final VoidCallback onTap;
  const _ModeCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: color, borderRadius: BorderRadius.circular(22), child: InkWell(borderRadius: BorderRadius.circular(22), onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: pine, size: 25), const SizedBox(height: 18), Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: pine, fontSize: 16)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(color: pine.withOpacity(.75), fontSize: 11, height: 1.3))]))));
}

class _WideAction extends StatelessWidget {
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  const _WideAction({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white.withOpacity(.82), borderRadius: BorderRadius.circular(18), child: InkWell(borderRadius: BorderRadius.circular(18), onTap: onTap, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFFE1EBD9), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: pine)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: pine, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: pine.withOpacity(.7), fontSize: 12))])), const Icon(Icons.chevron_right_rounded, color: pine)]))));
}

class _TileShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [('🍃', const Color(0xFFE3EDD9)), ('🌼', const Color(0xFFFFE7AF)), ('🍄', const Color(0xFFF6D8C8)), ('🦋', const Color(0xFFD9E8EF))];
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: data.map((e) => Transform.rotate(angle: (data.indexOf(e) - 1.5) * .07, child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 61, height: 72, decoration: BoxDecoration(color: e.$2, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white, width: 2), boxShadow: [BoxShadow(color: pine.withOpacity(.12), blurRadius: 8, offset: const Offset(0, 5))]), child: Center(child: Text(e.$1, style: const TextStyle(fontSize: 27)))))).toList());
  }
}

class NatureBackdrop extends StatelessWidget {
  final int theme;
  const NatureBackdrop({super.key, this.theme = 0});
  static const _gradients = [
    [Color(0xFFE8F0DE), Color(0xFFFFF6E7), Color(0xFFF8E3CD)],
    [Color(0xFFFFD6E8), Color(0xFFFFE7A8), Color(0xFFFFA6A6)],
    [Color(0xFFB8F2E6), Color(0xFFBDE0FE), Color(0xFFCDB4DB)],
    [Color(0xFF171B45), Color(0xFF302B63), Color(0xFF24243E)],
  ];
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: _gradients[theme.clamp(0, 3)]))),
    Positioned(top: 120, right: -65, child: _Sun()),
    Positioned(bottom: -95, left: -65, child: _Hill(width: 310, height: 250, color: const Color(0xFFC7D9B5))),
    Positioned(bottom: -115, right: -45, child: _Hill(width: 330, height: 260, color: const Color(0xFF9EBB91))),
    Positioned(bottom: -145, left: 80, child: _Hill(width: 340, height: 260, color: const Color(0xFF7F9F7A))),
  ]);
}

class _Sun extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFFD9A1).withOpacity(.6)));
}
class _Hill extends StatelessWidget {
  final double width; final double height; final Color color;
  const _Hill({required this.width, required this.height, required this.color});
  @override
  Widget build(BuildContext context) => Container(width: width, height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.all(Radius.elliptical(width, height))));
}
