function resultadosDecaimento = carregarDadosDecaimento()
% Carrega dados de decaimento para integração
% Retorna uma estrutura com os resultados de decaimento ou vazia se não houver dados

    resultadosDecaimento = [];
    arquivos_possiveis = {'resultados_decaimento.mat'};
    
    for i = 1:length(arquivos_possiveis)
        arquivo = arquivos_possiveis{i};
        if exist(arquivo, 'file')
            fprintf('Carregando dados de decaimento do arquivo: %s\n', arquivo);
            
            try
                dados = load(arquivo);
                
                % Verificar qual variável contém os resultados
                if isfield(dados, 'resultados_simulacoes')
                    resultadosDecaimento = dados.resultados_simulacoes;
                elseif isfield(dados, 'simulacoes')
                    resultadosDecaimento = dados.simulacoes;
                elseif isfield(dados, 'resultados')
                    resultadosDecaimento = dados.resultados;
                end
                
                if ~isempty(resultadosDecaimento)
                    fprintf('Dados carregados com sucesso! %d simulações encontradas.\n', ...
                        length(resultadosDecaimento));
                    return;
                end
            catch ME
                fprintf('Erro ao carregar arquivo %s: %s\n', arquivo, ME.message);
            end
        end
    end
    
    if isempty(resultadosDecaimento)
        fprintf('Nenhum arquivo de dados de decaimento encontrado.\n');
        fprintf('Execute primeiro o código de decaimento para gerar os dados.\n');
    end
end