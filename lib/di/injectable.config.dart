// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:liber/bloc/auth_bloc/auth_bloc.dart' as _i3;
import 'package:liber/core/api/base_api.dart' as _i6;
import 'package:liber/core/store/data_store.dart' as _i7;
import 'package:liber/data/repository/authed_repository.dart' as _i4;
import 'package:liber/data/service/authed_service.dart' as _i5;

/// ignore_for_file: unnecessary_lambdas
/// ignore_for_file: lines_longer_than_80_chars
/// initializes the registration of main-scope dependencies inside of [GetIt]
_i1.GetIt init(
  _i1.GetIt getIt, {
  String? environment,
  _i2.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i2.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.singleton<_i7.DataStore>(_i7.DataStore());
  gh.singleton<_i6.BaseAPI>(_i6.BaseAPI());
  gh.factory<_i5.AuthService>(() => _i5.AuthService());
  gh.singleton<_i4.AuthRepository>(_i4.AuthRepository());
  gh.singleton<_i3.AuthBloc>(_i3.AuthBloc());
  return getIt;
}
