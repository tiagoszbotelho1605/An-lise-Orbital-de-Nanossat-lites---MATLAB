% ====================================================
% ANÁLISE DE PASSAGENS E COMUNICAÇÃO
% ====================================================

disp('=== ANÁLISE DE PASSAGENS E COMUNICAÇÃO ===');
% CENÁRIO
startTime = datetime(2025,12,05,0,0,0); % UTC
stopTime = startTime + days(10);
sampleTime = 30; % segundos
sc = satelliteScenario(startTime,stopTime,sampleTime);

% SATÉLITE
sat = satellite(sc,"satellite.tle");

% Obter nome do satélite do TLE
try
    nomeSatelite = sat.Name;
    if isempty(nomeSatelite)
        nomeSatelite = 'Satelite_TLE';
    end
catch
    nomeSatelite = 'Satelite_TLE';
end

% GROUND STATION
name = "UFMA";
lat = -2.559584;
lon = -44.311605;
gs = groundStation(sc, "Name", name, "Latitude", lat, "Longitude", lon);

%satelliteScenarioViewer(sc,'Dimension','2D');
%satelliteScenarioViewer(sc,'Dimension','3D');

% PARÂMETROS DE COMUNICAÇÃO ALDEBARAN-1 - APENAS DOWNLINK
frequencia = 468.5e6;            % 468.5 MHz
potenciaTx_dBm = 20;             % 20 dBm
potenciaTx = potenciaTx_dBm - 30; % Converter para dBW

% Parâmetros do sistema
receiverSensitivity = -126.5;    % dBm
bitRate = 3.5156e3;              % 3.5156 kbps (constante)
bytesPorTelemetria = 73;         % 73 bytes (pacote completo, incluindo overhead)
bytesPorPacoteDados = 15;        % 15 bytes por pacote de dados da missão (completo)
intervaloTelemetria = 60;        % segundos
elevacaoMinimaOperacional = 30;  % graus

% Calcular ganhos das antenas
ganhoAntenaSatelite = calcularGanhoAntena(0.5, frequencia);
ganhoAntenaEstacao = calcularGanhoAntena(1, frequencia);

fprintf('=== PARÂMETROS DO SISTEMA ===\n');
fprintf('Frequência: %.3f MHz\n', frequencia/1e6);
fprintf('Potência TX: %.1f dBm\n', potenciaTx_dBm);
fprintf('Sensibilidade RX: %.1f dBm\n', receiverSensitivity);
fprintf('Taxa de dados: %.4f kbps\n', bitRate/1000);
fprintf('Tamanho de telemetria: %d bytes (pacote completo)\n', bytesPorTelemetria);
fprintf('Tamanho de pacote de dados: %d bytes (pacote completo)\n', bytesPorPacoteDados);
fprintf('Intervalo de telemetria: %d segundos\n', intervaloTelemetria);
fprintf('Elevação mínima: %d°\n', elevacaoMinimaOperacional);
fprintf('\n');

% Cálculo do acesso entre satélite e ground station
ac = access(sat, gs);
accessIntervals = accessIntervals(ac);

% Análise das passagens
fprintf('=== ANÁLISE DE PASSAGENS DO SATÉLITE ===\n\n');
fprintf('Estação: %s (Lat: %.6f, Lon: %.6f)\n', name, lat, lon);
fprintf('Período: %s a %s\n\n', startTime, stopTime);

if isempty(accessIntervals)
    fprintf('Nenhuma passagem detectada no período analisado.\n');
    return;
end

% Preparar arrays para armazenar resultados
numPassagens = height(accessIntervals);
durations = zeros(numPassagens, 1);
azStart = zeros(numPassagens, 1);
azMaxEl = zeros(numPassagens, 1);
azEnd = zeros(numPassagens, 1);
maxElevations = zeros(numPassagens, 1);

% Métricas para avaliação de qualidade
tempoUtilComunicacao = zeros(numPassagens, 1); % segundos acima de 30°
elevacaoMediaUtil = zeros(numPassagens, 1); % elevação média durante tempo útil
rangeMedioUtil = zeros(numPassagens, 1); % alcance médio durante tempo útil
dadosTransmitidosBytes = zeros(numPassagens, 1); % bytes por passagem
numTelemetrias = zeros(numPassagens, 1); % número de telemetrias por passagem
numPacotesDados = zeros(numPassagens, 1); % número de pacotes de dados por passagem
dadosMissaoBytes = zeros(numPassagens, 1); % dados da missão em bytes
dadosTotaisBytes = zeros(numPassagens, 1); % total de dados (telemetria + missão)
qualidadePassagem = zeros(numPassagens, 1); % Pontuação de qualidade 0-100
classificacaoPassagem = cell(numPassagens, 1); % Classificação textual

% Métricas de link budget
margemEbNoDownlink = zeros(numPassagens, 1); % Margem do downlink

% Arrays para pontos cardeais
pontoCardealStart = cell(numPassagens, 1);
pontoCardealMaxEl = cell(numPassagens, 1);
pontoCardealEnd = cell(numPassagens, 1);

% Arrays para strings de data/hora
startDateStr = cell(numPassagens, 1);
startTimeStr = cell(numPassagens, 1);
endDateStr = cell(numPassagens, 1);
endTimeStr = cell(numPassagens, 1);
maxElDateStr = cell(numPassagens, 1);
maxElTimeStr = cell(numPassagens, 1);

% Arrays para cálculo do tempo de revisita
revisitTimes = zeros(numPassagens-1, 1); % Tempo entre passagens consecutivas

% Análise detalhada de cada passagem
for i = 1:numPassagens
    fprintf('--- Passagem %d ---\n', i);
    
    startTimePass = accessIntervals.StartTime(i);
    endTimePass = accessIntervals.EndTime(i);
    duration = endTimePass - startTimePass;
    durations(i) = seconds(duration);
    
    % Converter para strings
    startDateStr{i} = datestr(startTimePass, 'dd/mm/yyyy');
    startTimeStr{i} = datestr(startTimePass, 'HH:MM:SS');
    endDateStr{i} = datestr(endTimePass, 'dd/mm/yyyy');
    endTimeStr{i} = datestr(endTimePass, 'HH:MM:SS');
    
    fprintf('Início (UTC): %s %s\n', startDateStr{i}, startTimeStr{i});
    fprintf('Fim (UTC):    %s %s\n', endDateStr{i}, endTimeStr{i});
    fprintf('Duração total: %.1f minutos\n', minutes(duration));
    
    % Amostrar pontos durante a passagem para análise
    timeSamples = startTimePass:seconds(5):endTimePass; % 5 segundos para melhor precisão
    
    % Arrays para azimute, elevação e alcance
    az = zeros(size(timeSamples));
    el = zeros(size(timeSamples));
    ranges = zeros(size(timeSamples));
    
    % Array para margem do downlink
    margem_downlink = zeros(size(timeSamples));
    
    % Coletar dados
    for j = 1:length(timeSamples)
        [az(j), el(j), ranges(j)] = aer(gs, sat, timeSamples(j));
        
        % Calcular margem do downlink para cada ponto
        margem_downlink(j) = calcularLinkBudget(ranges(j), frequencia, potenciaTx, ...
            ganhoAntenaSatelite, ganhoAntenaEstacao, receiverSensitivity);
    end
    
    % Encontrar ponto de máxima elevação
    [maxEl, idxMax] = max(el);
    maxElevations(i) = maxEl;
    
    % Horário da máxima elevação
    maxElTime = timeSamples(idxMax);
    maxElDateStr{i} = datestr(maxElTime, 'dd/mm/yyyy');
    maxElTimeStr{i} = datestr(maxElTime, 'HH:MM:SS');
    
    % Armazenar azimutes
    azStart(i) = az(1);
    azMaxEl(i) = az(idxMax);
    azEnd(i) = az(end);
    
    fprintf('Horário da máxima elevação: %s %s\n', maxElDateStr{i}, maxElTimeStr{i});
    
    % Calcular métricas de comunicação COM PACOTES DE DADOS
    [tempoUtilComunicacao(i), elevacaoMediaUtil(i), rangeMedioUtil(i), ...
     dadosTransmitidosBytes(i), margemEbNoDownlink(i), numTelemetrias(i), ...
     numPacotesDados(i), dadosMissaoBytes(i)] = ...
        calcularMetricasComunicacao(el, ranges, margem_downlink, elevacaoMinimaOperacional, bitRate);
    
    % Calcular dados totais
    dadosTotaisBytes(i) = dadosTransmitidosBytes(i);
    
    % Calcular qualidade da passagem
    [qualidadePassagem(i), classificacaoPassagem{i}] = calcularQualidadePassagem(...
        tempoUtilComunicacao, elevacaoMediaUtil, rangeMedioUtil, i, maxElevations, elevacaoMinimaOperacional);
    
    % Converter azimutes em pontos cardeais
    pontoCardealStart{i} = azimuteParaPontoCardeal(azStart(i));
    pontoCardealMaxEl{i} = azimuteParaPontoCardeal(azMaxEl(i));
    pontoCardealEnd{i} = azimuteParaPontoCardeal(azEnd(i));
    
    fprintf('Azimute - Início: %.1f° (%s), Máx Elevação: %.1f° (%s), Fim: %.1f° (%s)\n', ...
            azStart(i), pontoCardealStart{i}, azMaxEl(i), pontoCardealMaxEl{i}, azEnd(i), pontoCardealEnd{i});
    
    if tempoUtilComunicacao(i) > 0
        fprintf('--- MÉTRICAS DE COMUNICAÇÃO ---\n');
        fprintf('Tempo útil (>%d°): %.1f minutos\n', elevacaoMinimaOperacional, tempoUtilComunicacao(i)/60);
        fprintf('Elevação média durante tempo útil: %.1f°\n', elevacaoMediaUtil(i));
        fprintf('Alcance médio durante tempo útil: %.1f km\n', rangeMedioUtil(i)/1000);
        fprintf('Telemetrias recebidas: %d\n', numTelemetrias(i));
        fprintf('Pacotes de dados da missão: %d\n', numPacotesDados(i));
        fprintf('Dados de telemetria: %d bytes\n', numTelemetrias(i) * bytesPorTelemetria);
        fprintf('Dados da missão: %d bytes\n', dadosMissaoBytes(i));
        fprintf('Dados totais recebidos: %d bytes\n', dadosTransmitidosBytes(i));
        fprintf('Margem Eb/No Downlink: %.2f dB\n', margemEbNoDownlink(i));
        fprintf('Qualidade da passagem: %.1f/100\n', qualidadePassagem(i));
        fprintf('CLASSIFICAÇÃO: %s\n', classificacaoPassagem{i});
    else
        fprintf('--- SEM COMUNICAÇÃO EFETIVA ---\n');
        fprintf('Elevação máxima (%.1f°) abaixo do mínimo operacional (%d°)\n', maxElevations(i), elevacaoMinimaOperacional);
    end
    fprintf('\n');
end

% Cálculo do tempo de revisita (tempo entre o fim de uma passagem e início da próxima)
for i = 1:numPassagens-1
    endTimeCurrent = accessIntervals.EndTime(i);
    startTimeNext = accessIntervals.StartTime(i+1);
    revisitTimes(i) = seconds(startTimeNext - endTimeCurrent);
end

% Resumo geral
passagensComComunicacao = sum(qualidadePassagem > 0);
fprintf('\n=== RESUMO GERAL ===\n');
fprintf('Total de passagens: %d\n', numPassagens);
fprintf('Passagens com comunicação efetiva (>%d°): %d (%.1f%%)\n', ...
        elevacaoMinimaOperacional, passagensComComunicacao, (passagensComComunicacao/numPassagens)*100);

if passagensComComunicacao > 0
    fprintf('\n--- ESTATÍSTICAS DAS PASSAGENS COM COMUNICAÇÃO ---\n');
    fprintf('Tempo útil médio: %.1f minutos\n', mean(tempoUtilComunicacao(qualidadePassagem>0))/60);
    fprintf('Elevação média útil: %.1f°\n', mean(elevacaoMediaUtil(qualidadePassagem>0)));
    fprintf('Alcance médio útil: %.1f km\n', mean(rangeMedioUtil(qualidadePassagem>0))/1000);
    fprintf('Telemetrias totais recebidas: %d\n', sum(numTelemetrias));
    fprintf('Pacotes de dados totais: %d\n', sum(numPacotesDados));
    fprintf('Dados de telemetria totais: %d bytes\n', sum(numTelemetrias) * bytesPorTelemetria);
    fprintf('Dados da missão totais: %d bytes\n', sum(dadosMissaoBytes));
    fprintf('Dados totais recebidos: %d bytes\n', sum(dadosTransmitidosBytes));
    fprintf('Telemetrias médias por passagem: %.1f\n', mean(numTelemetrias(qualidadePassagem>0)));
    fprintf('Pacotes de dados médios por passagem: %.1f\n', mean(numPacotesDados(qualidadePassagem>0)));
    fprintf('Dados totais médios por passagem: %.0f bytes\n', mean(dadosTransmitidosBytes(qualidadePassagem>0)));
    fprintf('Margem Eb/No Downlink média: %.2f dB\n', mean(margemEbNoDownlink(qualidadePassagem>0)));
    
    % Top 5 melhores passagens
    [~, indicesOrdenados] = sort(qualidadePassagem, 'descend');
    fprintf('\n--- TOP 5 MELHORES PASSAGENS ---\n');
    for i = 1:min(5, passagensComComunicacao)
        idx = indicesOrdenados(i);
        fprintf('%d. Passagem %d: Qualidade %.1f/100 | Tempo útil: %.1f min | Telemetrias: %d | Pacotes dados: %d | Dados totais: %d bytes\n', ...
                i, idx, qualidadePassagem(idx), tempoUtilComunicacao(idx)/60, numTelemetrias(idx), numPacotesDados(idx), dadosTransmitidosBytes(idx));
    end
end

% Análise do tempo de revisita
if numPassagens > 1
    fprintf('\n=== ANÁLISE DO TEMPO DE REVISITA ===\n');
    fprintf('Tempo de revisita médio: %.1f minutos\n', mean(revisitTimes)/60);
    fprintf('Tempo de revisita mínimo: %.1f minutos\n', min(revisitTimes)/60);
    fprintf('Tempo de revisita máximo: %.1f minutos\n', max(revisitTimes)/60);
    
    % Cálculo do desvio padrão
    revisita_std_min = std(revisitTimes)/60;
    revisita_std_horas = std(revisitTimes)/3600;
    
    fprintf('Desvio padrão do tempo de revisita: %.1f minutos\n', revisita_std_min);
    fprintf('Desvio padrão do tempo de revisita: %.2f horas\n', revisita_std_horas);
    
    % Coeficiente de variação
    if mean(revisitTimes) > 0
        cv_revisita = (std(revisitTimes) / mean(revisitTimes)) * 100;
        fprintf('Coeficiente de variação: %.1f%%\n', cv_revisita);
    end
    
    fprintf('Tempo de revisita médio: %.2f horas\n', mean(revisitTimes)/3600);
    
    % Exibir tempos de revisita individuais
    fprintf('\nTempos de revisita individuais:\n');
    for i = 1:numPassagens-1
        fprintf('Entre passagem %d e %d: %.1f minutos (%.2f horas)\n', ...
                i, i+1, revisitTimes(i)/60, revisitTimes(i)/3600);
    end
else
    fprintf('\nApenas uma passagem detectada - não é possível calcular tempo de revisita.\n');
end

% Análise de telemetrias
fprintf('\n=== ANÁLISE DE TELEMETRIAS E DADOS ===\n');
if passagensComComunicacao > 0
    totalTelemetrias = sum(numTelemetrias);
    totalPacotesDados = sum(numPacotesDados);
    tempoUtilTotal = sum(tempoUtilComunicacao(qualidadePassagem>0)) / 3600; % horas
    
    % Eficiência teórica máxima
    maxTelemetriasPorHora = 60; % 1 por minuto
    telemetriasPorHora = totalTelemetrias / tempoUtilTotal;
    eficienciaSistema = (telemetriasPorHora / maxTelemetriasPorHora) * 100;
    
    fprintf('Total de telemetrias recebidas: %d\n', totalTelemetrias);
    fprintf('Total de pacotes de dados: %d\n', totalPacotesDados);
    fprintf('Tempo útil total: %.1f horas\n', tempoUtilTotal);
    fprintf('Telemetrias por hora: %.1f\n', telemetriasPorHora);
    fprintf('Pacotes de dados por hora: %.1f\n', totalPacotesDados / tempoUtilTotal);
    fprintf('Máximo teórico de telemetrias por hora: %d (1 por minuto)\n', maxTelemetriasPorHora);
    fprintf('Eficiência do sistema (telemetrias): %.1f%%\n', eficienciaSistema);
    
    if eficienciaSistema < 50
        fprintf('Recomendação: Considere reduzir o intervalo entre telemetrias para aumentar a eficiência.\n');
    end
else
    fprintf('Nenhuma telemetria ou dados recebidos.\n');
end

% Salvar resultados em arquivos
salvarResultados(numPassagens, startDateStr, startTimeStr, endDateStr, endTimeStr, ...
    durations, azStart, pontoCardealStart, azMaxEl, pontoCardealMaxEl, azEnd, ...
    pontoCardealEnd, maxElevations, dadosTransmitidosBytes, qualidadePassagem, ...
    tempoUtilComunicacao, elevacaoMediaUtil, rangeMedioUtil, classificacaoPassagem, ...
    revisitTimes, numPassagens, margemEbNoDownlink, numTelemetrias, ... 
    maxElDateStr, maxElTimeStr, numPacotesDados, dadosMissaoBytes, bytesPorTelemetria);

fprintf('\n========================================================\n');
fprintf('ANÁLISE DE PASSAGENS E COMUNICAÇÃO CONCLUÍDA COM SUCESSO!\n');
fprintf('===========================================================\n');