part of 'translist_bloc.dart';

@immutable
abstract class TranslistEvent {}

class InitTranslistEvent extends TranslistEvent{}
class AddTranslistEvent extends TranslistEvent{
  TransList? transList;
  Transaction? ftrans;
  
  AddTranslistEvent({this.transList,this.ftrans});
}

class DeleteTranslistEvent extends TranslistEvent{
  int? id;
  
  DeleteTranslistEvent({this.id});
}

class EditTranslistEvent extends TranslistEvent{
  int? id;
  TransList? newOne;

  EditTranslistEvent({this.id,this.newOne});
}