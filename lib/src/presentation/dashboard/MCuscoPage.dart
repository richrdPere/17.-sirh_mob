import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoBloc.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoEvent.dart';
import 'package:sirh_mob/src/presentation/dashboard/bloc/MCuscoState.dart';
import 'package:sirh_mob/src/presentation/profile/info/ProfileInfoPage.dart';

// Interfaces

// 1.- ModuloOptions
class ModuloOption {
  final String title;
  final String description;
  final IconData icon;
  final Color cardColor;
  final String route;

  ModuloOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.cardColor,
    required this.route,
  });
}

class MCuscoPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  // Module Options
  final List<ModuloOption> moduloOptions = [
    ModuloOption(
      title: "SSOMA",
      description: "Modulo de Ssoma",
      icon: Icons.health_and_safety,
      cardColor: Colors.green,
      route: "/ssoma",
    ),
    ModuloOption(
      title: "RR HH",
      description: "Modulo de RRHH",
      icon: Icons.group,
      cardColor: Colors.blue,
      route: "",
    ),
    ModuloOption(
      title: "Obras",
      description: "Modulo de Obras",
      icon: Icons.construction,
      cardColor: Colors.orange,
      route: "",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

      List<Widget> pageList = <Widget>[ProfileInfoPage()];

    return Scaffold(
      key: _scaffoldKey, // clave para abrir el drawer
      // endDrawer: Drawer(child: _drawerHeader(context)),
      endDrawer: BlocBuilder<MCuscoBloc, MCuscoState>(
        builder: (context, state) {
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue[400]),
                  child: Text(
                    'Menu del cliente',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  title: Text('Perfil del usuario'),
                  selected: state.pageIndex == 0,
                  onTap: () {
                    context.read<MCuscoBloc>().add(
                      ChangeDrawerPage(pageIndex: 0),
                    );
                    context.go("/profile");
                  },
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.white,
      body: BlocBuilder<MCuscoBloc, MCuscoState>(
        builder: (context, state) {
          // return pageList[state.pageIndex];
          return Column(
            children: [
              // Encabezado
              Container(
                width: double.infinity,
                // color: const Color.fromRGBO(73, 157, 255, 1),
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1.- Logo
                    _logo(),

                    // 2.- Iconos de acciones
                    _iconActions(),
                  ],
                ),
              ),

              // Lista de opciones
              Expanded(
                child: Container(
                  color: Color.fromRGBO(241, 241, 241, 1),

                  // child: _buildMenuList(
                  //   context: context,
                  //   menuOptions: menuOptions,
                  //   size: size,
                  // ),
                  child: _buildModuloList(
                    context: context,
                    moduloOptions: moduloOptions,
                    size: size,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ===============================
  // Widgets
  // ===============================
  Widget _drawerHeader(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Color.fromRGBO(189, 155, 36, 1)),
          margin: EdgeInsets.only(bottom: 5.0),
          child: Text(
            'SSOMA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.person, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Perfil"),
          onTap: () {
            context.go('/profile');
            // print("Ir a perfil");
          },
        ),
        ListTile(
          leading: Icon(Icons.work, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Otro Rol"),
          onTap: () {
            // Navigator.pop(context);
            context.go('/roles');
            print("Ir a configuración");
          },
        ),
        ListTile(
          leading: Icon(Icons.settings, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Configuración"),
          onTap: () {
            Navigator.pop(context);
            print("Ir a configuración");
          },
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app, color: Color.fromRGBO(5, 5, 5, 1)),
          title: Text("Cerrar sesión"),
          onTap: () {
            Navigator.pop(context);
            print("Cerrar sesión");
          },
        ),
      ],
    );
  }

  Widget _logo() {
    return Row(
      children: [
        Image.asset(
          "assets/img/logo.png", // Asegúrate de tener esta imagen
          height: 55,
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _iconActions() {
    return Row(
      children: [
        Icon(Icons.mail, color: Color.fromRGBO(5, 5, 5, 1), size: 35),
        SizedBox(width: 19),
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openEndDrawer();
          },
          child: Icon(Icons.menu, color: Colors.black, size: 43),
        ),
      ],
    );
  }

  Widget _buildModuloList({
    required List<ModuloOption> moduloOptions,
    required BuildContext context,
    required Size size,
  }) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size.width > 600 ? 3 : 2, // Responsivo
        crossAxisSpacing: 7,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5, // Más ancho que alto
      ),
      itemCount: moduloOptions.length,
      itemBuilder: (context, index) {
        final option = moduloOptions[index];
        return Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: option.cardColor,

          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                // Ícono izquierdo
                Align(
                  alignment: Alignment.topCenter,
                  child: Icon(option.icon, size: 45, color: Colors.white),
                ),
                const SizedBox(width: 10),

                // Texto (title y description)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          context.go(option.route);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: TextStyle(
                                fontSize: 17,

                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              option.description,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () {
                            context.go(option.route);
                          },
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
