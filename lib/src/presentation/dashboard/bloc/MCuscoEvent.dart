abstract class MCuscoEvent {}

class ChangeDrawerPage extends MCuscoEvent {
  final int pageIndex;

  ChangeDrawerPage({required this.pageIndex});

  
}
