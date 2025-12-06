# tdi-e5-final
Etapa 5: Proyecto del Curso - Tratamiento de Imágenes (UNAD).  Pipeline completo en MATLAB para adquisición, segmentación, binarización, filtrado morfológico, extracción de características y entrenamiento supervisado (SVM y método de umbral).
## Resumen del Pull Request
Este PR incorpora el bloque de entrenamiento del pipeline de visión por computador en MATLAB. Se agregan tres scripts que permiten procesar el dataset de imágenes, generar métricas geométricas por muestra y construir la tabla de entrenamiento para el clasificador supervisado.

### Contenido principal
- `aprendizaje.m`: script maestro que orquesta el flujo completo, define parámetros globales, procesa el dataset y exporta el conjunto final de características.
- `procesar_carpeta_con_guardado.m`: módulo de procesamiento en lote que recorre todas las imágenes `.jpg`, aplica el pipeline y consolida las métricas geométricas.
- `procesar_y_guardar_uno.m`: pipeline individual por imagen (ROI → gris → binarización → morfología → etiquetado) con exportación de artefactos e indicadores.

### Resultados esperados
- Carpeta con artefactos por imagen (original, gris, binaria, filtrada, etiquetada, histograma, recorte).
- Tabla `dataset_entrenamiento` con valores de centroide (X,Y), circularidad, área del objeto principal, umbral utilizado y conteo de objetos detectados.

### Propósito
Este bloque permite generar un dataset estructurado y reproducible para los modelos de clasificación supervisada (SVM y método de umbral).
