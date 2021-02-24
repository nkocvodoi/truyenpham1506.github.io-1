import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jlpt_testdate_countdown/src/env/application.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';

import '../../../env/application.dart';

part 'home.state.dart';

class HomeCubit extends Cubit<HomeState> {
  int imageIndex = Application.sharePreference.getInt("imageIndex") ?? 0;
  int lastImageIndex = Application.sharePreference.getInt("imageIndex") ?? 0;
  HomeCubit() : super(HomeInitial()) {
    DataConfig.imageAssetsLink.shuffle();
    emit(BackgroundImageChanged(DataConfig.imageAssetsLink[imageIndex],DataConfig.imageAssetsLink[lastImageIndex]));
  }

  void loadNewBackgroundImage() {
    if(imageIndex < DataConfig.imageAssetsLink.length -1){
      imageIndex++;
    }else {
      imageIndex =0;
    }
    Application.sharePreference.putInt("imageIndex", imageIndex);
    emit(BackgroundImageChanged(DataConfig.imageAssetsLink[imageIndex],DataConfig.imageAssetsLink[lastImageIndex]));
    Future.delayed(Duration(seconds: 1), () {
      lastImageIndex = imageIndex;
      emit(BackgroundImageChanged(DataConfig.imageAssetsLink[imageIndex],DataConfig.imageAssetsLink[lastImageIndex]));
    });



    // Future.delayed(Duration(seconds: 2), () => loadNewBackgroundImage());
  }

}
