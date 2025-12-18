function margem_downlink = calcularLinkBudget(range, frequencia, potenciaTx, ...
                                                  ganhoAntenaTx, ganhoAntenaRx, sensibilidadeRx)
% calcularMargemDownlink - Calcula a margem do link de downlink
%
% Entradas:
%   range - distância em metros
%   frequencia - frequência em Hz
%   potenciaTx - potência de transmissão em dBW
%   ganhoAntenaTx - ganho da antena transmissora (satélite) em dBi
%   ganhoAntenaRx - ganho da antena receptora (estação) em dBi
%   sensibilidadeRx - sensibilidade do receptor em dBm
%
% Saída:
%   margem_downlink - margem do link em dB

    % Constante de Boltzmann
    k = 1.380649e-23; % J/K
    k_dB = 10*log10(k); % -228.6 dBW/Hz/K
    
    % Converter sensibilidade para dBW
    sensibilidadeRx_dBW = sensibilidadeRx - 30; % dBm para dBW
    
    % Cálculo das perdas no espaço livre (Free Space Path Loss)
    c = 3e8;
    lambda = c / frequencia;
    FSPL = (4 * pi * range / lambda)^2;
    FSPL_dB = 10 * log10(FSPL);
    
    % Cálculo da potência recebida
    Prx = potenciaTx + ganhoAntenaTx - FSPL_dB + ganhoAntenaRx; % dBW
    
    % Margem do link
    margem_downlink = Prx - sensibilidadeRx_dBW; % dB
end