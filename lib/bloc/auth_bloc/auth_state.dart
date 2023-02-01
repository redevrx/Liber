import 'dart:io';

import '../../data/models/authed/singup_request.dart';

abstract class IAuthState {}

class AuthInitState extends IAuthState {}

class SingInSuccess extends IAuthState {}

class SingInFailed extends IAuthState {}

class SingUpSuccess extends IAuthState {}
class SingUpFailed extends IAuthState {}

class LoadFileState extends IAuthState {
  final File? file;

  LoadFileState({required this.file});
}

class SelectSexState extends IAuthState {
  final bool isMale;

  SelectSexState(this.isMale);
}

class ValidTextField extends IAuthState {
  ///
  final SingUpRequest? request;
   bool mPW = true;
   bool confirmPW = true;

  ValidTextField({this.request,this.mPW = true,this.confirmPW = true});
}

