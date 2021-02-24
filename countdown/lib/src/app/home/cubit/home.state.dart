part of 'home.cubit.dart';

@immutable
abstract class HomeState extends Equatable {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  List<Object> get props => [];
}

class BackgroundImageChanged extends HomeState {
  final AssetImage image;
  final AssetImage lastImage;

  BackgroundImageChanged(this.image,this.lastImage);

  @override
  List<Object> get props => [image,lastImage];
}

