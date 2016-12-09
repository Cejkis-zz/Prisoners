classdef WhatWillYouDoHT < Strategy
    %WhatWillYouDo10 Strategy that tries to infer the probability that the
    %opponent will play a defect based on the last 15 rounds (horizon). If this prob is
    %greater than 25% (tresh) then defect.
    
    
    properties
        horizon;
        tresh;
    end
    
    methods
        %Constructor
        function obj = WhatWillYouDoHT(H,T)
            obj.horizon=H;
            obj.tresh=T;
        end
        
        function [ out ] = Action(obj, history, ~ )
            if (length(history)<obj.horizon)
                %Cooperate if the history is not long enough.
                out =1;
                return;
            end
            
            %Calculate the number of defects
            defects=0;
            for n=0:obj.horizon-1
                
                if (history(end-n,2)==0)
                    defects=defects+1;
                end
            end
            
            if (defects/obj.horizon>obj.tresh)
                out =0;
                return
            end
            out =1;
        end
    end
    
end

