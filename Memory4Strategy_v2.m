classdef Memory4Strategy_v2 < Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        
        % Lookup-tables
        m1 = [[0,0];
              [0,0]];
               % C
                
        m2 = [[1,1];
              [1,1]];
              % C
        m3 = [[0,0];
              [1,1]]; 
        m4 = [[1,0];
              [1,1]]; 
        m5 = [[0,1];
              [1,1]]; 
    end
    
    methods
        function out = Action(obj, history, ~)
            T = size(history, 1);
            if T < 4
                out = 1;
            else
                last2 = (T-1:T);
                chunk = history(last2,:);
                if all(all(chunk == obj.m1)) || ...
                   all(all(chunk == obj.m2)) || ...
                   all(all(chunk == obj.m3)) || ...
                   all(all(chunk == obj.m4)) || ...
                   all(all(chunk == obj.m5))
                    out = 1;
                else 
                    out = 0;
                end
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

