function ganho = calcularGanhoAntena(diametro, frequencia)
    % Calcula o ganho de uma antena parabólica
    
    c = 3e8; % Velocidade da luz (m/s)
    lambda = c / frequencia;
    eficiencia = 0.55; % Eficiência típica para antenas parabólicas
    
    % Fórmula do ganho para antena parabólica
    ganho_linear = eficiencia * (pi * diametro / lambda)^2;
    ganho = 10 * log10(ganho_linear); % Converter para dB
end