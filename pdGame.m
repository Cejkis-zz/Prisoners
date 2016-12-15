function [ utilities,history ] = pdGame(a1,a2,gameRounds,mistakeProb)
%pdGame Playes the iterated prisoners dilemma game for a specified number
%of rounds and returns the utility for each agent for each round.
%   Parameters:
%   a1---Agent1 child of strategy class.
%   a2---Agent2 child of strategy class.
%   gameRounds---The number of rounds to play the game for.
%   mistakeProb---The probability of making a mistake during a move in the
%   game ie 0.02

history = zeros(gameRounds,2);
utilities = zeros(gameRounds,2);

for r = 1: gameRounds
    
    % get the id of each player.
    a1id = a1.get_id();
    a2id = a2.get_id();
    % get the move of each player.
    p1 = a1.Action(history(1:r-1,:), a2id);
    %Change columns of the history for the opponent.
    p2 = a2.Action([history(1:r-1,2),history(1:r-1,1)],a1id);
    
    %A mistake might occur. This causes choice to "flip".
    if(rand<mistakeProb)
        p1=~p1;
    end
    if(rand<mistakeProb)
        p2=~p2;
    end
    
    %Update history matrix.
    history(r,:) = [p1 p2];
    
    %Compute utilities for both players.
    utilities(r,:) = PrisonersRound(p1, p2);
end

end

