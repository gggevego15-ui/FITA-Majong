import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FitaMahjongApp());

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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _providerNotice(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider sign-in is a placeholder. Provider credentials are not connected yet.')),
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
                        onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen())),
                        child: const Text('Play as guest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      )),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => _providerNotice(context, 'Google'),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                        label: const Text('Google'),
                        style: OutlinedButton.styleFrom(foregroundColor: pine, side: const BorderSide(color: Color(0xFFB8C9B5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton.icon(
                        onPressed: () => _providerNotice(context, 'Apple'),
                        icon: const Icon(Icons.apple_rounded, size: 22),
                        label: const Text('Apple'),
                        style: OutlinedButton.styleFrom(foregroundColor: pine, side: const BorderSide(color: Color(0xFFB8C9B5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 14)),
                      )),
                    ]),
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
                  final won = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => GameScreen(level: level)));
                  if (won == true && mounted) setState(() => level++);
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
            Expanded(child: _ModeCard(icon: Icons.emoji_events_rounded, title: 'Trail ranks', subtitle: 'Climb the leaderboard', color: const Color(0xFFC8DCC1), onTap: () => _message(context, 'Online leaderboards are not connected yet.'))),
          ]),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.people_alt_rounded, title: 'Play with a friend', subtitle: 'Race through the same layout', onTap: () => _message(context, 'Online multiplayer is planned; no live matches yet.')),
          const SizedBox(height: 12),
          _WideAction(icon: Icons.grid_view_rounded, title: 'Tile garden', subtitle: 'Explore patterns and tile sets', onTap: () => _message(context, 'More tile sets are coming in the next build.')),
          const SizedBox(height: 18),
          Center(child: Text('Breathe in. Match two. Breathe out.', style: TextStyle(color: pine.withOpacity(.7), fontStyle: FontStyle.italic))),
        ]))),
      ])),
    ]),
  );

  void _settings(BuildContext context) => showModalBottomSheet(context: context, backgroundColor: cream, showDragHandle: true, builder: (context) => StatefulBuilder(builder: (context, setSheet) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Little comforts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: pine)),
      const SizedBox(height: 12),
      SwitchListTile(value: sound, onChanged: (v) { setState(() => sound = v); setSheet(() {}); }, title: const Text('Sound effects'), secondary: const Icon(Icons.volume_up_rounded, color: pine)),
      SwitchListTile(value: haptics, onChanged: (v) { setState(() => haptics = v); setSheet(() {}); }, title: const Text('Haptic feedback'), secondary: const Icon(Icons.vibration_rounded, color: pine)),
      const SizedBox(height: 8),
      const Text('Settings are session-only in this prototype. Saved preferences will be added with local storage.', style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  )));

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class GameScreen extends StatefulWidget {
  final int level;
  const GameScreen({super.key, required this.level});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<String> tiles;
  final Set<int> removed = {};
  int? selected;
  int moves = 0;
  int seconds = 0;

  @override
  void initState() {
    super.initState();
    final symbols = ['🍃','🌼','🍄','🦋','🌿','🍐','🌸','🐝','🌙','🍀','🌻','🪷'];
    final rng = Random(widget.level * 19 + 7);
    tiles = [...symbols.take(8), ...symbols.take(8)]..shuffle(rng);
  }

  bool _exposed(int i) {
    if (removed.contains(i)) return false;
    // Simple one-layer prototype: every remaining tile is selectable.
    return true;
  }

  void _tap(int i) {
    if (!_exposed(i)) return;
    setState(() {
      if (selected == null) { selected = i; return; }
      if (selected == i) { selected = null; return; }
      moves++;
      if (tiles[selected!] == tiles[i]) {
        removed.add(selected!);
        removed.add(i);
        selected = null;
      } else {
        selected = i;
      }
    });
    if (removed.length == tiles.length) {
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) Navigator.of(context).pop(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: cream, foregroundColor: pine, title: Text('Garden · Level ${widget.level}', style: const TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
    body: Stack(children: [
      const Positioned.fill(child: NatureBackdrop()),
      SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Row(children: [
          _StatPill(label: 'MOVES', value: '$moves'),
          const Spacer(),
          _StatPill(label: 'PAIRS LEFT', value: '${(tiles.length - removed.length) ~/ 2}'),
        ]),
        const SizedBox(height: 18),
        Expanded(child: Center(child: Wrap(alignment: WrapAlignment.center, spacing: 8, runSpacing: 10, children: List.generate(tiles.length, (i) {
          final gone = removed.contains(i);
          final active = selected == i;
          return AnimatedOpacity(opacity: gone ? 0 : 1, duration: const Duration(milliseconds: 180), child: SizedBox(width: 66, height: 78, child: gone ? const SizedBox.shrink() : Material(
            color: active ? const Color(0xFFFFDDAA) : const Color(0xFFFFFDF6),
            elevation: active ? 7 : 2,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(borderRadius: BorderRadius.circular(15), onTap: () => _tap(i), child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: active ? peach : const Color(0xFFD5DFC9), width: active ? 2 : 1)),
              child: Center(child: Text(tiles[i], style: const TextStyle(fontSize: 29))),
            )),
          )));
        })))),
        const Text('Match two identical garden tiles', style: TextStyle(color: pine, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => setState(() { selected = null; }), icon: const Icon(Icons.close_rounded), label: const Text('Deselect'))),
          const SizedBox(width: 10),
          Expanded(child: FilledButton.icon(onPressed: () => setState(() { tiles.shuffle(Random(); selected = null; }), icon: const Icon(Icons.shuffle_rounded), label: const Text('Shuffle'))),
        ]),
      ]))),
    ]),
  );
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
  const NatureBackdrop({super.key});
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
    const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8F0DE), Color(0xFFFFF6E7), Color(0xFFF8E3CD)]))),
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
