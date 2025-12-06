% Autor: Rodrigo Salazar Valencia
% Periodo: 1604_2025
% Curso: Tratamiento de Imágenes - UNAD
%
% Comparación de:
%   - Clasificador por umbral (2 características: Y, Circularidad)
%   - Perceptrón lineal (3 características: X, Y, Circularidad)
%
% Fuente de datos:
%   Data.xlsx   : Centroide_X | Centroide_Y | Circularidad | Experto (0/1)
%   Prueba.xlsx : Centroide_X | Centroide_Y | Circularidad

clear; clc; close all;

%% Helper para coma decimal -> double (funciona también si ya son numéricos)
toDouble = @(col) str2double(strrep(string(col), ',', '.'));

%% 1. ENTRENAMIENTO: cargar Data.xlsx
Ttr = readtable('Data.xlsx', 'PreserveVariableNames', true);

Xtr_all = [ ...
    toDouble(Ttr.Centroide_X), ...
    toDouble(Ttr.Centroide_Y), ...
    toDouble(Ttr.Circularidad) ];

ytr = Ttr.Experto;

% Filtrar filas válidas
okTr = all(~isnan([Xtr_all, ytr]), 2);
Xtr_all = Xtr_all(okTr, :);
ytr     = ytr(okTr);

% Separar features
Xtr = Xtr_all;          % 3D: [X Y C]
Ytr = Xtr_all(:,2);     % 2D: solo Y
Ctr = Xtr_all(:,3);     % 2D: solo C

fprintf('Clases presentes en entrenamiento: ');
disp(unique(ytr).');

%% 2. PRUEBA: cargar Prueba.xlsx
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

%% ========================================================================
%  CLASIFICADOR POR UMBRAL (2 features: Y, Circularidad)
%% ========================================================================

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

% Predicción y métricas en ENTRENAMIENTO (umbral)
yhat_tr_thr = double(f_umbral(Ytr,Ctr));
acc_tr_thr  = mean(yhat_tr_thr==ytr);
cm_tr_thr   = confusionmat(ytr, yhat_tr_thr);

cm_tr_thr_tbl = array2table(cm_tr_thr, ...
    'VariableNames', {'Pred_0','Pred_1'}, ...
    'RowNames',      {'Real_0','Real_1'});

% Predicción en PRUEBA (umbral)
yhat_te_thr = double(f_umbral(Yte,Cte));

fprintf('\n=== Clasificador por Umbral (2 features: Y, Circularidad) ===\n');
fprintf('Mejor regla: %s  | y0 = %.4f  | c0 = %.4f  | Accuracy train = %.2f %%\n', ...
        best.rule, best.y0, best.c0, 100*acc_tr_thr);
disp('Matriz de confusión (train, Umbral) [filas = real, columnas = predicción]:');
disp(cm_tr_thr_tbl);

T_thr = table(Yte, Cte, yhat_te_thr, ...
    'VariableNames', {'CentroideY','Circularidad','Pred_Umbral'});

disp('=== PRUEBA (Umbral) ===');
disp(T_thr);

%% ========================================================================
%  PERCEPTRÓN LINEAL (3 features: X, Y, Circularidad)
%% ========================================================================

% Estandarización (stats solo de entrenamiento)
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
w = zeros(size(Ztr,2),1);  % ahora 3 pesos (X,Y,C)
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

% Predicciones ENTRENAMIENTO (perceptrón)
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

% Predicciones PRUEBA (perceptrón)
s_te        = sign(Zte*w + b);
yhat_te_per = double(s_te==1);

T_per = table( ...
    Xte(:,1), Xte(:,2), Xte(:,3), yhat_te_per, ...
    'VariableNames', {'CentroideX','CentroideY','Circularidad','Pred_Perceptron'});

disp('=== PRUEBA (Perceptrón 3D) ===');
disp(T_per);