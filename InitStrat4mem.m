classdef InitStrat4mem < Strategy & handle
    % Memory 4 init strategy
    
    properties
        id = 0;
        innerCount = 99;
        stratCounter = 99;
        strategyNr;
        strategyNrs;
    end
    
    methods
        
        function [ out ] = Action( obj, history, ~ )

            strategies = {{1,1,1,1}, ...    
                          {1,1,1,0}, ...    
                          {1,1,0,1}, ...    
                          {1,1,0,0}, ...    
                          {1,0,1,1}, ...    
                          {1,0,1,0}, ...    
                          {1,0,0,1}, ...    
                          {1,0,0,0}, ...    
                          {0,1,1,1}, ...    
                          {0,1,1,0}, ...    
                          {0,1,0,1}, ...    
                          {0,1,0,0}, ...    
                          {0,0,1,1}, ...    
                          {0,0,1,0}, ...    
                          {0,0,0,1}, ...    
                          {0,0,0,0}};       

            if obj.innerCount > 4
                obj.stratCounter = obj.stratCounter+1;
                if obj.stratCounter > 16
                	obj.strategyNrs = randperm(16);
                	obj.stratCounter = 1;
                end
                obj.strategyNr = obj.strategyNrs(obj.stratCounter);
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