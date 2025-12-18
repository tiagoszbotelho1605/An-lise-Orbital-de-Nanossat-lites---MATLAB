function ponto = azimuteParaPontoCardeal(azimute)
% azimuteParaPontoCardeal - Converte azimute em ponto cardeal
% 
% Entrada:
%   azimute - ângulo em graus (0-360)
%
% Saída:
%   ponto - string com o ponto cardeal correspondente
pontos = {'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', ...
           'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'};
    
    % Cada setor tem 22.5° (360/16 = 22.5)
    % Deslocamento de 11.25° para centralizar o Norte em 0°
    az = mod(azimute + 11.25, 360);
    
    % Calcula o índice (1-16) usando divisão inteira
    indice = floor(az / 22.5) + 1;
    
    % Caso especial: quando az = 360, indice = 17, deve voltar para 1
    if indice > 16
        indice = 1;
    end
    
    ponto = pontos{indice};
end