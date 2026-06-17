library(shiny)
library(caret)
library(lime)
library(ggplot2)

# ============================================================
#  Cargar modelos y datos (la app arranca en frío)
# ============================================================
load("datos_app.RData")   # rf2_onco, svm_onco, test_set, train_set, oncogenes_only

muestras <- rownames(test_set)
predictores <- setdiff(colnames(train_set), "type")

# ---- Diccionario entrez -> símbolo (para traducir g_25 -> ABL1) ----
mapa_genes <- setNames(as.character(oncogenes_only$symbol),
                       as.character(oncogenes_only$entrez))

traducir <- function(codigos) {
  entrez   <- sub("^g_", "", codigos)      # "g_25" -> "25"
  simbolos <- mapa_genes[entrez]           # "25"   -> "ABL1"
  ifelse(is.na(simbolos), codigos, simbolos)  # si no está, deja el código
}

# ============================================================
#  UI: lo que se ve
# ============================================================
ui <- fluidPage(
  titlePanel("Clasificador de muestras tumorales con explicación"),
  sidebarLayout(
    sidebarPanel(
      selectInput("modelo", "Modelo:",
                  choices = c("SVM" = "svm", "Random Forest" = "rf")),
      selectInput("muestra", "Elige una muestra:", choices = muestras),
      actionButton("clasificar", "Clasificar y explicar", class = "btn-primary"),
      br(), br(),
      helpText("La explicación (LIME) puede tardar unos segundos.")
    ),
    mainPanel(
      h3("Resultado"),
      verbatimTextOutput("prediccion"),
      h3("¿Por qué? Genes más influyentes (LIME)"),
      plotOutput("explicacion", height = "550px")
    )
  )
)

# ============================================================
#  SERVER: la lógica
# ============================================================
server <- function(input, output) {
  
  observeEvent(input$clasificar, {
    
    # 1) Modelo elegido
    modelo <- if (input$modelo == "svm") svm_onco else rf2_onco
    
    # 2) Muestra elegida (su fila del test_set)
    fila <- test_set[input$muestra, , drop = FALSE]
    
    # 3) Predicción y etiqueta real
    prediccion <- predict(modelo, newdata = fila)
    real <- fila$type
    
    # 4) Mostrar el resultado en texto
    output$prediccion <- renderText({
      acierto <- if (prediccion == real) "ACIERTO" else "FALLO"
      paste0("Predicción del modelo: ", prediccion, "\n",
             "Etiqueta real: ", real, "\n",
             "Resultado: ", acierto)
    })
    
    # 5) Explicación LIME, dibujada limpia con ggplot2
    output$explicacion <- renderPlot({
      explicador <- lime(train_set[, predictores], modelo)
      explicacion <- explain(
        fila[, predictores],
        explicador,
        n_labels = 1,
        n_features = 15
      )
      
      # Traducir códigos g_... a símbolos de gen
      explicacion$gen <- traducir(explicacion$feature)
      
      # Gráfica de barras: nombre del gen + influencia + color
      ggplot(explicacion, aes(x = reorder(gen, feature_weight),
                              y = feature_weight,
                              fill = feature_weight > 0)) +
        geom_col() +
        coord_flip() +
        scale_fill_manual(values = c("FALSE" = "#C0392B", "TRUE" = "#2E86C1"),
                          labels = c("Contradice", "Apoya"),
                          name = "") +
        labs(x = "Gen", y = "Influencia en la predicción",
             title = paste("Muestra clasificada como:", prediccion)) +
        theme_minimal(base_size = 14)
    })
  })
}

shinyApp(ui = ui, server = server)