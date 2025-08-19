import 'package:flutter/material.dart';
import 'package:sirh_mob/src/presentation/modulos/Ssoma/pages/gestionIncidencias/gestionIncidencias.dart';
import 'package:sirh_mob/src/presentation/home/HomeScreen.dart';
import 'package:sirh_mob/src/presentation/notificaciones/notificaciones.dart';

class DashboardPage extends StatefulWidget {
  // static const name = 'dashboard';
  final Widget child;

  const DashboardPage({super.key, required this.child});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  // Lista de widgets que representan las pantallas
  final List<Widget> _screens = [
    Center(child: HomeScreen()), // Resume
    // Center(child: PatrolMapScreen()), // Mapa Interactivo
    //Center(child: Text('Búsqueda', style: TextStyle(fontSize: 24))), // Búsqueda
    Center(child: GestionIncidenciasScreen()), // Publicaciones
    // Center(child: ChatsScreen()), // Chats
    Center(child: NotificacionesScreen()), // Alerta - Notificaciones
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54, // O el color que uses en el header
        title: Row(
          children: [
            Image.asset(
              'assets/img/logo.png', // Ruta de tu logo
              height: 53, // Tamaño del logo
            ),
            const SizedBox(width: 10), // Espacio entre logo y texto
            // const Text(
            //   'Sistema SIRH',
            //   style: TextStyle(
            //     fontFamily: 'Roboto',
            //     fontWeight: FontWeight.bold,
            //     fontSize: 22,
            //     color: Colors.black, // Cambia según el diseño
            //   ),
            // ),
          ],
        ),
      ),

      body: _screens[_currentIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Principal',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.map_outlined),
          //   activeIcon: Icon(Icons.map),
          //   label: 'Mapa',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.search_outlined),
          //   activeIcon: Icon(Icons.search),
          //   label: 'Buscar',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pages_outlined),
            activeIcon: Icon(Icons.pages),
            label: 'Reportar',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.chat_outlined),
          //   activeIcon: Icon(Icons.chat),
          //   label: 'Chats',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            activeIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }

  // Widgets
  Widget _buildHeaderWave({
    double height = 150,
    Color color = const Color(0xff615AAB),
  }) {
    // return Icon(Icons.person, color: Colors.white, size: 125);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _HeaderWavePainter(color)),
    );
  }
}

// Painter modificado para recibir color
class _HeaderWavePainter extends CustomPainter {
  final Color color;

  _HeaderWavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final lapiz = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 20;

    final path = Path();
    path.lineTo(0, size.height * 0.25);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.30,
      size.width * 0.5,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.20,
      size.width,
      size.height * 0.25,
    );
    path.lineTo(size.width, 0);

    canvas.drawPath(path, lapiz);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
