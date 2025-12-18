function salvarResultados(numPassagens, startDateStr, startTimeStr, endDateStr, endTimeStr, ...
    durations, azStart, pontoCardealStart, azMaxEl, pontoCardealMaxEl, azEnd, ...
    pontoCardealEnd, maxElevations, dadosTransmitidosBytes, qualidadePassagem, ...
    tempoUtilComunicacao, elevacaoMediaUtil, rangeMedioUtil, classificacaoPassagem, ...
    revisitTimes, ~, margemEbNoDownlink, numTelemetrias, ...
    maxElDateStr, maxElTimeStr, numPacotesDados, dadosMissaoBytes, bytesPorTelemetria)

% Converter dados numericos para strings
durations_str = converterArrayParaVirgula(durations/60, '%.1f');
azStart_str = converterArrayParaVirgula(azStart, '%.1f');
azMaxEl_str = converterArrayParaVirgula(azMaxEl, '%.1f');
azEnd_str = converterArrayParaVirgula(azEnd, '%.1f');
maxElevations_str = converterArrayParaVirgula(maxElevations, '%.1f');

% Outras metricas (para tabela de comunicacao)
qualidadePassagem_str = converterArrayParaVirgula(qualidadePassagem, '%.1f');
tempoUtilComunicacao_str = converterArrayParaVirgula(tempoUtilComunicacao/60, '%.1f');
elevacaoMediaUtil_str = converterArrayParaVirgula(elevacaoMediaUtil, '%.1f');
rangeMedioUtil_str = converterArrayParaVirgula(rangeMedioUtil/1000, '%.1f');
margemEbNoDownlink_str = converterArrayParaVirgula(margemEbNoDownlink, '%.2f');

% Preparar strings para telemetrias e dados
numTelemetrias_str = cell(numPassagens, 1);
numPacotesDados_str = cell(numPassagens, 1);
dadosTelemetria_str = cell(numPassagens, 1);
dadosMissao_str = cell(numPassagens, 1);
dadosTransmitidos_str = cell(numPassagens, 1);

for i = 1:numPassagens
    numTelemetrias_str{i} = num2str(numTelemetrias(i));
    numPacotesDados_str{i} = num2str(numPacotesDados(i));
    dadosTelemetria_str{i} = num2str(numTelemetrias(i) * bytesPorTelemetria);
    dadosMissao_str{i} = num2str(dadosMissaoBytes(i));
    dadosTransmitidos_str{i} = num2str(dadosTransmitidosBytes(i));
end

% ================================================
% TABELA 1: ANALISE PASSAGENS
% ================================================
resultsTable1 = table((1:numPassagens)', startDateStr, startTimeStr, azStart_str, pontoCardealStart,...
    maxElTimeStr, maxElevations_str, azMaxEl_str, pontoCardealMaxEl, ...
    endTimeStr, azEnd_str, pontoCardealEnd, durations_str, ...
    'VariableNames', {'Passagem', 'Data_Inicio', 'Hora_Inicio', 'Az1', 'Inicio', ...
    'Hora_ElMax', 'ElMax', 'Az2', 'Max', ...
    'Hora_Fim', 'Az3', 'Fim', 'Duracao_min'});

writetable(resultsTable1, 'Analise Passagens.csv');

% ================================================
% TABELA 2: ANALISE COMUNICACAO 
% ================================================
resultsTable2 = table((1:numPassagens)', qualidadePassagem_str, ...
    tempoUtilComunicacao_str, elevacaoMediaUtil_str, rangeMedioUtil_str, ...
    margemEbNoDownlink_str, numTelemetrias_str, numPacotesDados_str, ...
    dadosTelemetria_str, dadosMissao_str, dadosTransmitidos_str, classificacaoPassagem, ...
    'VariableNames', {'Passagem', 'Qualidade', ...
    'Tempo_Util_min', 'El_Media', 'Alcance_Medio_km',  ...
    'Margem_Downlink_dB', 'Telemetrias', 'Pacotes_Dados', ...
    'Dados_Telemetria_bytes', 'Dados_Missao_bytes', 'Dados_Totais_bytes', 'Classificacao'});

writetable(resultsTable2, 'Analise Comunicacao.csv');

% ================================================
% TABELA 3: LISTA DE REVISITAS (se houver mais de uma passagem)
% ================================================
if numPassagens > 1
    % Preparar dados para a tabela de revisita
    numLinhas = numPassagens;
    
    % Inicializar arrays para a tabela
    passagemCell = cell(numLinhas, 1);
    dataCell = cell(numLinhas, 1);
    duracaoCell = cell(numLinhas, 1);
    revisitaCell = cell(numLinhas, 1);
    
    % Preencher dados das passagens
    for i = 1:numPassagens
        passagemCell{i} = num2str(i);
        dataCell{i} = startDateStr{i};
        duracaoCell{i} = durations_str{i};
        
        if i == 1
            revisitaCell{i} = '-';
        else
            revisitaCell{i} = converterParaVirgula(revisitTimes(i-1)/60, '%.1f');
        end
    end
    
    % Criar tabela apenas com dados das passagens
    tabelaRevisita = cell2table([passagemCell, dataCell, duracaoCell, revisitaCell], ...
        'VariableNames', {'Passagem', 'Data', 'Duracao_min', 'Tempo_Revisita_min'});
    
    writetable(tabelaRevisita, 'Lista Revisitas.csv');
    
    % ================================================
    % TABELA 4: ESTATISTICAS DE REVISITAS
    % ================================================
    
    % Calcular estatisticas basicas
    revisita_media_min = mean(revisitTimes)/60;
    revisita_min_min = min(revisitTimes)/60;
    revisita_max_min = max(revisitTimes)/60;
    revisita_desvio_min = std(revisitTimes)/60;
    revisita_media_hr = mean(revisitTimes)/3600;
    revisita_desvio_hr = std(revisitTimes)/3600;
    
    % Coeficiente de variacao
    if mean(revisitTimes) > 0
        cv_revisita = (std(revisitTimes) / mean(revisitTimes)) * 100;
    else
        cv_revisita = 0;
    end
    
    % ANALISE DE PADRAO - Detectar padroes com dois tempos distintos
    [ehPadrao, grupo1, grupo2, infoPadrao] = analisePadrao(revisitTimes);
    
    % Preparar dados para a tabela de estatisticas
    estatisticas = {
        'Tempo de revisita medio (m)', revisita_media_min;
        'Tempo de revisita minimo (m)', revisita_min_min;
        'Tempo de revisita maximo (m)', revisita_max_min;
        'Desvio padrao revisita (m)', revisita_desvio_min;
        'Tempo de revisita medio (h)', revisita_media_hr;
        'Desvio padrao revisita (h)', revisita_desvio_hr;
        'Coeficiente de variacao (%)', cv_revisita;
        };
    
    % Se padrao for detectado, adicionar informacoes extras
    if ehPadrao
        % Adicionar linha separadora
        estatisticas = [estatisticas; {'--- PADRAO ESPECIAL DETECTADO ---', ''}];
        
        % Adicionar informacoes sobre o padrao (sem ciclo completo)
        estatisticas = [estatisticas; {
            'Revisitas curtas (m)', mean(grupo1)/60;
            'Revisitas longas (m)', mean(grupo2)/60;
            'Desvio padrao curtas (m)', std(grupo1)/60;
            'Desvio padrao longas (m)', std(grupo2)/60;
            'Razao entre grupos', infoPadrao.razaoGrupos;
            'Numero de revisitas curtas', length(grupo1);
            'Numero de revisitas longas', length(grupo2);
            }];
    end
    
    % Converter valores numericos para strings com 2 casas decimais
    for i = 1:size(estatisticas, 1)
        if isnumeric(estatisticas{i, 2})
            if contains(estatisticas{i, 1}, 'Numero de revisitas')
                % Para contagens, manter formato inteiro
                valor_str = sprintf('%d', round(estatisticas{i, 2}));
            else
                % Para todos os outros valores, usar 2 casas decimais
                valor_str = sprintf('%.2f', estatisticas{i, 2});
            end
            
            % Substituir ponto por vírgula
            valor_str = strrep(valor_str, '.', ',');
            estatisticas{i, 2} = valor_str;
        end
    end
    
    % Criar tabela de estatisticas
    tabelaEstatisticas = cell2table(estatisticas, ...
        'VariableNames', {'Metrica', 'Valor'});
    
    writetable(tabelaEstatisticas, 'Estatisticas Revisitas.csv');
end

% APENAS MENSAGENS ESSENCIAIS SOBRE ARQUIVOS SALVOS
fprintf('\nResultados salvos em arquivos:\n');
fprintf('- Tabela 1 (Analise Passagens): ''Analise Passagens.csv''\n');
fprintf('- Tabela 2 (Analise Comunicacao): ''Analise Comunicacao.csv''\n');
if numPassagens > 1
    fprintf('- Tabela 3 (Lista Revisitas): ''Lista Revisitas.csv''\n');
    fprintf('- Tabela 4 (Estatisticas Revisitas): ''Estatisticas Revisitas.csv''\n');
end
end

% ================================================
% FUNÇÃO AUXILIAR: ANALISE DE PADRAO
% ================================================
function [ehPadrao, grupo1, grupo2, info] = analisePadrao(revisitTimes)
    % Inicializar saidas
    ehPadrao = false;
    grupo1 = [];
    grupo2 = [];
    info = struct('tipoPadrao', 'Nenhum', 'razaoGrupos', 0);
    
    % Verificar se ha dados suficientes
    if length(revisitTimes) < 4
        return;
    end
    
    % Converter para vetor coluna se necessario
    revisitTimes = revisitTimes(:);
    
    % Tentar identificar dois clusters usando k-means
    try
        % Usar k-means com 2 clusters
        [idx, centros] = kmeans(revisitTimes, 2);
        
        % Ordenar clusters do menor para o maior
        [centros_ord, ordem] = sort(centros);
        
        % Reorganizar indices conforme a ordenacao
        idx_ord = zeros(size(idx));
        idx_ord(idx == ordem(1)) = 1;
        idx_ord(idx == ordem(2)) = 2;
        
        % Separar os grupos
        grupo1 = revisitTimes(idx_ord == 1);
        grupo2 = revisitTimes(idx_ord == 2);
        
        % Verificar se os grupos sao significativamente diferentes
        razao = centros_ord(2) / centros_ord(1);
        dif_abs = abs(centros_ord(2) - centros_ord(1));
        
        % Criterios para padrao:
        % 1. Razao > 1.5 (um grupo pelo menos 50% maior que o outro)
        % 2. Diferenca absoluta > 30 minutos (1800 segundos)
        % 3. Ambos os grupos tem pelo menos 2 elementos
        if razao > 1.5 && dif_abs > 1800 && length(grupo1) >= 2 && length(grupo2) >= 2
            ehPadrao = true;
            info.razaoGrupos = razao;
            
            % Determinar tipo de padrao baseado na razao
            if razao > 3
                info.tipoPadrao = 'Padrao Extremo (razao > 3:1)';
            elseif razao > 2
                info.tipoPadrao = 'Padrao Forte (razao 2:1 a 3:1)';
            else
                info.tipoPadrao = 'Padrao Moderado (razao 1.5:1 a 2:1)';
            end
            
            % Verificar padrao de alternancia
            if length(revisitTimes) >= 6
                padraoAlternante = verificarAlternancia(idx_ord);
                if padraoAlternante
                    info.tipoPadrao = [info.tipoPadrao, ' - Padrao Alternante'];
                end
            end
        end
        
    catch
        % Se k-means falhar, tentar metodo simples baseado em mediana
        mediana = median(revisitTimes);
        limiar = mediana * 1.3; % 30% acima da mediana
        
        grupo1 = revisitTimes(revisitTimes <= limiar);
        grupo2 = revisitTimes(revisitTimes > limiar);
        
        if length(grupo1) >= 2 && length(grupo2) >= 2
            razao = median(grupo2) / median(grupo1);
            if razao > 1.5
                ehPadrao = true;
                info.razaoGrupos = razao;
                info.tipoPadrao = 'Padrao (metodo simplificado)';
            end
        end
    end
end

% ================================================
% FUNÇÃO AUXILIAR: VERIFICAR ALTERNÂNCIA
% ================================================
function alternante = verificarAlternancia(idx)
    % Verifica se os indices alternam regularmente (ex: 1,2,1,2,1,2)
    
    alternante = false;
    n = length(idx);
    
    if n < 4
        return;
    end
    
    % Padroes comuns de alternancia
    padrao1 = repmat([1; 2], ceil(n/2), 1);
    padrao2 = repmat([2; 1], ceil(n/2), 1);
    
    % Verificar se corresponde a algum padrao (com tolerancia)
    tolerancia = 1; % Permite 1 erro no padrao
    erros1 = sum(idx(1:n) ~= padrao1(1:n));
    erros2 = sum(idx(1:n) ~= padrao2(1:n));
    
    if erros1 <= tolerancia || erros2 <= tolerancia
        alternante = true;
    end
end