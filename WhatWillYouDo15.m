function [ out ] = WhatWillYouDo15( history )
%WhatWillYouDo10 Strategy that tries to infer the probability that the
%opponent will play a defect based on the last 15 rounds (horizon). If this prob is
%greater than 25% (tresh) then defect.

horizon=15;
tresh=0.25;

if (length(history)<horizon)
    %Cooperate if the history is not long enough.
    out =1;
    return;
end

%Calculate the number of defects
defects=0;
for n=0:horizon-1
    
    if (history(end-n,2)==0)
        defects=defects+1;
    end
end

if (defects/horizon>tresh)
    out =0;
    return
end
out =1;


end

