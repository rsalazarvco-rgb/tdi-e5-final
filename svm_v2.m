%% ========================================================================
%  SVM binario para clasificación de objetos
%  Autor: Rodrigo Salazar Valencia
%  Curso: Tratamiento de Imágenes - UNAD
%
%  - Lee datos de entrenamiento desde Data.xlsx (coma decimal).
%  - Convierte Centroide_X, Centroide_Y y Circularidad a double.
%  - Entrena un SVM lineal binario (clases: 0 / 1).
%  - Evalúa desempeño en entrenamiento.
%  - Lee datos de prueba desde Prueba.xlsx (coma decimal) y clasifica.
% ========================================================================

clear; clc; close all;

%% Helper para convertir columnas con coma decimal a double
toDouble = @(col) str2double(strrep(string(col), ',', '.'));

%% 1. ENTRENAMIENTO: lectura y preparación de Data.xlsx
Ttrain = readtable('Data.xlsx', 'PreserveVariableNames', true);

Xtrain = zeros(height(Ttrain), 3);
Xtrain(:,1) = toDouble(Ttrain.Centroide_X);
Xtrain(:,2) = toDouble(Ttrain.Centroide_Y);
Xtrain(:,3) = toDouble(Ttrain.Circularidad);

ytrain = Ttrain.Experto;   % etiquetas 0 / 1

% Eliminar filas inválidas (NaN) por seguridad
validRowsTrain = all(~isnan(Xtrain), 2) & ~isnan(ytrain);
Xtrain = Xtrain(validRowsTrain, :);
ytrain = ytrain(validRowsTrain, :);

fprintf('Clases presentes en entrenamiento: ');
disp(unique(ytrain).');

%% 2. Entrenamiento SVM binario
svmModel = fitcsvm( ...
    Xtrain, ytrain, ...
    'Standardize', true, ...
    'KernelFunction', 'linear', ...
    'KernelScale', 'auto');

%% 3. Evaluación en entrenamiento
y_pred_train = predict(svmModel, Xtrain);

confMat = confusionmat(ytrain, y_pred_train);
accuracy = sum(y_pred_train == ytrain) / numel(ytrain);

disp('=== Matriz de confusión (Entrenamiento) ===');
disp(array2table(confMat, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames', {'Real_0','Real_1'}));

fprintf('Accuracy en entrenamiento: %.2f %%\n\n', accuracy*100);

%% 4. PRUEBA: lectura y preparación de Prueba.xlsx
Ttest = readtable('Prueba.xlsx', 'PreserveVariableNames', true);

Xtest = zeros(height(Ttest), 3);
Xtest(:,1) = Ttest.Centroide_X;
Xtest(:,2) = Ttest.Centroide_Y;
Xtest(:,3) = Ttest.Circularidad;

% Eliminar filas inválidas en prueba
validRowsTest = all(~isnan(Xtest), 2);
Xtest = Xtest(validRowsTest, :);
Ttest = Ttest(validRowsTest, :);

%% 5. Clasificación en Prueba
y_pred_test = predict(svmModel, Xtest);

tabla_prueba = table( ...
    Xtest(:,1), Xtest(:,2), Xtest(:,3), y_pred_test, ...
    'VariableNames', {'Centroide_X','Centroide_Y','Circularidad','Clasificacion_SVM'});

disp('=== Clasificación de Prueba ===');
disp(tabla_prueba);

%% 6. (Opcional) Tabla de entrenamiento final
tabla_entrenamiento = table( ...
    Xtrain(:,1), Xtrain(:,2), Xtrain(:,3), ytrain, ...
    'VariableNames', {'Centroide_X','Centroide_Y','Circularidad','Experto'});

disp('=== Datos de Entrenamiento (post-conversión) ===');
disp(tabla_entrenamiento);

disp(' ');
disp('✔ Clasificación SVM binaria completada correctamente.');