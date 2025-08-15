import 'package:equatable/equatable.dart';

class RolesState extends Equatable {

  final List<String?>? roles;

  const RolesState({
    this.roles 
  });


  RolesState copyWith({
    final List<String?>? roles
  }){
    return RolesState(
      roles:roles
    );
  }

  @override
  List<Object?> get props => [roles];


}