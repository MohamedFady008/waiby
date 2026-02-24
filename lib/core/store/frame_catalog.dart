import 'package:flutter/foundation.dart';

@immutable
class FrameCatalogItem {
  final String id;
  final String name;
  final String assetPath;
  final double priceBuds;
  final bool giftable;

  const FrameCatalogItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.priceBuds,
    this.giftable = true,
  });
}

const List<FrameCatalogItem> frameCatalog = <FrameCatalogItem>[
  FrameCatalogItem(
    id: 'nautic_ring',
    name: 'Nautic Ring',
    assetPath: 'assets/medals/nautic_ring.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'goldbutterfly',
    name: 'Gold Butterfly',
    assetPath: 'assets/medals/goldbutterfly.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'happy_sprinkles',
    name: 'Happy Sprinkles',
    assetPath: 'assets/medals/happy_sprinkles.png',
    priceBuds: 9.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'lotus_aura',
    name: 'Lotus Aura',
    assetPath: 'assets/medals/lotus_aura.png',
    priceBuds: 15.99,
  ),
  FrameCatalogItem(
    id: 'lolita_pearl',
    name: 'Lolita Pearl',
    assetPath: 'assets/medals/lolita_pearl.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'steam_pipe',
    name: 'Steam Pipe',
    assetPath: 'assets/medals/steam_pipe.png',
    priceBuds: 9.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'golden',
    name: 'Golden',
    assetPath: 'assets/medals/golden.png',
    priceBuds: 9.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'aqua_ring',
    name: 'Aqua Ring',
    assetPath: 'assets/medals/aqua_ring.png',
    priceBuds: 9.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'luminova',
    name: 'Luminova',
    assetPath: 'assets/medals/luminova.png',
    priceBuds: 9.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'kittybloom',
    name: 'Kittybloom',
    assetPath: 'assets/medals/kittybloom.png',
    priceBuds: 15.99,
  ),
  FrameCatalogItem(
    id: 'aurealux_emblem',
    name: 'Aurealux Emblem',
    assetPath: 'assets/medals/aurealux_emblem.png',
    priceBuds: 15.99,
    giftable: false,
  ),
  FrameCatalogItem(
    id: 'moumou',
    name: 'Moumou',
    assetPath: 'assets/medals/moumou.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'boblin_treasure',
    name: 'Boblin Treasure',
    assetPath: 'assets/medals/boblin_treasure.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'demon1',
    name: 'Demon',
    assetPath: 'assets/medals/demon1.png',
    priceBuds: 9.99,
  ),
  FrameCatalogItem(
    id: 'sugarland',
    name: 'Sugarland',
    assetPath: 'assets/medals/sugarland.png',
    priceBuds: 15.99,
  ),
];

FrameCatalogItem? frameCatalogById(String? frameId) {
  if (frameId == null || frameId.trim().isEmpty) {
    return null;
  }
  final normalized = frameId.trim();
  for (final frame in frameCatalog) {
    if (frame.id == normalized) {
      return frame;
    }
  }
  return null;
}

String? frameAssetPathById(String? frameId) {
  return frameCatalogById(frameId)?.assetPath;
}
