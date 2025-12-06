function info = procesar_y_guardar_uno(rutaArchivo, rutaSalida, indice, params)
% ========================================================================
% procesar_y_guardar_uno
% Autor: Rodrigo Salazar Valencia
% Curso: Tratamiento de Imágenes - UNAD
%
% Procesa una imagen individual aplicando:
%   - Recorte por ROI
%   - Conversión a gris y normalización
%   - Binarización (umbral fijo o automático)
%   - Filtrado morfológico por área mínima
%   - Etiquetado y selección del objeto principal
%   - Exportación de resultados y artefactos
%
% Entradas:
%   rutaArchivo : archivo .jpg a procesar
%   rutaSalida  : carpeta donde guardar resultados
%   indice      : número incremental para prefijo
%   params      : estructura con parámetros del procesamiento
%
% Salida:
%   info : struct con métricas geométricas y parámetros utilizados
% ========================================================================

%% Validación de argumentos
if nargin < 4
    error(['procesar_y_guardar_uno requiere 4 argumentos: ' ...
           'rutaArchivo, rutaSalida, indice y params.']);
end

if ~isfile(rutaArchivo)
    error('El archivo no existe: %s', rutaArchivo);
end

if ~exist(rutaSalida, "dir")
    mkdir(rutaSalida);
end

% Configurar valores por defecto en params
if ~isfield(params, 'ROI'),            params.ROI = []; end
if ~isfield(params, 'umbral'),         params.umbral = []; end
if ~isfield(params, 'areaMin'),        params.areaMin = 240; end
if ~isfield(params, 'mostrarFiguras'), params.mostrarFiguras = false; end

% Validar ROI
if ~isempty(params.ROI) && (~isnumeric(params.ROI) || numel(params.ROI) ~= 4)
    error('params.ROI debe ser un vector [x y width height].');
end

%% Lectura de imagen
I = imread(rutaArchivo);

% Aplicar ROI
if ~isempty(params.ROI)
    I = imcrop(I, params.ROI);
end

%% Conversión a gris y normalización
GrayID = rgb2gray(I);
GrayID_double = im2double(GrayID);

%% Binarización
if isempty(params.umbral)
    umbralUsado = graythresh(GrayID_double);
else
    umbralUsado = params.umbral;
end

binID = imbinarize(GrayID_double, umbralUsado);
binID = ~binID;   % invertir objetos

%% Filtrado morfológico
Filtro1 = bwareaopen(binID, params.areaMin);

%% Etiquetado
[Lo, numObjetos] = bwlabel(Filtro1);

if numObjetos == 0
    error('No se detectaron objetos después del filtrado.');
end

props = regionprops(Lo, 'Area', 'Centroid', 'Circularity', 'BoundingBox');

% Seleccionar mayor área
[~, idx] = max([props.Area]);
obj = props(idx);

% Recorte del objeto principal
recorte = imcrop(Filtro1, obj.BoundingBox);

% Recalcular métricas en el recorte
recProps = regionprops(recorte, 'Area', 'Centroid', 'Circularity');
obj.Area        = recProps(1).Area;
obj.Centroid    = recProps(1).Centroid;
obj.Circularity = recProps(1).Circularity;

%% Construir prefijo (incluye nombre original)
[~, baseName, ~] = fileparts(rutaArchivo);
prefijo = sprintf('%03d_%s', indice, baseName);

%% Guardar artefactos
imwrite(I,        fullfile(rutaSalida, [prefijo '_Original.png']));
imwrite(GrayID,   fullfile(rutaSalida, [prefijo '_Gray.png']));
imwrite(binID,    fullfile(rutaSalida, [prefijo '_Binaria.png']));
imwrite(Filtro1,  fullfile(rutaSalida, [prefijo '_Filtrada.png']));
imwrite(label2rgb(Lo), fullfile(rutaSalida, [prefijo '_Label.png']));
imwrite(recorte,  fullfile(rutaSalida, [prefijo '_Objeto.png']));

%% Guardar histograma con fondo blanco y texto negro
fig = figure('Visible','off','Color','white');
imhist(GrayID_double);
title(sprintf('Histograma de Intensidad - %s', baseName), ...
    'FontSize', 12, 'Color', 'black');

xlabel('Intensidad', 'Color', 'black');
ylabel('Frecuencia', 'Color', 'black');

set(gca, 'Color', 'white');            % fondo del eje
set(gca, 'XColor', 'black');           % color de los números eje X
set(gca, 'YColor', 'black');           % color de los números eje Y
set(gca, 'LineWidth', 1.2);

saveas(fig, fullfile(rutaSalida, [prefijo '_Hist.png']));
close(fig);

%% Salida estructurada
info = struct();
info.GrayID          = GrayID;
info.Binaria         = binID;
info.Filtrada        = Filtro1;
info.Etiquetada      = label2rgb(Lo);
info.RecorteObjeto   = recorte;
info.ObjetoPrincipal = obj;
info.NumObjetos      = numObjetos;
info.Parametros = struct( ...
    'ROI',         params.ROI, ...
    'umbralUsado', umbralUsado, ...
    'areaMin',     params.areaMin);
end