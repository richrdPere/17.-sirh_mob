class MedidaControl {
  final int? id; // mec_id
  final int? riesgoId; // pel_id_evaluacion_riesgo (FK)
  final int? controlId; // mec_id_control (FK)
  final String? responsable; // mec_responsable
  final DateTime? fechaImplementacion; // mec_fecha_implementacion
  final String? eficacia; // mec_eficacia
  final String? estado; // mec_estado
  final String? ruta; // mec_imagen
  final String? evidencia; // mec_evidencia
  final String? std; // mec_std
  final String? usuarioCreacion; // mec_user_ins
  final DateTime? fechaCreacion; // mec_fecha_ins
  final String? usuarioModificacion; // mec_user_mod
  final DateTime? fechaModificacion; // mec_fecha_mod

  MedidaControl({
    this.id,
    this.riesgoId,
    this.controlId,
    this.responsable,
    this.fechaImplementacion,
    this.eficacia,
    this.estado,
    this.ruta,
    this.evidencia,
    this.std,
    this.usuarioCreacion,
    this.fechaCreacion,
    this.usuarioModificacion,
    this.fechaModificacion,
  });

  // --- Convertir de Map (SQLite o JSON) a objeto ---
  factory MedidaControl.fromMap(Map<String, dynamic> map) {
    return MedidaControl(
      id: map['mec_id'] as int?,
      riesgoId: map['pel_id_evaluacion_riesgo'] as int?,
      controlId: map['mec_id_control'] as int?,
      responsable: map['mec_responsable'] as String?,
      fechaImplementacion: map['mec_fecha_implementacion'] != null
          ? DateTime.tryParse(map['mec_fecha_implementacion'])
          : null,
      eficacia: map['mec_eficacia'] as String?,
      estado: map['mec_estado'] as String?,
      ruta: map['mec_imagen'] as String?,
      evidencia: map['mec_evidencia'] as String?,
      std: map['mec_std'] as String?,
      usuarioCreacion: map['mec_user_ins'] as String?,
      fechaCreacion: map['mec_fecha_ins'] != null
          ? DateTime.tryParse(map['mec_fecha_ins'])
          : null,
      usuarioModificacion: map['mec_user_mod'] as String?,
      fechaModificacion: map['mec_fecha_mod'] != null
          ? DateTime.tryParse(map['mec_fecha_mod'])
          : null,
    );
  }

  // --- Convertir objeto a Map (para SQLite o JSON) ---
  Map<String, dynamic> toMap() {
    return {
      'mec_id': id,
      'pel_id_evaluacion_riesgo': riesgoId,
      'mec_id_control': controlId,
      'mec_responsable': responsable,
      'mec_fecha_implementacion':
          fechaImplementacion?.toIso8601String(),
      'mec_eficacia': eficacia,
      'mec_estado': estado,
      'mec_imagen': ruta,
      'mec_evidencia': evidencia,
      'mec_std': std,
      'mec_user_ins': usuarioCreacion,
      'mec_fecha_ins': fechaCreacion?.toIso8601String(),
      'mec_user_mod': usuarioModificacion,
      'mec_fecha_mod': fechaModificacion?.toIso8601String(),
    };
  }
}
