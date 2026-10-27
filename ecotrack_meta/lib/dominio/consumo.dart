// Capa de dominio: reglas puras de EcoTrack. Sin Flutter.

/// Laboratorios de la UTEZ que pueden registrar consumo (orden fijo del contrato).
const laboratoriosUtez = ['Lab Química', 'Lab Redes', 'Lab Física'];

/// Un consumo registrado durante la semana.
class Consumo {
  const Consumo({required this.laboratorio, required this.litros});

  final String laboratorio;
  final double litros;
}

/// Valida los litros y devuelve el mensaje de error, o null si son válidos.
/// El orden importa: primero el dato ausente, después el rango.
String? validarLitros(double? litros) {
  if (litros == null) return 'Escribe los litros con número';
  if (litros <= 0) return 'Los litros deben ser mayores que cero';
  if (litros > 10000) return 'Los litros superan el tope de 10000';
  return null;
}
