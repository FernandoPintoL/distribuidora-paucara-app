import 'localidad.dart';
import 'ventana_entrega_cliente.dart';
import 'categoria_cliente.dart';

class Client {
  final int id;
  final int? userId;
  final String nombre;
  final String? razonSocial;
  final String? nit;
  final String? email;
  final String? telefono;
  final double? limiteCredito;
  final int? localidadId;
  final double? latitud;
  final double? longitud;
  final bool activo;
  final String? fechaRegistro;
  final String? observaciones;
  final List<ClientAddress>? direcciones;
  final String? fotoPerfil;
  final String? ciAnverso;
  final String? ciReverso;
  final String? codigoCliente;
  final dynamic localidad;
  final List<VentanaEntregaCliente>? ventanasEntrega;
  final List<CategoriaCliente>? categorias;

  Client({
    required this.id,
    this.userId,
    required this.nombre,
    this.razonSocial,
    this.nit,
    this.email,
    this.telefono,
    /* this.whatsapp,
    this.fechaNacimiento,
    this.genero, */
    this.limiteCredito,
    this.localidadId,
    this.latitud,
    this.longitud,
    required this.activo,
    this.fechaRegistro,
    this.observaciones,
    this.direcciones,
    this.fotoPerfil,
    this.ciAnverso,
    this.ciReverso,
    this.codigoCliente,
    this.localidad,
    this.ventanasEntrega,
    this.categorias,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      userId: json['user_id'],
      nombre: json['nombre'],
      razonSocial: json['razon_social'],
      nit: json['nit'],
      email: json['email'],
      telefono: json['telefono'],
      // whatsapp: json['whatsapp'],
      // fechaNacimiento: json['fecha_nacimiento'],
      // genero: json['genero'],
      limiteCredito: json['limite_credito'] != null
          ? double.tryParse(json['limite_credito'].toString()) ?? 0.0
          : null,
      localidadId: json['localidad_id'],
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      activo: json['activo'] ?? true,
      fechaRegistro: json['fecha_registro'],
      observaciones: json['observaciones'],
      direcciones: json['direcciones'] != null
          ? json['direcciones'] is List
                ? (json['direcciones'] as List)
                      .map((d) => ClientAddress.fromJson(d))
                      .toList()
                : json['direcciones'] is Map<String, dynamic>
                ? [ClientAddress.fromJson(json['direcciones'])]
                : null
          : null,
      fotoPerfil: json['foto_perfil'],
      ciAnverso: json['ci_anverso'],
      ciReverso: json['ci_reverso'],
      codigoCliente: json['codigo_cliente'],
      localidad: json['localidad'] is Map<String, dynamic>
          ? Localidad.fromJson(json['localidad'])
          : json['localidad'],
      ventanasEntrega: json['ventanas_entrega'] is List
          ? (json['ventanas_entrega'] as List)
              .map((v) => VentanaEntregaCliente.fromJson(v))
              .toList()
          : null,
      categorias: json['categorias'] is List
          ? (json['categorias'] as List)
              .map((c) => CategoriaCliente.fromJson(c))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre': nombre,
      'razon_social': razonSocial,
      'nit': nit,
      'email': email,
      'telefono': telefono,
      /* 'whatsapp': whatsapp,
      'fecha_nacimiento': fechaNacimiento,
      'genero': genero, */
      'limite_credito': limiteCredito,
      'localidad_id': localidadId,
      'latitud': latitud,
      'longitud': longitud,
      'activo': activo,
      'fecha_registro': fechaRegistro,
      'observaciones': observaciones,
      'direcciones': direcciones?.map((d) => d.toJson()).toList(),
      'foto_perfil': fotoPerfil,
      'ci_anverso': ciAnverso,
      'ci_reverso': ciReverso,
      'codigo_cliente': codigoCliente,
      'localidad': localidad,
      'ventanas_entrega': ventanasEntrega?.map((v) => v.toJson()).toList(),
      'categorias': categorias?.map((c) => c.toJson()).toList(),
    };
  }
}

class ClientAddress {
  final int? id;
  final int? clienteId;
  final String direccion;
  final String? observaciones;
  final String? ciudad;
  final String? departamento;
  final String? codigoPostal;
  final double? latitud;
  final double? longitud;
  final bool esPrincipal;
  final bool? activa;
  final String? createdAt;
  final String? updatedAt;

  ClientAddress({
    this.id,
    this.clienteId,
    required this.direccion,
    this.observaciones,
    this.ciudad,
    this.departamento,
    this.codigoPostal,
    this.latitud,
    this.longitud,
    required this.esPrincipal,
    this.activa = true, // ✅ Valor por defecto
    this.createdAt,
    this.updatedAt,
  });

  factory ClientAddress.fromJson(Map<String, dynamic> json) {
    return ClientAddress(
      id: json['id'],
      clienteId: json['cliente_id'],
      direccion: json['direccion'],
      observaciones: json['observaciones'],
      ciudad: json['ciudad'],
      departamento: json['departamento'],
      codigoPostal: json['codigo_postal'],
      latitud: json['latitud'] != null
          ? double.tryParse(json['latitud'].toString())
          : null,
      longitud: json['longitud'] != null
          ? double.tryParse(json['longitud'].toString())
          : null,
      esPrincipal: json['es_principal'] ?? false,
      activa: json['activa'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'direccion': direccion,
      'observaciones': observaciones,
      'ciudad': ciudad,
      'departamento': departamento,
      'codigo_postal': codigoPostal,
      'latitud': latitud,
      'longitud': longitud,
      'es_principal': esPrincipal,
      'activa': activa ?? true, // ✅ Valor por defecto si es null
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
