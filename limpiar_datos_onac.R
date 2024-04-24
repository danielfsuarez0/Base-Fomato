# Instalar y cargar las librerías necesarias
install.packages("readxl")
library(readxl)

# Leer el archivo Excel
datos <- read_excel("C:/Users/CAL-SOFIA/Documents/GitHub/Base-Fomato/ONAC_TECNICAS.xlsx")

# Verificar los nombres de las columnas
print(colnames(datos))

# Ajustar los nombres de las columnas para que coincidan exactamente
colnames(datos) <- c("CÓDIGO SECTOR GENERAL", "CÓDIGO SECTOR ESPECÍFICO", "ENSAYO", "TÉCNICA", "SUSTANCIA, MATERIAL, ELEMENTO O PRODUCTO A ENSAYAR", "FAMILIA DE TÉCNICAS", "DOCUMENTO NORMATIVO")

# Filtrar los datos para obtener valores únicos
datos_filtrados <- unique(datos[, c("CÓDIGO SECTOR GENERAL", "CÓDIGO SECTOR ESPECÍFICO", "ENSAYO", "TÉCNICA", "SUSTANCIA, MATERIAL, ELEMENTO O PRODUCTO A ENSAYAR", "FAMILIA DE TÉCNICAS", "DOCUMENTO NORMATIVO")])

# Mostrar los datos filtrados
print(datos_filtrados)


# Suponiendo que datos_filtrados contiene tus datos únicos después del primer filtrado

# Función para comparar y filtrar filas
filtrar_filas_unicas <- function(datos) {
  # Crear un vector para almacenar las filas únicas
  filas_unicas <- c()
  
  # Recorrer cada fila
  for (i in 1:nrow(datos)) {
    # Obtener la fila actual
    fila_actual <- datos[i, ]
    
    # Flag para verificar si la fila es única
    fila_unica <- TRUE
    
    # Recorrer nuevamente las filas para comparar con la fila actual
    for (j in 1:nrow(datos)) {
      if (i != j) {  # Evitar comparar la fila consigo misma
        fila_comparar <- datos[j, ]
        
        # Comparar columnas y verificar si coinciden en todas
        if (all(fila_actual[c("ENSAYO", "SUSTANCIA, MATERIAL, ELEMENTO O PRODUCTO A ENSAYAR",
                              "FAMILIA DE TÉCNICAS", "DOCUMENTO NORMATIVO")] == 
                fila_comparar[c("ENSAYO", "SUSTANCIA, MATERIAL, ELEMENTO O PRODUCTO A ENSAYAR",
                                "FAMILIA DE TÉCNICAS", "DOCUMENTO NORMATIVO")])) {
          fila_unica <- FALSE  # La fila no es única, marcar como falsa
          break  # Salir del bucle interior
        }
      }
    }
    
    # Si la fila es única, agregarla al vector de filas únicas
    if (fila_unica) {
      filas_unicas <- c(filas_unicas, i)
    }
  }
  
  # Devolver las filas únicas del conjunto de datos original
  return(datos[filas_unicas, ])
}

# Aplicar la función para filtrar filas únicas
datos_filtrados_unicos <- filtrar_filas_unicas(datos_filtrados)

# Mostrar los datos filtrados únicos
print(datos_filtrados_unicos)
assign("datos_filtrados_unicos", datos_filtrados_unicos, envir = .GlobalEnv)
write.xlsx(datos_filtrados_unicos, "datos_filtrados_unicos.xlsx")
