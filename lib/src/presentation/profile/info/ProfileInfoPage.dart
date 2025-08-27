import 'package:flutter/material.dart';
import 'package:sirh_mob/src/presentation/profile/info/ProfileInfoContent.dart';
import 'package:sirh_mob/src/presentation/widgets/TAppBar.dart';

class ProfileInfoPage extends StatefulWidget {
  const ProfileInfoPage({super.key});

  @override
  State<ProfileInfoPage> createState() => _ProfileInfoPageState();
}

class _ProfileInfoPageState extends State<ProfileInfoPage> {
  final String nombre = "Richard Pereira";
  final String username = "richard_dev";
  final String bio = "Flutter Developer  | FullStack |  Cusco, Perú";
  final String fotoPerfil = "https://i.pravatar.cc/300"; // Imagen de ejemplo

  final int publicaciones = 24;
  final int seguidores = 1200;
  final int siguiendo = 350;

  @override
  Widget build(BuildContext context) {
    // return ProfileInfoContent();

    return Scaffold(
      backgroundColor: Colors.black, // Estilo Instagram oscuro
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          username,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        children: [
          // FOTO Y ESTADÍSTICAS
          Row(
            children: [
              // Foto circular
              CircleAvatar(
                radius: 45,
                backgroundImage: NetworkImage(fotoPerfil),
              ),
              const SizedBox(width: 20),
              // Estadísticas
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat("Publicaciones", publicaciones),
                    _buildStat("Seguidores", seguidores),
                    _buildStat("Siguiendo", siguiendo),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // NOMBRE Y BIOGRAFÍA
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            bio,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),

          // BOTONES DE ACCIÓN
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Editar perfil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    side: const BorderSide(color: Colors.grey),
                  ),
                  onPressed: () {},
                  child: const Text(
                    "Compartir perfil",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // GRID DE FOTOS
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return Image.network(
                "https://picsum.photos/200?random=$index",
                fit: BoxFit.cover,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Widget para estadísticas
  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
