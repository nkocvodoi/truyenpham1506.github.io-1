import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jlpt_testdate_countdown/src/app/components/musicplayer.dart';
import 'package:jlpt_testdate_countdown/src/app/home/cubit/counter.cubit.dart';
import 'package:jlpt_testdate_countdown/src/app/home/cubit/home.cubit.dart';
import 'package:jlpt_testdate_countdown/src/resources/data.dart';
import 'package:jlpt_testdate_countdown/src/utils/sizeconfig.dart';

import '../../resources/data.dart';

import '../../utils/sizeconfig.dart';

import 'cubit/home.cubit.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  CarouselController buttonCarouselController = CarouselController();
  HomeCubit _homeCubit = HomeCubit();
  CounterCubit _counterCubit = CounterCubit();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: Container(
        height: SizeConfig.screenHeight,
        child: Stack(
          children: <Widget>[
            BlocBuilder<HomeCubit, HomeState>(
                cubit: _homeCubit,
                buildWhen: (prev, now) => now is BackgroundImageChanged,
                builder: (context, state) => Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image:
                              DataConfig.imageAssetsLink[_homeCubit.imageIndex],
                          fit: BoxFit.cover,
                        )),
                      ),
                    ),
            BlocBuilder<HomeCubit, HomeState>(
                cubit: _homeCubit,
                buildWhen: (prev, now) => now is BackgroundImageChanged,
                builder: (context, state) => AnimatedOpacity(
                    opacity:
                        (_homeCubit.lastImageIndex != _homeCubit.imageIndex)
                            ? 0
                            : 1,
                    duration: Duration(seconds: 1),
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: DataConfig
                              .imageAssetsLink[_homeCubit.lastImageIndex],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ))),
            Positioned(child: MusicView(),top: SizeConfig.safeBlockVertical * 5, right: SizeConfig.safeBlockHorizontal * 10),
            Container(
              height: SizeConfig.screenHeight,
              width: SizeConfig.originScreenWidth,
              color: Colors.black54,
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Text("TỪ NAY ĐẾN HÔM THI CÒN:",
                      style: TextStyle(
                          fontSize: AppText.fontSize20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: SizeConfig.safeBlockVertical * 3),
                  BlocBuilder<CounterCubit, CounterState>(
                    cubit: _counterCubit,
                    builder: (context, state) => (state is OneSecondPassed)
                        ? Row(
                            children: <Widget>[
                              Spacer(),
                              _buildColumnWithData(
                                  "${DetailCountdownData.fromDateCount(state.dateCount).daysLeft}",
                                  "NGÀY"),
                              const SizedBox(width: 20),
                              _buildColumnWithData(
                                  "${DetailCountdownData.fromDateCount(state.dateCount).hoursLeft}",
                                  "GIỜ"),
                              const SizedBox(width: 20),
                              _buildColumnWithData(
                                  "${DetailCountdownData.fromDateCount(state.dateCount).minutesLeft}",
                                  "PHÚT"),
                              const SizedBox(width: 20),
                              _buildColumnWithData(
                                  "${DetailCountdownData.fromDateCount(state.dateCount).secondsLeft}",
                                  "GIÂY"),
                              Spacer(),
                            ],
                          )
                        : Center(child: CircularProgressIndicator()),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 5),
                  Text(
                    "Ngày thi: ${DateFormat('dd-MM-yyyy').format(DataConfig.testDate)}",
                    style: TextStyle(
                        color: Colors.white, fontSize: AppText.fontSize18),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _homeCubit.loadNewBackgroundImage(),
      ),
    );
  }

  Widget _buildColumnWithData(String time, String type) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(time,
            style: TextStyle(
                color: Colors.white,
                fontSize: AppText.fontSize30,
                fontWeight: FontWeight.bold)),
        Center(
            child: Text(type,
                style: TextStyle(
                    color: Colors.white, fontSize: AppText.fontSize20))),
      ],
    );
  }
}
