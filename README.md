# Modelación DICE2023 en Julia

**Autora:** Jessica Daniela Ocaña Falcón  
**Fecha:** Julio 2026  
**Repositorio:** [https://github.com/tu-usuario/DICEModel_Project](https://github.com/tu-usuario/DICEModel_Project)

---

## Descripción del proyecto

Este repositorio contiene una implementación en Julia del modelo integrado de clima-economía **DICE2023** (Dynamic Integrated Climate-Economy), utilizando el paquete `DICEModel.jl`. Se realizan dos simulaciones:

1. **Escenario base:** Corresponde al escenario oficial `"base"` del modelo.
2. **Escenario modificado:** Introduce dos cambios:
   - Trayectoria de mitigación (`miuup`) personalizada mediante una función logística.
   - Restricción de temperatura máxima de **2.0 °C**, basada en el año de titulación (2020).

El script genera gráficas comparativas (temperatura, emisiones, tasa de mitigación y precio del carbono) y exporta los resultados completos a un archivo CSV.

---

## Requisitos

- **Julia** ≥ 1.6 (recomendado: 1.12)
- Paquetes Julia:
  - `DICEModel`
  - `Plots`
  - `DataFrames`
  - `CSV`

---

## Instalación y ejecución

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/DICEModel_Project.git
cd DICEModel_Project
