%% ========================================================================
%  Script de procesamiento automático de imágenes de entrenamiento
%  Autor: Rodrigo Salazar Valencia
%  Curso: Tratamiento de Imágenes - UNAD
%  Descripción:
%     - Procesa todas las imágenes .jpg en una carpeta de entrada.
%     - Aplica el pipeline definido en procesar_carpeta_con_guardado.m
%     - Genera una tabla con métricas geométricas por imagen.
%     - Exporta los resultados a un archivo CSV.
%  Dependencias:
%     - procesar_carpeta_con_guardado.m
%     - procesar_y_guardar_uno.m
% ========================================================================

%% Limpieza de entorno
clear;
clc;
close all;

%% Configuración de rutas
% Carpeta de entrada: contiene las imágenes .jpg a procesar
rutaCarpeta = fullfile( ...
    'C:', 'Users', 'rsala', 'OneDrive', 'UNAD', 'MATLAB', ...
    'tdi_final', 'Entrenamiento', 'entrada');

% Carpeta de salida: aquí se guardan imágenes intermedias y resultados
rutaSalida = fullfile( ...
    'C:', 'Users', 'rsala', 'OneDrive', 'UNAD', 'MATLAB', ...
    'tdi_final', 'Entrenamiento', 'salida');

%% Parámetros del procesamiento
params = struct();
params.ROI            = [];      % [] -> se pedirá ROI 1 sola vez sobre la primera imagen
params.umbral         = [];      % [] -> umbral automático (Otsu)
params.areaMin        = 240;     % área mínima en píxeles (ajustable)
params.mostrarFiguras = false;   % true para ver el pipeline por imagen (modo depuración)

%% Ejecución del procesamiento por carpeta
tablaResultados = procesar_carpeta_con_guardado(rutaCarpeta, rutaSalida, params);

%% Exportar resultados a CSV
nombreCSV = 'resultados_numericos.csv';
rutaCSV   = fullfile(rutaSalida, nombreCSV);

writetable(tablaResultados, rutaCSV);

fprintf('\n[OK] Tabla de resultados guardada en:\n   %s\n\n', rutaCSV);