part of 'translist_bloc.dart';

class TranslistState {
  final List<TransList>? transLists;

  TranslistState({this.transLists});
}

class TranslistInitial extends TranslistState {
  TranslistInitial():super(transLists: []);
}
