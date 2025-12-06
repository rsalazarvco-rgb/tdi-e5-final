# tdi-e5-final
Etapa 5: Proyecto del Curso - Tratamiento de Imágenes (UNAD).  Pipeline completo en MATLAB para adquisición, segmentación, binarización, filtrado morfológico, extracción de características y entrenamiento supervisado (SVM y método de umbral).
**Versión validada:** MATLAB R2025b
---

## Descripción general:
Este repositorio implementa un flujo completo de visión por computador basado en procesamiento morfológico, extracción de características y modelos supervisados clásicos. El trabajo fue desarrollado como parte de la **Etapa 5 del curso “Tratamiento de Imágenes” – UNAD**.

Incluye:
- Preprocesamiento y normalización del dataset de imágenes.
- Extracción de características geométricas (Centroide X/Y y Circularidad).
- Generación de un dataset tabular para aprendizaje supervisado.
- Entrenamiento y evaluación de tres clasificadores:
  - SVM lineal,
  - Perceptrón lineal,
  - Clasificación mediante umbral 2D.

El código está validado para **MATLAB R2025b** y diseñado para ejecución reproducible.
---

## Estructura del repositorio:

```text
/
├── training/             # Generación del dataset desde imágenes
│   ├── aprendizaje.m
│   ├── procesar_carpeta_con_guardado.m
│   └── procesar_y_guardar_uno.m
│
├── test/                 # Entrenamiento y comparación de modelos
│   ├── svm_v2.m
│   ├── umbral_perceptron_v2.m
│   ├── clasificacion_comparativa.m
│   └── curva_roc.m
│
└── README.md
