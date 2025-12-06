# tdi-e5-final
Etapa 5: Proyecto del Curso - Tratamiento de Imágenes (UNAD).  Pipeline completo en MATLAB para adquisición, segmentación, binarización, filtrado morfológico, extracción de características y entrenamiento supervisado (SVM y método de umbral).

## Resumen del Pull Request:
Este PR incorpora los scripts de clasificación supervisada y evaluación del desempeño para el proyecto de Tratamiento de Imágenes. Se implementan y comparan tres clasificadores (SVM lineal, Perceptrón lineal y clasificador por umbral) a partir de las características geométricas extraídas (Centroide_X, Centroide_Y, Circularidad) y se generan matrices de confusión, métricas y puntos ROC.

### Contenido Principal
- **Script SVM binario:**  
  - Lee `Data.xlsx` y `Prueba.xlsx` (con soporte para coma decimal).  
  - Construye el conjunto de entrenamiento con las features `[Centroide_X, Centroide_Y, Circularidad]`.  
  - Entrena un **SVM lineal binario** (clases 0/1), estandariza las variables y evalúa el accuracy en entrenamiento.  
  - Clasifica los datos de prueba y genera una tabla con las predicciones (`Clasificacion_SVM`).

- **Script Umbral vs Perceptrón:**  
  - Carga los mismos archivos (`Data.xlsx`, `Prueba.xlsx`) y separa las features.  
  - Calcula un **clasificador por umbral** óptimo en el plano (Y, Circularidad) buscando la mejor regla AND mediante barrido de parámetros.  
  - Implementa un **Perceptrón lineal 3D** (X, Y, Circularidad) con entrenamiento iterativo, estandarización y actualización de pesos.  
  - Reporta matrices de confusión y accuracy en entrenamiento para ambos modelos, además de tablas de clasificación en prueba.

- **Script de comparación global y métricas (Umbral, Perceptrón, SVM):**  
  - Vuelve a entrenar/ejecutar los tres clasificadores sobre `Data.xlsx` / `Prueba.xlsx`.  
  - Construye matrices de confusión para cada modelo, calcula métricas (exactitud, precisión, sensibilidad, especificidad, FPR).  
  - Genera una figura con la **curva ROC en forma de puntos** para SVM, Umbral y Perceptrón, incluyendo la recta de clasificador aleatorio.

### Resultados esperados:
- Tablas con predicciones por modelo sobre el conjunto de prueba.  
- Matrices de confusión y métricas consolidadas para los tres clasificadores.  
- Gráfico de curva ROC (puntos) para comparar el desempeño relativo de Umbral, Perceptrón y SVM.

### Propósito:
Este bloque de código completa la fase de **aprendizaje supervisado y evaluación estadística**, permitiendo comparar de forma cuantitativa la capacidad de discriminación de los tres clasificadores sobre el dataset generado en la etapa de procesamiento de imágenes.
