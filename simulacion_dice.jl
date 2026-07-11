# =============================================================================
# simulacion_dice.jl
# =============================================================================
# Autora       : Jessica Daniela Ocaña Falcón
# Fecha        : Julio 2026
# Descripción  : Simulación del modelo DICE2023 (implementado en DICEModel.jl)
#                con dos escenarios: 
#                  1) Base (escenario oficial "base")
#                  2) Modificada con trayectoria de mitigación logística
#                     y restricción de temperatura máxima de 2.0 °C
#                Genera gráficas comparativas y exporta resultados a CSV.
# =============================================================================

# -----------------------------------------------------------------------------
# 1. Carga de paquetes
# -----------------------------------------------------------------------------
using DICEModel
using Plots
using DataFrames
using CSV

# -----------------------------------------------------------------------------
# 2. Simulación base (escenario oficial)
# -----------------------------------------------------------------------------
println("--- Simulación BASE ---")
resultado_base = run_dice_scenario("base")

# -----------------------------------------------------------------------------
# 3. Simulación modificada
# -----------------------------------------------------------------------------
println("--- Simulación MODIFICADA ---")

# 3.1. Parámetros por defecto
pars = DICE2023()

# 3.2. Modificación de la trayectoria de mitigación (miuup)
#      Se sustituye la senda original por una función logística:
#      miuup(t) = 0.05 + 0.90 / (1 + exp(-0.03*(t-60)))
nt = length(pars.times)
miuup_nuevo = [0.05 + 0.90 / (1 + exp(-0.03 * (t - 60))) for t in pars.times]
pars = DICE2023(miuup = miuup_nuevo)

# 3.3. Restricción de temperatura
#      Límite superior = últimos dos dígitos del año de titulación / 10
anio_titulacion = 2020          # Cambiar según el año real
limite_temp = anio_titulacion % 100 / 10.0   # 2.0 °C para 2020
println("Límite de temperatura impuesto: $(limite_temp) °C")

# 3.4. Ejecución de la simulación con restricción
#      Se utiliza el argumento `bounds`. En DICEModel.jl la variable
#      de estado se denomina `TATM` (temperatura atmosférica).
#      La forma más robusta es definir un vector de límites para cada período:
#      bounds = Dict(:TATM => (fill(-Inf, nt), fill(limite_temp, nt)))
#      Sin embargo, la siguiente sintaxis también es aceptada por el paquete:
bounds = Dict("TATM" => ("<=", limite_temp))
resultado_mod = run_dice(pars; bounds = bounds)

# -----------------------------------------------------------------------------
# 4. Extracción de resultados
# -----------------------------------------------------------------------------
function extraer_datos(resultado)
    # `resultado` es una NamedTuple con todos los campos del modelo.
    # Los nombres de las variables pueden consultarse con `propertynames(resultado)`.
    return (
        tiempos   = resultado.times,          # Vector de años (0,5,10,...)
        tatm      = resultado.TATM,           # Temperatura atmosférica (°C)
        e_indust  = resultado.EIND,           # Emisiones industriales (GtCO2/año)
        miu       = resultado.MIU,            # Tasa de mitigación
        consumo   = resultado.C,              # Consumo (billones USD 2019)
        cprice    = resultado.CPRICE_R[:,1],  # Precio del carbono (USD/tCO2), región global
        damages   = resultado.DAMAGES,        # Daños económicos (billones USD)
        ygross    = resultado.YGROSS          # Producción bruta (billones USD)
    )
end

datos_base = extraer_datos(resultado_base)
datos_mod  = extraer_datos(resultado_mod)

# -----------------------------------------------------------------------------
# 5. Generación de gráficas comparativas
# -----------------------------------------------------------------------------

# Gráfica 1: Temperatura
p1 = plot(datos_base.tiempos, datos_base.tatm,
          label = "Base", lw = 2, color = :blue,
          title = "Temperatura atmosférica",
          xlabel = "Año", ylabel = "°C",
          legend = :topleft)
plot!(datos_mod.tiempos, datos_mod.tatm,
      label = "Modificada (límite $(limite_temp)°C)",
      lw = 2, color = :red, linestyle = :dash)
hline!([limite_temp], label = "Límite impuesto", lw = 1,
       color = :black, linestyle = :dot)

# Gráfica 2: Emisiones de CO₂
p2 = plot(datos_base.tiempos, datos_base.e_indust,
          label = "Base", lw = 2, color = :blue,
          title = "Emisiones industriales de CO₂",
          xlabel = "Año", ylabel = "GtCO₂/año",
          legend = :topright)
plot!(datos_mod.tiempos, datos_mod.e_indust,
      label = "Modificada", lw = 2, color = :red, linestyle = :dash)

# Gráfica 3: Tasa de mitigación
p3 = plot(datos_base.tiempos, datos_base.miu,
          label = "Base", lw = 2, color = :blue,
          title = "Tasa de mitigación (MIU)",
          xlabel = "Año", ylabel = "Tasa",
          legend = :bottomright)
plot!(datos_mod.tiempos, datos_mod.miu,
      label = "Modificada", lw = 2, color = :red, linestyle = :dash)

# Gráfica 4: Precio del carbono
p4 = plot(datos_base.tiempos, datos_base.cprice,
          label = "Base", lw = 2, color = :blue,
          title = "Precio del carbono",
          xlabel = "Año", ylabel = "USD/tCO₂",
          legend = :topleft)
plot!(datos_mod.tiempos, datos_mod.cprice,
      label = "Modificada", lw = 2, color = :red, linestyle = :dash)

# Composición del panel y guardado
panel = plot(p1, p2, p3, p4, layout = (2, 2), size = (900, 700))
savefig(panel, "comparacion_DICE.png")
println("Gráfica guardada como 'comparacion_DICE.png'")

# -----------------------------------------------------------------------------
# 6. Exportación de resultados a CSV
# -----------------------------------------------------------------------------

# Crear DataFrames separados para base y modificada
df_base = DataFrame(
    Año              = datos_base.tiempos,
    Temperatura_base = datos_base.tatm,
    Emisiones_base   = datos_base.e_indust,
    Mitigacion_base  = datos_base.miu,
    PrecioC_base     = datos_base.cprice
)

df_mod = DataFrame(
    Año              = datos_mod.tiempos,
    Temperatura_mod  = datos_mod.tatm,
    Emisiones_mod    = datos_mod.e_indust,
    Mitigacion_mod   = datos_mod.miu,
    PrecioC_mod      = datos_mod.cprice
)

# Unir ambos DataFrames por la columna 'Año'
df_completo = innerjoin(df_base, df_mod, on = "Año")

# Guardar tabla completa
CSV.write("resultados_completos.csv", df_completo)
println("Tabla completa guardada como 'resultados_completos.csv'")

# -----------------------------------------------------------------------------
# 7. (Me gusta tener el resultado en tablas) Tabla resumen para la nota técnica (año 2100)
# -----------------------------------------------------------------------------
idx_2100 = findfirst(==(2100), datos_base.tiempos)
if !isnothing(idx_2100)
    println("\n--- Tabla resumen en el año 2100 ---")
    println("Variable                | Base      | Modificada")
    println("------------------------|-----------|------------")
    println("Temperatura (°C)        | $(datos_base.tatm[idx_2100]) | $(datos_mod.tatm[idx_2100])")
    println("Emisiones (GtCO2/año)   | $(datos_base.e_indust[idx_2100]) | $(datos_mod.e_indust[idx_2100])")
    println("Mitigación              | $(datos_base.miu[idx_2100]) | $(datos_mod.miu[idx_2100])")
    println("Precio del carbono (USD)| $(datos_base.cprice[idx_2100]) | $(datos_mod.cprice[idx_2100])")
end

println("\n--- Fin del script ---")