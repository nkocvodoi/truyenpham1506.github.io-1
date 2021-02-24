import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import '../utils/sizeconfig.dart';

class DataConfig {
  static final List<AssetImage> imageAssetsLink = <AssetImage>[
    AssetImage("assets/background/background1.jpg"),
    AssetImage("assets/background/background2.jpg"),
    AssetImage("assets/background/background3.jpg"),
    AssetImage("assets/background/background4.jpg"),
    AssetImage("assets/background/background5.jpg"),
    AssetImage("assets/background/background6.jpg"),
    AssetImage("assets/background/background7.jpg"),
    AssetImage("assets/background/background8.jpg"),
    AssetImage("assets/background/background9.jpg"),
    AssetImage("assets/background/background10.jpg"),

  ];

  static final List<MediaItem> musicItems = <MediaItem>[
    MediaItem(
      id: "https://minigames.saokhuee.com/audios/game/3e826a4e5ef06ac7decbd575ceb00e86.mp3",
      album: "",
      title: "Stitches",
      artist: "Shawn Mendes",
      artUri: "https://minigames.saokhuee.com/images/game/afe5af25a6fb462fcf832b1e026df3b4.jpg",
    ),
  ];

  static final testDate = DateTime(2021,6,25);
}

class AppText{
  static final fontSize20 = SizeConfig.safeBlockHorizontal * 6;
  static final fontSize18 = SizeConfig.safeBlockHorizontal * 5;
  static final fontSize10 = SizeConfig.safeBlockHorizontal * 3;
  static final fontSize30 = SizeConfig.safeBlockHorizontal * 8;
}
