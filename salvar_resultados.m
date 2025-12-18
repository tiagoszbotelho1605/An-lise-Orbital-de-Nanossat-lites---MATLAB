function salvar_resultados(nome_base, resultados_simulacoes, nome_satelite, massa, area, Cd, F107, Ap, inclinacao, excentricidade, Re, mu)
% SALVAR_RESULTADOS Salva resultados em diferentes formatos (TXT, CSV, MAT)
%   nome_base: nome base para os arquivos (ex: "NANOSAT")
%   resultados_simulacoes: estrutura com resultados das simulações
%   Demais parâmetros: parâmetros fixos das simulações

    % 1. Criar arquivo TXT com RESUMO GERAL
    nome_arquivo_resumo = sprintf('%s Resumo Geral.txt', nome_base);
    fprintf('\nCriando arquivo TXT de resumo geral: %s\n', nome_arquivo_resumo);

    % Abrir arquivo TXT para escrita
    fid_res = fopen(nome_arquivo_resumo, 'w');

    % Escrever cabeçalho
    fprintf(fid_res, '==============================================================\n');
    fprintf(fid_res, '        RESUMO GERAL DA ANÁLISE DE DECAIMENTO ORBITAL        \n');
    fprintf(fid_res, '==============================================================\n\n');

    % Informações gerais
    fprintf(fid_res, 'INFORMAÇÕES GERAIS:\n');
    fprintf(fid_res, '====================\n');
    fprintf(fid_res, 'Satélite: %s\n', nome_satelite);
    fprintf(fid_res, 'Data da análise: %s\n', datestr(now, 'dd/mm/yyyy HH:MM'));
    fprintf(fid_res, 'Total de simulações: %d\n\n', length(resultados_simulacoes));

    % Parâmetros fixos
    fprintf(fid_res, 'PARÂMETROS FIXOS (aplicados a todas as simulações):\n');
    fprintf(fid_res, '====================================================\n');
    fprintf(fid_res, 'Massa: %.1f kg\n', massa);
    fprintf(fid_res, 'Área de arrasto: %.2f m²\n', area);
    fprintf(fid_res, 'Coeficiente de arrasto (Cd): %.1f\n', Cd);
    fprintf(fid_res, 'Fluxo solar F10.7: %.0f SFU\n', F107);
    fprintf(fid_res, 'Índice geomagnético Ap: %.0f\n', Ap);
    fprintf(fid_res, 'Inclinação: %.2f°\n', inclinacao);
    fprintf(fid_res, 'Excentricidade: %.6f\n\n', excentricidade);

    % Estatísticas gerais
    fprintf(fid_res, 'ESTATÍSTICAS GERAIS:\n');
    fprintf(fid_res, '=====================\n');
    altitudes_iniciais = [resultados_simulacoes.altitude_inicial];
    fprintf(fid_res, 'Altitude mínima inicial: %.0f km\n', min(altitudes_iniciais));
    fprintf(fid_res, 'Altitude máxima inicial: %.0f km\n', max(altitudes_iniciais));
    fprintf(fid_res, 'Altitude média inicial: %.0f km\n', mean(altitudes_iniciais));

    % Calcular estatísticas de decaimento
    decaimentos_totais = [resultados_simulacoes.decaimento_total];
    taxas_medias = [resultados_simulacoes.taxa_media_km_dia];
    fprintf(fid_res, 'Decaimento total médio: %.1f km\n', mean(decaimentos_totais));
    fprintf(fid_res, 'Taxa média de decaimento: %.3f km/dia\n', mean(taxas_medias));

    % Relação área/massa
    relacao_area_massa = area / massa;
    fprintf(fid_res, 'Relação área/massa: %.4f m²/kg\n\n', relacao_area_massa);

    % Resumo por simulação
    fprintf(fid_res, 'DETALHES POR SIMULAÇÃO:\n');
    fprintf(fid_res, '=======================\n');

    for i = 1:length(resultados_simulacoes)
        sim = resultados_simulacoes(i);
        
        fprintf(fid_res, '\n%d. %s\n', i, sim.nome);
        fprintf(fid_res, '   Altitude inicial: %.0f km\n', sim.altitude_inicial);
        fprintf(fid_res, '   Altitude final: %.0f km\n', sim.altitude_final);
        fprintf(fid_res, '   Tempo simulado: %.0f dias (%.1f anos)\n', sim.tempo_simulado_dias, sim.tempo_simulado_anos);
        fprintf(fid_res, '   Decaimento total: %.1f km\n', sim.decaimento_total);
        fprintf(fid_res, '   Taxa média de decaimento: %.3f km/dia\n', sim.taxa_media_km_dia);
        
        % Calcular período orbital inicial
        periodo_inicial_min = (2 * pi * sqrt((sim.altitude_inicial + Re)^3 / mu)) / 60;
        fprintf(fid_res, '   Período orbital inicial: %.2f minutos\n', periodo_inicial_min);
    end

    % Análise do Decaimento
    fprintf(fid_res, '\n\nANÁLISE DO DECAIMENTO:\n');
    fprintf(fid_res, '========================\n');

    % Classificar simulações por altitude
    altitudes_classificadas = sort(altitudes_iniciais);
    baixas = sum(altitudes_classificadas < 400);
    medias = sum(altitudes_classificadas >= 400 & altitudes_classificadas < 600);
    altas = sum(altitudes_classificadas >= 600);

    fprintf(fid_res, 'Distribuição por faixa orbital:\n');
    fprintf(fid_res, '  - LEO Baixa (< 400 km): %d simulações\n', baixas);
    fprintf(fid_res, '  - LEO Média (400-600 km): %d simulações\n', medias);
    fprintf(fid_res, '  - LEO Alta (≥ 600 km): %d simulações\n', altas);

    fprintf(fid_res, '\nANÁLISE GERAL:\n');
    fprintf(fid_res, '  - Decaimento total médio: %.1f km\n', mean(decaimentos_totais));
    fprintf(fid_res, '  - Taxa média de decaimento: %.3f km/dia\n', mean(taxas_medias));
    fprintf(fid_res, '  - Altitude inicial média: %.0f km\n', mean(altitudes_iniciais));

    % Lista de arquivos gerados
    fprintf(fid_res, '\n\nARQUIVOS GERADOS:\n');
    fprintf(fid_res, '================\n');
    fprintf(fid_res, '1. %s Resumo Geral.txt\n', nome_base);
    for i = 1:length(resultados_simulacoes)
        str_alt = formatar_altitude(resultados_simulacoes(i).altitude_inicial);
        fprintf(fid_res, '%d. %s Decaimento Alt. %skm.csv\n', i+1, nome_base, str_alt);
    end
    fprintf(fid_res, '%d. %s Gráfico Comparativo.png\n', length(resultados_simulacoes)+2, nome_base);
    fprintf(fid_res, '%d. %s Decaimento.mat (para dashboard)\n', length(resultados_simulacoes)+3, nome_base);
    fprintf(fid_res, '%d. resultados_decaimento.mat (padrão para dashboard)\n', length(resultados_simulacoes)+4);

    fclose(fid_res);
    fprintf('Arquivo TXT de resumo geral salvo: %s\n', nome_arquivo_resumo);

    % 2. Salvar CSVs com DADOS DE DECAIMENTO
    fprintf('\nCriando arquivos CSV de dados de decaimento...\n');

    for i = 1:length(resultados_simulacoes)
        sim = resultados_simulacoes(i);
        
        if ~isempty(sim.tempo_dias) && length(sim.tempo_dias) > 1
            % Formatar altitude para o nome do arquivo
            str_alt = formatar_altitude(sim.altitude_inicial);
            nome_arquivo_decaimento = sprintf('%s Decaimento Alt. %skm.csv', nome_base, str_alt);
            
            % Preparar dados de decaimento
            dados_decaimento = table();
            
            % Coletar dados de cada ponto no tempo
            for j = 1:length(sim.tempo_dias)
                linha_decaimento = struct();
                linha_decaimento.Tempo_dias = sim.tempo_dias(j);
                linha_decaimento.Altitude_km = sim.altitude_km(j);
                
                % Calcular período orbital em cada ponto
                if j <= length(sim.altitude_km)
                    alt_atual = sim.altitude_km(j);
                    a_atual = alt_atual + Re;
                    periodo_atual = 2 * pi * sqrt(a_atual^3 / mu);  % segundos
                    linha_decaimento.Periodo_min = periodo_atual / 60;
                    linha_decaimento.Movimento_Medio_rev_dia = (24 * 3600) / periodo_atual;
                    
                    % Calcular taxa instantânea de decaimento
                    if j > 1
                        dt = sim.tempo_dias(j) - sim.tempo_dias(j-1);
                        dalt = sim.altitude_km(j-1) - sim.altitude_km(j);
                        if dt > 0
                            linha_decaimento.Taxa_Decaimento_km_dia = dalt / dt;
                        else
                            linha_decaimento.Taxa_Decaimento_km_dia = 0;
                        end
                    else
                        linha_decaimento.Taxa_Decaimento_km_dia = 0;
                    end
                else
                    linha_decaimento.Periodo_min = NaN;
                    linha_decaimento.Movimento_Medio_rev_dia = NaN;
                    linha_decaimento.Taxa_Decaimento_km_dia = NaN;
                end
                
                dados_decaimento = [dados_decaimento; struct2table(linha_decaimento, 'AsArray', true)];
            end
            
            % Escrever dados de decaimento no arquivo CSV
            writetable(dados_decaimento, nome_arquivo_decaimento);
            
            fprintf('Arquivo CSV de decaimento %d salvo: %s (%d pontos)\n', i, nome_arquivo_decaimento, length(sim.tempo_dias));
        end
    end

    % 3. Salvar arquivo MAT para o dashboard
    fprintf('\nSalvando arquivos MAT para o dashboard...\n');
    
    % Adicionar os parâmetros fixos a cada estrutura de simulação para o dashboard
    for i = 1:length(resultados_simulacoes)
        resultados_simulacoes(i).Cd = Cd;
        resultados_simulacoes(i).F107 = F107;
        resultados_simulacoes(i).Ap = Ap;
        resultados_simulacoes(i).massa = massa;
        resultados_simulacoes(i).area = area;
        resultados_simulacoes(i).inclinacao = inclinacao;
        resultados_simulacoes(i).excentricidade = excentricidade;
    end
    
    % Salvar arquivo com nome personalizado
    nome_arquivo_mat_personalizado = sprintf('%s Decaimento.mat', nome_base);
    save(nome_arquivo_mat_personalizado, 'resultados_simulacoes');
    fprintf('Arquivo MAT personalizado salvo: %s\n', nome_arquivo_mat_personalizado);
    
    % Salvar também com o nome padrão esperado pelo dashboard
    save('resultados_decaimento.mat', 'resultados_simulacoes');
    fprintf('Arquivo padrão para dashboard salvo: resultados_decaimento.mat\n');
    
    % 4. Salvar resumo em CSV
    fprintf('\nCriando arquivo CSV de resumo...\n');
    
    % Criar tabela de resumo
    dados_resumo = table();
    
    for i = 1:length(resultados_simulacoes)
        sim = resultados_simulacoes(i);
        
        linha = struct();
        linha.Nome = sim.nome;
        linha.Altitude_Inicial_km = sim.altitude_inicial;
        linha.Altitude_Final_km = sim.altitude_final;
        linha.Tempo_Simulado_dias = sim.tempo_simulado_dias;
        linha.Tempo_Simulado_anos = sim.tempo_simulado_anos;
        linha.Decaimento_Total_km = sim.decaimento_total;
        linha.Taxa_Media_km_dia = sim.taxa_media_km_dia;
        
        % Calcular período orbital inicial
        periodo_inicial = (2 * pi * sqrt((sim.altitude_inicial + Re)^3 / mu)) / 60;
        linha.Periodo_Orbital_Inicial_min = periodo_inicial;
        
        % Adicionar parâmetros físicos
        linha.Cd = Cd;
        linha.F107 = F107;
        linha.Ap = Ap;
        linha.Massa_kg = massa;
        linha.Area_m2 = area;
        
        dados_resumo = [dados_resumo; struct2table(linha, 'AsArray', true)];
    end
    
    % Salvar CSV
    nome_csv_resumo = sprintf('%s Resumo Decaimento.csv', nome_base);
    writetable(dados_resumo, nome_csv_resumo);
    fprintf('Resumo em CSV salvo: %s\n', nome_csv_resumo);
    
    % 5. Criar arquivo de resumo das condições atmosféricas
    fprintf('\nCriando arquivo de condições atmosféricas...\n');
    
    condicoes_atmosfericas = struct(...
        'Satelite', nome_satelite, ...
        'Massa_kg', massa, ...
        'Area_m2', area, ...
        'Cd', Cd, ...
        'F107', F107, ...
        'Ap', Ap, ...
        'Inclinacao_graus', inclinacao, ...
        'Excentricidade', excentricidade, ...
        'Data_Analise', datestr(now, 'dd/mm/yyyy HH:MM'), ...
        'Num_Simulacoes', length(resultados_simulacoes) ...
    );
    
    nome_condicoes = sprintf('%s Condicoes Atmosfericas.txt', nome_base);
    fid_cond = fopen(nome_condicoes, 'w');
    
    fprintf(fid_cond, 'CONDIÇÕES ATMOSFÉRICAS PARA SIMULAÇÃO DE DECAIMENTO\n');
    fprintf(fid_cond, '===================================================\n\n');
    fprintf(fid_cond, 'Satélite: %s\n', condicoes_atmosfericas.Satelite);
    fprintf(fid_cond, 'Data da análise: %s\n', condicoes_atmosfericas.Data_Analise);
    fprintf(fid_cond, 'Número de simulações: %d\n\n', condicoes_atmosfericas.Num_Simulacoes);
    fprintf(fid_cond, 'PARÂMETROS FÍSICOS:\n');
    fprintf(fid_cond, 'Massa: %.1f kg\n', condicoes_atmosfericas.Massa_kg);
    fprintf(fid_cond, 'Área de arrasto: %.2f m²\n', condicoes_atmosfericas.Area_m2);
    fprintf(fid_cond, 'Coeficiente de arrasto (Cd): %.1f\n\n', condicoes_atmosfericas.Cd);
    fprintf(fid_cond, 'PARÂMETROS ATMOSFÉRICOS:\n');
    fprintf(fid_cond, 'Fluxo solar F10.7: %.0f SFU\n', condicoes_atmosfericas.F107);
    fprintf(fid_cond, 'Índice geomagnético Ap: %.0f\n\n', condicoes_atmosfericas.Ap);
    fprintf(fid_cond, 'PARÂMETROS ORBITAIS:\n');
    fprintf(fid_cond, 'Inclinação: %.2f°\n', condicoes_atmosfericas.Inclinacao_graus);
    fprintf(fid_cond, 'Excentricidade: %.6f\n', condicoes_atmosfericas.Excentricidade);
    
    fclose(fid_cond);
    fprintf('Arquivo de condições atmosféricas salvo: %s\n', nome_condicoes);
    
    % 6. Criar arquivo de metadados para referência
    fprintf('\nCriando arquivo de metadados...\n');
    
    metadados = struct();
    metadados.nome_satelite = nome_satelite;
    metadados.nome_base_arquivos = nome_base;
    metadados.data_criacao = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    metadados.numero_simulacoes = length(resultados_simulacoes);
    metadados.altitudes_simuladas = altitudes_iniciais;
    metadados.versao_matlab = version;
    
    nome_metadados = sprintf('%s Metadados.mat', nome_base);
    save(nome_metadados, 'metadados');
    fprintf('Arquivo de metadados salvo: %s\n', nome_metadados);
    
    % 7. Resumo final
    fprintf('\n==============================================\n');
    fprintf('TODOS OS ARQUIVOS SALVOS COM SUCESSO!\n');
    fprintf('==============================================\n');
    fprintf('Arquivos gerados:\n');
    fprintf('1. %s\n', nome_arquivo_resumo);
    fprintf('2. %d arquivos CSV com dados detalhados\n', length(resultados_simulacoes));
    fprintf('3. %s\n', nome_arquivo_mat_personalizado);
    fprintf('4. resultados_decaimento.mat\n');
    fprintf('5. %s\n', nome_csv_resumo);
    fprintf('6. %s\n', nome_condicoes);
    fprintf('7. %s\n', nome_metadados);
    fprintf('\nOs dados de decaimento estão prontos para uso no dashboard!\n');
end

% Função auxiliar para formatar altitude
function str_alt = formatar_altitude(alt)
% FORMATAR_ALTITUDE Formata altitude para usar no nome do arquivo
%   Remove decimais desnecessários
    if round(alt) == alt
        str_alt = sprintf('%d', alt);
    else
        str_alt = sprintf('%.0f', alt); % Arredonda para inteiro
    end
end