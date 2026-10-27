// Etapa 3 — ViewModel con ChangeNotifier, probado sin pantallas.
//   flutter test test/etapa3_viewmodel_test.dart -r expanded

// Importa la entidad Consumo.
import 'package:ecotrack_meta/dominio/consumo.dart';
// Importa las constantes de la meta.
import 'package:ecotrack_meta/dominio/meta.dart';
// Importa el ViewModel.
import 'package:ecotrack_meta/presentacion/consumos_view_model.dart';
// Importa ChangeNotifier para comprobar el tipo.
import 'package:flutter/foundation.dart';
// Importa test y expect.
import 'package:flutter_test/flutter_test.dart';

// Importa el repositorio falso.
import 'soporte/repositorio_espia.dart';

// Punto de entrada de las pruebas.
void main() {
  // Repositorio falso de cada prueba.
  late RepositorioEspia espia;
  // ViewModel bajo prueba.
  late ConsumosViewModel vm;
  // Cuántas veces avisó el ViewModel.
  late int avisos;

  // Antes de cada prueba: ViewModel nuevo que cuenta sus avisos.
  setUp(() {
    espia = RepositorioEspia();
    vm = ConsumosViewModel(espia);
    avisos = 0;
    vm.addListener(() => avisos++);
  });

  // Después de cada prueba: se libera el ViewModel.
  tearDown(() => vm.dispose());

  // Es observable: así lo pueden escuchar ListenableBuilder y provider.
  test('es un ChangeNotifier', () {
    expect(vm, isA<ChangeNotifier>());
  });

  // Estado inicial.
  test('empieza vacío, sin error y con la meta inicial', () {
    expect(vm.consumos, isEmpty);
    expect(vm.error, isNull);
    expect(vm.guardando, isFalse);
    expect(vm.meta, metaInicial);
    expect(vm.total, 0);
    expect(vm.avance, 0);
    expect(vm.metaSuperada, isFalse);
  });

  // La fuente de verdad es el repositorio.
  test('cargar() trae lo que ya tenía el repositorio y avisa', () async {
    final conDatos = ConsumosViewModel(
      RepositorioEspia([const Consumo(laboratorio: 'Lab Redes', litros: 40)]),
    );
    var avisosCarga = 0;
    conDatos.addListener(() => avisosCarga++);

    await conDatos.cargar();

    expect(conDatos.consumos.single.litros, 40);
    expect(avisosCarga, greaterThan(0));
    conDatos.dispose();
  });

  // Camino feliz.
  test('guardar válido llega al repositorio y actualiza consumos', () async {
    final ok = await vm.guardar('Lab Física', '12.5');

    expect(ok, isTrue);
    expect(espia.recibidos.single.laboratorio, 'Lab Física');
    expect(espia.recibidos.single.litros, 12.5);
    expect(vm.consumos.single.litros, 12.5);
    expect(vm.error, isNull);
    expect(vm.guardando, isFalse);
  });

  // Coma decimal.
  test('guardar acepta coma decimal', () async {
    expect(await vm.guardar('Lab Redes', '12,5'), isTrue);
    expect(vm.consumos.single.litros, 12.5);
  });

  // Sin notifyListeners la pantalla no se entera.
  test('guardar avisa "guardando" y luego "listo"', () async {
    final valoresGuardando = <bool>[];
    vm.addListener(() => valoresGuardando.add(vm.guardando));

    await vm.guardar('Lab Redes', '5');

    expect(valoresGuardando.first, isTrue);
    expect(valoresGuardando.last, isFalse);
  });

  // La regla vive en el dominio; el repositorio no se toca.
  test('guardar inválido pone el error del dominio y no guarda', () async {
    expect(await vm.guardar('Lab Redes', '0'), isFalse);
    expect(vm.error, 'Los litros deben ser mayores que cero');

    expect(await vm.guardar('Lab Redes', 'abc'), isFalse);
    expect(vm.error, 'Escribe los litros con número');

    expect(espia.recibidos, isEmpty);
    expect(avisos, greaterThan(0));
  });

  // El error se limpia al guardar bien.
  test('un guardado correcto limpia el error anterior', () async {
    await vm.guardar('Lab Redes', '0');
    await vm.guardar('Lab Redes', '3');
    expect(vm.error, isNull);
  });

  // Estado derivado: se calcula, no se guarda.
  test('total, avance y metaSuperada se derivan de consumos y meta', () async {
    await vm.guardar('Lab Redes', '30');
    await vm.guardar('Lab Física', '20');
    expect(vm.total, 50);
    expect(vm.avance, 0.5);
    expect(vm.metaSuperada, isFalse);

    await vm.guardar('Lab Química', '60');
    expect(vm.total, 110);
    expect(vm.avance, 1);
    expect(vm.metaSuperada, isTrue);
  });

  // Acciones de la meta.
  test('subirMeta y bajarMeta cambian la meta y avisan', () {
    vm.subirMeta();
    expect(vm.meta, metaInicial + pasoMeta);
    vm.bajarMeta();
    vm.bajarMeta();
    expect(vm.meta, metaInicial - pasoMeta);
    expect(avisos, 3);
  });

  // La regla del mínimo viene del dominio.
  test('bajarMeta nunca deja la meta por debajo de metaMinima', () {
    for (var i = 0; i < 30; i++) {
      vm.bajarMeta();
    }
    expect(vm.meta, metaMinima);
  });
}
