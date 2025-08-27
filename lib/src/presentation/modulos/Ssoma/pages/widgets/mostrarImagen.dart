import 'package:flutter/material.dart';

class MostrarImagen extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final double borderRadius;

  const MostrarImagen({
    Key? key,
    required this.imageUrl,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: height,
              width: width,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: height,
                  width: width,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                    size: 50,
                  ),
                );
              },
            )
          : Container(
              height: height,
              width: width,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Icon(
                Icons.image,
                size: 60,
                color: Colors.grey,
              ),
            ),
    );
  }
}
