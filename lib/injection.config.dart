// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sirh_mob/src/data/datasource/local/SharedPref.dart' as _i990;
import 'package:sirh_mob/src/data/datasource/remote/services/AuthService.dart'
    as _i969;
import 'package:sirh_mob/src/di/AppModule.dart' as _i437;
import 'package:sirh_mob/src/domain/repositories/AuthRepository.dart' as _i520;
import 'package:sirh_mob/src/domain/usesCases/auth/AuthUseCases.dart' as _i155;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i969.AuthService>(() => appModule.authService);
    gh.factory<_i990.SharedPref>(() => appModule.sharedPref);
    gh.factory<_i520.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i155.AuthUsesCases>(() => appModule.authUseCases);
    return this;
  }
}

class _$AppModule extends _i437.AppModule {}
