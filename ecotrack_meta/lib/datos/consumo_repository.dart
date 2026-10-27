// Capa de datos: contrato que cumple cualquier fuente de datos.
// Solo la conocen el ViewModel y las variantes; quién la implementa
// lo decide main*.dart.
import 'package:ecotrack_meta/dominio/consumo.dart';

abstract class ConsumoRepository {
  Future<void> guardar(Consumo consumo);
  Future<List<Consumo>> todos();
}
