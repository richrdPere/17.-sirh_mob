enum ControlType { eliminacion, sustitucion, ingenieria, administrativo, epp }

extension ControlTypeText on ControlType {
  String get label {
    switch (this) {
      case ControlType.eliminacion:
        return 'Eliminación';
      case ControlType.sustitucion:
        return 'Sustitución';
      case ControlType.ingenieria:
        return 'Ingeniería';
      case ControlType.administrativo:
        return 'Administrativo';
      case ControlType.epp:
        return 'EPP';
    }
  }
}

class Control {
  int? id; // con_id
  String nombre; // con_nombre
  String descripcion; // con_descripcion
  String tipo; // con_tipo
  // ControlType tipo; // con_tipo
  String categoria; // con_categoria
  String std; // con_std
  String usuarioCreacion; // con_user_ins
  DateTime fechaCreacion; // con_fecha_ins
  String usuarioModificacion; // con_user_mod
  DateTime fechaModificacion; // con_fecha_mod

  Control({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.categoria,
    required this.std,
    required this.usuarioCreacion,
    required this.fechaCreacion,
    required this.usuarioModificacion,
    required this.fechaModificacion,
  });

  // Convertir objeto -> Map (para insertar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'con_id': id,
      'con_nombre': nombre,
      'con_descripcion': descripcion,
      // 'con_tipo': tipo.label,
      'con_tipo': tipo,
      'con_categoria': categoria,
      'con_std': std,
      'con_user_ins': usuarioCreacion,
      'con_fecha_ins': fechaCreacion.toIso8601String(),
      'con_user_mod': usuarioModificacion,
      'con_fecha_mod': fechaModificacion.toIso8601String(),
    };
  }

  // Convertir Map -> objeto (para leer de SQLite)
  factory Control.fromMap(Map<String, dynamic> map) {
    return Control(
      id: map['con_id'],
      nombre: map['con_nombre'],
      descripcion: map['con_descripcion'],
      tipo: map['con_tipo'],
      // tipo: ControlType.values.firstWhere(
      //   (e) => e.label == map['con_tipo'],
      //   orElse: () => ControlType.epp,
      // ),
      categoria: map['con_categoria'],
      std: map['con_std'],
      usuarioCreacion: map['con_user_ins'],
      fechaCreacion: DateTime.parse(map['con_fecha_ins']),
      usuarioModificacion: map['con_user_mod'],
      fechaModificacion: DateTime.parse(map['con_fecha_mod']),
    );
  }
}
