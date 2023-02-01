import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:liber/core/api/base_api.dart';
import 'package:liber/core/api/endpoint/auth_endpoint/auth_endpoint.dart';
import 'package:liber/core/store/data_store.dart';
import 'package:liber/core/store/store_key.dart';
import 'package:liber/data/models/authed/singing_request.dart';
import 'package:liber/data/models/authed/singing_response.dart';
import 'package:liber/data/models/authed/singup_request.dart';
import 'package:liber/data/models/authed/singup_response.dart';
import 'package:liber/data/models/wrapper_result.dart';

abstract class IAuthService {
  Future<File> loadImage();
  Future<WrapperValue<SingInResponse?>> singIn(SingInRequest request);
  Future<WrapperValue<SingUpResponse?>> singUp(SingUpRequest request);
  Future<String?> getToken();
  Future<String?> getRefreshToken();
  void saveToken(String token,String refreshToken);
  Future<WrapperValue<bool>> putFile(String path);
}

@Injectable()
class AuthService implements IAuthService {
  final _client = GetIt.instance.get<BaseAPI>();
  final _dataStore = GetIt.instance.get<DataStore>();

  @override
  Future<File> loadImage() async {
    final picker = ImagePicker();
    final mFile = await picker.pickImage(source: ImageSource.gallery);
    return File("${mFile?.path}");
  }

  @override
  Future<WrapperValue<SingInResponse?>> singIn(SingInRequest request) async {
    final res = await _client.post(path: singInPath, request: request.toJson());
    return res.copy(res.isSuccess()
        ? SingInResponse.fromJson(res.value)
        : null);
  }

  @override
  Future<WrapperValue<SingUpResponse?>> singUp(SingUpRequest request) async {
    final res = await _client.post(path: singUpPath, request: request.toJson());
    return res.copy(res.isSuccess()
        ?  SingUpResponse.fromJson(res.value)
        : null);
  }

  @override
  Future<String?> getRefreshToken() async{
    final token = await _dataStore.get(kRefreshTokenKey);
    final response = await _client.post(path: refreshToken,request: Map.of({"refreshToken":"$token"}));
    final data = response.copy(response.isSuccess() ? SingInResponse.fromJson(response.value):null);
    var mToken = "";
    data.take(success: (it) {
      saveToken("${it?.accessToken}", "${it?.refreshToken}");
      mToken = "${it?.accessToken}";
    });
    return mToken;
  }

  @override
  Future<String?> getToken() {
   return _dataStore.get(kTokenKey);
  }

  @override
  void saveToken(String token, String refreshToken) {
    _dataStore.keep(kTokenKey, token);
    _dataStore.keep(kRefreshTokenKey, refreshToken);
  }

  @override
  Future<WrapperValue<bool>> putFile(String path) async {
    final response = await _client.postFormData(path: "upload/profile/image",request: Map.of({"imageProfile":MultipartFile.fromFile(path)}));
    return response.copy(response.value as bool);
  }
}
