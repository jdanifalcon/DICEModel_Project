# ============================================================
# analisis_sensibilidad.jl
# Análisis de sensibilidad: efecto del límite de temperatura
# sobre emisiones, precio del carbono y daños económicos
# Autora: Jessica Daniela Ocaña Falcón
# Fecha: Julio 2026
# ============================================================

using DICEModel
using Plots
using DataFrames
using CSV

# ---------- 1. Definir escenarios ----------
# Límites de temperatura a evaluar (°C sobre nivel preindustrial)
limites = [1.5, 1.8, 2.0, 2.5, 3.0]

# Colores para cada escenario
colores = [:purple, :red, :darkorange, :green, :blue]
estilos = [:solid, :dash, :solid, :dashdot, :dot]

# ---------- 2. Correr escenario base ----------
println("Corriendo escenario BASE...")
res_base = run_dice_scenario("base")
times    = res_base.times
años     = times .+ 2020  # convertir a años calendario

# ---------- 3. Correr escenarios con restricción de temperatura ----------
resultados = Dict{Float64, Any}()

for lim in limites
    println("Corriendo escenario con límite de temperatura: $(lim) °C...")
    res = run_dice(bounds = Dict("TATM" => ("<=", lim)))
    resultados[lim] = res
end

println("Todas las simulaciones completadas.")

# ---------- 4. Gráficas comparativas ----------
# Usar solo los primeros 17 períodos (2020-2100, cada 5 años)
idx = 1:17  # 2020 a 2100

# --- 4.1 Temperatura atmosférica ---
p1 = plot(años[idx], res_base.TATM[idx],
          label = "Base (sin límite)", lw = 2.5, color = :black,
          title = "Temperatura atmosférica",
          xlabel = "Año", ylabel = "°C sobre nivel preindustrial",
          legend = :topleft, legendfontsize = 7,
          grid = true, gridalpha = 0.3)

for (i, lim) in enumerate(limites)
    plot!(años[idx], resultados[lim].TATM[idx],
          label = "Límite $(lim) °C", lw = 1.8,
          color = colores[i], linestyle = estilos[i])
    hline!([lim], label = "", lw = 0.5, color = colores[i],
           linestyle = :dot, alpha = 0.5)
end

# --- 4.2 Emisiones de CO₂ ---
p2 = plot(años[idx], res_base.ECO2[idx],
          label = "Base", lw = 2.5, color = :black,
          title = "Emisiones totales de CO₂",
          xlabel = "Año", ylabel = "GtCO₂/año",
          legend = :topright, legendfontsize = 7,
          grid = true, gridalpha = 0.3)

for (i, lim) in enumerate(limites)
    plot!(años[idx], resultados[lim].ECO2[idx],
          label = "Límite $(lim) °C", lw = 1.8,
          color = colores[i], linestyle = estilos[i])
end

# --- 4.3 Precio del carbono ---
p3 = plot(años[idx], res_base.CPRICE_R[idx],
          label = "Base", lw = 2.5, color = :black,
          title = "Precio del carbono",
          xlabel = "Año", ylabel = "USD 2019 / tCO₂",
          legend = :topleft, legendfontsize = 7,
          grid = true, gridalpha = 0.3)

for (i, lim) in enumerate(limites)
    plot!(años[idx], resultados[lim].CPRICE_R[idx],
          label = "Límite $(lim) °C", lw = 1.8,
          color = colores[i], linestyle = estilos[i])
end

# --- 4.4 Tasa de mitigación ---
p4 = plot(años[idx], res_base.MIU[idx],
          label = "Base", lw = 2.5, color = :black,
          title = "Tasa de mitigación (MIU)",
          xlabel = "Año", ylabel = "Tasa (0-1)",
          legend = :bottomright, legendfontsize = 7,
          grid = true, gridalpha = 0.3)

for (i, lim) in enumerate(limites)
    plot!(años[idx], resultados[lim].MIU[idx],
          label = "Límite $(lim) °C", lw = 1.8,
          color = colores[i], linestyle = estilos[i])
end

# --- Panel completo ---
panel = plot(p1, p2, p3, p4,
             layout = (2, 2), size = (1000, 750),
             plot_title = "Análisis de sensibilidad: límite de temperatura en DICE2023",
             plot_titlefontsize = 11,
             margin = 5Plots.mm)

savefig(panel, "sensibilidad_temperatura.png")
println("Panel guardado: sensibilidad_temperatura.png")

# ---------- 5. Tabla resumen al año 2100 ----------
# El índice del año 2100 es el período 17 (2020 + 16*5 = 2100)
idx_2100 = 17

df = DataFrame(
    Escenario           = vcat("Base", ["Límite $(lim) °C" for lim in limites]),
    Temp_2100_C         = vcat(res_base.TATM[idx_2100],
                               [resultados[lim].TATM[idx_2100] for lim in limites]),
    Emisiones_2100_GtCO2 = vcat(res_base.ECO2[idx_2100],
                                [resultados[lim].ECO2[idx_2100] for lim in limites]),
    Precio_C_2100_USD   = vcat(res_base.CPRICE_R[idx_2100],
                               [resultados[lim].CPRICE_R[idx_2100] for lim in limites]),
    MIU_2100            = vcat(res_base.MIU[idx_2100],
                               [resultados[lim].MIU[idx_2100] for lim in limites])
)

println("\n===== Resumen al año 2100 =====")
println(df)

CSV.write("sensibilidad_resumen_2100.csv", df)
println("\nTabla guardada: sensibilidad_resumen_2100.csv")
