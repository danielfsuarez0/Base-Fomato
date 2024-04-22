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
library(htmlwidgets)


ui <- dashboardPage (
  skin = "black",
  dashboardHeader(
    title = span(img(src = "logo.svg", height = 35), "InterLabs"),
    titleWidth = 300,
    dropdownMenu(
      type = "notifications", 
      headerText = strong("HELP"), 
      icon = icon("question"), 
      badgeStatus = NULL,
      notificationItem(
        text = ("Como usar la app"),
        icon = icon("spinner")
        
      )

    ),
    tags$li(
      a(
        strong("Acerca de la app"),
        height = 40,
        href = "https://github.com/ceefluz/radar/blob/master/README.md",
        title = "",
        target = "_blank"
      ),
      class = "dropdown"
    )
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("Cargar Excel", 
               tabName = "ideamexcel", 
               icon = icon("folder-open"),
               fileInput("file_excel", "Seleccionar archivo Excel", accept = ".xlsx")
      ),
      menuItem("Datos del formato", 
               tabName = "excel", 
               icon = icon("folder-open")
              
      ),
      menuItem("IDEAM", tabName = "ideam", icon = icon("flask"),

               menuItem("Indicadores", tabName = "indicadores", icon = icon("chart-simple")),
               menuItem("Cartas Control", tabName = "cartaideam", icon = icon("chart-line"))
               ),
      menuItem("ONAC", tabName = "onac", icon = icon("seedling"),
               
               menuItem("Indicadores", tabName = "indicadoresonac", icon = icon("chart-simple")),
               menuItem("Cartas Control", tabName = "cartaonac", icon = icon("chart-line"))
               )
      
    ),
    tags$div(style = "text-align: center; margin-top: 300px;",
             img(src = "logo.png", height = 100, width = 180)),

  tags$footer("Desarrollado por Daniel F. Suárez", align = "right", style = "bottom:0;color: grey; padding:10px;
                position:absolute;width:100%;")
  ),
  dashboardBody(   
    tabItems(
      tabItem(
        tabName = "excel",
        uiOutput("dropdown_sheets"),
        dataTableOutput("table_data")
        
      ),
      tabItem(
        tabName = "cartaideam",
        fluidRow(
        column(width = 6,
               h1("Graficos de control"),  # Título grande
               p(style = "textalign: justify;", "En esta sección, podrás analizar gráficamente", strong("las tendencias de los resultados de las pruebas de desempeño"), "presentadas por Biopolab a lo largo del tiempo. Este análisis te permitirá visualizar cómo se comportan los resultados de las diferentes técnicas utilizadas por Biopolab,
                      específicamente en relación con los proveedores."),
               p(style = "textalign: justify;","Podrás seleccionar un año específico para ver cómo evolucionan los resultados de las pruebas según los proveedores a lo largo de ese período. Esto te proporcionará una visión detallada de las tendencias y patrones que pueden surgir en las pruebas de desempeño en diferentes momentos.Explora las gráficas y descubre valiosas insights sobre el rendimiento de Biopolab a través de los años, analizando cómo se desenvuelven los resultados de las pruebas con cada proveedor en las diversas técnicas aplicadas."),
               br(),  # Salto de línea
               hr(),  # Línea horizontal
               br(),  # Salto de línea

        ),
        column(width = 6,
               uiOutput("dropdowns"),
               actionButton("update_plot", "Actualizar Gráfico")
               )),
        fluidRow(
          column(width = 6,
                 plotOutput("zscore_plot")  # Gráfico zscore_plot en una columna
          ),
          column(width = 6,
                 plotOutput("zscore_plot_all")  # Gráfico zscore_plot_all en otra columna
          )
        )
      ),
      tabItem(tabName = "indicadores", 
              column(width = 6,
                     uiOutput("dropdown_indicadores"),
                     actionButton("update_indicadores_plot", "Actualizar Gráficas")
              ),
              column(width = 6,
                     
                     actionButton("generate_indicators_btn", "Generar indicadores")
              ),
              fluidRow(
                column(width = 12,
                       plotOutput("barras_satisfactorias_insatisfactorias")  # Gráfico de barras de satisfactorias e insatisfactorias
                )),
              fluidRow(
                column(width = 12,
                       plotOutput("barras_proveedor_pruebas")  # Gráfico de barras de proveedores y pruebas
                ) 
              
              ),
              fluidRow(
                column(width = 12,
              plotOutput("barras_totales")
                ),
              plotOutput("dona_porcentajes")
              ),
              fluidRow(
                uiOutput("year_selector"),
                             
                plotOutput("barras_totales2")
                
              )
      )
      
)

    )
  )
 


server <- function(input, output, session) {
  observeEvent(input$help_button, {
    # Crear un modal con el contenido HTML de instrucciones
    showModal(
      modalDialog(
        title = "Instrucciones",
        HTML("<object type='text/html' data='instrucciones.html' style='width:100%; height:500px'></object>")
      )
    )
  })

  # Leer el archivo Excel y obtener nombres de hojas
  observeEvent(input$file_excel, {
    sheets <- excel_sheets(input$file_excel$datapath)
    output$dropdown_sheets <- renderUI({
      selectInput("selected_sheet", "Seleccionar Hoja:", choices = sheets)
    })
  })
  
  # Mostrar la tabla de la hoja seleccionada
  output$table_data <- renderDataTable({
    req(input$selected_sheet)
    df <- read_excel(input$file_excel$datapath, sheet = input$selected_sheet)
    datatable(df)
  })
  

  data <- reactive({
    req(input$file_excel)
    df <- read_excel(input$file_excel$datapath, sheet = "IDEAM")
    df
  })
  
  
  # Generate dropdowns based on data
  output$dropdowns <- renderUI({
    req(data())
    dropdowns <- lapply(c("Area", "Matriz", "Prueba", "Proveedor"), function(col) {
      unique_values <- sort(unique(data()[[col]]))
      selectInput(inputId = paste0("dropdown_", col), label = col, choices = c("", unique_values))
    })
    tagList(dropdowns)
  })
  
  # Filter data based on user selections
  filtered_data <- reactive({
    req(data())
    data() %>%
      filter(Area == input$dropdown_Area,
             Matriz == input$dropdown_Matriz,
             Prueba == input$dropdown_Prueba,
             Proveedor == input$dropdown_Proveedor)
  })
  
  # Plot z-scores para el proveedor seleccionado
  output$zscore_plot <- renderPlot({
    req(input$update_plot)
    all_data <- data() %>%
      filter(Area == input$dropdown_Area,
             Matriz == input$dropdown_Matriz,
             Prueba == input$dropdown_Prueba,
             Proveedor == input$dropdown_Proveedor)
    
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Prueba`)) +
      geom_point() +
      geom_line() +
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores por Proveedor", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  # Fondo negro
        panel.background = element_rect(fill = "#D3E3D3"),  # Fondo negro para el panel
        text = element_text(color = "black", size = 10, face = "bold"),  # Texto blanco, tamaño 12, negrita
        plot.title = element_text(hjust = 0.5),  # Centrar título
        axis.title = element_text(hjust = 0.5)  # Centrar etiquetas de los ejes
      )+
      
      geom_point(data = all_data[all_data$`z Score` < -2 | all_data$`z Score` > 2, ], aes(shape = "Outside Limits"), size = 4) +
      scale_shape_manual(values = c("Outside Limits" = 1))  # Cambiar la forma de los puntos fuera de los límites
  })
  
  # Plot z-scores para todos los proveedores
  output$zscore_plot_all <- renderPlot({
    req(input$update_plot)
    all_data <- data() %>%
      filter(Area == input$dropdown_Area,
             Matriz == input$dropdown_Matriz,
             Prueba == input$dropdown_Prueba)
    
    # Convertir la columna z Score a numérica
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    # Calcular los límites del eje Y basados en los datos
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Proveedor`, group = `Proveedor`)) +
      geom_point(size = 3) +  # Tamaño de los puntos
      geom_line() +
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores de Todos los Proveedores", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  # Fondo negro
        panel.background = element_rect(fill = "#D3E3D3"),  # Fondo negro para el panel
        text = element_text(color = "black", size = 10, face = "bold"),  # Texto blanco, tamaño 12, negrita
        plot.title = element_text(hjust = 0.5),  # Centrar título
        axis.title = element_text(hjust = 0.5)  # Centrar etiquetas de los ejes
      ) +
      
      geom_point(data = all_data[all_data$`z Score` < -2 | all_data$`z Score` > 2, ], aes(shape = "Outside Limits"), size = 4) +
      scale_shape_manual(values = c("Outside Limits" = 1))  # Cambiar la forma de los puntos fuera de los límites
  })
  
  output$dropdown_indicadores <- renderUI({
    req(data())
    dropdowns <- lapply(c("Area", "Matriz", "Prueba"), function(col) {
      unique_values <- sort(unique(data()[[col]]))
      selectInput(inputId = paste0("dropdown_indicadores_", col), label = col, choices = c("", unique_values))
    })
    tagList(dropdowns)
  })
  
  # Filtrar datos según selecciones
  filtered_data_indicadores <- reactive({
    req(data())
    data() %>%
      filter(Area == input$dropdown_indicadores_Area,
             Matriz == input$dropdown_indicadores_Matriz,
             Prueba == input$dropdown_indicadores_Prueba)
  })

  
  # Gráfico de barras de satisfactorias e insatisfactorias
  output$barras_satisfactorias_insatisfactorias <- renderPlot({
    req(input$update_indicadores_plot)
    data_indicadores <- filtered_data_indicadores()
    
    ggplot(data_indicadores, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas: Satisfactorias vs Insatisfactorias", x = "Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow"))  # Colores para barras
  })
  
  # Gráfico de barras de proveedores y pruebas
  output$barras_proveedor_pruebas <- renderPlot({
    req(input$update_indicadores_plot)
    data_indicadores <- filtered_data_indicadores()
    
    ggplot(data_indicadores, aes(x = Proveedor, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas por Proveedor", x = "Proveedor", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow"))  # Colores para barras
  })
  
  output$barras_totales <- renderPlot({
    req(input$update_indicadores_plot)
    data_total <- data()  # Obtener todos los datos
    
    # Sumar las cantidades de cada categoría
    summarised_data <- data_total %>%
      group_by(Resultado_de_la_prueba) %>%
      summarise(Cantidad = n())
    
    ggplot(summarised_data, aes(x = Resultado_de_la_prueba, y = Cantidad, fill = Resultado_de_la_prueba)) +
      geom_bar(stat = "identity") +
      labs(title = "Resultados de Pruebas totales", x = "Resultado de la Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))  # Colores para barras
  })
  
  calculate_percentages <- function(data) {
  
    total_pruebas <- nrow(data)
    insatisfactorias <- sum(data$Resultado_de_la_prueba == "Insatisfactorio")
    satisfactorias <- sum(data$Resultado_de_la_prueba == "Satisfactorio")
    cuestionables <- total_pruebas - insatisfactorias - satisfactorias
    
    percentages <- list(
      insatisfactorias = (insatisfactorias / total_pruebas) * 100,
      satisfactorias = (satisfactorias / total_pruebas) * 100,
      cuestionables = (cuestionables / total_pruebas) * 100
    )
    percentages
  }
  


  output$dona_porcentajes <- renderPlot({
    req(input$update_indicadores_plot)
    data_total <- data()  # Obtener todos los datos
    
    # Calcular los porcentajes de cada categoría
    percentages <- data_total %>%
      count(Resultado_de_la_prueba) %>%
      mutate(percentage = n / sum(n) * 100)
    
    # Gráfico de dona
    ggplot(percentages, aes(x = "", y = percentage, fill = Resultado_de_la_prueba)) +
      geom_bar(width = 1, stat = "identity") +
      coord_polar(theta = "y") +
      geom_text(aes(label = paste0(round(percentage, 2), "%")), position = position_stack(vjust = 0.5)) +
      labs(title = "Porcentaje de Resultados de Pruebas totales", fill = "Resultado de la Prueba") +
      theme_void() +
      theme(legend.position = "right")
  })
  
  output$year_selector <- renderUI({
    data_total <- data()  # Obtener todos los datos
    data_total$Fecha_del_informe_year <- lubridate::year(data_total$Fecha_del_informe)
    choices <- unique(data_total$Fecha_del_informe_year)
    radioButtons("year_selector", "Seleccione el año:",
                 choices = choices,
                 selected = NULL)
  })
  
  
  output$barras_totales2 <- renderPlot({
    req(input$update_indicadores_plot)
    data_total <- data()  # Obtener todos los datos
    
    # Filtrar por año si se selecciona uno, de lo contrario, usar todos los años
    if (!is.null(input$year_selector)) {
      data_total <- data_total[data_total$Fecha_del_informe == input$year_selector, ]
    }
    
    ggplot(data_total, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas totales", x = "Fecha_del_informe", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))  # Colores para barras
  })
  
}
# Run the application 
shinyApp(ui = ui, server = server)
