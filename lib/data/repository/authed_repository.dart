import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:liber/data/models/authed/singing_request.dart';
import 'package:liber/data/models/authed/singing_response.dart';
import 'package:liber/data/models/authed/singup_request.dart';
import '../models/authed/singup_response.dart';
import '../models/wrapper_result.dart';
import '../service/authed_service.dart';

@Singleton()
class AuthRepository {
  final _service = GetIt.instance.get<AuthService>();

  Future<File> loadImage() {
    return _service.loadImage();
  }


  /// *
  /// sing up
  Future<WrapperValue<SingUpResponse?>> singUp(SingUpRequest request) async {
    return await _service.singUp(request);
  }

  /// *
  /// sing in
  Future<WrapperValue<SingInResponse?>> singIn(SingInRequest request) async {
    return await _service.singIn(request);
  }


  void saveToken(String token,String refreshToken) {
    _service.saveToken(token, refreshToken);
  }

  Future<WrapperValue<bool>> putFile(String path) async {
    return await _service.putFile(path);
  }
}
