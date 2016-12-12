classdef TitForTat < Strategy & handle
    %TITFORTA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
    end
    
    methods
        function [ out ] = Action( obj,history,~ )
            if size(history,1) ==0
                out = 1;
                return;
            end
            
            out = history(end, 2);
        end
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
    end
    
end
