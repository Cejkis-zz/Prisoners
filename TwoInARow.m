classdef TwoInARow < Strategy & handle
    %TITFORTA Summary of this class goes here
    %   Pattern: 11001100110011
    
    properties
        id = 0;
    end
    
    methods
        function [ out ] = Action( obj,history, ~ )
            if size(history,1) < 2
                out = 1;
                return;
            end
            
            if history(end, 1) == history(end-1, 1)
                if history(end, 1) == 1
                    out = 0;
                else 
                    out = 1;
                end
            else
                out = history(end, 1);
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
