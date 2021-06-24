function [SV, ACC] = m14_SV(trialData, param, blockseq)
%parameters 1 = k, 2 = tau, 3= beta
%   자세한 설명 위치
     data = trialData.gameData;
     
    %column 2, social distance
    social_distance = data(:,8);
    resp = data(:,7);
    social_distance(social_distance == 50) = 100;
    social_distance(social_distance == 20) = 50;
    social_distance(social_distance == 10) = 20;
    social_distance(social_distance == 5) = 10;
    social_distance(social_distance == 3) = 5;
    
    
    %Column 6 choice
    resp(resp == -1) = 0;
    %shifting selfish decision yes to prosocial decision yes. 
    choice = resp.*-1 +1;
    
    
    for counts = 1:length(blockseq)
        if rem(blockseq(counts),2) == 0
            unfairseq(1+(counts-1)*30:counts*30) = 1;
            fairseq(1+(counts-1)*30:counts*30) = 0;
        else
            unfairseq(1+(counts-1)*30:counts*30) = 0;
            fairseq(1+(counts-1)*30:counts*30) = 1;
        end
    end
    amount_default = 20.*fairseq +  10.*unfairseq;
    amount_other = 20.*fairseq +  30.*unfairseq;
    
    
    amountSelf = data(:,9);
    evSelf = param(3)*(amountSelf);
    evOther = (1-param(3))*(amount_other + amount_default) ./ (1 + param(1)*social_distance');
    
    psplit = (1 ./ (1 + exp(-1*param(2).*(evOther'-evSelf))));
    y_pred = round(psplit);
    ACC = sum(y_pred == choice);
    
    SV(:,1) = evSelf; SV(:,2) = evOther; SV(:,3) = psplit; SV(:,4) = y_pred; 
end

