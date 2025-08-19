class Tarea {
  final int? id; // tar_id
  final String nombre; // tar_nombre
  final String tipo; // tar_tipo
  final String pasos; // tar_pasos
  final String frecuencia; // tar_frecuencia
  final String std; // tar_std
  final String usuarioCreacion; // tar_user_ins
  final DateTime? fechaCreacion; // tar_fecha_ins
  final String? usuarioModificacion; // tar_user_mod
  final DateTime? fechaModificacion; // tar_fecha_mod

  Tarea({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.pasos,
    required this.frecuencia,
    required this.std,
    required this.usuarioCreacion,
    this.fechaCreacion,
    this.usuarioModificacion,
    this.fechaModificacion,
  });

  /// Convertir de Map (SQLite → Dart)
  factory Tarea.fromMap(Map<String, dynamic> map) {
    return Tarea(
      id: map['tar_id'] as int?,
      nombre: map['tar_nombre'] ?? '',
      tipo: map['tar_tipo'] ?? '',
      pasos: map['tar_pasos'] ?? '',
      frecuencia: map['tar_frecuencia'] ?? '',
      std: map['tar_std'] ?? '',
      usuarioCreacion: map['tar_user_ins'] ?? '',
      fechaCreacion: map['tar_fecha_ins'] != null
          ? DateTime.tryParse(map['tar_fecha_ins'])
          : null,
      usuarioModificacion: map['tar_user_mod'],
      fechaModificacion: map['tar_fecha_mod'] != null
          ? DateTime.tryParse(map['tar_fecha_mod'])
          : null,
    );
  }

  /// Convertir a Map (Dart → SQLite)
  Map<String, dynamic> toMap() {
    return {
      'tar_id': id,
      'tar_nombre': nombre,
      'tar_tipo': tipo,
      'tar_pasos': pasos,
      'tar_frecuencia': frecuencia,
      'tar_std': std,
      'tar_user_ins': usuarioCreacion,
      'tar_fecha_ins': fechaCreacion?.toIso8601String(),
      'tar_user_mod': usuarioModificacion,
      'tar_fecha_mod': fechaModificacion?.toIso8601String(),
    };
  }
}
