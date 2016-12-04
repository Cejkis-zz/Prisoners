classdef Random < Strategy & handle
    %RANDOM Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function [ out ] = Action( obj, history )
            
            if rand > 0.5
                out = 1;
            else
                out = 0;
            end
            
        end
        
    end
    
end
