1. Sistema de Análise Orbital e de Comunicação de Satélites
Sistema integrado em MATLAB para análise de decaimento orbital e comunicação de satélites LEO (Low Earth Orbit). O sistema permite simular a degradação orbital ao longo do tempo e avaliar a qualidade das passagens para comunicação com uma estação terrestre.

2. Estrutura de Arquivos
Principais Scripts de Execução
Arquivo	Descrição
analise_integrada.m	Script principal que orquestra a análise completa
analise_dec.m	Análise de decaimento orbital
analise_pc.m	Análise de passagens e comunicação
Funções de Suporte
Arquivo	Descrição
converterParaVirgula.m	Converte números para formato brasileiro (vírgula decimal)
converterArrayParaVirgula.m	Converte arrays numéricos para células com formato brasileiro
azimuteParaPontoCardeal.m	Converte azimute em graus para pontos cardeais
calcularGanhoAntena.m	Calcula ganho de antena parabólica
calcularLinkBudget.m	Calcula margem do link de downlink
calcularMetricasComunicacao.m	Calcula métricas de comunicação (downlink)
calcularQualidadePassagem.m	Avalia qualidade das passagens (0-100 pontos)
computeOrbitalDecay.m	Calcula decaimento orbital usando modelo atmosférico
executar_simulacoes.m	Executa múltiplas simulações de decaimento
gerarDashboard.m	Gera dashboard visual com todas as métricas
salvarResultados.m	Salva resultados em arquivos CSV
salvar_resultados.m	Salva resultados de decaimento em múltiplos formatos
carregarDadosDecaimento.m	Carrega dados de decaimento para integração

3. Pré-requisitos
MATLAB R2020b ou superior
Toolboxes necessárias:
Aerospace Toolbox
Satellite Communications Toolbox
Arquivo TLE: satellite.tle com dados do satélite

4. Como Usar
4.1. Preparação dos Dados
Coloque o arquivo TLE do satélite na pasta do projeto com o nome satellite.tle
Certifique-se de que todas as funções estão no path do MATLAB

4.2. Execução Completa
Execute o script principal:
matlab
analise_integrada

O script irá:
Perguntar se deseja executar análise de decaimento orbital
Perguntar se deseja executar análise de comunicação
Integrar os resultados e gerar um dashboard

4.3. Execução Individual
Análise de Decaimento Orbital:
matlab
analise_dec

Análise de Comunicação:
matlab
analise_pc

5. Configuração dos Parâmetros
Parâmetros de Satélite (solicitados durante execução):
Massa (kg)
Área de arrasto (m²)
Coeficiente de arrasto (Cd)
Condições Atmosféricas:
Fluxo Solar F10.7 (SFU)
Índice geomagnético Ap
Parâmetros de Comunicação (configurados em analise_pc.m):
Frequência: 468.5 MHz
Potência TX: 20 dBm
Sensibilidade RX: -126.5 dBm
Taxa de dados: 3.5156 kbps
Elevação mínima operacional: 30°

6. Análises Realizadas
6.1. Análise de Decaimento Orbital
Simulação do decaimento orbital usando modelo atmosférico simplificado
Cálculo do tempo até reentrada (180 km de altitude)
Taxa média de decaimento (km/dia)
Suporte a simulação única ou múltipla para comparação

6.2. Análise de Passagens e Comunicação
Detecção de passagens sobre a estação terrestre (UFMA)
Cálculo de métricas de comunicação:
Tempo útil (>30° de elevação)
Elevação média e alcance médio
Margem do link de downlink
Telemetrias e pacotes de dados transmitidos
Classificação da qualidade das passagens (0-100 pontos)
Cálculo de tempos de revisita

6.3. Sistema de Classificação
As passagens são classificadas em:
ÓTIMA (≥80 pontos)
MUITO BOA (70-79 pontos)
BOA (60-69 pontos)
REGULAR (40-59 pontos)
FRACA (30-39 pontos)
MUITO FRACA (<30 pontos)
SEM COMUN. (sem comunicação possível)

7. Saídas Geradas
Arquivos CSV:
Analise Passagens.csv - Dados detalhados de cada passagem
Analise Comunicacao.csv - Métricas de comunicação por passagem
Lista Revisitas.csv - Tempos entre passagens consecutivas
Estatisticas Revisitas.csv - Estatísticas de revisita
Arquivos de Resultados (Decaimento):
[SATÉLITE] Resumo Geral.txt - Resumo completo das simulações
[SATÉLITE] Decaimento Alt. [X]km.csv - Dados detalhados de decaimento por altitude
resultados_decaimento.mat - Dados em formato MAT para o dashboard
Dashboard:
Dashboard [SATÉLITE].png - Dashboard visual com 15 métricas e 4 gráficos

8. Dashboard
O dashboard gerado inclui:
15 Métricas Principais:
Total de passagens
Total de telemetrias
Total de pacotes de dados
Dados totais transmitidos
Percentual de passagens úteis
Qualidade média
Margem downlink média
Elevação média
Tempo de revisita médio
Tempo útil médio
Alcance médio
Telemetrias por passagem
Pacotes de dados por passagem
Duração média total
Tempo até reentrada (da maior altitude)

4 Gráficos:
Distribuição das classificações
Top 3 melhores passagens
Resumo textual da comunicação
Resumo do decaimento orbital

📄 Licença
Este projeto foi desenvolvido para fins acadêmicos e de pesquisa. Consulte os autores para uso comercial.

👥 Autores
Sistema desenvolvido para análise de missões de satélites LEO.

