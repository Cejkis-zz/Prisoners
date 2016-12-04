classdef TitForTat < Strategy & handle
    %TITFORTA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [ out ] = Action( obj,history )
            if size(history,1) ==0
                out = 1;
                return;
            end
            
            out = history(end, 2);
        end
    end
    
end

