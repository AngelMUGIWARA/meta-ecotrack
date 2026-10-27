// Apoyo de pruebas: otra fuente de datos que cumple el contrato.
// Si la app funciona con este espía sin tocar pantallas, pasa el criterio "Sustitución".

// Importa el contrato del repositorio.
import 'package:ecotrack_meta/datos/consumo_repository.dart';
// Importa la entidad Consumo.
import 'package:ecotrack_meta/dominio/consumo.dart';

// Repositorio falso que anota lo que recibe y puede arrancar con datos.
class RepositorioEspia implements ConsumoRepository {
  // Constructor: opcionalmente recibe consumos que "ya estaban guardados".
  RepositorioEspia([List<Consumo> iniciales = const []])
    : _guardados = [...iniciales];

  // Todo lo que hay en esta fuente de datos.
  final List<Consumo> _guardados;
  // Solo lo que la app le pidió guardar durante la prueba.
  final List<Consumo> recibidos = [];

  // Indica que cumple el contrato de ConsumoRepository.
  @override
  // Anota el consumo recibido y lo agrega a la fuente.
  Future<void> guardar(Consumo consumo) async {
    recibidos.add(consumo);
    _guardados.add(consumo);
  }

  // Indica que cumple el contrato de ConsumoRepository.
  @override
  // Devuelve una copia de todo lo guardado.
  Future<List<Consumo>> todos() async => List.of(_guardados);
}
