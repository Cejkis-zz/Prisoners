classdef InitStrat3mem < Strategy & handle
    % Memory 3 init strategy
    
    properties
        id = 0;
        innerCount = 99;
        strategyNr = 99;
    end
    
    methods
        
        function [ out ] = Action( obj, history, ~ )

            strategies = {{1,1,1},  ...    
                          {1,1,0},  ...    
                          {1,0,1},  ...    
                          {1,0,0},  ...    
                          {0,1,1},  ...    
                          {0,1,0},  ...    
                          {0,0,1},  ...    
                          {0,0,0}};   
                      
            if obj.innerCount > 3
                obj.strategyNr = randi([1 8],1,1);
                obj.innerCount = 1;
            end
            
            outtmp = strategies{obj.strategyNr};
            out = outtmp{obj.innerCount};
            obj.innerCount = obj.innerCount+1;
        end
        
        function out = get_id(obj)
            out = obj.id;
        end
        
        function set_id(obj, id)
            obj.id = id;
        end
    end
    
end