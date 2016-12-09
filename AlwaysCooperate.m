classdef AlwaysCooperate < Strategy & handle
    %ALWAYSCOOPERATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function [ out ] = Action(obj, history, ~ )
            out = 1;
        end
    end
    
end
