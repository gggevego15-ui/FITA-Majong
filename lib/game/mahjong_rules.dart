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
