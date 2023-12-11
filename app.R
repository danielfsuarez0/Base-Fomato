# Codigo desarrollado por Daniel Felipe Suarez. El siguiente código creara una aplicación web para poder llevar el formato F-CE-xx Pruebas de desempeño
#a traves de una base de datos de MYSQL. Ademas se podran cargar otros formatos anteriores para poder realizar estadisticas. 

library(shiny)
library(readxl)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(DT)
library(openxlsx)
library(officer)
library(flextable)
library(plotly)
library(tidyr)
library(RMySQL)
library(shinythemes)
library(shinyjs) 

# Establecer la conexión a la base de datos
con <- dbConnect(RMySQL::MySQL(), 
                 dbname = "ejemplo", 
                 host = "localhost", 
                 port = 3306, 
                 user = "root", 
                 password = "biopolab100%")

# Crear una tabla en la base de datos si no existe
crear_tabla <- function(tabla) {
  query <- paste("CREATE TABLE IF NOT EXISTS", tabla, "(Area VARCHAR(255), Matriz VARCHAR(255), Parametro VARCHAR(255), Metodologia VARCHAR(255), ZScore VARCHAR(255), Proveedor VARCHAR(255), Informe VARCHAR(255), Fecha DATE, Resultado VARCHAR(255));")
  dbSendQuery(con, query)
}

crear_tabla("F_GC_27")


# Define UI for application that draws a histogram
ui <- dashboardPage (
  skin = "green",
  dashboardHeader( title = "Pruebas de desempeño",
                   titleWidth = 300
                   ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio", icon = icon("info")),
      menuItem("Datos de excel", tabName = "excel_data", icon = icon("paste")),
      menuItem("Ingreso de pruebas", tabName = "ingreso_pruebas", icon = icon("pen-to-square")),
      menuItem("Estadística", tabName = "estadisticas", icon = icon("percent"))
    ),
    tags$div(style = "text-align: center; margin-top: 300px;",
             img(src = "logo.png", height = 100, width = 180)),

  tags$footer("Desarrollado por Daniel F. Suárez", align = "right", style = "bottom:0;color: grey; padding:10px;
                position:absolute;width:100%;")
  ),
  dashboardBody(   


    tabItems(
      tabItem(tabName = "inicio",  
              h1("F-GC-27 Indicador de Pruebas de Desempeño", style = "text-align: center;"),
              fluidRow(
                column(width = 6, align = "justify",
                       p("La aplicación proporciona una solución eficiente para el seguimiento integral de las pruebas de desempeño realizadas en el laboratorio. Se permite registrar y evaluar indicadores clave de rendimiento, facilitando el análisis detallado de variables medidas. Con la capacidad de exportar datos y generar informes especializados, esta aplicación simplifica el proceso de evaluación del rendimiento, brindando una visión completa y perspicaz para el continuo mejoramiento en el laboratorio."),
                       p("Esta aplicación ha sido desarrollada exclusivamente por el equipo del", strong("Área de Calidad")," del laboratorio. Su implementación se ha diseñado para ser utilizada de manera interna, proporcionando una plataforma segura y eficiente para el monitoreo riguroso de las pruebas de desempeño."),

                       tags$div(
                                h2("Descripción de la Aplicación Shiny - BIOPOLAB Pruebas de Desempeño"),
                                p("La aplicación Shiny BIOPOLAB Pruebas de Desempeño ofrece una solución completa y dinámica para el monitoreo y análisis exhaustivo de pruebas realizadas en el laboratorio. Diseñada por el equipo del Área de Calidad, esta aplicación proporciona herramientas poderosas que facilitan la gestión eficiente de datos y generación de informes especializados."),
                                h3("Funcionalidades Destacadas:"),
                                tags$ol(
                                  tags$li(strong("Gráficos Estadísticos:"), " La aplicación genera gráficos interactivos que ofrecen estadísticas detalladas sobre el desempeño de las pruebas, permitiendo un análisis visual rápido y preciso."),
                                  tags$li(strong("Seguimiento de Avance:"), " Proporciona un seguimiento claro y en tiempo real del avance de las pruebas presentadas en un período determinado, facilitando la identificación de patrones y tendencias."),
                                  tags$li(strong("Acceso a Base de Datos:"), " Conéctate a una base de datos desarrollada por el Área de Calidad para almacenar de manera segura y eficiente los formatos de pruebas llevados a cabo. Esto garantiza una gestión de datos organizada y confiable."),
                                  tags$li(strong("Generación de Informes:"), " Ofrece una característica excepcional que permite la generación instantánea de informes en formato PDF o Word. Estos informes contienen análisis detallados y estadísticas clave para respaldar la toma de decisiones informadas."),
                                  tags$li(strong("Descarga de Datos en Excel:"), " La aplicación facilita la descarga de datos en formato Excel, permitiendo a los usuarios obtener conjuntos de datos completos para análisis adicionales o almacenamiento externo.")
                                ),
                                h3("Ventajas:"),
                                tags$ul(
                                  tags$li(strong("Registro Dinámico:"), " La aplicación proporciona un registro dinámico y preciso de las pruebas presentadas, permitiendo un monitoreo riguroso y continuo."),
                                  tags$li(strong("Eficiencia en la Toma de Decisiones:"), " Facilita la toma de decisiones informadas al ofrecer análisis detallados y visualizaciones claras del desempeño de las pruebas."),
                                  tags$li(strong("Mejora Continua:"), " Contribuye a iniciativas internas de mejora continua al proporcionar una plataforma eficiente y segura para la gestión de pruebas de desempeño.")
                                ),
                                p("La aplicación Shiny BIOPOLAB Pruebas de Desempeño es una herramienta esencial para cualquier laboratorio que busque optimizar su proceso de evaluación de pruebas y mantener un control preciso de su rendimiento.")
                       )
                ),
                column(width = 3, selectInput("tabla_seleccionada", "Seleccionar Tabla", "") ),
                column(width = 3, actionButton("crear", "Crear nuevo formato"), textAreaInput("nombre", label = "Formato", placeholder = "Escribe el nombre del formato aquí") ),
                column(width = 6, DTOutput("datos_tabla_seleccionada"))
                ),

              h2(strong("¿CÓMO USARLA?", style = "text-align: right;")),
              fluidRow(
                column(width = 3,
                       box(title = "1. LISTA DE TÉCNICAS", width = NULL, solidHeader = TRUE, status = "primary", p("Debe seleccionar un archivo de excel para cargar la lista completa de las técnicas acreditadas con IDEAM o de ONAC, de esta manera se podrá calcular la estadística del formato"))
                ),
                column(width = 3,
                       box(title = "2.ACCESO A BASE DE DATOS", width = NULL, solidHeader = TRUE, status = "success", p("La aplicación web tiene acceso a la base de datos de los formatos. Seleccione el formato en el cual desea agregar nuevos datos, o del cual desea visualizar las estadísticas. Si desea puede crear un nuevo formato para guardar en la base de datos."))
                ),
                column(width = 3,
                       box(title = "3.REGISTRE DATOS NUEVOS", width = NULL, solidHeader = TRUE, status = "danger", p("Utilice los espacios para cada dato, para registrar los datos. Al darle click al botón de registrar, los datos son automáticamente guardados en la base de datos. Si desea eliminar algún valor erróneo, presione el botón de eliminar y seleccione la fila que desea eliminar, luego dé click en aceptar"))
                ),
                column(width = 3,
                       box(title = "4. UTILICE LAS ESTADÍSTICAS PARA GENERAR REPORTES", width = NULL, solidHeader = TRUE, status = "warning", p("Revise las gráficas generadas automáticamente. Puede generar un reporte en pdf o word o descargar los datos en un archivo de excel."))
                )
                )
              
              ), #tabtiem1 cierre
      tabItem(tabName = "excel_data",
              h1(strong("Lista completa de técnicas acreditadas", style = "text-align: center")),
              fileInput("file", "Seleccionar archivo Excel"),
              
              fluidRow(
                column(4,
                       valueBoxOutput("total_filas", width = 12),
                       
                ),
                column(4,
                       valueBoxOutput("fisicoquimica_filas", width = 12)
                ),
                column(4,
                       valueBoxOutput("microbiologia_filas", width = 12)
                )
              ),
              fluidRow(
                column(12,tableOutput("tabla_excel"))
              )
        
        
      ), #cierre tabitem2
      tabItem(tabName = "ingreso_pruebas",
              h1(strong("Ingreso de datos")),
              fluidRow(
                column(4, selectInput("area", "Área", NULL)),
                column(4, selectInput("matriz", "Matriz", NULL)),
                column(4, selectInput("parametro", "Parámetro", NULL))
              ),
              fluidRow(
                column(4, selectInput("metodologia", "Metodología", NULL)),
                column(4, textInput("zcore", "Z Score")),
                column(4, textInput("proveedor", "Proveedor"))
              ),
              fluidRow(
                column(4, dateInput("fecha", "Fecha de Prueba", value = Sys.Date())),
                column(4, selectInput("resultado", "Resultado",
                                      choices = c("Satisfactorio", "Cuestionable", "Insatisfactorio"))),
                column(4, textInput("informe", "Número de informe/Ronda"))
              ),
              
              fluidRow(
                column(8, dataTableOutput("tabla_datos_completos")),
                column(4, actionButton("submit_prueba", "Registrar Prueba")),
                column(4,downloadButton("exportar_excel", "Exportar a Excel", class = "butt1"))
              )
      
        
        
      ), # tabitem 3 cierre
      tabItem(tabName = "estadisticas",
              h2("Estadísticas Generales"),
              fluidRow(
                
                column(4,downloadButton("generar_reporte", "Generar Informe PDF")),
                column(4,radioButtons('format', 'Document format', c('PDF', 'HTML', 'Word'),
                                      inline = TRUE))
              ),
              fluidRow(
                column(6, plotOutput("grafico_satisfactorias")),
                column(6, plotOutput("grafico_mes")),
                column(6, plotOutput("grafico_avance")),
                column(6, DTOutput("tabla_faltantes"))
              ),
              h2("Estadísticas Fisicoquímica"),
              fluidRow(
                column(6, plotOutput("grafico_satisfactorias_fq")),
                column(6, plotOutput("grafico_mes_fq")),
                column(6, plotOutput("grafico_avance_fq")),
                column(6, DTOutput("tabla_faltantes_fq"))
              ),
              h2("Estadísticas Microbiología"),
              fluidRow(
                column(6, plotOutput("grafico_satisfactorias_micro")),
                column(6, plotOutput("grafico_mes_micro")),
                column(6, plotOutput("grafico_avance_micro")),
                column(6, DTOutput("tabla_faltantes_micro"))
              ),
              fluidRow(
                
                # Gráfico de radar: Puntos fuertes y débiles de cada proveedor
                box(
                  title = "Barras de Rendimiento de Proveedores",
                  plotlyOutput("grafico_barras_proveedores", height = 300)
                )
              ),
              fluidRow(
                #  Gráfico de barras: Rendimiento histórico por técnica
                box(
                  title = "Rendimiento Histórico por Técnica",
                  plotOutput("grafico_barras_tecnicas", height = 300)
                ),
                column(6,
                       textAreaInput("analisis", label = "Análisis", placeholder = "Escribe tu análisis aquí..."),
                       textAreaInput("conclusiones", label = "Conclusiones", placeholder = "Escribe tus conclusiones aquí...")
                )
              )
      )
      
      
      ) #tabitems cierre
    )
  )
 


server <- function(input, output, session) {
  datos_excel <- reactiveVal(NULL)
  datos_completos <- reactiveVal(data.frame())
  actualizarDatosCompletos <- function() {
    if (!is.null(input$tabla_seleccionada)) {
      query_select <- paste("SELECT * FROM", input$tabla_seleccionada, ";")
      
      datos_actuales <- dbGetQuery(con, query_select)
      datos_actuales$Fecha <- as.Date(datos_actuales$Fecha, format = "%Y-%m-%d")
      datos_completos(datos_actuales)

      
    }
  }
  
  # Función para cargar y seleccionar tablas
  observe({
    tablas <- dbListTables(con)
    updateSelectInput(session, "tabla_seleccionada", choices = tablas)
  })
  
  # Función para mostrar datos de la tabla seleccionada
  output$datos_tabla_seleccionada <- DT::renderDataTable({
    if (!is.null(input$tabla_seleccionada)) {
      query <- paste("SELECT * FROM", input$tabla_seleccionada, ";")
      datos_tabla <- dbGetQuery(con, query)
      datatable(datos_tabla)
      
  }
  })
  

  
  observeEvent(input$file, {
    datos_leidos <- read_excel(input$file$datapath)
    datos_excel(datos_leidos)

    # Actualizar el total de filas
    output$total_filas <- renderValueBox({
      valueBox(
        value = nrow(datos_leidos),
        subtitle = "Total técnicas acreditadas",
        icon = icon("thumbs-up", lib = "glyphicon")
      )
    })
    
    # Filtrar datos por área y actualizar las filas para Fisicoquímica
    fisicoquimica_filas <- nrow(subset(datos_leidos, Area == "Fisicoquímicos"))
    output$fisicoquimica_filas <- renderValueBox({
      valueBox(
        value = fisicoquimica_filas,
        subtitle = "Fisicoquímica",
        icon = icon("flask"),
        color = "green"
      )
    })
    
    # Filtrar datos por área y actualizar las filas para Microbiología
    microbiologia_filas <- nrow(subset(datos_leidos, Area == "Microbiología"))
    output$microbiologia_filas <- renderValueBox({
      valueBox(
        value = microbiologia_filas,
        subtitle = "Microbiología",
        icon = icon("vial-virus"),
        color = "red"
      )
    })
    
    updateSelectInput(session, "area", choices = unique(datos_leidos$Area))
    updateSelectInput(session, "matriz", choices = NULL)
    updateSelectInput(session, "parametro", choices = NULL)
    updateSelectInput(session, "metodologia", choices = NULL)
  })
  
  observeEvent(input$area, {
    updateSelectInput(session, "matriz", choices = unique(datos_excel()$Matriz[datos_excel()$Area == input$area]))
  })
  
  observeEvent(input$matriz, {
    updateSelectInput(session, "parametro", choices = unique(datos_excel()$Parametro[datos_excel()$Area == input$area & datos_excel()$Matriz == input$matriz]))
  })
  
  observeEvent(input$parametro, {
    updateSelectInput(session, "metodologia", choices = unique(datos_excel()$Metodologia[datos_excel()$Area == input$area & datos_excel()$Matriz == input$matriz & datos_excel()$Parametro == input$parametro]))
  })
  
  output$tabla_excel <- renderTable({
    if (!is.null(datos_excel())) {
      datos_excel()
    }
  })
  
  output$tabla_excel <- renderTable({
    if (!is.null(datos_excel())) {
      datos_excel()
    }
  })
  output$tabla_datos_completos <- renderDataTable({
    actualizarDatosCompletos()

      datatable(datos_completos(), options = list(pageLength = 5, lengthChange = FALSE))
    
  })
  
  
  observeEvent(input$submit_prueba, {

    Area <- input$area
    Matriz = input$matriz
    Parametro = input$parametro
    Metodologia = input$metodologia
    ZScore = input$zcore
    Proveedor = input$proveedor
    Informe = input$informe
    Fecha = input$fecha
    Resultado = input$resultado


    # Obtener el nombre de la tabla seleccionada por el usuario
    tabla_seleccionada <- input$tabla_seleccionada
    # Crear la consulta INSERT INTO
    consulta <- sprintf("INSERT INTO %s (Area, Matriz, Parametro, Metodologia, ZScore, Proveedor, Informe, Fecha, Resultado) VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s')",
                        tabla_seleccionada, Area, Matriz, Parametro, Metodologia, ZScore, Proveedor, Informe, Fecha, Resultado)
    
    # Ejecutar la consulta
    dbExecute(con, consulta)
    query_select <- paste("SELECT * FROM", tabla_seleccionada, ";")
    datos_actuales <- dbGetQuery(con, query_select)
    
  })
  output$grafico_satisfactorias <- renderPlot({
    actualizarDatosCompletos()
    if (!is.null(datos_completos())) {
      ggplot(datos_completos(), aes(x = Resultado)) +
        geom_bar(fill = "steelblue") +
        labs(title = "Pruebas Satisfactorias",
             x = "Resultado",
             y = "Cantidad")
    }
  })
  
  output$grafico_mes <- renderPlot({
    actualizarDatosCompletos()
    
    # Verificar si datos_completos() no es NULL
    if (!is.null(datos_completos())) {

      ggplot(datos_completos(), aes(x = format(Fecha, "%m"), fill = Resultado)) +
        geom_bar(position = "dodge", stat = "count") +
        labs(title = "Pruebas Presentadas por Mes",
             x = "Mes",
             y = "Cantidad")
    }
  })
  
  
  output$grafico_avance <- renderPlot({
    actualizarDatosCompletos()
    if (!is.null(datos_completos())) {
      avance <- nrow(datos_completos()) / length(unique(datos_excel()$Parametro)) * 100
      datos_avance <- data.frame(Estado = c("Presentado", "Faltante"), Porcentaje = c(avance, 100 - avance))
      
      ggplot(datos_avance, aes(x = "", y = Porcentaje, fill = Estado)) +
        geom_bar(stat = "identity") +
        coord_polar("y") +
        labs(title = "Porcentaje de Avance",
             x = NULL,
             y = NULL) +
        theme_void()
    }
  })
  
  output$tabla_faltantes <- renderDT({
    if (!is.null(datos_completos())) {
      parametros_faltantes <- setdiff(unique(datos_excel()$Parametro), unique(datos_completos()$Parametro))
      tabla_faltantes <- data.frame(Parametro = parametros_faltantes)
      datatable(tabla_faltantes, options = list(pageLength = 5, lengthChange = FALSE))
    }
  })
  
  output$grafico_satisfactorias_fq <- renderPlot({
    if (!is.null(datos_completos())) {
      datos_fq <- datos_completos()[datos_completos()$Area == "Ambiental", ]
      ggplot(datos_fq, aes(x = Resultado)) +
        geom_bar(fill = "steelblue") +
        labs(title = "Pruebas Satisfactorias (Ambiental)",
             x = "Resultado",
             y = "Cantidad")
    }
  })
  
  output$grafico_mes_fq <- renderPlot({
    if (!is.null(datos_completos())) {
      datos_fq <- datos_completos()[datos_completos()$Area == "Fisicoquímicos", ]
      ggplot(datos_fq, aes(x = format(Fecha, "%B"), fill = Resultado)) +
        geom_bar(position = "dodge", stat = "count") +
        labs(title = "Pruebas Presentadas por Mes (Ambiental)",
             x = "Mes",
             y = "Cantidad")
    }
  })
  
  output$grafico_avance_fq <- renderPlot({
    if (!is.null(datos_completos())) {
      avance_fq <- nrow(datos_completos()[datos_completos()$Area == "Fisicoquímicos", ]) / length(unique(datos_excel()$Parametro[datos_excel()$Area == "Fisicoquímicos"])) * 100
      datos_avance_fq <- data.frame(Estado = c("Presentado", "Faltante"), Porcentaje = c(avance_fq, 100 - avance_fq))
      
      ggplot(datos_avance_fq, aes(x = "", y = Porcentaje, fill = Estado)) +
        geom_bar(stat = "identity") +
        coord_polar("y") +
        labs(title = "Porcentaje de Avance (Ambiental)",
             x = NULL,
             y = NULL) +
        theme_void()
    }
  })
  
  output$tabla_faltantes_fq <- renderDT({
    if (!is.null(datos_completos())) {
      parametros_faltantes_fq <- setdiff(unique(datos_excel()$Parametro[datos_excel()$Area == "Fisicoquímicos"]), unique(datos_completos()$Parametro[datos_completos()$Area == "Fisicoquímicos"]))
      tabla_faltantes_fq <- data.frame(Parametro = parametros_faltantes_fq)
      datatable(tabla_faltantes_fq, options = list(pageLength = 5, lengthChange = FALSE))
    }
  })
  
  output$grafico_satisfactorias_micro <- renderPlot({
    if (!is.null(datos_completos())) {
      datos_micro <- datos_completos()[datos_completos()$Area == "Microbiología", ]
      ggplot(datos_micro, aes(x = Resultado)) +
        geom_bar(fill = "steelblue") +
        labs(title = "Pruebas Satisfactorias (Microbiologia)",
             x = "Resultado",
             y = "Cantidad")
    }
  })
  
  output$grafico_mes_micro <- renderPlot({
    if (!is.null(datos_completos())) {
      datos_micro <- datos_completos()[datos_completos()$Area == "Microbiología", ]
      ggplot(datos_micro, aes(x = format(Fecha, "%B"), fill = Resultado)) +
        geom_bar(position = "dodge", stat = "count") +
        labs(title = "Pruebas Presentadas por Mes (Microbiologia)",
             x = "Mes",
             y = "Cantidad")
    }
  })
  
  output$grafico_avance_micro <- renderPlot({
    if (!is.null(datos_completos())) {
      avance_micro <- nrow(datos_completos()[datos_completos()$Area == "Microbiología", ]) / length(unique(datos_excel()$Parametro[datos_excel()$Area == "Microbiología"])) * 100
      datos_avance_micro <- data.frame(Estado = c("Presentado", "Faltante"), Porcentaje = c(avance_micro, 100 - avance_micro))
      
      ggplot(datos_avance_micro, aes(x = "", y = Porcentaje, fill = Estado)) +
        geom_bar(stat = "identity") +
        coord_polar("y") +
        labs(title = "Porcentaje de Avance (Microbiologia)",
             x = NULL,
             y = NULL) +
        theme_void()
    }
  })
  
  output$tabla_faltantes_micro <- renderDT({
    if (!is.null(datos_completos())) {
      parametros_faltantes_micro <- setdiff(unique(datos_excel()$Parametro[datos_excel()$Area == "Microbiología"]), unique(datos_completos()$Parametro[datos_completos()$Area == "Microbiología"]))
      tabla_faltantes_micro <- data.frame(Parametro = parametros_faltantes_micro)
      datatable(tabla_faltantes_micro, options = list(pageLength = 5, lengthChange = FALSE))
    }
  })

  
  onStop(function() {
    dbDisconnect(con)
  })
  
}
# Run the application 
shinyApp(ui = ui, server = server)
