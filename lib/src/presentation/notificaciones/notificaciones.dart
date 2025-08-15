import 'package:flutter/material.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  // Simulación de datos de alertas
  final List<Map<String, String>> incidentAlerts = [
    {
      'type': 'Robo',
      'date': '10-01-2025',
      'location': 'Calle Pumacurco, Cusco',
      'details': 'Un robo en proceso reportado cerca de la tienda XYZ.',
    },
    {
      'type': 'Accidente',
      'date': '10-01-2025',
      'location': 'Avenida El Sol, Cusco',
      'details': 'Un choque entre dos vehículos bloqueando la vía principal.',
    },
    {
      'type': 'Disturbio',
      'date': '09-01-2025',
      'location': 'Plaza de Armas, Cusco',
      'details': 'Un disturbio reportado con varias personas involucradas.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = isDarkMode ? Colors.blueGrey : Colors.blue;
    final Color secondaryColor = isDarkMode ? Colors.greenAccent : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alertas de Incidentes',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"),
            ),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const ProfileScreen()),
              // );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: incidentAlerts.length, // Número de alertas
        itemBuilder: (context, index) {
          final incident = incidentAlerts[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo de incidente
                  Text(
                    'Tipo: ${incident['type']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Fecha del incidente
                  Text(
                    'Fecha: ${incident['date']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  // Lugar del incidente
                  Text(
                    'Lugar: ${incident['location']}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8),
                  // Detalles del incidente
                  Text(
                    'Detalles: ${incident['details']}',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  SizedBox(height: 16),
                  // Botón para confirmar intervención
                  ElevatedButton(
                    onPressed: () {
                      // Acción al confirmar intervención
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Intervención confirmada para el incidente "${incident['type']}"',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      'Confirmar Intervención',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
