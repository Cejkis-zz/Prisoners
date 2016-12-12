classdef IllCountToThreeButMayForget< Strategy
    %IllCountToThreeButMayForget Strategy that counts up to three defects. If this limit is
    %passed, it will defect constantly untill it forgets its grudge.
    
    properties
        threeCounter=0;
        id = 0;
    end
    
    methods
        
        %Reset the state.
        function []=resetState(obj)
            obj.threeCounter=0;
        end
        
        function [ out ] = Action(obj, history, ~ )
            %cooperate initially.
            if size(history,1) ==0
                out = 1;
                return;
            end
            
            %Check if last round was a defect and counter not already passed.
            if (history(end,2)==0)
                obj.threeCounter=obj.threeCounter+1;
            end
            
            %Randomly forget the grudge (or count).
            if(rand>.85)
                %clc
                %disp('I seem to have forgotten something.')
                obj.threeCounter=0;
            end
            
            %If counter has reched 3 or more then always defect.
            if (obj.threeCounter>=3)
                %clc
                %disp('Now im angry!')
                out = 0;
            else
                %Play nice.
                out =1;
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
