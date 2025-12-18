clear all
close all
clc

% ================================================
% 1. EXECUTAR ANÁLISE DE DECAIMENTO
% ================================================
fprintf('=== ETAPA 1: ANÁLISE DE DECAIMENTO ORBITAL ===\n');
executarDecaimento = input('Deseja executar a análise de decaimento orbital? (s/n): ', 's');

resultadosDecaimento = [];
if strcmpi(executarDecaimento, 's') || strcmpi(executarDecaimento, 'sim')
    try
        fprintf('\nExecutando análise de decaimento...\n');
        analise_dec;  % Executa o script de decaimento
        
        % Aguardar um momento para garantir que o arquivo seja salvo
        pause(2);
        
        % TENTAR CARREGAR OS DADOS DE DECAIMENTO DIRETAMENTE
        fprintf('Tentando carregar dados de decaimento...\n');
        try
            % Tenta carregar o arquivo diretamente
            if exist('resultados_decaimento.mat', 'file')
                load('resultados_decaimento.mat');
                fprintf('Arquivo resultados_decaimento.mat encontrado.\n');
                
                % Verificar qual variável foi carregada
                vars = who('-file', 'resultados_decaimento.mat');
                fprintf('Variáveis no arquivo: %s\n', strjoin(vars, ', '));
                
                if ismember('resultados_simulacoes', vars)
                    resultadosDecaimento = resultados_simulacoes;
                    fprintf('Dados de decaimento carregados (resultados_simulacoes).\n');
                elseif ismember('resultadosDecaimento', vars)
                    % Já carregado como resultadosDecaimento
                    fprintf('Dados de decaimento carregados (resultadosDecaimento).\n');
                elseif ismember('simulacoes', vars)
                    resultadosDecaimento = simulacoes;
                    fprintf('Dados de decaimento carregados (simulacoes).\n');
                end
            else
                fprintf('Arquivo resultados_decaimento.mat não encontrado.\n');
            end
        catch ME
            fprintf('Erro ao carregar resultados_decaimento.mat: %s\n', ME.message);
        end
        
        % Se ainda estiver vazio, tentar a função carregarDadosDecaimento
        if isempty(resultadosDecaimento)
            resultadosDecaimento = carregarDadosDecaimento();
        end
        
        if ~isempty(resultadosDecaimento)
            fprintf('Dados de decaimento carregados com sucesso! %d simulações encontradas.\n', ...
                length(resultadosDecaimento));
        else
            fprintf('ATENÇÃO: Nenhum dado de decaimento carregado.\n');
            fprintf('Verifique se o arquivo resultados_decaimento.mat foi criado.\n');
        end
    catch ME
        fprintf('Erro na execução do decaimento: %s\n', ME.message);
        fprintf('Continuando sem dados de decaimento...\n');
    end
else
    fprintf('Pulando análise de decaimento...\n');
    % Tentar carregar resultados de decaimento existentes
    fprintf('Tentando carregar dados de decaimento existentes...\n');
    resultadosDecaimento = carregarDadosDecaimento();
    if ~isempty(resultadosDecaimento)
        fprintf('Dados de decaimento existentes carregados: %d simulações.\n', length(resultadosDecaimento));
    else
        fprintf('Nenhum dado de decaimento encontrado.\n');
    end
end

% ================================================
% 2. EXECUTAR ANÁLISE DE COMUNICAÇÃO
% ================================================
fprintf('\n=== ETAPA 2: ANÁLISE DE COMUNICAÇÃO ===\n');
executarComunicacao = input('Deseja executar a análise de comunicação? (s/n): ', 's');

if strcmpi(executarComunicacao, 's') || strcmpi(executarComunicacao, 'sim')
    try
        fprintf('\nExecutando análise de comunicação...\n');
        
        % VERIFICAR SE TEMOS DADOS DE DECAIMENTO ANTES DE LIMPAR
        temDadosDecaimento = ~isempty(resultadosDecaimento);
        if temDadosDecaimento
            fprintf('Salvando dados de decaimento temporariamente...\n');
            save('temp_decaimento.mat', 'resultadosDecaimento');
        end
        
        % Executar análise de comunicação (isso limpa o workspace)
        analise_pc;  % Executa o script de comunicação
        
        % CARREGAR DADOS DE DECAIMENTO APÓS A COMUNICAÇÃO
        if temDadosDecaimento && exist('temp_decaimento.mat', 'file')
            fprintf('Recuperando dados de decaimento...\n');
            load('temp_decaimento.mat');
            delete('temp_decaimento.mat');
        else
            % Tentar carregar do arquivo padrão
            try
                load('resultados_decaimento.mat', 'resultadosDecaimento');
                fprintf('Dados de decaimento carregados do arquivo.\n');
            catch
                fprintf('Nenhum dado de decaimento encontrado após comunicação.\n');
                resultadosDecaimento = [];
            end
        end
        
        % ================================================
        % 3. GERAR DASHBOARD INTEGRADO
        % ================================================
        fprintf('\n=== GERANDO DASHBOARD INTEGRADO ===\n');
        
        % Verificar se as variáveis necessárias existem no workspace
        if exist('nomeSatelite', 'var') && exist('qualidadePassagem', 'var')
            
            % Se não temos dados de decaimento, tentar carregar
            if isempty(resultadosDecaimento)
                fprintf('Tentando carregar dados de decaimento...\n');
                try
                    load('resultados_decaimento.mat');
                    if exist('resultados_simulacoes', 'var')
                        resultadosDecaimento = resultados_simulacoes;
                    end
                catch
                    fprintf('Não foi possível carregar dados de decaimento.\n');
                end
            end
            
            % Chamar o dashboard com todos os parâmetros
            try
                gerarDashboard(nomeSatelite, qualidadePassagem, durations, tempoUtilComunicacao, maxElevations, ...
                    elevacaoMediaUtil, azStart, azMaxEl, azEnd, rangeMedioUtil, dadosTransmitidosBytes, ...
                    classificacaoPassagem, revisitTimes, numPassagens, passagensComComunicacao, ...
                    elevacaoMinimaOperacional, margemEbNoDownlink, numTelemetrias, ...
                    startDateStr, startTimeStr, numPacotesDados, resultadosDecaimento);
                
                fprintf('Dashboard integrado gerado com sucesso!\n');
            catch ME
                fprintf('Erro ao gerar dashboard integrado: %s\n', ME.message);
                fprintf('Gerando dashboard padrão...\n');
                
                % Fallback para o dashboard original
                gerarDashboard(nomeSatelite, qualidadePassagem, durations, tempoUtilComunicacao, maxElevations, ...
                    elevacaoMediaUtil, azStart, azMaxEl, azEnd, rangeMedioUtil, dadosTransmitidosBytes, ...
                    classificacaoPassagem, revisitTimes, numPassagens, passagensComComunicacao, ...
                    elevacaoMinimaOperacional, margemEbNoDownlink, numTelemetrias, ...
                    startDateStr, startTimeStr, numPacotesDados);
            end
        else
            fprintf('Variáveis de comunicação não encontradas. Dashboard não gerado.\n');
            fprintf('Execute primeiro o "analise_pc.m" para gerar os dados.\n');
        end
        
    catch ME
        fprintf('Erro na execução da comunicação: %s\n', ME.message);
    end
else
    fprintf('Pulando análise de comunicação...\n');
end

fprintf('\n==============================================\n');
fprintf('   ANÁLISE INTEGRADA CONCLUÍDA\n');
fprintf('==============================================\n');