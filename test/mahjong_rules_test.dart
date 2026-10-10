import 'package:flutter_test/flutter_test.dart';
import 'package:fita_mahjong/game/mahjong_rules.dart';

void main() {
  group('classic 144-tile layout', () {
    test('contains 144 tiles across four layers', () {
      final layout = MahjongRules.classicTurtleLayout();
      expect(layout, hasLength(144));
      expect(layout.where((tile) => tile.layer == 0), hasLength(96));
      expect(layout.where((tile) => tile.layer == 1), hasLength(24));
      expect(layout.where((tile) => tile.layer == 2), hasLength(16));
      expect(layout.where((tile) => tile.layer == 3), hasLength(8));
    });

    test('provides a complete legal removal order', () {
      final layout = MahjongRules.classicTurtleLayout();
      final order = MahjongRules.classicRemovalOrder(layout);
      expect(order, hasLength(144));
      expect(MahjongRules.isValidRemovalOrder(layout, order), isTrue);
    });
  });

  group('MahjongRules.isAvailable', () {
    test('allows an edge tile when the opposite side is open', () {
      const layout = [
        TileSpot(x: 0, y: 0, layer: 0),
        TileSpot(x: 1, y: 0, layer: 0),
        TileSpot(x: 2, y: 0, layer: 0),
      ];
      expect(MahjongRules.isAvailable(0, layout, <int>{}), isTrue);
      expect(MahjongRules.isAvailable(1, layout, <int>{}), isFalse);
      expect(MahjongRules.isAvailable(2, layout, <int>{}), isTrue);
    });

    test('a tile covered by an upper layer is blocked until cover is removed', () {
      const layout = [
        TileSpot(x: 0, y: 0, layer: 0),
        TileSpot(x: 0, y: 0, layer: 1),
      ];
      expect(MahjongRules.isAvailable(0, layout, <int>{}), isFalse);
      expect(MahjongRules.isAvailable(0, layout, <int>{1}), isTrue);
    });

    test('rejects removed and out-of-range tile indexes', () {
      const layout = [TileSpot(x: 0, y: 0, layer: 0)];
      expect(MahjongRules.isAvailable(0, layout, <int>{0}), isFalse);
      expect(MahjongRules.isAvailable(-1, layout, <int>{}), isFalse);
      expect(MahjongRules.isAvailable(1, layout, <int>{}), isFalse);
    });
  });

  group('MahjongRules.isValidRemovalOrder', () {
    const line = [
      TileSpot(x: 0, y: 0, layer: 0),
      TileSpot(x: 1, y: 0, layer: 0),
      TileSpot(x: 2, y: 0, layer: 0),
    ];

    test('accepts a legal complete removal order', () {
      expect(MahjongRules.isValidRemovalOrder(line, [0, 2, 1]), isTrue);
    });

    test('rejects orders that remove a blocked tile first', () {
      expect(MahjongRules.isValidRemovalOrder(line, [1, 0, 2]), isFalse);
    });

    test('rejects incomplete and duplicate orders', () {
      expect(MahjongRules.isValidRemovalOrder(line, [0, 2]), isFalse);
      expect(MahjongRules.isValidRemovalOrder(line, [0, 0, 2]), isFalse);
    });
  });
}
