classdef Forgiving < Strategy & handle
    %Forgiving. Forgives one mistake of the opponent if the strategy also
    %has made a previous mistake.
    
    properties
        id = 0;
        mistOk = 0;
    end
    
    methods
        function [ out ] = Action( obj,history,~ )
            if size(history,1) == 0
                out = 1;
                return;
            else 
                if (history(end, 1) == 0)
                    obj.mistOk = 1;
                end
                
                if history(end,2)
                    out = 1;
                else
                    if obj.mistOk
                        obj.mistOk = 0;
                        out = 1;
                    else
                        out = 0;
                    end
                end
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
