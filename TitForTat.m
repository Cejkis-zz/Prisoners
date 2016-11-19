function [ out ] = TitForTat( history )

if size(history,1) ==0
    out = 1;
    return;
end

out = history(end, 2);

end

