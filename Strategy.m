classdef (Abstract) Strategy < handle
    %PRISONER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Abstract)
        
        Action( obj,history,id )
        get_id( obj )
        set_id( obj,id )
    end
    
end

