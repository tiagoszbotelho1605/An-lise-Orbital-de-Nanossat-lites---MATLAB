% ====================================================
% ANÁLISE DE DECAIMENTO ORBITAL
% ====================================================

disp('=== ANÁLISE DE DECAIMENTO ORBITAL ===');
%% 1. CARREGAR TLE DO SATÉLITE
fprintf('\n--- CARREGANDO DADOS DO SATÉLITE ---\n');

% Ler arquivo TLE
tle_filename = 'satellite.tle';
if ~exist(tle_filename, 'file')
    error('Arquivo TLE não encontrado: %s\nCrie um arquivo "satellite.tle" com dados do satélite.', tle_filename);
end

% Ler linhas do TLE
fid = fopen(tle_filename, 'r');
tle_lines = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
tle_lines = tle_lines{1};

if length(tle_lines) < 3
    error('Arquivo TLE deve ter pelo menos 3 linhas: nome + linha1 + linha2');
end

% Extrair nome do satélite
nome_satelite = strtrim(tle_lines{1});
fprintf('Satélite: %s\n', nome_satelite);

% Extrair parâmetros orbitais da linha 2 do TLE
tle_line2 = tle_lines{3};  % Segunda linha do TLE

% Parse do TLE (valores nas posições fixas)
num_epoch = tle_line2(19:32);          % Época (ano + dia fracionário)
inclinacao = str2double(tle_line2(9:16));   % Inclinação (graus)
raan = str2double(tle_line2(18:25));        % RAAN (graus)
excentricidade_str = tle_line2(27:33);      % Excentricidade (formato .XXXXXXX)
excentricidade = str2double(['0.' strrep(excentricidade_str, ' ', '0')]);
arg_perigeu = str2double(tle_line2(35:42)); % Argumento do perigeu (graus)
anomalia_media = str2double(tle_line2(44:51)); % Anomalia média (graus)
movimento_medio = str2double(tle_line2(53:63)); % Movimento médio (rev/dia)
revolucoes = str2double(tle_line2(64:68));  % Número de revoluções na época

fprintf('Movimento médio inicial: %.4f rev/dia\n', movimento_medio);

%% 2. PARÂMETROS FÍSICOS DO SATÉLITE
fprintf('\n--- PARÂMETROS FÍSICOS DO SATÉLITE ---\n');

% Solicitar parâmetros do usuário
massa = input('Massa do satélite (kg): ');
while isempty(massa)
    massa = input('Por favor, insira a massa do satélite (kg): ');
end

area = input('Área de arrasto efetiva (m²): ');
while isempty(area)
    area = input('Por favor, insira a área de arrasto (m²): ');
end

Cd = input('Coeficiente de arrasto (Cd) [padrão: 2.2]: ');
if isempty(Cd)
    Cd = 2.2;
end

fprintf('\nParâmetros definidos:\n');
fprintf('Massa: %.1f kg\n', massa);
fprintf('Área de arrasto: %.2f m²\n', area);
fprintf('Coeficiente de arrasto (Cd): %.1f\n', Cd);

%% 3. CONDIÇÕES ATMOSFÉRICAS
fprintf('\n--- CONDIÇÕES ATMOSFÉRICAS ---\n');

fprintf('\nValores típicos:\n');
fprintf('Fluxo Solar F10.7:\n');
fprintf('  - Mínimo solar: 70-80 SFU\n');
fprintf('  - Médio: 120-150 SFU\n');
fprintf('  - Máximo solar: 200-250 SFU\n');

fprintf('\nÍndice geomagnético Ap:\n');
fprintf('  - Calmo: 0-15\n');
fprintf('  - Moderado: 15-30\n');
fprintf('  - Tempestuoso: 30-100+\n');

F107 = input('\nFluxo Solar F10.7 (SFU): ');
if isempty(F107)
    F107 = 150;
end

Ap = input('Índice geomagnético Ap: ');
if isempty(Ap)
    Ap = 15;
end

fprintf('\nCondições atmosféricas definidas:\n');
fprintf('F10.7: %.0f SFU\n', F107);
fprintf('Ap: %.0f\n', Ap);

%% 4. ESCOLHER MODO DE SIMULAÇÃO
fprintf('\n=== MODO DE SIMULAÇÃO ===\n');

% Constantes
Re = 6378.137;           % Raio da Terra (km)
mu = 398600.4418;        % Parâmetro gravitacional da Terra (km³/s²)

% Calcular altitude inicial do TLE
periodo_tle = (24 * 3600) / movimento_medio;
semi_eixo_tle = (mu * (periodo_tle/(2*pi))^2)^(1/3);
altitude_tle = semi_eixo_tle - Re;

fprintf('\nAltitude calculada do TLE: %.1f km\n', altitude_tle);

% Opções para o usuário
fprintf('\nEscolha o modo de simulação:\n');
fprintf('1. Simulação única (apenas uma altitude)\n');
fprintf('2. Simulação múltipla (comparação entre várias altitudes)\n');

modo = input('\nEscolha o modo (1 ou 2): ');

while ~ismember(modo, [1, 2])
    fprintf('Opção inválida. Escolha 1 ou 2.\n');
    modo = input('Escolha o modo (1 ou 2): ');
end

%% 5. COLETAR ALTITUDES DE ACORDO COM O MODO ESCOLHIDO
altitudes_km = [];
nomes_simulacoes = {};

if modo == 1
    % ================================================
    % MODO 1: SIMULAÇÃO ÚNICA
    % ================================================
    fprintf('\n=== MODO: SIMULAÇÃO ÚNICA ===\n');
    
    fprintf('\nOpções de altitude:\n');
    fprintf('1. Usar altitude do TLE (%.1f km)\n', altitude_tle);
    fprintf('2. Definir uma altitude manualmente\n');
    
    opcao = input('\nEscolha a opção (1 ou 2): ');
    
    while ~ismember(opcao, [1, 2])
        fprintf('Opção inválida. Escolha 1 ou 2.\n');
        opcao = input('Escolha a opção (1 ou 2): ');
    end
    
    if opcao == 1
        altitude_escolhida = altitude_tle;
        nome_simulacao = sprintf('TLE (%.0f km)', altitude_tle);
        fprintf('\nUsando altitude do TLE: %.1f km\n', altitude_tle);
    else
        altitude_escolhida = input('\nDigite a altitude para simulação (km): ');
        while isempty(altitude_escolhida) || altitude_escolhida < 0
            if isempty(altitude_escolhida)
                altitude_escolhida = input('Altitude não pode ser vazia. Digite a altitude (km): ');
            else
                altitude_escolhida = input('Altitude inválida. Digite uma altitude positiva (km): ');
            end
        end
        nome_simulacao = sprintf('Alt %.0f km', altitude_escolhida);
        fprintf('\nAltitude escolhida: %.1f km\n', altitude_escolhida);
    end
    
    % Adicionar à lista (apenas uma altitude)
    altitudes_km = altitude_escolhida;
    nomes_simulacoes = {nome_simulacao};
    
    num_simulacoes = 1;
    
else
    % ================================================
    % MODO 2: SIMULAÇÃO MÚLTIPLA
    % ================================================
    fprintf('\n=== MODO: SIMULAÇÃO MÚLTIPLA ===\n');
    
    fprintf('\nTipos de órbita para referência:\n');
    fprintf(' - LEO Baixo: 200-400 km\n');
    fprintf(' - LEO Médio: 400-600 km\n');
    fprintf(' - LEO Alto: 600-1000 km\n');
    fprintf(' - Órbita de reentrada: < 200 km\n');
    fprintf(' - Órbita muito estável: > 1000 km\n');
    
    % Inicializar lista de altitudes
    altitudes_km = [];
    
    % Perguntar se deseja incluir a altitude do TLE
    incluir_tle = input('\nDeseja incluir a altitude do TLE na análise comparativa? (s/n) [s]: ', 's');
    if isempty(incluir_tle) || strcmpi(incluir_tle, 's')
        altitudes_km = [altitudes_km, altitude_tle];
        nomes_simulacoes{end+1} = sprintf('TLE (%.0f km)', altitude_tle);
        fprintf('Altitude do TLE incluída: %.1f km\n', altitude_tle);
    end
    
    % Loop para adicionar múltiplas altitudes
    adicionar_mais = 's';
    contador_simulacoes = length(altitudes_km) + 1;
    
    fprintf('\n=== ADICIONAR ALTITUDES PARA COMPARAÇÃO ===\n');
    
    while strcmpi(adicionar_mais, 's') || strcmpi(adicionar_mais, 'sim')
        fprintf('\n--- Simulação %d ---\n', contador_simulacoes);
        
        nova_altitude = input('Digite a altitude para simulação (km): ');
        
        % Validar entrada
        while isempty(nova_altitude) || nova_altitude < 0
            if isempty(nova_altitude)
                nova_altitude = input('Altitude não pode ser vazia. Digite a altitude (km): ');
            else
                nova_altitude = input('Altitude inválida. Digite uma altitude positiva (km): ');
            end
        end
        
        % Adicionar à lista
        altitudes_km = [altitudes_km, nova_altitude];
        nomes_simulacoes{end+1} = sprintf('Alt %.0f km', nova_altitude);
        
        fprintf('Altitude adicionada: %.1f km\n', nova_altitude);
        
        % Perguntar se deseja adicionar mais
        contador_simulacoes = contador_simulacoes + 1;
        adicionar_mais = input('\nDeseja adicionar outra altitude para comparação? (s/n): ', 's');
    end
    
    num_simulacoes = length(altitudes_km);
end

% Verificar se temos altitudes para simular
if isempty(altitudes_km)
    fprintf('Nenhuma altitude selecionada para simulação. Encerrando...\n');
    return;
end

fprintf('\n=== RESUMO DAS SIMULAÇÕES CONFIGURADAS ===\n');
fprintf('Total de simulações: %d\n', num_simulacoes);
for i = 1:num_simulacoes
    fprintf('%d. %s (%.1f km)\n', i, nomes_simulacoes{i}, altitudes_km(i));
end

%% 6. EXECUTAR SIMULAÇÕES
fprintf('\n=== EXECUTANDO SIMULAÇÕES ===\n');
resultados_simulacoes = executar_simulacoes(altitudes_km, nomes_simulacoes, Re, mu, excentricidade, area, Cd, massa, F107, Ap);

% Verificar se temos resultados
if isempty(resultados_simulacoes)
    fprintf('\nNenhuma simulação foi concluída com sucesso. Encerrando...\n');
    return;
end

%% 7. EXIBIR RESUMO NO CONSOLE
fprintf('\n=== RESUMO DAS SIMULAÇÕES ===\n');

fprintf('\nParâmetros fixos para todas as simulações:\n');
fprintf('Satélite: %s\n', nome_satelite);
fprintf('Massa: %.1f kg\n', massa);
fprintf('Área: %.2f m²\n', area);
fprintf('Cd: %.1f\n', Cd);
fprintf('F10.7: %.0f SFU\n', F107);
fprintf('Ap: %.0f\n', Ap);
fprintf('Inclinação: %.2f°\n', inclinacao);
fprintf('Excentricidade: %.6f\n', excentricidade);

fprintf('\nResultados das simulações:\n');
for i = 1:length(resultados_simulacoes)
    sim = resultados_simulacoes(i);
    fprintf('\nSimulação %d: %s\n', i, sim.nome);
    fprintf('  Altitude inicial: %.1f km\n', sim.altitude_inicial);
    fprintf('  Altitude final: %.1f km\n', sim.altitude_final);
    fprintf('  Tempo simulado: %.0f dias (%.1f anos)\n', sim.tempo_simulado_dias, sim.tempo_simulado_anos);
    fprintf('  Decaimento total: %.1f km\n', sim.decaimento_total);
    fprintf('  Taxa média: %.3f km/dia\n', sim.taxa_media_km_dia);
    
    % Calcular período orbital inicial
    periodo_inicial_min = (2 * pi * sqrt((sim.altitude_inicial + Re)^3 / mu)) / 60;
    fprintf('  Período orbital inicial: %.2f minutos\n', periodo_inicial_min);
end

%% 8. SALVAR RESULTADOS
fprintf('\n=== SALVANDO RESULTADOS ===\n');

% Criar nome base para arquivos (remover caracteres especiais)
nome_base = regexprep(nome_satelite, '[^a-zA-Z0-9]', ' ');
nome_base = strtrim(nome_base);
if isempty(nome_base)
    nome_base = 'Satelite';
end

% Chamar a função de salvamento completo
salvar_resultados(nome_base, resultados_simulacoes, nome_satelite, massa, area, Cd, F107, Ap, inclinacao, excentricidade, Re, mu)

fprintf('\n==============================================\n');
fprintf('ANÁLISE DE DECAIMENTO CONCLUÍDA COM SUCESSO!\n');
fprintf('==============================================\n');