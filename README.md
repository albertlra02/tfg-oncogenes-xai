# Análisis de oncogenes en datos transcriptómicos de cáncer mediante IA explicable

Trabajo de Fin de Grado · Grado en Ingeniería de la Salud, mención Informática Clínica
Escuela Técnica Superior de Ingeniería Informática · Universidad de Sevilla

**Autor:** Alberto Lobo Ramos
**Tutora:** Isabel Nepomuceno Chamorro

## Descripción

Este proyecto clasifica muestras de tejido tumoral y sano a partir de datos de expresión génica bulk RNA-seq usando aprendizaje supervisado. El análisis se centra especialmente en oncogenes y aplica técnicas de inteligencia artificial explicable (XAI) para interpretar las predicciones y comprobar si los genes relevantes para los modelos son coherentes con la literatura biológica.

Se trabaja con cáncer de próstata (PRAD) y adenocarcinoma de pulmón (LUAD), combinando muestras tumorales de TCGA y muestras sanas de GTEx. El trabajo reproduce y amplía el tutorial de Cereda Lab sobre inteligencia artificial aplicada a datos de RNA-seq.

El análisis se organiza en tres fases:

1. **Fase 1 — Reproducción del pipeline:** clasificación tumor vs. sano y PRAD vs. LUAD con Random Forest y SVM usando genes de cáncer.
2. **Fase 2 — Clasificación basada en oncogenes:** repetición del análisis usando únicamente oncogenes. Además, se comparan Random Forest y SVM con Gradient Boosting y una red neuronal.
3. **Fase 3 — Explicabilidad:** aplicación de LIME, SHAP y PDP para interpretar las predicciones e identificar los genes más influyentes.

Además, se incluyen métricas complementarias de evaluación, una comparación cuantitativa entre varImp y SHAP mediante índice de Jaccard, y un análisis de sensibilidad del preprocesado para comprobar si ajustar las transformaciones únicamente sobre el conjunto de entrenamiento altera las conclusiones principales.

## Demo web

Además del análisis reproducible en R Markdown, el proyecto incluye una aplicación web interactiva desarrollada con Shiny. La aplicación permite seleccionar una muestra del conjunto de prueba, elegir el modelo de clasificación y visualizar tanto la predicción como una explicación local basada en LIME.

**Aplicación web:** https://alberto-lobo.shinyapps.io/tfg-oncogenes/

La aplicación tiene finalidad académica y demostrativa. No está validada para uso clínico ni debe interpretarse como una herramienta diagnóstica.

## Estructura del repositorio

```text
TFG_Notebook.Rmd      Notebook principal con todo el análisis en R Markdown.
TFG_Notebook.pdf      Notebook ejecutado con resultados, tablas y figuras.
app.R                 Aplicación Shiny interactiva.
datos_app.RData       Modelos y datos necesarios para ejecutar la app.
figuras/              Figuras generadas por el notebook.
figuras/anexo/        Figuras individuales de explicabilidad usadas en el anexo.
sources/              Carpeta donde deben colocarse los datos de entrada.
```

## Datos

Los datos de expresión génica no se incluyen en el repositorio por su tamaño y porque proceden de fuentes públicas externas. Para reproducir el análisis hay que descargarlos y colocarlos en una carpeta llamada `sources/`.

### Datos de expresión RNA-seq

Los datos proceden de RNAseqDB, basado en Wang et al. (2018), que integra muestras de TCGA y GTEx.

Repositorio: https://github.com/mskcc/RNAseqDB

Ficheros necesarios:

```text
prad-rsem-fpkm-tcga-t.txt.gz       Tumor próstata, PRAD
luad-rsem-fpkm-tcga-t.txt.gz       Tumor pulmón, LUAD
prostate-rsem-fpkm-gtex.txt.gz     Tejido sano próstata
lung-rsem-fpkm-gtex.txt.gz         Tejido sano pulmón
```

### Genes de cáncer

Se utiliza el catálogo Network of Cancer Genes, versión 7.1.

Fichero necesario:

```text
NCG_cancerdrivers_annotation_supporting_evidence.tsv
```

## Requisitos

El proyecto se ha desarrollado en R/RStudio.

Paquetes principales de R:

```r
install.packages(c(
  "caret", "randomForest", "e1071", "kernlab", "gbm", "nnet",
  "Rtsne", "ggplot2", "gridExtra", "lime", "iml", "pdp",
  "pROC", "shiny"
))
```

## Uso

### Reproducir el análisis

1. Clonar el repositorio.
2. Crear una carpeta `sources/`.
3. Descargar los ficheros de expresión génica y el fichero de NCG.
4. Colocar todos los datos en `sources/`.
5. Abrir `TFG_Notebook.Rmd` en RStudio.
6. Ejecutar el notebook con `Knit`.

Las figuras se guardan automáticamente en la carpeta `figuras/`.

Para consultar los resultados sin ejecutar el análisis, puede abrirse directamente el archivo `TFG_Notebook.pdf`.

### Ejecutar la aplicación Shiny

### Ejecutar la aplicación Shiny

La aplicación puede consultarse directamente desde la demo web:

**Demo:** https://alberto-lobo.shinyapps.io/tfg-oncogenes/

También puede ejecutarse localmente:

1. Abrir `app.R` en RStudio.
2. Comprobar que el archivo `datos_app.RData` está en el directorio del proyecto.
3. Pulsar `Run App`.

La aplicación permite elegir un modelo, seleccionar una muestra del conjunto de prueba y visualizar la predicción junto con una explicación local generada mediante LIME.

## Resultados principales

* Random Forest y SVM clasifican muestras tumorales y sanas con una exactitud superior al 97 %.
* Al restringir el análisis a 253 oncogenes, el rendimiento se mantiene, lo que justifica trabajar con un subconjunto reducido e interpretable de genes.
* La SVM obtiene el mejor rendimiento global frente a Random Forest, Gradient Boosting y una red neuronal, especialmente al considerar métricas como balanced accuracy, AUC y MCC.
* El análisis de sensibilidad del preprocesado muestra que ajustar las transformaciones únicamente sobre el conjunto de entrenamiento no altera de forma sustancial las conclusiones principales.
* La comparación entre varImp y SHAP muestra 15 genes comunes entre los 20 primeros de ambos rankings, con una coincidencia del 75 % y un índice de Jaccard de 0,60.
* Las técnicas de explicabilidad señalan genes coherentes con la literatura biológica, como FOXA1, NFE2L2, MACC1, GLI1, XPO1, ESR1 e IDH1, entre otros.
* LIME permite estudiar casos concretos mal clasificados, SHAP aporta una interpretación local y direccional de las contribuciones, y PDP ayuda a visualizar relaciones no lineales entre expresión génica y probabilidad predicha.

## Limitaciones

Este repositorio tiene finalidad académica. Los modelos no están validados para uso clínico y no deben interpretarse como herramientas diagnósticas. Una limitación importante del diseño es que las muestras tumorales proceden de TCGA y las muestras sanas de GTEx, por lo que no puede descartarse completamente la presencia de efecto de lote. Además, las técnicas de explicabilidad utilizadas proporcionan interpretaciones asociativas, no causales.

## Licencia

El código propio desarrollado para este trabajo se distribuye bajo licencia MIT. Los datos externos utilizados no se redistribuyen en este repositorio y quedan sujetos a las condiciones de uso de sus fuentes originales.

## Referencias

Del Giudice, M. et al. (2021). *Artificial intelligence in bulk and single-cell RNA-sequencing data to foster precision oncology*. Tutorial, Cereda Lab.

Wang, Q. et al. (2018). *Unifying cancer and normal RNA sequencing data from different sources*. Scientific Data, 5, 180061.

Repana, D. et al. (2019). *The Network of Cancer Genes: a comprehensive catalogue of known and candidate cancer genes*. Genome Biology, 20, 1.
