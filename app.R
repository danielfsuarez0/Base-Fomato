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
  query <- paste("CREATE TABLE IF NOT EXISTS", tabla, "(Area VARCHAR(255), Matriz VARCHAR(255), Parametro VARCHAR(255), Metodologia VARCHAR(255), ZScore VARCHAR(255), Proveedor VARCHAR(255), Informe VARCHAR(255), Fecha VARCHAR(255), Resultado VARCHAR(255));")
  dbSendQuery(con, query)
}



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
                )
              ),
              h2(strong("¿CÓMO USARLA?", style = "text-align: right")),
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
      )
    )
    

              )
      )
 


server <- function(input, output, session) {
  onStop(function() {
    dbDisconnect(con)
  })
  
}
# Run the application 
shinyApp(ui = ui, server = server)
