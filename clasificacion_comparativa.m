% Autor: Rodrigo Salazar Valencia
% Periodo: 1604_2025
% Curso: Tratamiento de Imágenes - UNAD
%
% Comparación de tres clasificadores:
%   1) SVM lineal (3 features: X, Y, Circularidad)
%   2) Perceptrón lineal (3 features: X, Y, Circularidad)
%   3) Clasificador por Umbral (2 features: Y, Circularidad)
%
% Archivos de entrada:
%   Data.xlsx   : Centroide_X | Centroide_Y | Circularidad | Experto (0/1)
%   Prueba.xlsx : Centroide_X | Centroide_Y | Circularidad | Experto (opcional)

clear; clc; close all;

%% Helper para coma decimal -> double (tolerante si ya son numéricos)
toDouble = @(col) str2double(strrep(string(col), ',', '.'));

%% ===========================
%  1. ENTRENAMIENTO (Data.xlsx)
%% ===========================

Ttr = readtable('Data.xlsx', 'PreserveVariableNames', true);

Xtr_all = [ ...
    toDouble(Ttr.Centroide_X), ...
    toDouble(Ttr.Centroide_Y), ...
    toDouble(Ttr.Circularidad) ];

ytr = Ttr.Experto;

% Filtrar filas válidas
okTr = all(~isnan(Xtr_all), 2) & ~isnan(ytr);
Xtr_all = Xtr_all(okTr, :);
ytr     = ytr(okTr);

% Separación explícita de features
Xtr = Xtr_all;          % 3D: [X Y C]
Ytr = Xtr_all(:,2);     % 2D: solo Y
Ctr = Xtr_all(:,3);     % 2D: solo Circularidad

fprintf('Clases presentes en entrenamiento: ');
disp(unique(ytr).');

%% =======================
%  2. PRUEBA (Prueba.xlsx)
%% =======================

Tte = readtable('Prueba.xlsx', 'PreserveVariableNames', true);

Xte_all = [ ...
    toDouble(Tte.Centroide_X), ...
    toDouble(Tte.Centroide_Y), ...
    toDouble(Tte.Circularidad) ];

okTe   = all(~isnan(Xte_all), 2);
Xte_all = Xte_all(okTe, :);

Xte = Xte_all;          % 3D
Yte = Xte_all(:,2);     % 2D
Cte = Xte_all(:,3);     % 2D

% Etiquetas de prueba (si existen en la tabla)
tieneEtiquetaPrueba = ismember('Experto', Tte.Properties.VariableNames);
if tieneEtiquetaPrueba
    yte = Tte.Experto(okTe);
else
    yte = [];
end

%% ================================================
%  3. CLASIFICADOR POR UMBRAL (2D: Y, Circularidad)
%% ================================================

Ny = 100; Nc = 100;
ys = linspace(min(Ytr), max(Ytr), Ny);
cs = linspace(min(Ctr), max(Ctr), Nc);

bestAcc = -Inf;
best = struct('y0',NaN,'c0',NaN,'rule','');

for iy = 1:Ny
    y0 = ys(iy);
    for ic = 1:Nc
        c0 = cs(ic);

        % 4 reglas AND posibles en el plano (Y,C)
        predA = (Ytr >= y0) & (Ctr >= c0);
        predB = (Ytr >= y0) & (Ctr <  c0);
        predC = (Ytr <  y0) & (Ctr >= c0);
        predD = (Ytr <  y0) & (Ctr <  c0);

        ACC = [ ...
            mean(double(predA==ytr)), ...
            mean(double(predB==ytr)), ...
            mean(double(predC==ytr)), ...
            mean(double(predD==ytr)) ];

        [accHere, k] = max(ACC);
        if accHere > bestAcc
            bestAcc = accHere;
            best.y0 = y0;
            best.c0 = c0;
            best.rule = 'A';
            if k==2, best.rule='B';
            elseif k==3, best.rule='C';
            elseif k==4, best.rule='D';
            end
        end
    end
end

% Función con la mejor regla
switch best.rule
    case 'A', f_umbral = @(Y,C) (Y>=best.y0) & (C>=best.c0);
    case 'B', f_umbral = @(Y,C) (Y>=best.y0) & (C< best.c0);
    case 'C', f_umbral = @(Y,C) (Y< best.y0) & (C>=best.c0);
    case 'D', f_umbral = @(Y,C) (Y< best.y0) & (C< best.c0);
end

% ENTRENAMIENTO (Umbral)
yhat_tr_thr = double(f_umbral(Ytr,Ctr));
acc_tr_thr  = mean(yhat_tr_thr==ytr);
cm_tr_thr   = confusionmat(ytr, yhat_tr_thr);
cm_tr_thr_tbl = array2table(cm_tr_thr, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames',      {'Real_0','Real_1'});

% PRUEBA (Umbral)
yhat_te_thr = double(f_umbral(Yte,Cte));

fprintf('\n=== Clasificador por UMBRAL (2 features: Y, Circularidad) ===\n');
fprintf('Mejor regla: %s  | y0 = %.4f  | c0 = %.4f  | Accuracy train = %.2f %%\n', ...
        best.rule, best.y0, best.c0, 100*acc_tr_thr);
disp('Matriz de confusión (train, Umbral) [filas = real, columnas = predicción]:');
disp(cm_tr_thr_tbl);

T_thr = table(Yte, Cte, yhat_te_thr, ...
    'VariableNames', {'CentroideY','Circularidad','Pred_Umbral'});
disp('=== PRUEBA (Umbral) ===');
disp(T_thr);

if ~isempty(yte)
    cm_te_thr = confusionmat(yte, yhat_te_thr);
    disp('Matriz de confusión (prueba, Umbral):');
    disp(array2table(cm_te_thr, ...
        'VariableNames', {'Pred_0','Pred_1'}, ...
        'RowNames',      {'Real_0','Real_1'}));
end

%% ===========================================
%  4. SVM LINEAL (3D: X, Y, Circularidad)
%% ===========================================

svmModel = fitcsvm( ...
    Xtr, ytr, ...
    'Standardize', true, ...
    'KernelFunction', 'linear', ...
    'KernelScale', 'auto');

% ENTRENAMIENTO (SVM)
yhat_tr_svm = predict(svmModel, Xtr);
acc_tr_svm  = mean(yhat_tr_svm==ytr);
cm_tr_svm   = confusionmat(ytr, yhat_tr_svm);

cm_tr_svm_tbl = array2table(cm_tr_svm, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames',      {'Real_0','Real_1'});

fprintf('\n=== SVM Lineal (3 features: X, Y, Circularidad) ===\n');
fprintf('Accuracy train = %.2f %%\n', 100*acc_tr_svm);
disp('Matriz de confusión (train, SVM) [filas = real, columnas = predicción]:');
disp(cm_tr_svm_tbl);

% PRUEBA (SVM)
yhat_te_svm = predict(svmModel, Xte);
T_svm = table( ...
    Xte(:,1), Xte(:,2), Xte(:,3), yhat_te_svm, ...
    'VariableNames', {'CentroideX','CentroideY','Circularidad','Pred_SVM'});
disp('=== PRUEBA (SVM) ===');
disp(T_svm);

if ~isempty(yte)
    cm_te_svm = confusionmat(yte, yhat_te_svm);
    disp('Matriz de confusión (prueba, SVM):');
    disp(array2table(cm_te_svm, ...
        'VariableNames', {'Pred_0','Pred_1'}, ...
        'RowNames',      {'Real_0','Real_1'}));
end

%% ==============================================
%  5. PERCEPTRÓN LINEAL (3D: X, Y, Circularidad)
%% ==============================================

% Estandarización (igual que SVM, pero explícita)
mu  = mean(Xtr,1);
sig = std(Xtr,[],1); 
sig(sig==0) = 1;

Ztr = (Xtr - mu)./sig;
Zte = (Xte - mu)./sig;

% Etiquetas en {-1, +1}
t = double(ytr);
t(t==0) = -1;

% Inicialización Perceptrón
rng(1);
w = zeros(size(Ztr,2),1);  % 3 pesos (X,Y,C)
b = 0;
eta    = 0.05;   % tasa de aprendizaje
epochs = 60;

for ep = 1:epochs
    idx = randperm(size(Ztr,1));
    err = 0;
    for i = idx
        xi = Ztr(i,:)';  
        yi = t(i);
        if yi*(w.'*xi + b) <= 0      % mal clasificado
            w = w + eta*yi*xi;
            b = b + eta*yi;
            err = err + 1;
        end
    end
    if err == 0
        break;   % convergió
    end
end

% ENTRENAMIENTO (Perceptrón)
s_tr        = sign(Ztr*w + b);
yhat_tr_per = double(s_tr==1);
acc_tr_per  = mean(yhat_tr_per==ytr);
cm_tr_per   = confusionmat(ytr, yhat_tr_per);

cm_tr_per_tbl = array2table(cm_tr_per, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames',      {'Real_0','Real_1'});

fprintf('\n=== Perceptrón Lineal (3 features: X, Y, Circularidad) ===\n');
fprintf('Epochs usados: %d  | Accuracy train = %.2f %%\n', ep, 100*acc_tr_per);
disp('Matriz de confusión (train, Perceptrón) [filas = real, columnas = predicción]:');
disp(cm_tr_per_tbl);

% PRUEBA (Perceptrón)
s_te        = sign(Zte*w + b);
yhat_te_per = double(s_te==1);

T_per = table( ...
    Xte(:,1), Xte(:,2), Xte(:,3), yhat_te_per, ...
    'VariableNames', {'CentroideX','CentroideY','Circularidad','Pred_Perceptron'});
disp('=== PRUEBA (Perceptrón 3D) ===');
disp(T_per);

if ~isempty(yte)
    cm_te_per = confusionmat(yte, yhat_te_per);
    disp('Matriz de confusión (prueba, Perceptrón):');
    disp(array2table(cm_te_per, ...
        'VariableNames', {'Pred_0','Pred_1'}, ...
        'RowNames',      {'Real_0','Real_1'}));
end

disp(' ');
disp('✔ Comparación de UMBRAL, SVM y PERCEPTRÓN completada.');