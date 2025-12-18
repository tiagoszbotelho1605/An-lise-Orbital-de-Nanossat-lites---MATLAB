function gerarDashboard(nomeSatelite, qualidadePassagem, durations, tempoUtilComunicacao, maxElevations, ...
    elevacaoMediaUtil, azStart, azMaxEl, azEnd, rangeMedioUtil, dadosTransmitidosBytes, ...
    classificacaoPassagem, revisitTimes, numPassagens, passagensComComunicacao, ...
    elevacaoMinimaOperacional, margemEbNoDownlink, numTelemetrias, ...
    startDateStr, startTimeStr, numPacotesDados, resultadosDecaimento)

    % ================================================
    % DASHBOARD 
    % ================================================
    
    % Configurações gerais
    colors = [0.2 0.6 0.8;    % Azul principal
              0.8 0.5 0.2;    % Laranja
              0.6 0.2 0.6;    % Roxo
              0.2 0.8 0.4;    % Verde
              0.9 0.3 0.3];   % Vermelho suave
    
    % Cores para as métricas (apenas 3 cores)
    corVerdeClaro = [0.85 1.00 0.85];
    corVerdeEscuro = [0.00 0.50 0.00];
    corAmareloClaro = [1.00 1.00 0.85];
    corAmareloEscuro = [0.60 0.60 0.00];
    corVermelhoClaro = [1.00 0.85 0.85];
    corVermelhoEscuro = [0.60 0.00 0.00];
    corCinzaClaro = [0.95 0.95 0.95];
    corCinzaEscuro = [0.30 0.30 0.30];
    
    % Criar figura
    fig = figure('Name', 'Dashboard', ...
        'Position', [50, 50, 1600, 900], ...
        'NumberTitle', 'off', ...
        'Color', [0.98 0.98 0.98]);
    
    % Título principal
    annotation('textbox', [0.1, 0.965, 0.8, 0.03], ...
        'String', sprintf('DASHBOARD - SATÉLITE: %s', nomeSatelite), ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center', ...
        'EdgeColor', 'none', ...
        'BackgroundColor', [0.9 0.95 1], ...
        'Margin', 5);
    
    % ===== PARTE SUPERIOR: 15 MÉTRICAS =====
    
    % Validação básica dos dados
    if isempty(numPassagens) || numPassagens == 0
        text(0.5, 0.5, 'Nenhuma passagem disponível para análise', ...
            'HorizontalAlignment', 'center', 'FontSize', 14, 'Color', 'red');
        return;
    end
    
    % Calcular métricas corretamente
    indicesComComunicacao = qualidadePassagem > 0;
    numPassagensComComunicacao = sum(indicesComComunicacao);
    
    % Definir posições para as 15 métricas
    pos_x = [0.05, 0.23, 0.41, 0.59, 0.77];
    pos_y = [0.73, 0.53, 0.33];
    largura_metrica = 0.15;
    altura_metrica = 0.15;
    
    % Métrica 1: Total de passagens
    criarCaixaMetrica3Cores([pos_x(1), pos_y(1), largura_metrica, altura_metrica], ...
        'Total Passagens', numPassagens, numPassagens);
    
    % Métrica 2: Total de telemetrias
    totalTelemetrias = sum(numTelemetrias);
    criarCaixaMetrica3Cores([pos_x(2), pos_y(1), largura_metrica, altura_metrica], ...
        'Total Telemetrias', totalTelemetrias, totalTelemetrias);
    
    % Métrica 3: Total de pacotes de dados
    totalPacotesDados = sum(numPacotesDados);
    criarCaixaMetrica3Cores([pos_x(3), pos_y(1), largura_metrica, altura_metrica], ...
        'Total Pacotes Dados', totalPacotesDados, totalPacotesDados);
    
    % Métrica 4: Total de dados
    dadosTotais = sum(dadosTransmitidosBytes);
    criarCaixaMetrica3Cores([pos_x(4), pos_y(1), largura_metrica, altura_metrica], ...
        'Dados Totais (bytes)', dadosTotais, dadosTotais);
    
    % Métrica 5: Passagens com comunicação
    if numPassagens > 0
        percentComunicacao = (numPassagensComComunicacao/numPassagens)*100;
    else
        percentComunicacao = 0;
    end
    criarCaixaMetrica3Cores([pos_x(5), pos_y(1), largura_metrica, altura_metrica], ...
        'Passagens Úteis (%)', percentComunicacao, percentComunicacao);

    % Métrica 6: Qualidade média
    if numPassagensComComunicacao > 0
        qualidadeMedia = mean(qualidadePassagem(qualidadePassagem>0));
    else
        qualidadeMedia = 0;
    end
    if isnan(qualidadeMedia), qualidadeMedia = 0; end
    criarCaixaMetrica3Cores([pos_x(1), pos_y(2), largura_metrica, altura_metrica], ...
        'Qualidade Média', qualidadeMedia, qualidadeMedia);

    % Métrica 7: Margem Downlink média
    if numPassagensComComunicacao > 0
        margemDLMedia = mean(margemEbNoDownlink(qualidadePassagem>0));
    else
        margemDLMedia = 0;
    end
    if isnan(margemDLMedia), margemDLMedia = 0; end
    criarCaixaMetrica3Cores([pos_x(2), pos_y(2), largura_metrica, altura_metrica], ...
        'Margem DL Média (dB)', margemDLMedia, margemDLMedia);
    
    % Métrica 8: Elevação média
    if numPassagensComComunicacao > 0
        elevacaoMedia = mean(maxElevations(qualidadePassagem>0));
    else
        elevacaoMedia = 0;
    end
    if isnan(elevacaoMedia), elevacaoMedia = 0; end
    criarCaixaMetrica3Cores([pos_x(3), pos_y(2), largura_metrica, altura_metrica], ...
        'Elevação Média (°)', elevacaoMedia, elevacaoMedia);
    
    % Métrica 9: Revisita média
    if numPassagens > 1 && ~isempty(revisitTimes)
        revisitaMedia = mean(revisitTimes)/3600;
        criarCaixaMetrica3Cores([pos_x(4), pos_y(2), largura_metrica, altura_metrica], ...
            'Revisita Média (h)', revisitaMedia, revisitaMedia);
    else
        criarCaixaMetrica3Cores([pos_x(4), pos_y(2), largura_metrica, altura_metrica], ...
            'Revisita Média', 'N/A', 0);
    end
    
    % Métrica 10: Tempo útil médio
    if numPassagensComComunicacao > 0
        tempoUtilMedio = mean(tempoUtilComunicacao(qualidadePassagem>0))/60;
    else
        tempoUtilMedio = 0;
    end
    if isnan(tempoUtilMedio), tempoUtilMedio = 0; end
    criarCaixaMetrica3Cores([pos_x(5), pos_y(2), largura_metrica, altura_metrica], ...
        'Tempo Útil Médio (min)', tempoUtilMedio, tempoUtilMedio);
    
    % Métrica 11: Alcance médio
    if numPassagensComComunicacao > 0
        alcanceMedio = mean(rangeMedioUtil(qualidadePassagem>0))/1000;
    else
        alcanceMedio = 0;
    end
    if isnan(alcanceMedio), alcanceMedio = 0; end
    criarCaixaMetrica3Cores([pos_x(1), pos_y(3), largura_metrica, altura_metrica], ...
        'Alcance Médio (km)', alcanceMedio, alcanceMedio);
    
    % Métrica 12: Telemetrias por passagem
    if numPassagensComComunicacao > 0
        telemetriasMedia = mean(numTelemetrias(qualidadePassagem>0));
    else
        telemetriasMedia = 0;
    end
    criarCaixaMetrica3Cores([pos_x(2), pos_y(3), largura_metrica, altura_metrica], ...
        'Telemetrias Média', telemetriasMedia, telemetriasMedia);
    
    % Métrica 13: Pacotes de dados por passagem
    if numPassagensComComunicacao > 0
        pacotesDadosMedia = mean(numPacotesDados(qualidadePassagem>0));
    else
        pacotesDadosMedia = 0;
    end
    criarCaixaMetrica3Cores([pos_x(3), pos_y(3), largura_metrica, altura_metrica], ...
        'Pacotes Dados Média', pacotesDadosMedia, pacotesDadosMedia);
    
    % Métrica 14: Duração média total
    if numPassagensComComunicacao > 0
        duracaoMediaTotal = mean(durations(qualidadePassagem>0))/60;
    else
        duracaoMediaTotal = 0;
    end
    if isnan(duracaoMediaTotal), duracaoMediaTotal = 0; end
    criarCaixaMetrica3Cores([pos_x(4), pos_y(3), largura_metrica, altura_metrica], ...
        'Duração Média (min)', duracaoMediaTotal, duracaoMediaTotal);
    
    % Métrica 15: TEMPO DE DECAIMENTO DA MAIOR ALTITUDE (SUBSTITUÍDA)
    if ~isempty(resultadosDecaimento) && isfield(resultadosDecaimento, 'altitude_inicial')
        % Encontrar a maior altitude
        altitudes_iniciais = [resultadosDecaimento.altitude_inicial];
        [maior_altitude, idx_maior] = max(altitudes_iniciais);
        
        % Obter o tempo de decaimento em anos da maior altitude
        tempo_decaimento_anos = resultadosDecaimento(idx_maior).tempo_simulado_anos;
        
        % Determinar cor baseada no tempo de decaimento
        if tempo_decaimento_anos > 5
            corFundo = corVerdeClaro;
            corTexto = corVerdeEscuro;
        elseif tempo_decaimento_anos > 2
            corFundo = corAmareloClaro;
            corTexto = corAmareloEscuro;
        else
            corFundo = corVermelhoClaro;
            corTexto = corVermelhoEscuro;
        end
        
        % Criar caixa métrica customizada para decaimento
        criarCaixaMetricaCustomizada([pos_x(5), pos_y(3), largura_metrica, altura_metrica], ...
            sprintf('Tempo Reentrada (anos)'), ...
            tempo_decaimento_anos, corFundo, corTexto);
    else
        criarCaixaMetrica3Cores([pos_x(5), pos_y(3), largura_metrica, altura_metrica], ...
            'Tempo Reentrada', 'N/D', 0);
    end
    
    % ===== PARTE INFERIOR: 4 GRÁFICOS =====
    
    % Ajustar largura para caber 4 gráficos
    largura_grafico = 0.25;
    
    % Gráfico 1: Distribuição das Classificações
    ax1 = axes('Position', [0.05, 0.08, largura_grafico, 0.20]);
    if numPassagensComComunicacao > 0
        uniqueClasses = {};
        classCounts = [];
        
        for i = 1:numPassagens
            if qualidadePassagem(i) > 0 && ~isempty(classificacaoPassagem{i}) && ischar(classificacaoPassagem{i})
                currentClass = classificacaoPassagem{i};
                found = false;
                for j = 1:length(uniqueClasses)
                    if strcmp(uniqueClasses{j}, currentClass)
                        found = true;
                        classCounts(j) = classCounts(j) + 1;
                        break;
                    end
                end
                if ~found
                    uniqueClasses{end+1} = currentClass;
                    classCounts(end+1) = 1;
                end
            end
        end
        
        if ~isempty(uniqueClasses)
            barh(ax1, 1:length(uniqueClasses), classCounts, 'FaceColor', colors(1,:), 'EdgeColor', 'k', 'LineWidth', 1);
            set(ax1, 'YTick', 1:length(uniqueClasses), 'YTickLabel', uniqueClasses, 'FontSize', 9);
            xlabel(ax1, 'Número de Passagens', 'FontSize', 10);
            ylabel(ax1, 'Classificação', 'FontSize', 10);
            title(ax1, 'Distribuição das Classificações', 'FontSize', 11, 'FontWeight', 'bold');
            grid(ax1, 'on');
            
            % Adicionar valores nas barras
            for i = 1:length(uniqueClasses)
                text(classCounts(i) + 0.1, i, sprintf('%d', classCounts(i)), ...
                    'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontSize', 9);
            end
        else
            text(ax1, 0.5, 0.5, 'Sem classificações disponíveis', ...
                'HorizontalAlignment', 'center', 'FontSize', 10);
            title(ax1, 'Distribuição das Classificações', 'FontSize', 11, 'FontWeight', 'bold');
            axis(ax1, 'off');
        end
    else
        text(ax1, 0.5, 0.5, 'Nenhuma passagem com comunicação', ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
        title(ax1, 'Distribuição das Classificações', 'FontSize', 11, 'FontWeight', 'bold');
        axis(ax1, 'off');
    end
    
    % ================================================
    % GRÁFICO 2: TOP 3 MELHORES PASSAGENS
    % ================================================
    ax2 = axes('Position', [0.34, 0.08, 0.28, 0.20]);
    
    if numPassagensComComunicacao >= 1
        % Ordenar passagens por qualidade
        [qualidadeOrdenada, indicesOrdenados] = sort(qualidadePassagem, 'descend');
        top3 = min(3, numPassagensComComunicacao);
        
        % Preparar dados
        tempoUtilTop3 = zeros(top3, 1);
        elevacaoMaxTop3 = zeros(top3, 1);
        pacotesDadosTop3 = zeros(top3, 1);
        
        for i = 1:top3
            idx = indicesOrdenados(i);
            tempoUtilTop3(i) = tempoUtilComunicacao(idx)/60; % minutos
            elevacaoMaxTop3(i) = maxElevations(idx); % graus
            pacotesDadosTop3(i) = numPacotesDados(idx);
        end
        
        % Calcular os máximos para normalização
        maxVals = [max(tempoUtilTop3), max(elevacaoMaxTop3), max(pacotesDadosTop3)];
        
        % Evitar divisão por zero
        maxVals(maxVals == 0) = 1;
        
        % Normalizar dados (0-1)
        tempoUtilNorm = tempoUtilTop3 / maxVals(1);
        elevacaoNorm = elevacaoMaxTop3 / maxVals(2);
        pacotesNorm = pacotesDadosTop3 / maxVals(3);
        
        % Criar posições X para as barras
        x = 1:top3;
        barWidth = 0.25;
        offset = 0.30;
        
        hold(ax2, 'on');
        
        % Plotar barras para cada métrica
        bar1 = bar(ax2, x - offset, tempoUtilNorm, barWidth, ...
            'FaceColor', colors(1,:), 'EdgeColor', 'k', 'LineWidth', 1);
        bar2 = bar(ax2, x, elevacaoNorm, barWidth, ...
            'FaceColor', colors(2,:), 'EdgeColor', 'k', 'LineWidth', 1);
        bar3 = bar(ax2, x + offset, pacotesNorm, barWidth, ...
            'FaceColor', colors(3,:), 'EdgeColor', 'k', 'LineWidth', 1);
        
        % Configurar eixo X
        set(ax2, 'XTick', x, ...
            'XTickLabel', arrayfun(@(idx) sprintf('Pass. %d', indicesOrdenados(idx)), 1:top3, 'UniformOutput', false), ...
            'FontSize', 9);
        
        % Configurar eixo Y
        ylabel(ax2, 'Valor Normalizado', 'FontSize', 10);
        ylim([0 1.2]);
        
        % Título
        title(ax2, 'Top 3 Melhores Passagens', 'FontSize', 11, 'FontWeight', 'bold');
        
        % Legenda
        legend([bar1, bar2, bar3], {'Tempo Útil (min)', 'Elevação Máx (°)', 'Pacotes Dados'}, ...
            'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 8);
        
        % Grade
        grid(ax2, 'on');
        
        % Adicionar valores reais acima das barras
        for i = 1:top3
            % Tempo útil
            text(ax2, x(i) - offset, tempoUtilNorm(i) + 0.03, ...
                sprintf('%.1fm', tempoUtilTop3(i)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'FontWeight', 'bold');
            
            % Elevação
            text(ax2, x(i), elevacaoNorm(i) + 0.05, ...
                sprintf('%.1f°', elevacaoMaxTop3(i)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'FontWeight', 'bold');
            
            % Pacotes de dados
            text(ax2, x(i) + offset, pacotesNorm(i) + 0.07, ...
                sprintf('%d', pacotesDadosTop3(i)), ...
                'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', ...
                'FontSize', 8, 'FontWeight', 'bold');
        end
        
        hold(ax2, 'off');
        
    else
        text(ax2, 0.5, 0.5, 'Nenhuma passagem com comunicação', ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
        title(ax2, 'Top 3 Melhores Passagens', 'FontSize', 11, 'FontWeight', 'bold');
        axis(ax2, 'off');
    end
    
    % ================================================
    % GRÁFICO 3: RESUMO TEXTUAL DA COMUNICAÇÃO
    % ================================================
    ax3 = axes('Position', [0.63, 0.08, largura_grafico, 0.20]);
    axis(ax3, 'off');
    
    if numPassagens > 0 && ~isempty(startDateStr) && ~isempty(startTimeStr)
        % Calcular estatísticas
        if numPassagensComComunicacao > 0
            melhorQualidadeVal = max(qualidadePassagem(qualidadePassagem>0));
            piorQualidadeVal = min(qualidadePassagem(qualidadePassagem>0));
            totalPacotesDadosVal = sum(numPacotesDados);
            tempoUtilTotal = sum(tempoUtilComunicacao(qualidadePassagem>0)) / 3600;
        else
            melhorQualidadeVal = 0;
            piorQualidadeVal = 0;
            totalPacotesDadosVal = 0;
            tempoUtilTotal = 0;
        end
        
        % Calcular revisita média
        if numPassagens > 1 && ~isempty(revisitTimes)
            revisitaMediaVal = mean(revisitTimes)/3600;
            revisitaMediaStr = sprintf('%.1f', revisitaMediaVal);
        else
            revisitaMediaStr = 'N/A';
        end
        
        % Formatar texto
        resumoTexto = sprintf(['RESUMO DA ANÁLISE: \n\n' ...
            'Período: %s %s a\n%s %s\n\n' ...
            'Total de passagens: %d\n' ...
            'Passagens úteis: %d (%.1f%%)\n' ...
            'Telemetrias totais: %d\n' ...
            'Pacotes de dados: %d\n' ...
            'Dados totais: %d bytes\n' ...
            'Tempo útil total: %.1f horas\n' ...
            'Revisita média: %s horas\n' ...
            'Melhor qualidade: %.1f/100\n' ...
            'Pior qualidade: %.1f/100'], ...
            startDateStr{1}, startTimeStr{1}, ...
            startDateStr{end}, startTimeStr{end}, ...
            numPassagens, numPassagensComComunicacao, (numPassagensComComunicacao/numPassagens)*100, ...
            sum(numTelemetrias), totalPacotesDadosVal, sum(dadosTransmitidosBytes), tempoUtilTotal, ...
            revisitaMediaStr, melhorQualidadeVal, piorQualidadeVal);
        
        % Exibir texto
        text(ax3, 0.02, 0.98, resumoTexto, ...
            'VerticalAlignment', 'top', ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 9, ...
            'FontName', 'Arial', ...
            'FontWeight', 'normal', ...
            'BackgroundColor', [0.97 0.97 0.97], ...
            'EdgeColor', [0.7 0.7 0.7], ...
            'LineWidth', 1, ...
            'Margin', 5);
    else
        text(ax3, 0.5, 0.5, 'Dados insuficientes para resumo', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 10, ...
            'FontName', 'Arial', ...
            'FontWeight', 'normal');
    end
    
    % ================================================
    % GRÁFICO 4: RESUMO TEXTUAL DO DECAIMENTO (ATUALIZADO)
    % ================================================
    ax4 = axes('Position', [0.77, 0.08, largura_grafico, 0.20]);
    axis(ax4, 'off');
    
    if ~isempty(resultadosDecaimento) && isfield(resultadosDecaimento, 'altitude_inicial')
        % Calcular estatísticas do decaimento
        altitudes_iniciais = [resultadosDecaimento.altitude_inicial];
        
        % Encontrar apenas a maior altitude
        [maior_altitude, idx_maior] = max(altitudes_iniciais);
        sim_maior = resultadosDecaimento(idx_maior);
        
        % Verificar se os campos existem
        if isfield(sim_maior, 'Cd') && isfield(sim_maior, 'F107') && isfield(sim_maior, 'Ap')
            Cd_valor = sim_maior.Cd;
            F107_valor = sim_maior.F107;
            Ap_valor = sim_maior.Ap;
            
            % Calcular período orbital inicial (em minutos)
            Re = 6378.137;  % Raio da Terra em km
            mu = 398600.4418;  % Parâmetro gravitacional da Terra (km³/s²)
            a = maior_altitude + Re;  % Semi-eixo maior em km
            periodo_orbital_seg = 2 * pi * sqrt(a^3 / mu);  % Período em segundos
            periodo_orbital_min = periodo_orbital_seg / 60;  % Período em minutos
            
            % Formatar texto do resumo do decaimento
            resumoDecaimento = sprintf(['RESUMO DO DECAIMENTO ORBITAL:\n\n' ...
                'Condições Atmosféricas: \n' ...
                '  - Coeficiente de arrasto (Cd): %.1f\n' ...
                '  - Fluxo solar F10.7: %.0f SFU\n' ...
                '  - Índice geomagnético Ap: %.0f\n\n' ...
                'Altitude Atual: %.0f km\n' ...
                '  - Altitude final: %.0f km\n' ...
                '  - Tempo até reentrada: %.1f anos\n' ...
                '  - Decaimento total: %.1f km\n' ...
                '  - Taxa média: %.3f km/dia\n' ...
                '  - Período orbital inicial: %.1f minutos'], ...
                Cd_valor, ...
                F107_valor, ...
                Ap_valor, ...
                maior_altitude, ...
                sim_maior.altitude_final, ...
                sim_maior.tempo_simulado_anos, ...
                sim_maior.decaimento_total, ...
                sim_maior.taxa_media_km_dia, ...
                periodo_orbital_min);
        else
            % Campos não existem, usar valores padrão
            resumoDecaimento = sprintf(['RESUMO DO DECAIMENTO ORBITAL:\n\n' ...
                'Altitude Atual: %.0f km\n' ...
                '  - Altitude final: %.0f km\n' ...
                '  - Tempo até reentrada: %.1f anos\n' ...
                '  - Decaimento total: %.1f km\n' ...
                '  - Taxa média: %.3f km/dia'], ...
                maior_altitude, ...
                sim_maior.altitude_final, ...
                sim_maior.tempo_simulado_anos, ...
                sim_maior.decaimento_total, ...
                sim_maior.taxa_media_km_dia);
        end
        
        % Exibir texto
        text(ax4, 0.02, 0.98, resumoDecaimento, ...
            'VerticalAlignment', 'top', ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 9, ...
            'FontName', 'Arial', ...
            'FontWeight', 'normal', ...
            'BackgroundColor', [0.97 0.97 0.97], ...
            'EdgeColor', [0.7 0.7 0.7], ...
            'LineWidth', 1, ...
            'Margin', 5);
    else
        text(ax4, 0.5, 0.5, 'Sem dados de decaimento disponíveis', ...
            'HorizontalAlignment', 'center', ...
            'FontSize', 10, ...
            'FontName', 'Arial', ...
            'FontWeight', 'normal');
    end
    
    % ===== SALVAR FIGURA =====
    try
        filename = sprintf('Dashboard %s.png', nomeSatelite);
        exportgraphics(fig, filename, 'Resolution', 300);
        fprintf('\n Dashboard salvo como: %s\n', filename);
    catch
        saveas(fig, 'Dashboard.png');
    end
    
    fprintf('Dashboard gerado com sucesso!\n');
    
    % ======================================================================
    % FUNÇÃO ANINHADA criarCaixaMetrica3Cores
    % ======================================================================
    function criarCaixaMetrica3Cores(posicao, titulo, valor, valorNumerico)
        % Criar axes
        ax = axes('Position', posicao);
        
        % Cores definidas
        corAzulClaro = [0.85 0.95 1.00];
        corAzulEscuro = [0.00 0.30 0.60];
        corVerdeClaro = [0.85 1.00 0.85];
        corVerdeEscuro = [0.00 0.50 0.00];
        corAmareloClaro = [1.00 1.00 0.85];
        corAmareloEscuro = [0.60 0.60 0.00];
        corVermelhoClaro = [1.00 0.85 0.85];
        corVermelhoEscuro = [0.60 0.00 0.00];
        corCinzaClaro = [0.95 0.95 0.95];
        corCinzaEscuro = [0.30 0.30 0.30];
        
        % Lista de métricas que devem ser sempre azul
        metricasAzul = {'Total Passagens', 'Total Telemetrias', 'Total Pacotes Dados', 'Dados Totais (bytes)'};
        
        % Verificar se é uma métrica que deve ser sempre azul
        if ismember(titulo, metricasAzul)
            corFundo = corAzulClaro;
            corTexto = corAzulEscuro;
            
        % Para valores não numéricos
        elseif ischar(valor) || isstring(valor)
            corFundo = corCinzaClaro;
            corTexto = corCinzaEscuro;
            
        % Determinar cor baseada em limiares específicos
        elseif contains(titulo, 'Passagens Úteis')
            if valorNumerico >= 60
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 40
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Qualidade')
            if valorNumerico >= 60
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 40
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Margem DL')
            if valorNumerico >= 10
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 5
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Elevação')
            if valorNumerico >= 50
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 30
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Revisita')
            if valorNumerico <= 4
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico <= 8
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Alcance')
            if valorNumerico <= 1500
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico <= 2500
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Tempo Útil')
            if valorNumerico >= 5
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 2
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Duração')
            if valorNumerico >= 10
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 5
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Telemetrias') && ~contains(titulo, 'Total')
            if valorNumerico >= 5
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 2
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        elseif contains(titulo, 'Pacotes Dados') && ~contains(titulo, 'Total')
            if valorNumerico >= 2
                corFundo = corVerdeClaro;
                corTexto = corVerdeEscuro;
            elseif valorNumerico >= 1
                corFundo = corAmareloClaro;
                corTexto = corAmareloEscuro;
            else
                corFundo = corVermelhoClaro;
                corTexto = corVermelhoEscuro;
            end
            
        else
            % Métricas não classificadas - padrão azul
            corFundo = corAzulClaro;
            corTexto = corAzulEscuro;
        end
        
        % Configurar caixa
        box(ax, 'on');
        set(ax, 'Color', corFundo);
        set(ax, 'XTick', [], 'YTick', []);
        
        % Adicionar título
        title(ax, titulo, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.4], 'FontSize', 9);
        
        % Adicionar valor
        if ischar(valor) || isstring(valor)
            valorStr = valor;
            fontSize = 14;
        elseif isnumeric(valor) && mod(valor, 1) == 0
            valorStr = sprintf('%d', valor);
            fontSize = 16;
        else
            valorStr = sprintf('%.1f', valor);
            fontSize = 16;
        end
        
        text(ax, 0.5, 0.6, valorStr, ...
            'HorizontalAlignment', 'center', ...
            'FontSize', fontSize, ...
            'FontWeight', 'bold', ...
            'Color', corTexto);
        
        % Borda
        set(ax, 'XColor', [0.4 0.4 0.4], 'YColor', [0.4 0.4 0.4], 'LineWidth', 1);
    end
    
    % ======================================================================
    % FUNÇÃO ANINHADA criarCaixaMetricaCustomizada
    % ======================================================================
    function criarCaixaMetricaCustomizada(posicao, titulo, valor, corFundo, corTexto)
        % Criar axes
        ax = axes('Position', posicao);
        
        % Configurar caixa
        box(ax, 'on');
        set(ax, 'Color', corFundo);
        set(ax, 'XTick', [], 'YTick', []);
        
        % Adicionar título (com quebra de linha)
        titleLines = strsplit(titulo, '\n');
        if length(titleLines) > 1
            title(ax, {titleLines{1}, titleLines{2}}, 'FontWeight', 'bold', ...
                'Color', [0.1 0.1 0.4], 'FontSize', 9);
        else
            title(ax, titulo, 'FontWeight', 'bold', 'Color', [0.1 0.1 0.4], 'FontSize', 9);
        end
        
        % Adicionar valor
        if ischar(valor) || isstring(valor)
            valorStr = valor;
            fontSize = 14;
        elseif isnumeric(valor) && mod(valor, 1) == 0
            valorStr = sprintf('%d', valor);
            fontSize = 16;
        else
            valorStr = sprintf('%.1f', valor);
            fontSize = 16;
        end
        
        text(ax, 0.5, 0.6, valorStr, ...
            'HorizontalAlignment', 'center', ...
            'FontSize', fontSize, ...
            'FontWeight', 'bold', ...
            'Color', corTexto);
        
        % Borda
        set(ax, 'XColor', [0.4 0.4 0.4], 'YColor', [0.4 0.4 0.4], 'LineWidth', 1);
    end
end