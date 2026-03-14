import 'package:flutter/foundation.dart';

@immutable
class LiveGiftCatalogItem {
  final String id;
  final String name;
  final String assetPath;
  final double priceBuds;

  const LiveGiftCatalogItem({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.priceBuds,
  });
}

const List<LiveGiftCatalogItem> liveGiftCatalog = <LiveGiftCatalogItem>[
  LiveGiftCatalogItem(
    id: 'kiss',
    name: 'Kiss',
    assetPath: 'assets/gifts/kiss.png',
    priceBuds: 2,
  ),
  LiveGiftCatalogItem(
    id: 'kitty-paw',
    name: 'Kitty Paw',
    assetPath: 'assets/gifts/kitty_paw.png',
    priceBuds: 5,
  ),
  LiveGiftCatalogItem(
    id: 'waiby',
    name: 'Waiby',
    assetPath: 'assets/gifts/waiby.png',
    priceBuds: 10,
  ),
  LiveGiftCatalogItem(
    id: 'cake',
    name: 'Cake',
    assetPath: 'assets/gifts/cake.png',
    priceBuds: 25,
  ),
  LiveGiftCatalogItem(
    id: 'magic-bell',
    name: 'Magic Bell',
    assetPath: 'assets/gifts/magic_bell.png',
    priceBuds: 50,
  ),
  LiveGiftCatalogItem(
    id: 'rocket',
    name: 'Rocket',
    assetPath: 'assets/gifts/rocket.png',
    priceBuds: 100,
  ),
  LiveGiftCatalogItem(
    id: 'wubycar',
    name: 'WubyCar',
    assetPath: 'assets/gifts/wuby_car.png',
    priceBuds: 350,
  ),
  LiveGiftCatalogItem(
    id: 'dream-castle',
    name: 'Dream Castle',
    assetPath: 'assets/gifts/dream_castle.png',
    priceBuds: 1000,
  ),
];
