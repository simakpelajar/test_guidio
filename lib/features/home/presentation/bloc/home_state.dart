class HomeState {
  final bool streaming;
  HomeState({required this.streaming});

  HomeState copyWith({bool? streaming}) => HomeState(streaming: streaming ?? this.streaming);

  static HomeState initial() => HomeState(streaming: false);
}
