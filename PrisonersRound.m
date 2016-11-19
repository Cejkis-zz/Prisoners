function [ utility ] = PrisonersRound( p1, p2 )

if p1 == 0
    if p2 == 0
        utility = [1 1];
    else
        utility = [5 0];
    end
else
    if p2 == 0
        utility = [0 5];
    else
        utility = [3 3];
    end
end

end

