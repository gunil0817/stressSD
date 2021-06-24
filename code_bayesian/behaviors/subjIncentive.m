function [selfInc] = subjIncentive(trialData,blockseq)
%input : obtain the struct called trialData, which contains individual
%data. and return the frequency of how many "selfish" decisions were made. 
    data = trialData.gameData;
    incentive = data(:,9);
    resp = data(:,7);
    resp(resp == -1) = 0;
    
    %shifting selfish decision yes to prosocial decision yes. 
    resp(resp == 0) = 2;
    resp(resp == 1) = 0;
    resp(resp == 2) = 1;
    
    
    selfInc = zeros(2,6);
    
    
    
%generating sequence of unfair
    for counts = 1:length(blockseq)
        if rem(blockseq(counts),2) == 0
            unfairseq(1+(counts-1)*30:counts*30) = 1;
            fairseq(1+(counts-1)*30:counts*30) = 0;
        else
            unfairseq(1+(counts-1)*30:counts*30) = 0;
            fairseq(1+(counts-1)*30:counts*30) = 1;
        end
    end
    
    respF = resp.*fairseq';
    respU = resp.*unfairseq';
    %for fair
    for i = 1:length(resp)
        switch incentive(i)
            case 19
                selfInc(1,1) = selfInc(1,1) + respF(i);
            case 25
                selfInc(1,2) = selfInc(1,2) + respF(i);
            case 31
                selfInc(1,3) = selfInc(1,3) + respF(i);
            case 37
                selfInc(1,4) = selfInc(1,4) + respF(i);
            case 43
                selfInc(1,5) = selfInc(1,5) + respF(i);
        end
    end
    
    %for unfiar
    for i = 1:length(resp)
        switch incentive(i)
            case 19
                selfInc(2,1) = selfInc(2,1) + respU(i);
            case 25
                selfInc(2,2) = selfInc(2,2) + respU(i);
            case 31
                selfInc(2,3) = selfInc(2,3) + respU(i);
            case 37
                selfInc(2,4) = selfInc(2,4) + respU(i);
            case 43
                selfInc(2,5) = selfInc(2,5) + respU(i);
        end
    end
end

