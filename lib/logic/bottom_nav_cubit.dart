import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavState {
  final int currentIndex;

  BottomNavState([this.currentIndex = 0]);

  BottomNavState copyWith({int? currentIndex}) {
    return BottomNavState(currentIndex ?? this.currentIndex);
  }
}

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState(0));

  setIndex(int index) {
    emit(state.copyWith(currentIndex: index));
  }
}
