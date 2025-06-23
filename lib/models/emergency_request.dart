class EmergencyRequest {
  final int idSolicitud;
  final String fechaInicioIncendio;
  final String fechaSolicitud;
  final int cantidadPersonas;
  final String categoria;
  final String listaProductos;
  final int idSolicitante;
  final int idDestino;
  final Map<String, int> personalNecesario;
  final bool apoyoaceptado;

  const EmergencyRequest({
    required this.idSolicitud,
    required this.fechaInicioIncendio,
    required this.fechaSolicitud,
    required this.cantidadPersonas,
    required this.categoria,
    required this.listaProductos,
    required this.idSolicitante,
    required this.idDestino,
    required this.personalNecesario,
    required this.apoyoaceptado,
  });

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      idSolicitud: json['idSolicitud'],
      fechaInicioIncendio: json['fechaInicioIncendio'],
      fechaSolicitud: json['fechaSolicitud'],
      cantidadPersonas: json['cantidadPersonas'],
      categoria: json['categoria'],
      listaProductos: json['listaProductos'],
      idSolicitante: json['idSolicitante'],
      idDestino: json['idDestino'],
      personalNecesario: Map<String, int>.from(json['personalNecesario']),
      apoyoaceptado: json['apoyoaceptado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSolicitud': idSolicitud,
      'fechaInicioIncendio': fechaInicioIncendio,
      'fechaSolicitud': fechaSolicitud,
      'cantidadPersonas': cantidadPersonas,
      'categoria': categoria,
      'listaProductos': listaProductos,
      'idSolicitante': idSolicitante,
      'idDestino': idDestino,
      'personalNecesario': personalNecesario,
      'apoyoaceptado': apoyoaceptado,
    };
  }

  Map<String, int> get parsedProducts {
    final Map<String, int> products = {};
    if (listaProductos.isNotEmpty) {
      final items = listaProductos.split(',');
      for (final item in items) {
        final parts = item.split(':');
        if (parts.length == 2) {
          products[parts[0].trim()] = int.tryParse(parts[1].trim()) ?? 0;
        }
      }
    }
    return products;
  }

  bool requiresPersonnel(String personnelType) {
    return personalNecesario.containsKey(personnelType) && 
           (personalNecesario[personnelType] ?? 0) > 0;
  }
} 