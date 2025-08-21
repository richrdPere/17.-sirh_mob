import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PhotoPicker extends StatefulWidget {
  final String label;
  // final void Function(File?)? onImageSelected;
  final void Function(String?)? onImageSelected; // Devuelve la URL en String

  const PhotoPicker({super.key, required this.label, this.onImageSelected});

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  String? _uploadedImageUrl;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _uploadedImageUrl = null; // Reset anterior
      });

      // Subimos la imagen automáticamente a S3
      await _uploadToS3(File(pickedFile.path));

      // if (widget.onImageSelected != null) {
      //   widget.onImageSelected!(_imageFile);
      // }
    }
  }

  // FUNCIONES
  Future<void> _uploadToS3(File imageFile) async {
    try {
      setState(() => _isUploading = true);

      final uri = Uri.parse(
        "https://TU_BACKEND.com/upload",
      ); //  Cambiar por tu backend
      var request = http.MultipartRequest("POST", uri);
      request.files.add(
        await http.MultipartFile.fromPath("file", imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        setState(() {
          _uploadedImageUrl = data['url']; // URL pública desde S3
          _isUploading = false;
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(_uploadedImageUrl);
        }
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al subir la imagen a S3")),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Tomar foto"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Seleccionar de galería"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showPickerOptions(context),
          child: _isUploading
              ? Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              : _imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _imageFile!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        if (_uploadedImageUrl != null)
          Text(
            "URL: $_uploadedImageUrl",
            style: const TextStyle(color: Colors.green, fontSize: 12),
          ),

        // child: _imageFile != null
        //     ? ClipRRect(
        //         borderRadius: BorderRadius.circular(12),
        //         child: Image.file(
        //           _imageFile!,
        //           width: double.infinity,
        //           height: 180,
        //           fit: BoxFit.cover,
        //         ),
        //       )
        //     : Container(
        //         width: double.infinity,
        //         height: 180,
        //         decoration: BoxDecoration(
        //           border: Border.all(color: Colors.grey),
        //           borderRadius: BorderRadius.circular(12),
        //         ),
        //         child: const Center(
        //           child: Icon(
        //             Icons.add_a_photo,
        //             size: 40,
        //             color: Colors.grey,
        //           ),
        //         ),
        //       ),
        // ),
      ],
    );
  }
}
