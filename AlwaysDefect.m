classdef AlwaysDefect < Strategy & handle
    %ALWAYSCOOPERATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
    end
    
    methods
        function [ out ] = Action( obj,history, ~ )
            out = 0;
        end
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
    end
    
end
