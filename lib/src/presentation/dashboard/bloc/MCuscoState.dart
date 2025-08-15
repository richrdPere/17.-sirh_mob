import 'package:equatable/equatable.dart';

class MCuscoState extends Equatable {
  final int pageIndex;

  MCuscoState({this.pageIndex = 0});

  MCuscoState copyWith({int? pageIndex}) {
    return MCuscoState(pageIndex: pageIndex ?? this.pageIndex);
  }

  @override
  List<Object?> get props => [pageIndex];
}
