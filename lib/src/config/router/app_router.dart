import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/OptionsSsoma/OptionsSsoma.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/AgregarPasosTareas.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/CasosDeUso/AgregarPuestoTrabajo.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/identificarPeligro/IdentificarPeligro.dart';
import 'package:sirh_mob/src/presentation/auth/login/LoginPage.dart';
import 'package:sirh_mob/src/presentation/auth/register/RegisterPage.dart';
import 'package:sirh_mob/src/presentation/dashboard/MCuscoPage.dart';
import 'package:sirh_mob/src/presentation/profile/info/ProfileInfoPage.dart';
import 'package:sirh_mob/src/presentation/roles/RolesPage.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/muni',
  // initialLocation: '/roles',
  debugLogDiagnostics: true,

  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(
      path: '/loading',
      builder: (_, __) =>
          const Text('SplashLoadingScreen()'), // pantalla intermedia opcional
    ),
    GoRoute(path: '/register', builder: (context, state) => RegisterPage()),
    GoRoute(path: '/roles', builder: (context, state) => RolesPage()),
    GoRoute(path: '/profile', builder: (context, state) => ProfileInfoPage()),
    GoRoute(path: '/muni', builder: (context, state) => MCuscoPage()),

    GoRoute(
      path: '/ssoma',
      builder: (context, state) => OptionsSsoma(),
      routes: [
        GoRoute(
          path: '/seguridad_proteccion',
          builder: (context, state) => IdentificarPeligro(),
          routes: [
            GoRoute(
              path: '/add_puesto',
              builder: (context, state) => AgregarPuestoTrabajo(),
            ),
            GoRoute(
              path: '/add_tareas',
              builder: (context, state) => AgregarPasosTareas(),
            ),
          ],
        ),
      ],
    ),

    //GoRoute(path: '/home', builder: (context, state) => DashboardPage()),
    // ShellRoute(
    //   builder: (_, __, child) => DashboardPage(child: child),
    //   routes: [
    //     GoRoute(
    //       path: '/dashboard/home',
    //       builder: (_, __) => const HomeScreen(),
    //       // builder: (_, __) => MunicipalidadCuscoPage(),
    //     ),
    //     // GoRoute(
    //     //   path: '/dashboard/mapa',
    //     //   builder: (_, __) => const MapaScreen(),
    //     // ),
    //     GoRoute(
    //       path: '/dashboard/gestion_incidencias',
    //       builder: (_, __) => const GestionIncidenciasScreen(),
    //     ),
    //     // GoRoute(
    //     //   path: '/dashboard/chats',
    //     //   builder: (_, __) => const ChatsScreen(),
    //     // ),
    //     GoRoute(
    //       path: '/dashboard/notificaciones',
    //       builder: (_, __) => const NotificacionesScreen(),
    //     ),
    //   ],
    // ),
  ],
);
