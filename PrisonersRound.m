function [ utility ] = PrisonersRound( p1, p2 )
%PrisonersRound Function for determining the score of each strategy based
%on what they played.
%   The function returns the payoffs for each agent based on their move. 

if p1 == 0
    if p2 == 0
        %Both defect.
        utility = [1 1];
    else
        %Player1 defect but played 2 cooperated.
        utility = [5 0];
    end
else
    if p2 == 0
        %Player2 defect but played1 cooperated.
        utility = [0 5];
    else
        %Both cooperated.
        utility = [3 3];
    end
end

end

