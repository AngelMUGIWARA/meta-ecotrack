// Fuente de datos en memoria: la verdad de la sesión vive en _guardados.
// Se implementa el contrato; nada más la conoce quien la arma en main*.dart.
import 'package:ecotrack_meta/datos/consumo_repository.dart';
import 'package:ecotrack_meta/dominio/consumo.dart';

class MemoriaConsumoRepository implements ConsumoRepository {
  final List<Consumo> _guardados = <Consumo>[];

  @override
  Future<void> guardar(Consumo consumo) async {
    _guardados.add(consumo); // al final: conserva el orden de inserción
  }

  @override
  Future<List<Consumo>> todos() async => List.unmodifiable(_guardados); // nadie modifica la lista interna desde fuera
}
