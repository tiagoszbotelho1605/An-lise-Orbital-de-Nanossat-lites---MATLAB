function resultados_simulacoes = executar_simulacoes(altitudes_km, nomes_simulacoes, Re, mu, excentricidade, area, Cd, massa, F107, Ap)
% EXECUTAR_SIMULACOES Executa simulações de decaimento orbital para múltiplas altitudes
%   altitudes_km: vetor com altitudes iniciais
%   nomes_simulacoes: cell array com nomes das simulações
%   Re: raio da Terra (km)
%   mu: parâmetro gravitacional da Terra (km³/s²)
%   excentricidade: excentricidade orbital
%   area: área de arrasto (m²)
%   Cd: coeficiente de arrasto
%   massa: massa do satélite (kg)
%   F107: fluxo solar F10.7 (SFU)
%   Ap: índice geomagnético Ap

% Inicializar estruturas para armazenar resultados
resultados_simulacoes = struct();
todos_tempos = {};
todas_altitudes = {};

% Cores para o gráfico (paleta distinta)
cores = lines(length(altitudes_km));

for i = 1:length(altitudes_km)
    fprintf('\n--- Simulação %d/%d: %s ---\n', i, length(altitudes_km), nomes_simulacoes{i});
    
    % Calcular parâmetros orbitais para esta altitude
    altitude_inicial = altitudes_km(i);
    semi_eixo_maior = altitude_inicial + Re;
    
    % Recalcular período orbital usando a 3ª Lei de Kepler
    periodo_inicial = 2 * pi * sqrt(semi_eixo_maior^3 / mu);  % em segundos
    movimento_medio_sim = (24 * 3600) / periodo_inicial;  % rev/dia
    
    fprintf('Altitude: %.1f km\n', altitude_inicial);
    fprintf('Semi-eixo maior: %.2f km\n', semi_eixo_maior);
    fprintf('Período orbital: %.2f minutos\n', periodo_inicial/60);
    
    % Executar simulação usando a função computeOrbitalDecay
    try
        [P_seconds, t_seconds] = computeOrbitalDecay(semi_eixo_maior, excentricidade, area, Cd, massa, F107, Ap);
        
        if isempty(P_seconds)
            fprintf('Nenhum decaimento significativo detectado para esta altitude.\n');
            % Criar dados vazios para manter consistência
            resultados_simulacoes(i).tempo_dias = [];
            resultados_simulacoes(i).altitude_km = [];
            continue;
        end
        
        % Processar resultados
        altitude_km = ((P_seconds./(2.*pi)).^2 .* mu).^(1/3) - Re;
        tempo_dias = t_seconds ./ 86400;
        
        % Remover valores NaN (após reentrada)
        valid_idx = ~isnan(P_seconds(:,1));
        tempo_dias = tempo_dias(valid_idx);
        altitude_km = altitude_km(valid_idx);
        
        % Armazenar resultados
        todos_tempos{i} = tempo_dias;
        todas_altitudes{i} = altitude_km;
        
        % Calcular estatísticas
        decaimento_total = altitude_km(1) - altitude_km(end);
        if tempo_dias(end) > 0
            taxa_media_km_dia = decaimento_total / tempo_dias(end);
        else
            taxa_media_km_dia = 0;
        end
        
        % Armazenar resultados completos
        resultados_simulacoes(i).nome = nomes_simulacoes{i};
        resultados_simulacoes(i).altitude_inicial = altitude_inicial;
        resultados_simulacoes(i).tempo_dias = tempo_dias;
        resultados_simulacoes(i).altitude_km = altitude_km;
        resultados_simulacoes(i).altitude_final = altitude_km(end);
        resultados_simulacoes(i).tempo_simulado_dias = tempo_dias(end);
        resultados_simulacoes(i).tempo_simulado_anos = tempo_dias(end) / 365;
        resultados_simulacoes(i).decaimento_total = decaimento_total;
        resultados_simulacoes(i).taxa_media_km_dia = taxa_media_km_dia;
        resultados_simulacoes(i).cor = cores(i,:);
        resultados_simulacoes(i).Cd = Cd;
        resultados_simulacoes(i).F107 = F107;
        resultados_simulacoes(i).Ap = Ap;
        
        fprintf('Simulação concluída com sucesso!\n');
        fprintf('Decaimento total: %.1f km\n', decaimento_total);
        fprintf('Taxa média de decaimento: %.3f km/dia\n', taxa_media_km_dia);
        
    catch ME
        fprintf('Erro na simulação %d: %s\n', i, ME.message);
        fprintf('Continuando com as próximas simulações...\n');
        % Criar estrutura vazia para manter o índice
        resultados_simulacoes(i).tempo_dias = [];
        resultados_simulacoes(i).altitude_km = [];
    end
end

% Remover simulações vazias
if exist('resultados_simulacoes', 'var')
    idx_validos = arrayfun(@(x) ~isempty(x.tempo_dias), resultados_simulacoes);
    resultados_simulacoes = resultados_simulacoes(idx_validos);
else
    resultados_simulacoes = [];
end
end