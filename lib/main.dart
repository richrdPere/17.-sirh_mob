import 'package:flutter/material.dart';

// Bloc Providers
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sirh_mob/blocProviders.dart';

// Injection
import 'package:sirh_mob/injection.dart';

// Router y Theme
import 'package:sirh_mob/src/config/router/app_router.dart';
import 'package:sirh_mob/src/config/theme/app_theme.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.ñ
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
        title: 'Sistema SIRH',
        theme: AppTheme().getTheme(),
      ),
    );
  }
}
