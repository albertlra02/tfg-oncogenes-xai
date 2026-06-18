library(shiny)
library(caret)
library(lime)
library(ggplot2)
library(randomForest)
library(kernlab)
library(e1071)

load("datos_app.RData")   # rf2_onco, svm_onco, test_set, train_set, oncogenes_only

muestras    <- rownames(test_set)
predictores <- setdiff(colnames(train_set), "type")

mapa_genes <- setNames(as.character(oncogenes_only$symbol),
                       as.character(oncogenes_only$entrez))

traducir <- function(codigos) {
  entrez   <- sub("^g_", "", codigos)
  simbolos <- mapa_genes[entrez]
  ifelse(is.na(simbolos), codigos, simbolos)
}

PINE <- "#3A6B5E"; CLAY <- "#B05E3B"; INK <- "#22312B"

ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background-color: #FBFAF7; }
    .titulo-app { background:#22312B; color:#FBFAF7; padding:22px 26px; border-radius:10px; margin-bottom:22px; }
    .titulo-app h2 { margin:0; font-weight:700; }
    .titulo-app p { margin:6px 0 0; opacity:.85; font-size:15px; }
    .panel-lateral { background:#F2EFE9; border:1px solid #E2DCD0; border-radius:10px; padding:18px; }
    .tarjeta { border-radius:10px; padding:18px 20px; margin-bottom:18px; color:white; font-size:16px; line-height:1.6; }
    .tarjeta b { font-size:19px; }
    .btn-clasificar { background:#B05E3B !important; color:white !important; border:none !important; width:100%; font-weight:600; padding:10px; border-radius:8px; }
    .seccion-titulo { color:#22312B; font-weight:700; margin:8px 0 14px; border-bottom:2px solid #3A6B5E; padding-bottom:6px; }
  "))),
  
  div(class = "titulo-app",
      h2("Clasificación de muestras de cáncer con IA explicable"),
      p("Elige un modelo y una muestra. La app predice si es tumoral o sana y explica en qué oncogenes se apoya.")
  ),
  
  sidebarLayout(
    sidebarPanel(class = "panel-lateral", width = 4,
                 selectInput("modelo", "Modelo de clasificación:",
                             choices = c("SVM (radial)" = "svm", "Random Forest" = "rf")),
                 selectInput("muestra", "Muestra del conjunto de test:", choices = muestras),
                 actionButton("clasificar", "Clasificar y explicar", class = "btn-clasificar"),
                 br(), br(),
                 helpText("El cálculo de la explicación LIME puede tardar unos segundos.")
    ),
    
    mainPanel(width = 8,
              uiOutput("tarjeta_resultado"),
              conditionalPanel("input.clasificar > 0",
                               div(class = "seccion-titulo", "¿En qué se apoya el modelo? (LIME)"),
                               plotOutput("explicacion", height = "560px")
              )
    )
  )
)

server <- function(input, output) {
  
  resultado <- eventReactive(input$clasificar, {
    modelo <- if (input$modelo == "svm") svm_onco else rf2_onco
    fila   <- test_set[input$muestra, , drop = FALSE]
    pred   <- predict(modelo, newdata = fila)
    real   <- fila$type
    list(modelo = modelo, fila = fila, pred = pred, real = real)
  })
  
  output$tarjeta_resultado <- renderUI({
    r <- resultado()
    acierto  <- r$pred == r$real
    color    <- if (acierto) PINE else CLAY
    etiqueta <- if (acierto) "ACIERTO" else "FALLO"
    div(class = "tarjeta", style = paste0("background:", color, ";"),
        HTML(paste0(
          "Predicci&oacute;n del modelo: <b>", r$pred, "</b><br>",
          "Etiqueta real: <b>", r$real, "</b><br>",
          "Resultado: <b>", etiqueta, "</b>"))
    )
  })
  
  output$explicacion <- renderPlot({
    r <- resultado()
    withProgress(message = "Calculando explicacion LIME...", value = 0.5, {
      explicador  <- lime(train_set[, predictores], r$modelo)
      explicacion <- explain(r$fila[, predictores], explicador,
                             n_labels = 1, n_features = 15)
    })
    explicacion$gen <- traducir(explicacion$feature)
    
    ggplot(explicacion, aes(x = reorder(gen, feature_weight),
                            y = feature_weight,
                            fill = feature_weight > 0)) +
      geom_col(width = 0.7) +
      coord_flip() +
      scale_fill_manual(values = c("FALSE" = CLAY, "TRUE" = PINE),
                        labels = c("Empuja a sano", "Empuja a tumor"),
                        name = "") +
      labs(x = NULL, y = "Influencia en la predicción",
           title = paste("Muestra clasificada como:", r$pred)) +
      theme_minimal(base_size = 15) +
      theme(plot.title = element_text(face = "bold", color = INK),
            legend.position = "top",
            panel.grid.major.y = element_blank(),
            axis.text.y = element_text(color = INK))
  })
}

shinyApp(ui = ui, server = server)