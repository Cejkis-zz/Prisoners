classdef Memory4Strategy < Strategy
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        id = 0;
        
        % Lookup-tables
        m1 = [[1,1];
              [1,1];
              [1,1];
              [1,1]];
                % C
                
        m2 = [[0,0];
             [1,1];
             [1,1];
             [1,1];];
              % C
              
        m3 = [[0,0];
             [0,0];
             [1,1];
             [1,1];];
                % C
                
        m4 = [[0,0];
             [0,0];
             [0,0];
             [1,1];];
                % C
        m5 = [[0,0];
             [0,0];
             [0,0];
             [0,0];];
                % C
        m6 = [[0,1];
              [0,0];
              [0,0];
              [1,1]];
                % C
        
        m7 = [[1,0];
             [0,0];
             [0,0];
             [1,1];];
              % C
        m8 = [[1,1];
             [0,0];
             [0,0];
             [1,1];];
              % C 
              
        m9 = [[1,1];
             [1,0];
             [0,0];
             [0,0];];
              % C 
        m10 = [[1,1];
              [0,1];
              [0,0];
              [0,0];];
              % C 
        m11 = [[0,1];
              [0,1];
              [0,0];
              [0,0];];
              % C 
        m12 = [[1,0];
              [1,0];
              [0,0];
              [0,0];];
              % C 
        m13 = [[0,1];
              [1,0];
              [0,0];
              [0,0];];
              % C 
        m14 = [[1,0];
              [0,1];
              [0,0];
              [0,0];];
              % C 
        m15 = [[0,0];
              [0,1];
              [0,0];
              [0,0];];
              % C 
        
        m16 = [[0,0];
              [1,0];
              [0,0];
              [0,0];];
              % C       
         
    end
    
    methods
        function out = Action(obj, history, ~)
            T = size(history, 1);
            if T < 4
                out = 1;
            else
                last4 = (T-3:T);
                chunk = history(last4,:);
                if all(all(chunk == obj.m1)) || ...
                   all(all(chunk == obj.m2)) || ...
                   all(all(chunk == obj.m3)) || ...
                   all(all(chunk == obj.m4)) || ...
                   all(all(chunk == obj.m5)) || ...
                   all(all(chunk == obj.m6)) || ...
                   all(all(chunk == obj.m7)) || ...
                   all(all(chunk == obj.m8)) || ...
                   all(all(chunk == obj.m9)) || ...
                   all(all(chunk == obj.m10)) || ...
                   all(all(chunk == obj.m11)) || ...
                   all(all(chunk == obj.m12)) || ...
                   all(all(chunk == obj.m13)) || ...
                   all(all(chunk == obj.m14)) || ...
                   all(all(chunk == obj.m15)) || ...
                   all(all(chunk == obj.m16))
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

