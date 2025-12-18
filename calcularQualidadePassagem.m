function [qualidade, classificacao] = calcularQualidadePassagem(...
    tempoUtilComunicacao, elevacaoMediaUtil, rangeMedioUtil, i, maxElevations, elevacaoMinimaOperacional)
% calcularQualidadePassagem - Calcula a qualidade da passagem (0-100) e classificação
% USANDO CRITÉRIOS ABSOLUTOS independentes do conjunto de passagens
%
% Fatores: tempo útil 50%, elevação média 30%, alcance médio 20%
% Todos os cálculos usam valores de referência fixos (não relativos)

    % Verificar se há comunicação possível
    if maxElevations(i) >= elevacaoMinimaOperacional && tempoUtilComunicacao(i) > 0
        
        % ================================================
        % 1. TEMPO ÚTIL (0-50 pontos)
        % ================================================
        tempo_minutos = tempoUtilComunicacao(i) / 60;
        
        % Curva de pontos: mais pontos para tempos maiores, com saturação
        % Base: 10 minutos = 50 pontos, 2 minutos = 20 pontos, 0 minutos = 0 pontos
        if tempo_minutos <= 0
            pontuacao_tempo = 0;
        elseif tempo_minutos <= 2
            % Linear de 0-2 minutos: 0-20 pontos
            pontuacao_tempo = (tempo_minutos / 2) * 20;
        elseif tempo_minutos <= 5
            % Linear de 2-5 minutos: 20-50 pontos
            pontuacao_tempo = 20 + ((tempo_minutos - 2) / 3) * 30;
        else
            % Acima de 10 minutos: 50 pontos (máximo)
            pontuacao_tempo = 50;
        end
        
        % ================================================
        % 2. ELEVAÇÃO MÉDIA (0-30 pontos)
        % ================================================
        % Base: 90° = 30 pontos, 30° = 10 pontos, 0° = 0 pontos
        elevacao = elevacaoMediaUtil(i);
        
        if elevacao <= 0
            pontuacao_elevacao = 0;
        elseif elevacao <= 30
            % Linear de 0-30°: 0-10 pontos
            pontuacao_elevacao = (elevacao / 30) * 10;
        elseif elevacao <= 90
            % Linear de 30-90°: 10-30 pontos
            pontuacao_elevacao = 10 + ((elevacao - 30) / 60) * 20;
        else
            % Acima de 90°: 30 pontos (máximo)
            pontuacao_elevacao = 30;
        end
        
        % ================================================
        % 3. ALCANCE MÉDIO (0-20 pontos)
        % ================================================
        % BASEADO NA FÍSICA DA ÓRBITA
        % Para órbita LEO típica (500 km altitude):
        % - Alcance mínimo teórico: 500 km (zênite) = 20 pontos
        % - Alcance máximo teórico: ~2600 km (horizonte) = 0 pontos
        alcance_km = rangeMedioUtil(i) / 1000;
        
        % Valores de referência teóricos
        alcance_min_teorico = 500;      % Satélite no zênite (melhor caso)
        alcance_max_teorico = 1500;     % Satélite no horizonte (pior caso)
        
        if alcance_km <= alcance_min_teorico
            pontuacao_alcance = 20;
        elseif alcance_km >= alcance_max_teorico
            pontuacao_alcance = 0;
        else
            % FUNÇÃO NÃO-LINEAR: penalidade quadrática (lei do inverso do quadrado)
            % Quanto maior o alcance, maior a penalidade
            fator = (alcance_km - alcance_min_teorico) / ...
                    (alcance_max_teorico - alcance_min_teorico);
            
            % Penalidade quadrática: piora rapidamente com alcance maior
            pontuacao_alcance = (1 - fator^2) * 20;
            
            % Garantir que não fique negativo
            pontuacao_alcance = max(0, pontuacao_alcance);
        end
        
        % ================================================
        % 4. QUALIDADE TOTAL
        % ================================================
        qualidade = pontuacao_tempo + pontuacao_elevacao + pontuacao_alcance;
        
        % Ajuste final para garantir 0-100
        qualidade = max(0, min(100, qualidade));
        
        % Classificação da passagem
        if qualidade >= 80 
            classificacao = 'OTIMA';
        elseif qualidade >= 70 
            classificacao = 'MUITO BOA';
        elseif qualidade >= 60 
            classificacao = 'BOA';
        elseif qualidade >= 40 
            classificacao = 'REGULAR';
        elseif qualidade >= 30 
            classificacao = 'FRACA';
        else
            classificacao = 'MUITO FRACA';
        end
        
    else
        qualidade = 0;
        classificacao = 'SEM COMUN.';
    end
end