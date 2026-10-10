class TileSpot {
  final int x;
  final int y;
  final int layer;

  const TileSpot({required this.x, required this.y, required this.layer});
}

class MahjongRules {
  const MahjongRules._();

  /// A tile is free when no live tile covers it and either its left or right
  /// edge is open on the same layer.
  static bool isAvailable(int index, List<TileSpot> layout, Set<int> removed) {
    if (index < 0 || index >= layout.length || removed.contains(index)) {
      return false;
    }
    final spot = layout[index];
    for (var i = 0; i < layout.length; i++) {
      if (i == index || removed.contains(i)) continue;
      final other = layout[i];
      if (other.layer > spot.layer && other.x == spot.x && other.y == spot.y) {
        return false;
      }
    }
    final leftBlocked = layout.asMap().entries.any((entry) =>
        !removed.contains(entry.key) &&
        entry.key != index &&
        entry.value.layer == spot.layer &&
        entry.value.y == spot.y &&
        entry.value.x == spot.x - 1);
    final rightBlocked = layout.asMap().entries.any((entry) =>
        !removed.contains(entry.key) &&
        entry.key != index &&
        entry.value.layer == spot.layer &&
        entry.value.y == spot.y &&
        entry.value.x == spot.x + 1);
    return !leftBlocked || !rightBlocked;
  }


  /// A centered four-layer turtle-style board containing exactly 144 tiles.
  /// The layout has 96 base tiles, then 24, 16 and 8 tiles on upper terraces.
  static List<TileSpot> classicTurtleLayout() {
    final layout = <TileSpot>[];
    // Base layer silhouette: narrow tail, shoulders, wide shell, and head.
    final baseRows = <int, List<int>>{
      -1: [6, 7],
      0: List.generate(8, (i) => i + 3),
      1: List.generate(12, (i) => i + 1),
      2: List.generate(14, (i) => i),
      3: List.generate(14, (i) => i),
      4: List.generate(12, (i) => i + 1),
      5: List.generate(12, (i) => i + 1),
      6: List.generate(12, (i) => i + 1),
      7: List.generate(8, (i) => i + 3),
      8: [6, 7],
    };
    for (final row in baseRows.entries) {
      for (final x in row.value) {
        layout.add(TileSpot(x: x, y: row.key, layer: 0));
      }
    }
    for (var y = 2; y < 6; y++) {
      for (var x = 3; x < 9; x++) {
        layout.add(TileSpot(x: x, y: y, layer: 1));
      }
    }
    for (var y = 2; y < 6; y++) {
      for (var x = 4; x < 8; x++) {
        layout.add(TileSpot(x: x, y: y, layer: 2));
      }
    }
    for (var y = 2; y < 6; y++) {
      for (var x = 5; x < 7; x++) {
        layout.add(TileSpot(x: x, y: y, layer: 3));
      }
    }
    return layout;
  }

  /// Creates a legal peel order from the top layer down. Every row has even
  /// width, so repeatedly removing its left and right ends preserves access.
  static List<int> classicRemovalOrder(List<TileSpot> layout) {
    final order = <int>[];
    for (var layer = 3; layer >= 0; layer--) {
      final rows = layout
          .where((spot) => spot.layer == layer)
          .map((spot) => spot.y)
          .toSet()
          .toList()
        ..sort();
      for (final y in rows) {
        final row = layout.asMap().entries
            .where((entry) => entry.value.layer == layer && entry.value.y == y)
            .map((entry) => entry.key)
            .toList()
          ..sort((a, b) => layout[a].x.compareTo(layout[b].x));
        var left = 0;
        var right = row.length - 1;
        while (left < right) {
          order.add(row[left++]);
          order.add(row[right--]);
        }
      }
    }
    if (!isValidRemovalOrder(layout, order)) {
      throw StateError('Generated classic Mahjong removal order is invalid');
    }
    return order;
  }

  /// Checks a complete proposed removal order against the availability rules.
  static bool isValidRemovalOrder(List<TileSpot> layout, List<int> order) {
    if (order.length != layout.length || order.toSet().length != layout.length) {
      return false;
    }
    final removed = <int>{};
    for (final index in order) {
      if (!isAvailable(index, layout, removed)) return false;
      removed.add(index);
    }
    return true;
  }
}
