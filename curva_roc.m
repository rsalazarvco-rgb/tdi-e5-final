% ========================================================================
% MATRICES DE CONFUSIÓN, MÉTRICAS Y CURVA ROC (PUNTOS)
% PARA: UMBRAL - PERCEPTRON - SVM
%
% Autor: Rodrigo Salazar Valencia
% Curso: Tratamiento de Imágenes - UNAD
% ========================================================================

clc; clear; close all;

%% ==========================================================
% 1. Tabla exacta suministrada por el estudiante
% ===========================================================

% Columnas: Experto | Umbral | Perceptron | SVM
datos = [
    0  0  1  0;
    1  0  1  1;
    0  0  0  0;
    1  1  1  1;
    0  1  0  0;
    1  1  1  1;
    0  0  0  0;
    1  1  1  1];

y_true   = datos(:,1);
y_thr    = datos(:,2);
y_perc   = datos(:,3);
y_svm    = datos(:,4);

%% ==========================================================
% 2. Funciones auxiliares para matriz de confusión y métricas
% ==========================================================

% Calcula VP, FP, FN, VN (positiva = clase 1)
calc_conf = @(yt,yp) deal( ...
    sum(yt==0 & yp==0), ... % VN
    sum(yt==0 & yp==1), ... % FP
    sum(yt==1 & yp==0), ... % FN
    sum(yt==1 & yp==1));    % VP

metricas = @(VP,FP,FN,VN) struct( ...
    'Exactitud',     (VP+VN)/(VP+VN+FP+FN), ...
    'Precision',    VP/(VP+FP+eps), ...
    'Sensibilidad', VP/(VP+FN+eps), ...   % Recall / TPR
    'Especificidad',VN/(VN+FP+eps), ...   % TNR
    'FPR',          1 - VN/(VN+FP+eps) ); % False Positive Rate

%% ==========================================================
% 3. UMBRAL
% ==========================================================

[VN_thr, FP_thr, FN_thr, VP_thr] = calc_conf(y_true, y_thr);
cm_thr = [VN_thr FP_thr; FN_thr VP_thr];
m_thr  = metricas(VP_thr, FP_thr, FN_thr, VN_thr);

%% ==========================================================
% 4. PERCEPTRÓN
% ==========================================================

[VN_per, FP_per, FN_per, VP_per] = calc_conf(y_true, y_perc);
cm_per = [VN_per FP_per; FN_per VP_per];
m_per  = metricas(VP_per, FP_per, FN_per, VN_per);

%% ==========================================================
% 5. SVM
% ==========================================================

[VN_svm, FP_svm, FN_svm, VP_svm] = calc_conf(y_true, y_svm);
cm_svm = [VN_svm FP_svm; FN_svm VP_svm];
m_svm  = metricas(VP_svm, FP_svm, FN_svm, VN_svm);

%% ==========================================================
% 6. Mostrar matrices de confusión y métricas
% ==========================================================

fprintf('\n====================== UMBRAL ======================\n');
disp('Matriz de confusión [Real x Pred]:');
disp(cm_thr);
disp(m_thr);

fprintf('\n====================== PERCEPTRON ==================\n');
disp('Matriz de confusión [Real x Pred]:');
disp(cm_per);
disp(m_per);

fprintf('\n====================== SVM =========================\n');
disp('Matriz de confusión [Real x Pred]:');
disp(cm_svm);
disp(m_svm);

%% ==========================================================
% 7. CURVA ROC (PUNTOS) COMO EN LA ACTIVIDAD ANTERIOR
% ==========================================================

FPR_svm = m_svm.FPR;
TPR_svm = m_svm.Sensibilidad;

FPR_thr = m_thr.FPR;
TPR_thr = m_thr.Sensibilidad;

FPR_per = m_per.FPR;
TPR_per = m_per.Sensibilidad;

figure;
plot(FPR_svm, TPR_svm, 'o', 'MarkerSize', 8, 'LineWidth',1.5); hold on;
plot(FPR_thr, TPR_thr, 's', 'MarkerSize', 8, 'LineWidth',1.5);
plot(FPR_per, TPR_per, 'd', 'MarkerSize', 8, 'LineWidth',1.5);

% Línea del clasificador aleatorio
plot([0 1], [0 1], '--');

xlim([0 1]); ylim([0 1]);
xlabel('1 - Especificidad (FPR)');
ylabel('Sensibilidad (TPR)');
title('Curva ROC (puntos) para SVM, Umbral y Perceptrón');
grid on;

legend('SVM','Umbral','Perceptrón','Aleatorio','Location','SouthEast');

disp(' ');
disp('✔ Curva ROC, matrices de confusión y métricas generadas correctamente.');