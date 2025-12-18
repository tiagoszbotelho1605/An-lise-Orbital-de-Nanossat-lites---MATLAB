function [tempoUtil, elevacaoMedia, rangeMedio, dadosTransmitidosBytes, ...
          margemDownlinkMedia, numTelemetrias, numPacotesDados, dadosMissaoBytes] = ...
         calcularMetricasComunicacao(el, ranges, margem_downlink, elevacaoMinima, bitRate)
% calcularMetricasComunicacao - Calcula métricas de comunicação (apenas downlink)
% COM SUPORTE A PACOTES DE DADOS DA MISSÃO
%
% Entradas:
%   el - vetor de elevações em graus
%   ranges - vetor de alcances em metros
%   margem_downlink - vetor de margens de downlink em dB
%   elevacaoMinima - elevação mínima para comunicação em graus
%   bitRate - taxa de dados em bps
%
% Saídas:
%   tempoUtil - tempo útil em segundos
%   elevacaoMedia - elevação média durante tempo útil em graus
%   rangeMedio - alcance médio durante tempo útil em metros
%   dadosTransmitidosBytes - dados transmitidos totais em bytes
%   margemDownlinkMedia - margem média de downlink em dB
%   numTelemetrias - número estimado de telemetrias
%   numPacotesDados - número estimado de pacotes de dados da missão
%   dadosMissaoBytes - dados da missão transmitidos em bytes

    % Parâmetros Aldebaran-1 - 73 bytes
    bytesPorTelemetria = 73; % bytes (pacote completo)
    bytesPorPacoteDados = 15; % bytes por pacote de dados da missão (completo)
    intervaloTelemetria = 60; % segundos (1 minuto)
    
    % Encontrar índices onde a elevação é suficiente para comunicação
    indicesUtil = find(el >= elevacaoMinima);
    
    if isempty(indicesUtil)
        tempoUtil = 0;
        elevacaoMedia = 0;
        rangeMedio = 0;
        dadosTransmitidosBytes = 0;
        margemDownlinkMedia = 0;
        numTelemetrias = 0;
        numPacotesDados = 0;
        dadosMissaoBytes = 0;
        return;
    end
    
    % Verificar margens positivas do downlink
    downlink_positivo = margem_downlink(indicesUtil) > 0;
    
    % Comunicação efetiva quando downlink tem margem positiva
    indicesComunicacao = indicesUtil(downlink_positivo);
    
    if isempty(indicesComunicacao)
        tempoUtil = 0;
        elevacaoMedia = 0;
        rangeMedio = 0;
        dadosTransmitidosBytes = 0;
        margemDownlinkMedia = 0;
        numTelemetrias = 0;
        numPacotesDados = 0;
        dadosMissaoBytes = 0;
        return;
    end
    
    % Calcular tempo útil (em segundos)
    tempoUtil = length(indicesComunicacao) * 5; % 5 segundos entre amostras
    
    % Estimar número de telemetrias
    if tempoUtil < intervaloTelemetria
        numTelemetrias = 0;
    else
        numTelemetrias = floor(tempoUtil / intervaloTelemetria);
    end
    
    % CÁLCULO DOS PACOTES DE DADOS DA MISSÃO
    % Calcular tempo disponível para dados da missão (tempo entre telemetrias)
    if numTelemetrias > 0
        % Tempo total menos tempo ocupado por telemetrias
        tempoTelemetria = (bytesPorTelemetria * 8) / bitRate; % segundos por telemetria
        tempoTotalTelemetrias = numTelemetrias * tempoTelemetria;
        tempoDisponivelDados = tempoUtil - tempoTotalTelemetrias;
    else
        % Se não há telemetrias, todo o tempo útil está disponível
        tempoDisponivelDados = tempoUtil;
    end
    
    % Estimar número de pacotes de dados da missão
    if tempoDisponivelDados > 0
        tempoPorPacoteDados = (bytesPorPacoteDados * 8) / bitRate; % segundos por pacote
        numPacotesDados = floor(tempoDisponivelDados / tempoPorPacoteDados);
    else
        numPacotesDados = 0;
    end
    
    % Calcular dados transmitidos
    dadosTelemetriaBytes = numTelemetrias * bytesPorTelemetria;
    dadosMissaoBytes = numPacotesDados * bytesPorPacoteDados;
    dadosTransmitidosBytes = dadosTelemetriaBytes + dadosMissaoBytes;
    
    % Outras métricas
    elevacaoMedia = mean(el(indicesComunicacao));
    rangeMedio = mean(ranges(indicesComunicacao));
    margemDownlinkMedia = mean(margem_downlink(indicesComunicacao));
end