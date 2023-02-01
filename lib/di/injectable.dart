import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injectable.config.dart';

@InjectableInit(asExtension: false)
FutureOr<GetIt> configureDependencies(GetIt getIt) => init(getIt);

// void configureDependencies(GetIt getIt){
//   getIt.registerSingleton<AuthRepository>(AuthRepository());
//   getIt.registerSingleton<AuthBloc>(AuthBloc());
//   getIt.registerFactory<AuthService>(() => AuthService());
//   getIt.registerSingleton<DataStore>(DataStore());
//   getIt.registerSingleton<BaseAPI>(BaseAPI());
// }