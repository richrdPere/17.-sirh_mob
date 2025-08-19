import 'dart:convert';

class PuestoTrabajo {
  final int? id;
  final int areaMetaId;
  final String nombre;
  final String descripcion;
  final String std;
  final String usuarioCreacion;
  final DateTime fechaCreacion;
  final String usuarioModificacion;
  final DateTime fechaModificacion;

  PuestoTrabajo({
    this.id,
    required this.areaMetaId,
    required this.nombre,
    required this.descripcion,
    required this.std,
    required this.usuarioCreacion,
    required this.fechaCreacion,
    this.usuarioModificacion = '',
    DateTime? fechaModificacion,
  }) : fechaModificacion = fechaModificacion ?? DateTime.now();

  // Crear objeto desde un Map (SQLite o JSON)
  factory PuestoTrabajo.fromMap(Map<String, dynamic> map) {
    return PuestoTrabajo(
      id: map['ptr_id'],
      areaMetaId: map['ptr_id_area_meta'],
      nombre: map['ptr_nombre'],
      descripcion: map['ptr_descripcion'] ?? '',
      std: map['ptr_std'] ?? '',
      usuarioCreacion: map['ptr_user_ins'] ?? '',
      fechaCreacion: map['ptr_fecha_ins'] != null
          ? DateTime.tryParse(map['ptr_fecha_ins'].toString()) ?? DateTime.now()
          : DateTime.now(),
      usuarioModificacion: map['ptr_user_mod'] ?? '',
      fechaModificacion: map['ptr_fecha_mod'] != null
          ? DateTime.tryParse(map['ptr_fecha_mod'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  // Convertir objeto a Map (para SQLite o JSON)
  Map<String, dynamic> toMap() {
    return {
      'ptr_id': id,
      'ptr_id_area_meta': areaMetaId,
      'ptr_nombre': nombre,
      'ptr_descripcion': descripcion,
      'ptr_std': std,
      'ptr_user_ins': usuarioCreacion,
      'ptr_fecha_ins': fechaCreacion.toIso8601String(),
      'ptr_user_mod': usuarioModificacion,
      'ptr_fecha_mod': fechaModificacion.toIso8601String(),
    };
  }

  // Métodos para JSON
  String toJson() => json.encode(toMap());

  factory PuestoTrabajo.fromJson(String source) =>
      PuestoTrabajo.fromMap(json.decode(source));
}
