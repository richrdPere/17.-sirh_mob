class Peligro {
  final int? id;
  final int? puestoTrabajoId; // Referencia a PuestoTrabajo
  final int? tareaId; // Referencia a Tarea
  final String nombre;
  final String gravedad;
  final String? fechaIdentificacion;
  final String? ruta; // imagen
  final String? std;
  final String? usuarioCreacion;
  final String? fechaCreacion;
  final String? usuarioModificacion;
  final String? fechaModificacion;

  Peligro({
    this.id,
    required this.puestoTrabajoId,
    required this.tareaId,
    required this.nombre,
    required this.gravedad,
    required this.fechaIdentificacion,
    required this.ruta,
    this.std,
    this.usuarioCreacion,
    this.fechaCreacion,
    this.usuarioModificacion,
    this.fechaModificacion,
  });

  // ---- JSON serialization ----
  factory Peligro.fromJson(Map<String, dynamic> json) {
    return Peligro(
      id: json['id'],
      puestoTrabajoId: json['puestoTrabajoId'],
      tareaId: json['tareaId'],
      nombre: json['nombre'] ?? '',
      gravedad: json['gravedad'] ?? '',
      // fechaIdentificacion: json['fechaIdentificacion'] != null
      //     ? DateTime.parse(json['fechaIdentificacion'])
      //     : null,
      fechaIdentificacion: json['fechaIdentificacion'],
      ruta: json['ruta'],
      std: json['std'],
      usuarioCreacion: json['usuarioCreacion'],
      fechaCreacion: json['fechaCreacion'],
      // fechaCreacion: json['fechaCreacion'] != null
      //     ? String.parse(json['fechaCreacion'])
      //     : null,
      usuarioModificacion: json['usuarioModificacion'],
      fechaModificacion: json['fechaModificacion']
      // fechaModificacion: json['fechaModificacion'] != null
      //     ? DateTime.parse(json['fechaModificacion'])
      //     : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'puestoTrabajoId': puestoTrabajoId,
      'tareaId': tareaId,
      'nombre': nombre,
      'gravedad': gravedad,
      // 'fechaIdentificacion': fechaIdentificacion?.toIso8601String(),
      'fechaIdentificacion': fechaIdentificacion,
      'ruta': ruta,
      'std': std,
      'usuarioCreacion': usuarioCreacion,
      'fechaCreacion': fechaCreacion,
      // 'fechaCreacion': fechaCreacion?.toIso8601String(),
      'usuarioModificacion': usuarioModificacion,
      // 'fechaModificacion': fechaModificacion?.toIso8601String(),
      'fechaModificacion': fechaModificacion
    };
  }

  // Convertir objeto a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'pel_id': id,
      'pel_id_puesto_trabajo': puestoTrabajoId,
      'pel_id_tarea': tareaId,
      'pel_nombre': nombre,
      'pel_gravedad': gravedad,
      'pel_imagen': ruta,
      'pel_fecha_identificacion': fechaIdentificacion,
      'pel_std': std,
      'pel_user_ins': usuarioCreacion,
      'pel_fecha_ins': fechaCreacion,
      'pel_user_mod': usuarioModificacion,
      'pel_fecha_mod': fechaModificacion,
    };
  }

  // Crear objeto desde Map de SQLite
  factory Peligro.fromMap(Map<String, dynamic> map) {
    return Peligro(
      id: map['pel_id'],
      puestoTrabajoId: map['pel_id_puesto_trabajo'],
      tareaId: map['pel_id_tarea'],
      nombre: map['pel_nombre'],
      gravedad: map['pel_gravedad'],
      ruta: map['pel_imagen'],
      fechaIdentificacion: map['pel_fecha_identificacion'],
      std: map['pel_std'],
      usuarioCreacion: map['pel_user_ins'],
      fechaCreacion: map['pel_fecha_ins'],
      usuarioModificacion: map['pel_user_mod'],
      fechaModificacion: map['pel_fecha_mod'],
    );
  }
}
