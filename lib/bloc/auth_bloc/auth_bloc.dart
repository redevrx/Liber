import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:liber/bloc/auth_bloc/auth_state.dart';
import 'package:liber/data/models/authed/singing_request.dart';
import 'package:liber/data/models/authed/singup_request.dart';
import 'package:liber/data/models/wrapper_result.dart';
import 'package:liber/data/repository/authed_repository.dart';

abstract class IAuthBloc {
  void singIn(SingInRequest request);
  void singOut();
  void register(SingUpRequest request);
  void setUserInfo();
  void loadFile();
  void selectSex(bool isMale);
  void visiblePW(bool pw, bool isConfirmPW, SingUpRequest request);
  void putFile(File file);
}

@Singleton()
class AuthBloc extends Cubit<IAuthState> implements IAuthBloc {
  AuthBloc() : super(AuthInitState());

  final _repository = GetIt.instance.get<AuthRepository>();

  @override
  void register(SingUpRequest request) async {
    if (request.valid()) {
      final response = await _repository.singUp(request);

      ///save token
      response.take(success: (value) {
        _repository.saveToken("${value?.accessToken}", "${value?.refreshToken}");
        emit(SingUpSuccess());
      }, error: (error, code) {
        emit(SingUpFailed());
      });
    } else {
      emit(ValidTextField(request: request));
    }
  }

  @override
  void setUserInfo() {}

  ///sing in success
  /// save access token and refresh token.
  @override
  void singIn(SingInRequest request) async {
    final response = await _repository.singIn(request);
    response.take(success: (value) {
      _repository.saveToken("${value?.accessToken}", "${value?.refreshToken}");
      emit(SingInSuccess());
    }, error: (error, code) {
      ///sing in error
      emit(SingInFailed());
    });
  }

  @override
  void singOut() {}

  @override
  void loadFile() async {
    final mFile = await _repository.loadImage();

    if (await mFile.exists()) {
      emit(LoadFileState(file: mFile));
    } else {
      emit(LoadFileState(file: null));
    }
  }

  @override
  void selectSex(bool isMale) {
    emit(SelectSexState(isMale));
  }

  @override
  void visiblePW(bool pw, bool isConfirmPW, SingUpRequest request) {
    emit(ValidTextField(request: request, mPW: pw, confirmPW: isConfirmPW));
  }

  /// ### Image Profile
  ///upload image profile
  @override
  void putFile(File file) async {
    (await _repository.putFile(file.path)).take(success: (value) {
      ///update image profile success
    }, error: (error, code) {
      ///update image profile error
    });
  }
}
