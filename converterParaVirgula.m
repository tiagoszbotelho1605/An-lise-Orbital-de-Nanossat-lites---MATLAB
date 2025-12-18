function str = converterParaVirgula(numero, formato)
% converterParaVirgula - Converte número para string com vírgula como separador decimal
%
% Entradas:
%   numero - número a ser convertido
%   formato - string de formatação (ex: '%.1f', '%.2f')
%
% Saída:
%   str - string formatada com vírgula

    if nargin < 2
        formato = '%.1f';
    end
    str = strrep(sprintf(formato, numero), '.', ',');
end
