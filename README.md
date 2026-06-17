# Análisis de oncogenes en datos transcriptómicos de cáncer mediante IA explicable

Trabajo de Fin de Grado · Grado en Ingeniería de la Salud (mención Informática Clínica)
Escuela Técnica Superior de Ingeniería Informática · Universidad de Sevilla
Autor: Alberto Lobo Ramos · Tutora: Isabel Nepomuceno Chamorro

## Descripción

Este proyecto clasifica muestras de tejido tumoral y sano a partir de datos de expresión génica (RNA-seq) usando aprendizaje supervisado, restringe el análisis a los oncogenes y aplica técnicas de inteligencia artificial explicable (XAI) para comprobar si los modelos aprenden patrones biológicos reales.

Se trabaja con cáncer de próstata (PRAD) y de pulmón (LUAD), combinando muestras tumorales de TCGA y muestras sanas de GTEx. El trabajo reproduce y amplía el tutorial de Cereda Lab sobre IA aplicada a datos de RNA-seq.

El análisis se organiza en tres fases:

- **Fase 1 — Reproducción:** clasificación tumor vs. sano y próstata vs. pulmón con Random Forest y SVM sobre el conjunto completo de genes de cáncer.
- **Fase 2 — Oncogenes:** se repite el análisis usando únicamente oncogenes, y se compara con Gradient Boosting y una red neuronal.
- **Fase 3 — Explicabilidad:** se aplican LIME, SHAP y PDP para interpretar las predicciones e identificar los genes más influyentes.

## Estructura del repositorio

- `TFG_Notebook.Rmd` — Notebook principal con todo el análisis (R Markdown).
- `TFG_Notebook.pdf` — Notebook ya ejecutado (resultados y figuras).
- `app.R` — Aplicación Shiny interactiva.
- `datos_app.RData` — Modelos y datos que carga la app.
- `figuras/` — Figuras generadas por el notebook (la subcarpeta `anexo/` contiene las figuras individuales de explicabilidad del Anexo D).
- `sources/` — Datos de entrada (no incluidos, ver la sección Datos).

## Datos

Los datos de expresión no se incluyen en el repositorio por su tamaño y porque son de acceso público. Para reproducir el análisis hay que descargarlos y colocarlos en una carpeta `sources/`:

- **Expresión RNA-seq (TCGA + GTEx unificados):** repositorio RNAseqDB (https://github.com/mskcc/RNAseqDB), basado en Wang et al. (2018), *Scientific Data*. Ficheros necesarios:
  - `prad-rsem-fpkm-tcga-t.txt.gz` (tumor próstata)
  - `luad-rsem-fpkm-tcga-t.txt.gz` (tumor pulmón)
  - `prostate-rsem-fpkm-gtex.txt.gz` (sano próstata)
  - `lung-rsem-fpkm-gtex.txt.gz` (sano pulmón)
- **Genes de cáncer:** Network of Cancer Genes (NCG) 7.1, fichero `NCG_cancerdrivers_annotation_supporting_evidence.tsv`.

## Requisitos

- R y RStudio.
- Paquetes de R:

```r
install.packages(c(
  "caret", "randomForest", "e1071", "kernlab", "gbm", "nnet",
  "Rtsne", "ggplot2", "gridExtra", "lime", "iml", "pdp", "shiny"
))
```

## Uso

### Reproducir el análisis

1. Clona el repositorio y coloca los datos en la carpeta `sources/`.
2. Abre `TFG_Notebook.Rmd` en RStudio.
3. Pulsa **Knit** para ejecutar todo el análisis y generar el informe. Las figuras se guardan automáticamente en `figuras/`.

Si solo quieres ver los resultados sin ejecutar nada, abre `TFG_Notebook.pdf`.

### Ejecutar la aplicación interactiva

1. Abre `app.R` en RStudio.
2. Pulsa **Run App**.
3. Elige un modelo (Random Forest o SVM) y una muestra del conjunto de prueba; la app devuelve la predicción, si coincide con la etiqueta real y una explicación LIME con los oncogenes más influyentes.

## Resultados principales

- Random Forest y SVM clasifican tumor vs. sano con exactitud superior al 97 %.
- Restringir el análisis a 253 oncogenes mantiene el rendimiento, lo que justifica centrarse en un subconjunto reducido e interpretable de genes.
- Modelos más complejos (Gradient Boosting, red neuronal) no superan a la SVM.
- La explicabilidad muestra que los modelos se apoyan en oncogenes conocidos (FOXA1, NFE2L2, MACC1, GLI1, XPO1, entre otros).

## Licencia

Distribuido bajo licencia MIT. Consulta el archivo `LICENSE` para más detalles.

## Referencias

- Del Giudice, M. et al. (2021). *Artificial intelligence in bulk and single-cell RNA-sequencing data to foster precision oncology.* Tutorial, Cereda Lab.
- Wang, Q. et al. (2018). Unifying cancer and normal RNA sequencing data from different sources. *Scientific Data*, 5, 180061.
- Repana, D. et al. (2019). The Network of Cancer Genes: a comprehensive catalogue of known and candidate cancer genes. *Genome Biology*, 20, 1.
