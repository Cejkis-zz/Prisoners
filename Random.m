classdef Random < Strategy & handle
    %RANDOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
    end
    
    methods
        
        function [ out ] = Action( obj, history, ~ )
            
            if rand > 0.5
                out = 1;
            else
                out = 0;
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
