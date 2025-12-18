function str_celula = converterArrayParaVirgula(array, formato)
% converterArrayParaVirgula - Converte array numérico para cell array com vírgula
%
% Entradas:
%   array - array numérico
%   formato - string de formatação
%
% Saída:
%   str_celula - cell array com strings formatadas

    if nargin < 2
        formato = '%.1f';
    end
    str_celula = cell(length(array), 1);
    for i = 1:length(array)
        str_celula{i} = converterParaVirgula(array(i), formato);
    end
end