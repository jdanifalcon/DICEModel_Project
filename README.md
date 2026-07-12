# DICEModel_Project

Simulación y análisis de sensibilidad del modelo integrado clima-economía **DICE2023** ([Nordhaus, 2023](https://bit.ly/3TwJ5nO)), implementado con el paquete [DICEModel.jl](https://github.com/sylvaticus/DICEModel.jl) en Julia.

## Contenido

| Archivo | Descripción |
|---|---|
| `simulacion_dice.jl` | Simulación base vs. modificada (mitigación logística + límite 2.0 °C) |
| `analisis_sensibilidad.jl` | Análisis de sensibilidad variando el límite de temperatura (1.5–3.0 °C) |
| `reporte_tecnico_jdof.pdf` | Nota técnica con metodología, resultados y discusión |
| `comparacion_DICE.png` | Panel comparativo: base vs. modificada |
| `sensibilidad_temperatura.png` | Panel de sensibilidad: efecto del límite de temperatura |
| `resultados_completos.csv` | Datos de la simulación base y modificada |
| `sensibilidad_resumen_2100.csv` | Tabla resumen de todos los escenarios al año 2100 |

## Reproducir

```bash
git clone https://github.com/jdanifalcon/DICEModel_Project.git
cd DICEModel_Project
```

```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()

# Simulación base vs. modificada
include("simulacion_dice.jl")

# Análisis de sensibilidad
include("analisis_sensibilidad.jl")
```

**Requisitos:** Julia ≥ 1.10. Las dependencias se instalan automáticamente con `Pkg.instantiate()`.

## Escenarios

### Simulación principal (`simulacion_dice.jl`)

- **Base:** escenario oficial DICE2023 sin intervención.
- **Modificada:** trayectoria de mitigación logística personalizada (`miuup`) + restricción de temperatura ≤ 2.0 °C.

### Análisis de sensibilidad (`analisis_sensibilidad.jl`)

Se evalúa el efecto de imponer distintos límites de temperatura máxima:

| Límite (°C) | Referencia |
|---|---|
| 1.5 | Meta aspiracional del Acuerdo de París |
| 1.8 | Escenario intermedio |
| 2.0 | Meta principal del Acuerdo de París / Año de titulación (2020) |
| 2.5 | Trayectoria de pledges actuales (NDCs) |
| 3.0 | Escenario de referencia relajado |

## Autora

**Jessica Daniela Ocaña Falcón**
Maestría en Ciencias de la Información Geoespacial · CentroGeo
Licenciatura en Gestión Ambiental · UJAT

## Licencia

MIT
