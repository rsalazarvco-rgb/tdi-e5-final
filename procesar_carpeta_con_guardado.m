function tablaResultados = procesar_carpeta_con_guardado(rutaCarpeta, rutaSalida, params)
% Autor: Rodrigo Salazar Valencia
% Periodo: 1604_2025
% Curso: Tratamiento de Imágenes - UNAD
%
% Procesa todas las imágenes .jpg en "rutaCarpeta".
% Para cada imagen:
%   - Ejecuta el pipeline: ROI -> gris -> binarización -> filtrado -> etiquetado.
%   - Selecciona el objeto principal (mayor área).
%   - Calcula centroide, circularidad y área.
%   - Guarda imágenes intermedias en "rutaSalida".
% Devuelve una tabla con las métricas por imagen.

    % Validación de parámetros de entrada
    if nargin < 2
        error('Se requieren al menos rutaCarpeta y rutaSalida.');
    end
    if nargin < 3 || isempty(params)
        params = struct();
    end

    % Valores por defecto
    if ~isfield(params, 'ROI'),            params.ROI = []; end
    if ~isfield(params, 'umbral'),         params.umbral = []; end
    if ~isfield(params, 'areaMin'),        params.areaMin = 240; end
    if ~isfield(params, 'mostrarFiguras'), params.mostrarFiguras = false; end

    % Crear carpeta de salida si no existe
    if ~exist(rutaSalida, 'dir')
        mkdir(rutaSalida);
    end

    % Listar imágenes .jpg en carpeta de entrada
    archivos = dir(fullfile(rutaCarpeta, '*.jpg'));
    if isempty(archivos)
        error('No se encontraron imágenes .jpg en la ruta: %s', rutaCarpeta);
    end

    % Definir ROI una única vez si no viene dada
    if isempty(params.ROI)
        imgEjemplo = imread(fullfile(rutaCarpeta, archivos(1).name));
        figure; imshow(imgEjemplo);
        title('Seleccione la región de interés (ROI) y presione Enter');

        % Obtener rectángulo de recorte: [x y width height]
        [~, rect] = imcrop;   % rect es el segundo output
        close;

        % Validar rect
        if isempty(rect) || ~isnumeric(rect) || numel(rect) ~= 4
            error('La ROI seleccionada no es válida. Ejecute de nuevo y seleccione un rectángulo.');
        end

        params.ROI = rect;
    else
        % Validar ROI si vino desde fuera
        if ~isnumeric(params.ROI) || numel(params.ROI) ~= 4
            error('params.ROI debe ser un vector [x y width height].');
        end
    end

    n = numel(archivos);

    % Prealocar vectores para la tabla de resultados
    nombres  = strings(n, 1);
    centroX  = nan(n, 1);
    centroY  = nan(n, 1);
    circ     = nan(n, 1);
    areaObj  = nan(n, 1);
    umbrales = nan(n, 1);
    numObjs  = nan(n, 1);

    for k = 1:n
        nombre = archivos(k).name;
        ruta   = fullfile(rutaCarpeta, nombre);

        try
            info = procesar_y_guardar_uno(ruta, rutaSalida, k, params);

            nombres(k)  = string(nombre);
            centroX(k)  = info.ObjetoPrincipal.Centroid(1);
            centroY(k)  = info.ObjetoPrincipal.Centroid(2);
            circ(k)     = info.ObjetoPrincipal.Circularity;
            areaObj(k)  = info.ObjetoPrincipal.Area;
            umbrales(k) = info.Parametros.umbralUsado;
            numObjs(k)  = info.NumObjetos;

        catch ME
            warning('Error procesando %s: %s', nombre, ME.message);
            nombres(k) = string(nombre);
            % resto queda NaN
        end
    end

    % Construir tabla de resultados
    tablaResultados = table( ...
        nombres, centroX, centroY, circ, areaObj, umbrales, numObjs, ...
        'VariableNames', {'Archivo','CentroideX','CentroideY', ...
                          'Circularidad','Area','Umbral','NumObjetos'});

    disp('Resultados del procesamiento automático por imagen:');
    disp(tablaResultados);
end