import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/authed/singup_request.dart';

abstract class IDataStore {
  ///write value to storage
  void keep(String key,String value);
  ///remove value in storage
  void unKeep(String key);
  ///get value in storage
  Future<String?> get(String key);
}

@Singleton()
class DataStore extends DataStoreWrapper {

  ///instance of sing up request
  late SingUpRequest? _singUpRequest;

  setSingUp(SingUpRequest? request){
    _singUpRequest = request;
  }

  SingUpRequest? get getSingUp => _singUpRequest;
}

class DataStoreWrapper implements IDataStore {

  ///secure storage
  late FlutterSecureStorage _storage;

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );

  ///new instance secure storage
  DataStoreWrapper(){
    _storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  }

  @override
  Future<String?> get(String key) => _storage.read(key: key);

  @override
  void keep(String key, String value) async{
    await _storage.write(key: key, value: value);
  }

  @override
  void unKeep(String key) async{
    await _storage.delete(key: key);
  }
}