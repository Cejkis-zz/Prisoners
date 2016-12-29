classdef InitStrategy < Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        counter = 1;
        init_strategy = TitForTat();
    end
    
    methods
        function out = Action(obj, history, ~)
            p = rand;
            if p > 1.0
                out = obj.init_strategy.Action(history);
            elseif p > 0.5
                out = 1.0;
            else
                out = 0.0;
            end
        end
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
    end
    
end

