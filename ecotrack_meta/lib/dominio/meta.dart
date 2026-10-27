// Capa de dominio: reglas de la meta semanal. Sin Flutter.

/// Meta con la que arranca la semana.
const metaInicial = 100.0;

/// Cuánto sube o baja la meta en cada toque de botón.
const pasoMeta = 10.0;

/// Piso: la meta nunca puede quedar por debajo de este valor.
const metaMinima = 10.0;

/// Aplica el cambio a la meta sin bajar de metaMinima (no hay techo).
double ajustarMeta(double actual, double cambio) {
  final resultado = actual + cambio;
  return resultado < metaMinima ? metaMinima : resultado;
}

/// Fracción de la meta ya usada, acotada entre 0 y 1.
double avanceDeMeta({required double total, required double meta}) {
  if (meta <= 0 || total <= 0) return 0;
  return (total / meta).clamp(0.0, 1.0).toDouble();
}
