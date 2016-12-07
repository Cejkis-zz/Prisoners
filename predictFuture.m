        maxRounds = 5

        function totalValue = predictFuture( history, rounds, y_t, c_t, firstChoice)
            predictsOut = predict(y_t, c_t, T, history);
            predicted = predictsOut(1);
            y_t = predictsOut(2);
            c_t = predictsOut(3);
            if rounds == maxRounds
                totalValue = PrisonersRound(predicted, firstChoice) + ...
                  predictFuture([firstChoice, predicted], rounds-1, y_t, c_t, firstChoice);
            elseif (rounds > 0)
                totalValue = max([PrisonersRound(predicted,0) + ...
                                   predictFuture([0, predicted], rounds-1, y_t, c_t, firstChoice) ...
                                  PrisonersRound(predicted,1) + ...
                                   predictFuture([1, predicted], rounds-1, y_t, c_t, firstChoice)]);
            else
                totalValue = max([PrisonersRound(predicted,0) ...
                                    PrisonersRound(predicted,1)]);
               
            end
        end
        
        function out = Action( obj, history )
            stmp = size(history);
            histLen = stmp(1);
            train_network(obj, y_t, c_t, histLen, ...
                history(:,1:histLen-1), history(histLen));
            if predictFuture( history, maxRounds, y_t, c_t, 0) > ...
               predictFuture( history, maxRounds, y_t, c_t, 1)
                out = 0;
            else
                out = 1;
            end
        end
        
        totalValue = max([PrisonersRound(predicted,0) + ...
                                   predictFuture([0, predicted], rounds-1, y_t, c_t, firstChoice) ...
                                  PrisonersRound(predicted,1) + ...
                                   predictFuture([1, predicted], rounds-1, y_t, c_t, firstChoice)]);
        
        
                        max(PrisonersRound(predicted,0) +
                        predictFuture([ [0, prediction] history(:,1:nrHistory-1)], rounds-1, y_t, c_t),
                    PrisonersRound(predicted,1) +
                        predictFuture([ [1, prediction] history(:,1:nrHistory-1)], rounds-1, y_t, c_t),