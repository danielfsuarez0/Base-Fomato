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
library(lubridate)
library(shinydashboardPlus)



ui <- dashboardPage (

  
  skin = "black",
  dashboardHeader(
    title = span(img(src = "logo.svg", height = 35), "InterLabs"),
    titleWidth = 300,

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
               ),
      menuItem("PICCAP", tabName = "piccap", icon = icon("vial-virus"),
               
               menuItem("Indicadores", tabName = "indicadorespiccap", icon = icon("chart-simple")),
               menuItem("Cartas Control", tabName = "cartapiccap", icon = icon("chart-line"))
      )
      
    ),
    tags$div(style = "text-align: center; margin-top: 300px;",
             img(src = "logo.png", height = 100, width = 180)),

  tags$footer("Desarrollado por Daniel F. Suárez", align = "right", style = "bottom:0;color: grey; padding:10px;
                position:absolute;width:100%;")
  ),
  dashboardBody( 
    tags$head(tags$style(HTML("body {background-color: #00008B !important;}"))),
    tabItems(
      tabItem(
        tabName = "excel",
        tags$h1("BIENVENIDO A LABINTERLAB", style = "text-align: center;") %>%
          tags$p("En primer lugar, primero cargue el formato ", tags$strong("F-GC-27 Indicador de pruebas de desempeño"), " en formato ", tags$strong(".xlsx"), ", a continuación se muestran las tablas que se cargan de las diferentes hojas del excel.|"),
        uiOutput("dropdown_sheets"),
        dataTableOutput("table_data")
        
      ),
      tabItem(
        tabName = "cartaideam",
        fluidRow(
          column(width = 6, h1(style = "font-weight:bold", "CARTAS CONTROL")),

          box(title = "Análisis de Z-score", background = "light-blue",
              fluidRow(
                column(width = 12, align = "justify",
                       "A continuación puede encontrar las gráficas discriminadas por proveedor para cada técnica que desee ver. Seleccione del menu los parámetros necesarios para poder
                       visualizar los gráficos. Allí puede ver y analizar las tendencias, según el Z-score obtenido en las pruebas"
                )
              )
          )),
          fluidRow(
            column(width = 6,
                   uiOutput("dropdowns"),
                   actionButton("update_plot", "Actualizar Gráfico")
            ),
            box(title = "Cartas control", background = "green",
                fluidRow(
                column(width = 12, align = "justify",
                "Las cartas de control son una herramienta invaluable en el análisis de pruebas, ya que permiten observar de manera discriminada los resultados a lo largo del tiempo. Con ellas, podemos estudiar tendencias y desviaciones en los datos obtenidos, lo que nos brinda una visión detallada y precisa del desempeño de las pruebas a lo largo de distintos períodos. 
                Al utilizar cartas de control, podemos identificar patrones y cambios significativos en los resultados de las pruebas, lo que nos ayuda a comprender mejor cómo se comportan los procesos y a tomar decisiones informadas para mejorar la calidad y consistencia en los resultados."
                                   )
                                 )
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
              fluidRow( h1(style = "text-align: center", "INDICADORES DE PRUEBAS DE DESEMPEÑO")
                
              ),
              br(),
              br(),
                fluidRow(box(title = "Análisis de Desempeño de Pruebas en el Laboratorio", background = "green",
                             fluidRow(
                               column(width = 12, align = "justify",
                                      "Esta sección proporciona un análisis detallado del desempeño de las pruebas realizadas en el laboratorio, ofreciendo una visión integral de los resultados obtenidos. Las gráficas presentadas resaltan distintas categorías de desempeño, como resultados satisfactorios, insatisfactorios y cuestionables, permitiendo una evaluación exhaustiva de los datos clave de rendimiento."
                               )
                             )
                ),
                
                box(title = "Exploración Detallada", background = "green",
                    fluidRow(
                      column(width = 12, align = "justify",
                             "Seleccione la técnica específica que desea analizar por separado a través de los menús desplegables a continuación. Esto le permitirá enfocarse en un aspecto particular del desempeño de las pruebas y obtener una comprensión más profunda de los resultados asociados.",
                             "Además, puede seleccionar el año de interés para visualizar cómo han evolucionado los resultados a lo largo del tiempo. Esto le brinda la oportunidad de identificar tendencias, patrones y áreas de mejora en función de la cronología de las pruebas realizadas."
                      )
                    )
                ),
                
                box(title = "Acceso a Información Histórica", background = "green",
                    fluidRow(
                      column(width = 12, align = "justify",
                             "También se generan gráficas que incluyen la totalidad de las pruebas de desempeño presentadas históricamente por el laboratorio. Esta perspectiva histórica le proporciona una visión general de largo plazo, facilitando la comparación entre diferentes períodos y la evaluación de la progresión del desempeño a lo largo de los años."
                      )
                    )
                ),
                
                box(title = "Interacción Intuitiva", background = "green",
                    fluidRow(
                      column(width = 12, align = "justify",
                             "Utilice los menús desplegables a continuación para seleccionar la técnica de interés y el año deseado. Al explorar las gráficas generadas, podrá identificar tendencias, anomalías y áreas de enfoque para mejorar continuamente el desempeño y la calidad de las pruebas en el laboratorio."
                      )
                    )
                )),
              
              fluidRow(
              column(width = 6,
                     uiOutput("dropdown_indicadores"),
                     actionButton("update_indicadores_plot", "Actualizar Gráficas")
              )),
              fluidRow(
                column(width = 6,
                       plotOutput("barras_satisfactorias_insatisfactorias")  # Gráfico de barras de satisfactorias e insatisfactorias
                ),
            
                column(width = 6,
                       plotOutput("barras_proveedor_pruebas")  # Gráfico de barras de proveedores y pruebas
                ) 
              ),
           
              fluidRow(
                column(width = 12,
              plotOutput("barras_totales")
                )
              ),
              fluidRow(plotOutput("dona_porcentajes")),
              fluidRow( column(width = 6,
                               uiOutput("year_selector")
                               )

              ),
              fluidRow(column(width = 12,
                        plotOutput("barras_totales2")))
      ),
      tabItem(
        tabName = "cartaonac",
        fluidRow(
          column(width = 6, h1(style = "font-weight:bold", "CARTAS CONTROL")),
          
          box(title = "Análisis de Z-score", background = "light-blue",
              fluidRow(
                column(width = 12, align = "justify",
                       "A continuación puede encontrar las gráficas discriminadas por proveedor para cada técnica que desee ver. Seleccione del menu los parámetros necesarios para poder
                       visualizar los gráficos. Allí puede ver y analizar las tendencias, según el Z-score obtenido en las pruebas"
                )
              )
          )),
        fluidRow(
          column(width = 6,
                 uiOutput("dropdowns_onac"),
                 actionButton("update_plot_onac", "Actualizar Gráfico")
          ),
          box(title = "Cartas control", background = "green",
              fluidRow(
                column(width = 12, align = "justify",
                       "Las cartas de control son una herramienta invaluable en el análisis de pruebas, ya que permiten observar de manera discriminada los resultados a lo largo del tiempo. Con ellas, podemos estudiar tendencias y desviaciones en los datos obtenidos, lo que nos brinda una visión detallada y precisa del desempeño de las pruebas a lo largo de distintos períodos. 
                Al utilizar cartas de control, podemos identificar patrones y cambios significativos en los resultados de las pruebas, lo que nos ayuda a comprender mejor cómo se comportan los procesos y a tomar decisiones informadas para mejorar la calidad y consistencia en los resultados."
                )
              )
          )),
        
        
        fluidRow(
          column(width = 6,
                 plotOutput("zscore_plot_onac")  # Gráfico zscore_plot en una columna
          ),
          column(width = 6,
                 plotOutput("zscore_plot_all_onac")  # Gráfico zscore_plot_all en otra columna
          )
        )
      ),
      tabItem(tabName = "indicadoresonac", 
              fluidRow( h1(style = "text-align: center", "INDICADORES DE PRUEBAS DE DESEMPEÑO")
                        
              ),
              br(),
              br(),
              fluidRow(box(title = "Análisis de Desempeño de Pruebas en el Laboratorio", background = "green",
                           fluidRow(
                             column(width = 12, align = "justify",
                                    "Esta sección proporciona un análisis detallado del desempeño de las pruebas realizadas en el laboratorio, ofreciendo una visión integral de los resultados obtenidos. Las gráficas presentadas resaltan distintas categorías de desempeño, como resultados satisfactorios, insatisfactorios y cuestionables, permitiendo una evaluación exhaustiva de los datos clave de rendimiento."
                             )
                           )
              ),
              
              box(title = "Exploración Detallada", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "Seleccione la técnica específica que desea analizar por separado a través de los menús desplegables a continuación. Esto le permitirá enfocarse en un aspecto particular del desempeño de las pruebas y obtener una comprensión más profunda de los resultados asociados.",
                           "Además, puede seleccionar el año de interés para visualizar cómo han evolucionado los resultados a lo largo del tiempo. Esto le brinda la oportunidad de identificar tendencias, patrones y áreas de mejora en función de la cronología de las pruebas realizadas."
                    )
                  )
              ),
              
              box(title = "Acceso a Información Histórica", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "También se generan gráficas que incluyen la totalidad de las pruebas de desempeño presentadas históricamente por el laboratorio. Esta perspectiva histórica le proporciona una visión general de largo plazo, facilitando la comparación entre diferentes períodos y la evaluación de la progresión del desempeño a lo largo de los años."
                    )
                  )
              ),
              
              box(title = "Interacción Intuitiva", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "Utilice los menús desplegables a continuación para seleccionar la técnica de interés y el año deseado. Al explorar las gráficas generadas, podrá identificar tendencias, anomalías y áreas de enfoque para mejorar continuamente el desempeño y la calidad de las pruebas en el laboratorio."
                    )
                  )
              )),
              
              fluidRow(
                column(width = 6,
                       uiOutput("dropdown_indicadores_onac"),
                       actionButton("update_indicadores_plot_onac", "Actualizar Gráficas")
                )),
              fluidRow(
                column(width = 6,
                       plotOutput("barras_satisfactorias_insatisfactorias_onac")  # Gráfico de barras de satisfactorias e insatisfactorias
                ),
                
                column(width = 6,
                       plotOutput("barras_proveedor_pruebas_onac")  # Gráfico de barras de proveedores y pruebas
                ) 
              ),
              
              fluidRow(
                column(width = 12,
                       plotOutput("barras_totales_onac")
                )
              ),
              fluidRow(plotOutput("dona_porcentajes_onac")),
              fluidRow( column(width = 6,
                               uiOutput("year_selector_onac")
              )
              
              ),
              fluidRow(column(width = 12,
                              plotOutput("barras_totales2_onac")))
      ),
      tabItem(
        tabName = "cartapiccap",
        fluidRow(
          column(width = 6, h1(style = "font-weight:bold", "CARTAS CONTROL")),
          
          box(title = "Análisis de Z-score", background = "light-blue",
              fluidRow(
                column(width = 12, align = "justify",
                       "A continuación puede encontrar las gráficas discriminadas por proveedor para cada técnica que desee ver. Seleccione del menu los parámetros necesarios para poder
                       visualizar los gráficos. Allí puede ver y analizar las tendencias, según el Z-score obtenido en las pruebas"
                )
              )
          )),
        fluidRow(
          column(width = 6,
                 uiOutput("dropdowns_¨piccap"),
                 actionButton("update_plot_piccap", "Actualizar Gráfico")
          ),
          box(title = "Cartas control", background = "green",
              fluidRow(
                column(width = 12, align = "justify",
                       "Las cartas de control son una herramienta invaluable en el análisis de pruebas, ya que permiten observar de manera discriminada los resultados a lo largo del tiempo. Con ellas, podemos estudiar tendencias y desviaciones en los datos obtenidos, lo que nos brinda una visión detallada y precisa del desempeño de las pruebas a lo largo de distintos períodos. 
                Al utilizar cartas de control, podemos identificar patrones y cambios significativos en los resultados de las pruebas, lo que nos ayuda a comprender mejor cómo se comportan los procesos y a tomar decisiones informadas para mejorar la calidad y consistencia en los resultados."
                )
              )
          )),
        
        
        fluidRow(
          column(width = 6,
                 plotOutput("zscore_plot_piccap")  # Gráfico zscore_plot en una columna
          ),
          column(width = 6,
                 plotOutput("zscore_plot_all_piccap")  # Gráfico zscore_plot_all en otra columna
          )
        )
      ),
      tabItem(tabName = "indicadorespiccap", 
              fluidRow( h1(style = "text-align: center", "INDICADORES DE PRUEBAS DE DESEMPEÑO")
                        
              ),
              br(),
              br(),
              fluidRow(box(title = "Análisis de Desempeño de Pruebas en el Laboratorio", background = "green",
                           fluidRow(
                             column(width = 12, align = "justify",
                                    "Esta sección proporciona un análisis detallado del desempeño de las pruebas realizadas en el laboratorio, ofreciendo una visión integral de los resultados obtenidos. Las gráficas presentadas resaltan distintas categorías de desempeño, como resultados satisfactorios, insatisfactorios y cuestionables, permitiendo una evaluación exhaustiva de los datos clave de rendimiento."
                             )
                           )
              ),
              
              box(title = "Exploración Detallada", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "Seleccione la técnica específica que desea analizar por separado a través de los menús desplegables a continuación. Esto le permitirá enfocarse en un aspecto particular del desempeño de las pruebas y obtener una comprensión más profunda de los resultados asociados.",
                           "Además, puede seleccionar el año de interés para visualizar cómo han evolucionado los resultados a lo largo del tiempo. Esto le brinda la oportunidad de identificar tendencias, patrones y áreas de mejora en función de la cronología de las pruebas realizadas."
                    )
                  )
              ),
              
              box(title = "Acceso a Información Histórica", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "También se generan gráficas que incluyen la totalidad de las pruebas de desempeño presentadas históricamente por el laboratorio. Esta perspectiva histórica le proporciona una visión general de largo plazo, facilitando la comparación entre diferentes períodos y la evaluación de la progresión del desempeño a lo largo de los años."
                    )
                  )
              ),
              
              box(title = "Interacción Intuitiva", background = "green",
                  fluidRow(
                    column(width = 12, align = "justify",
                           "Utilice los menús desplegables a continuación para seleccionar la técnica de interés y el año deseado. Al explorar las gráficas generadas, podrá identificar tendencias, anomalías y áreas de enfoque para mejorar continuamente el desempeño y la calidad de las pruebas en el laboratorio."
                    )
                  )
              )),
              
              fluidRow(
                column(width = 6,
                       uiOutput("dropdown_indicadores_piccap"),
                       actionButton("update_indicadores_plot_piccap", "Actualizar Gráficas")
                )),
              fluidRow(
                column(width = 6,
                       plotOutput("barras_satisfactorias_insatisfactorias_piccap")  # Gráfico de barras de satisfactorias e insatisfactorias
                ),
                
                column(width = 6,
                       plotOutput("barras_proveedor_pruebas_piccap")  # Gráfico de barras de proveedores y pruebas
                ) 
              ),
              
              fluidRow(
                column(width = 12,
                       plotOutput("barras_totales_piccap")
                )
              ),
              fluidRow(plotOutput("dona_porcentajes_piccap")),
              fluidRow( column(width = 6,
                               uiOutput("year_selector_piccap")
              )
              
              ),
              fluidRow(column(width = 12,
                              plotOutput("barras_totales2_piccap")))
      )

)# Cierre de TabItems 

    ) # Dashboardbody
  )
 


server <- function(input, output, session) {

  observeEvent("", {
    showModal(modalDialog(
      includeHTML("instrucciones.html"),
      easyClose = TRUE,
      footer = tagList(
        actionButton(inputId = "intro", label = "INTRODUCTION TOUR", icon = icon("info-circle"))
      )
    ))
  })
  observeEvent(input$help_button, {
    # Crear un modal con el contenido HTML de instrucciones
    showModal(
      modalDialog(
        title = "Instrucciones",
        HTML("<object type='text/html' data='instrucciones.html' style='width:100%; height:500px'></object>")
      )
    )
  })
  
  
  # PESTAÑA DE IDEAM
  #-----------------------------------------------------------------------------#

  observeEvent(input$file_excel, {
    sheets <- excel_sheets(input$file_excel$datapath)
    output$dropdown_sheets <- renderUI({
      selectInput("selected_sheet", "Seleccionar Hoja:", choices = sheets)
    })
  })

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
  

  
  output$dropdowns <- renderUI({
    req(data())
    dropdowns <- lapply(c("Area", "Matriz", "Prueba", "Proveedor"), function(col) {
      unique_values <- sort(unique(data()[[col]]))
      selectInput(inputId = paste0("dropdown_", col), label = col, choices = c("", unique_values))
    })
    tagList(
      tags$style(HTML("
      .dropdown-wrapper {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
    ")),
      div(class = "dropdown-wrapper", dropdowns)
    )
  })
  
# IDEAM- CARTAS CONTROL  
  #------------------------------------------------------------#
  
  filtered_data <- reactive({
    req(data())
    data() %>%
      filter(Area == input$dropdown_Area,
             Matriz == input$dropdown_Matriz,
             Prueba == input$dropdown_Prueba,
             Proveedor == input$dropdown_Proveedor)
  })
  
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
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores por Proveedor", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
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
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores de Todos los Proveedores", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      ) +
      geom_point(data = all_data[all_data$`z Score` < -2 | all_data$`z Score` > 2, ], aes(shape = "Outside Limits"), size = 4) +
      scale_shape_manual(values = c("Outside Limits" = 1))  # Cambiar la forma de los puntos fuera de los límites
  })
  
  # IDEAM - INDICADORES
  # -----------------------------------------------------------#
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
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow")) + 
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
  })
  
  # Gráfico de barras de proveedores y pruebas
  output$barras_proveedor_pruebas <- renderPlot({
    req(input$update_indicadores_plot)
    data_indicadores <- filtered_data_indicadores()
    
    ggplot(data_indicadores, aes(x = Proveedor, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas por Proveedor", x = "Proveedor", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
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
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
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
      
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
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

    data_total$Fecha_del_informe <- as.Date(data_total$Fecha_del_informe, format = "%d/%m/%Y")
    
    # Filtrar por año
    data_filtered <- data_total %>%
      filter(year(Fecha_del_informe) == as.numeric(input$year_selector))
    
    
    ggplot(data_filtered, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
     
      labs(title = "Resultados de Pruebas totales", x = "Fecha_del_informe", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  
  
  
  # PESTAÑA DE ONAC
  #-----------------------------------------------------------------------------#
  

  data_onac <- reactive({
    req(input$file_excel)
    df <- read_excel(input$file_excel$datapath, sheet = "ONAC")
    df
  })
  
 
  
  # ONAC- CARTAS CONTROL  
  #------------------------------------------------------------#
  output$dropdowns_onac <- renderUI({
    req(data())
    dropdowns <- lapply(c("Prueba", "Técnica", "Proveedor"), function(col) {
      unique_values <- sort(unique(data_onac()[[col]]))
      selectInput(inputId = paste0("dropdown_", col), label = col, choices = c("", unique_values))
    })
    tagList(
      tags$style(HTML("
      .dropdown-wrapper {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
    ")),
      div(class = "dropdown-wrapper", dropdowns)
    )
  })
  
  
  filtered_data_onac <- reactive({
    req(data_onac())
    data_onac() %>%
      filter(Prueba == input$dropdown_Prueba,
             Tecnica == input$dropdown_Técnica,
             Proveedor == input$dropdown_Proveedor)
  })
  
  output$zscore_plot_onac <- renderPlot({
    req(input$update_plot)
    all_data <- data_onac() %>%
      filter(Prueba == input$dropdown_Prueba,
             Tecnica == input$dropdown_Técnica,
             Proveedor == input$dropdown_Proveedor)
    
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Prueba`)) +
      geom_point() +
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores por Proveedor", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
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
  
  output$zscore_plot_all_onac <- renderPlot({
    req(input$update_plot)
    all_data <- data_onac() %>%
      filter(Prueba == input$dropdown_Prueba,
             Tecnica == input$dropdown_Técnica,
             Proveedor == input$dropdown_Proveedor)
    
    # Convertir la columna z Score a numérica
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    # Calcular los límites del eje Y basados en los datos
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Proveedor`, group = `Proveedor`)) +
      geom_point(size = 3) +  # Tamaño de los puntos
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores de Todos los Proveedores", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      ) +
      geom_point(data = all_data[all_data$`z Score` < -2 | all_data$`z Score` > 2, ], aes(shape = "Outside Limits"), size = 4) +
      scale_shape_manual(values = c("Outside Limits" = 1))  # Cambiar la forma de los puntos fuera de los límites
  })
  
  # ONAC - INDICADORES
  # -----------------------------------------------------------#
  output$dropdown_indicadores_onac <- renderUI({
    req(data())
    dropdowns <- lapply(c("Prueba", "Técnica"), function(col) {
      unique_values <- sort(unique(data_onac()[[col]]))
      selectInput(inputId = paste0("dropdown_indicadores_", col), label = col, choices = c("", unique_values))
    })
    tagList(dropdowns)
  })
  
  # Filtrar datos según selecciones
  filtered_data_indicadores_onac <- reactive({
    req(data())
    data() %>%
      filter(Prueba == input$dropdown_indicadores_Prueba,
             Técnica == input$dropdown_indicadores_Técnica)
  })
  
  
  # Gráfico de barras de satisfactorias e insatisfactorias
  output$barras_satisfactorias_insatisfactorias_onac <- renderPlot({
    req(input$update_indicadores_plot_onac)
    data_indicadores <- filtered_data_indicadores_onac()
    
    ggplot(data_indicadores, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas: Satisfactorias vs Insatisfactorias", x = "Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow")) + 
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
  })
  
  # Gráfico de barras de proveedores y pruebas
  output$barras_proveedor_pruebas_onac <- renderPlot({
    req(input$update_indicadores_plot_onac)
    data_indicadores <- filtered_data_indicadores_onac()
    
    ggplot(data_indicadores, aes(x = Proveedor, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas por Proveedor", x = "Proveedor", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  output$barras_totales_onac <- renderPlot({
    req(input$update_indicadores_plot_onac)
    data_total <- data_onac()  # Obtener todos los datos
    
    # Sumar las cantidades de cada categoría
    summarised_data <- data_total %>%
      group_by(Resultado_de_la_prueba) %>%
      summarise(Cantidad = n())
    
    ggplot(summarised_data, aes(x = Resultado_de_la_prueba, y = Cantidad, fill = Resultado_de_la_prueba)) +
      geom_bar(stat = "identity") +
      labs(title = "Resultados de Pruebas totales", x = "Resultado de la Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
  })
  
  calculate_percentages_onac <- function(data) {
    
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
  
  output$dona_porcentajes_onac <- renderPlot({
    req(input$update_indicadores_plot_onac)
    data_total <- data_onac()  # Obtener todos los datos
    
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
      
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  output$year_selector_onac <- renderUI({
    data_total <- data_onac()  # Obtener todos los datos
    data_total$Fecha_del_informe_year <- lubridate::year(data_total$Fecha_del_informe)
    choices <- unique(data_total$Fecha_del_informe_year)
    radioButtons("year_selector", "Seleccione el año:",
                 choices = choices,
                 selected = NULL)
  })
  
  output$barras_totales2_onac <- renderPlot({
    req(input$update_indicadores_plot_onac)
    data_total <- data_onac()  # Obtener todos los datos
    
    data_total$Fecha_del_informe <- as.Date(data_total$Fecha_del_informe, format = "%d/%m/%Y")
    
    # Filtrar por año
    data_filtered <- data_total %>%
      filter(year(Fecha_del_informe) == as.numeric(input$year_selector))
    
    
    ggplot(data_filtered, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      
      labs(title = "Resultados de Pruebas totales", x = "Fecha_del_informe", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  
  # PESTAÑA DE PICCAP
  #-----------------------------------------------------------------------------#
  
  
  data_piccap <- reactive({
    req(input$file_excel)
    df <- read_excel(input$file_excel$datapath, sheet = "PICCAP")
    df
  })
  
  
  
  # ONAC- CARTAS CONTROL  
  #------------------------------------------------------------#
  output$dropdowns_piccap <- renderUI({
    req(data_piccap())
    dropdowns <- lapply(c("Prueba"), function(col) {
      unique_values <- sort(unique(data_piccap()[[col]]))
      selectInput(inputId = paste0("dropdown_", col), label = col, choices = c("", unique_values))
    })
    tagList(
      tags$style(HTML("
      .dropdown-wrapper {
        display: flex;
        flex-direction: column;
        gap: 10px;
      }
    ")),
      div(class = "dropdown-wrapper", dropdowns)
    )
  })
  
  
  filtered_data_piccap <- reactive({
    req(data_piccap())
    data_piccap() %>%
      filter(Prueba == input$dropdown_Prueba)
  })
  
  output$zscore_plot_piccap <- renderPlot({
    req(input$update_plot_piccap)
    all_data <- data_piccap() %>%
      filter(Prueba == input$dropdown_Prueba)
    
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Prueba`)) +
      geom_point() +
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores por Proveedor", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
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
  
  output$zscore_plot_all_piccap <- renderPlot({
    req(input$update_plot_piccap)
    all_data <- data_piccap() %>%
      filter(Prueba == input$dropdown_Prueba)
    
    # Convertir la columna z Score a numérica
    all_data$`z Score` <- as.numeric(all_data$`z Score`)
    
    # Calcular los límites del eje Y basados en los datos
    y_limits <- range(all_data$`z Score`, na.rm = TRUE)
    
    ggplot(all_data, aes(x = Fecha_del_informe, y = `z Score`, color = `Proveedor`, group = `Proveedor`)) +
      geom_point(size = 3) +  # Tamaño de los puntos
      geom_smooth(method = "loess", se = FALSE) +  # Suavizado de dispersión
      geom_hline(yintercept = c(-2, 2), linetype = "solid", color = "red") +
      labs(title = "Z-Scores de Todos los Proveedores", x = "Fecha del Informe", y = "Z-Score") +  # Etiquetas de los ejes
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      ) +
      geom_point(data = all_data[all_data$`z Score` < -2 | all_data$`z Score` > 2, ], aes(shape = "Outside Limits"), size = 4) +
      scale_shape_manual(values = c("Outside Limits" = 1))  # Cambiar la forma de los puntos fuera de los límites
  })
  
  # ONAC - INDICADORES
  # -----------------------------------------------------------#
  output$dropdown_indicadores_piccap <- renderUI({
    req(data_piccap())
    dropdowns <- lapply(c("Prueba"), function(col) {
      unique_values <- sort(unique(data_piccap()[[col]]))
      selectInput(inputId = paste0("dropdown_indicadores_", col), label = col, choices = c("", unique_values))
    })
    tagList(dropdowns)
  })
  
  # Filtrar datos según selecciones
  filtered_data_indicadores_piccap <- reactive({
    req(data())
    data() %>%
      filter(Prueba == input$dropdown_indicadores_Prueba)
  })
  
  
  # Gráfico de barras de satisfactorias e insatisfactorias
  output$barras_satisfactorias_insatisfactorias_piccap <- renderPlot({
    req(input$update_indicadores_plot_piccap)
    data_indicadores <- filtered_data_indicadores_piccap()
    
    ggplot(data_indicadores, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas: Satisfactorias vs Insatisfactorias", x = "Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow")) + 
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
  })
  
  # Gráfico de barras de proveedores y pruebas
  output$barras_proveedor_pruebas_piccap <- renderPlot({
    req(input$update_indicadores_plot_piccap)
    data_indicadores <- filtered_data_indicadores_piccap()
    
    ggplot(data_indicadores, aes(x = Proveedor, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      labs(title = "Resultados de Pruebas por Proveedor", x = "Proveedor", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable"="yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  output$barras_totales_piccap <- renderPlot({
    req(input$update_indicadores_plot_piccap)
    data_total <- data_piccap()  # Obtener todos los datos
    
    # Sumar las cantidades de cada categoría
    summarised_data <- data_total %>%
      group_by(Resultado_de_la_prueba) %>%
      summarise(Cantidad = n())
    
    ggplot(summarised_data, aes(x = Resultado_de_la_prueba, y = Cantidad, fill = Resultado_de_la_prueba)) +
      geom_bar(stat = "identity") +
      labs(title = "Resultados de Pruebas totales", x = "Resultado de la Prueba", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )
  })
  
  calculate_percentages_piccap <- function(data) {
    
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
  
  output$dona_porcentajes_piccap <- renderPlot({
    req(input$update_indicadores_plot_piccap)
    data_total <- data_piccap()  # Obtener todos los datos
    
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
      
      theme_minimal() +  # Estilo minimalista
      theme(
        legend.position = "right",
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  output$year_selector_piccap <- renderUI({
    data_total <- data_piccap()  # Obtener todos los datos
    data_total$Fecha_del_informe_year <- lubridate::year(data_total$Fecha_del_informe)
    choices <- unique(data_total$Fecha_del_informe_year)
    radioButtons("year_selector", "Seleccione el año:",
                 choices = choices,
                 selected = NULL)
  })
  
  output$barras_totales2_piccap <- renderPlot({
    req(input$update_indicadores_plot_piccap)
    data_total <- data_piccap()  # Obtener todos los datos
    
    data_total$Fecha_del_informe <- as.Date(data_total$Fecha_del_informe, format = "%d/%m/%Y")
    
    # Filtrar por año
    data_filtered <- data_total %>%
      filter(year(Fecha_del_informe) == as.numeric(input$year_selector))
    
    
    ggplot(data_filtered, aes(x = Fecha_del_informe, fill = Resultado_de_la_prueba)) +
      geom_bar(position = "dodge") +
      
      labs(title = "Resultados de Pruebas totales", x = "Fecha_del_informe", y = "Cantidad") +
      scale_fill_manual(values = c("Satisfactorio" = "green", "Insatisfactorio" = "red", "Cuestionable" = "yellow"))+
      theme_minimal() +  # Estilo minimalista
      theme(
        plot.background = element_rect(fill = "#F0F8FF"),  
        panel.background = element_rect(fill = "#D3E3D3"),  
        text = element_text(color = "black", size = 10, face = "bold"),  
        plot.title = element_text(hjust = 0.5),  
        axis.title = element_text(hjust = 0.5)  
      )# Colores para barras
  })
  
  
  
}

shinyApp(ui = ui, server = server)
