classdef Mutant < Strategy & handle
    %Evolver A strategy class for the PD game. May sometimes mutate its
    %strategy.
    %   Detailed explanation goes here
    
    properties
        %The likelihood of a mutation.
        mutateRate=0.25;
    end
    
    methods
        function [ out ] = Action( obj,history, ~ )
            out = 0;
        end
    end
    
end

