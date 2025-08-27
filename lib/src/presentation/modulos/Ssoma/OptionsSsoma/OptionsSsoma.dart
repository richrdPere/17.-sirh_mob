import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Interfaces
// 1.- MenuOptions
class MenuOption {
  final String title;
  final IconData icon;
  final String route;

  MenuOption({required this.title, required this.icon, required this.route});
}

class OptionsSsoma extends StatefulWidget {
  const OptionsSsoma({super.key});

  @override
  State<OptionsSsoma> createState() => _OptionsSsomaState();
}

class _OptionsSsomaState extends State<OptionsSsoma> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Menu Options
  final List<MenuOption> menuOptions = [
    MenuOption(
      title: "Crear Reporte - Seguridad/Protección",
      icon: Icons.health_and_safety,
      route: "/ssoma/seguridad_proteccion",
    ),
    MenuOption(
      title: "Identificación de Peligros",
      icon: Icons.warning_amber_rounded,
      route: "/ssoma/ver_identificacion_peligros",
    ),
    MenuOption(
      title: "Evaluación de Riesgos",
      icon: Icons.analytics_outlined,
      route: "/ssoma/ver_evaluacion_riesgo",
    ),
    MenuOption(
      title: "Medidas de Control",
      icon: Icons.security,
      route: "/ssoma/ver_medidas_control",
    ),
    MenuOption(
      title: "VER REGISTROS - IPERC",
      icon: Icons.warning,
      route: "/ssoma/ver_medidas_control",
    ),
    // MenuOption(
    //   title: "Medio Ambiente",
    //   icon: Icons.eco,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Prevención/Alertas",
    //   icon: Icons.warning,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Maeria",
    //   icon: Icons.health_and_safety,
    //   route: "",
    // ),
    // MenuOption(title: "Registro de Vecinos", icon: Icons.person_add, route: ""),
    // MenuOption(
    //   title: "Generar Permiso Municipal",
    //   icon: Icons.lock_open,
    //   route: "",
    // ),
    // MenuOption(title: "Pago de Impuestos", icon: Icons.receipt_long, route: ""),
    // MenuOption(
    //   title: "Declaraciones y Trámites",
    //   icon: Icons.assignment,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Renta Municipal Anual",
    //   icon: Icons.account_balance,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Validar Datos de Contacto",
    //   icon: Icons.contact_mail,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Reporte de Obras Públicas",
    //   icon: Icons.bar_chart,
    //   route: "",
    // ),
    // MenuOption(
    //   title: "Gastos y Presupuesto",
    //   icon: Icons.attach_money,
    //   route: "",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      key: _scaffoldKey, // clave para abrir el drawer
      endDrawer: Drawer(child: _drawerHeader(context)),
      backgroundColor: Colors.white,
      body: Column(
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
                // 1.- Titulo
                // _logo(),
                _titulo(),

                // 2.- Iconos de acciones
                _iconActions(),
              ],
            ),
          ),

          // Lista de opciones
          Expanded(
            child: Container(
              color: Color.fromRGBO(241, 241, 241, 1),
              child: _buildMenuList(
                context: context,
                menuOptions: menuOptions,
                size: size,
              ),
            ),
          ),
        ],
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
            Navigator.pop(context);
            print("Ir a perfil");
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

  Widget _titulo() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            context.go("/muni");
          },
          child: Icon(Icons.arrow_back, color: Colors.black, size: 30),
        ),
        const SizedBox(width: 20),
        Text(
          "Opciones - SSOMA",
          style: TextStyle(
            color: const Color.fromRGBO(75, 86, 117, 1),
            fontSize: 20, // Escalable
            fontWeight: FontWeight.w600,
          ),
        ),
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

  Widget _buildMenuList({
    required List<MenuOption> menuOptions,
    required BuildContext context,
    required Size size,
  }) {
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: menuOptions.length,
      itemBuilder: (context, index) {
        final option = menuOptions[index];
        return Card(
          elevation: 3,
          margin: const EdgeInsetsDirectional.only(
            start: 25,
            end: 25,
            bottom: 5,
            top: 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(
              option.icon,
              color: const Color.fromRGBO(5, 5, 5, 1),
              size: 35,
            ),
            title: Text(
              option.title,
              style: TextStyle(
                color: const Color.fromRGBO(75, 86, 117, 1),
                fontSize: size.width * 0.038, // Escalable
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color.fromRGBO(189, 155, 36, 1),
            ),
            onTap: () {
              // Aquí puedes usar Navigator o context.go dependiendo de tu navegación
              context.go(option.route);
            },
          ),
        );
      },
    );
  }
}
