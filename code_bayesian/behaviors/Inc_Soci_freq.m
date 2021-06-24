function [freqTar] = Inc_Soci_freq(trialData)
%UNTITLED7 이 함수의 요약 설명 위치
%   자세한 설명 위치
%incents = [9000, 10500, 12000, 13500, 15000, 16500];
incents = [43, 37, 31, 25, 19];

    data = trialData.gameData;
    socialDists = data(:,8);
    incentive = data(:,9);
    resp = data(:,7);
    resp(resp == -1) = 0;
    freqTar = zeros(5,6);
    %shifting selfish decision yes to prosocial decision yes. 
%     resp(resp == 0) = 2;
%     resp(resp == 1) = 0;
%     resp(resp == 2) = 1;

    
    
    for i = 1:length(resp)
        switch socialDists(i)
            case 1
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,1) = freqTar(1,1) + resp(i);
                    case incents(2)       
                        freqTar(2,1) = freqTar(2,1) + resp(i);
                    case incents(3)
                        freqTar(3,1) = freqTar(3,1) + resp(i);
                    case incents(4)
                        freqTar(4,1) = freqTar(4,1) + resp(i);
                    case incents(5)
                        freqTar(5,1) = freqTar(5,1) + resp(i);
                 end

            case 3
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,2) = freqTar(1,2) + resp(i);
                    case incents(2)  
                        freqTar(2,2) = freqTar(2,2) + resp(i);
                    case incents(3)
                        freqTar(3,2) = freqTar(3,2) + resp(i);
                    case incents(4)
                        freqTar(4,2) = freqTar(4,2) + resp(i);
                    case incents(5)
                        freqTar(5,2) = freqTar(5,2) + resp(i);

                end

            case 5
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,3) = freqTar(1,3) + resp(i);
                    case incents(2)       
                        freqTar(2,3) = freqTar(2,3) + resp(i);
                    case incents(3)
                        freqTar(3,3) = freqTar(3,3) + resp(i);
                    case incents(4)
                        freqTar(4,3) = freqTar(4,3) + resp(i);
                    case incents(5)
                        freqTar(5,3) = freqTar(5,3) + resp(i);
                end

            case 10
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,4) = freqTar(1,4) + resp(i);
                    case incents(2)       
                        freqTar(2,4) = freqTar(2,4) + resp(i);
                    case incents(3)
                        freqTar(3,4) = freqTar(3,4) + resp(i);
                    case incents(4)
                        freqTar(4,4) = freqTar(4,4) + resp(i);
                    case incents(5)
                        freqTar(5,4) = freqTar(5,4) + resp(i);

                end

            case 20
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,5) = freqTar(1,5) + resp(i);
                    case incents(2)       
                        freqTar(2,5) = freqTar(2,5) + resp(i);
                    case incents(3)
                        freqTar(3,5) = freqTar(3,5) + resp(i);
                    case incents(4)
                        freqTar(4,5) = freqTar(4,5) + resp(i);
                    case incents(5)
                        freqTar(5,5) = freqTar(5,5) + resp(i);

                end

            case 50 
                switch incentive(i) 
                    case incents(1)
                        freqTar(1,6) = freqTar(1,6) + resp(i);
                    case incents(2)       
                        freqTar(2,6) = freqTar(2,6) + resp(i);
                    case incents(3)
                        freqTar(3,6)  = freqTar(3,6) + resp(i);
                    case incents(4)
                        freqTar(4,6) = freqTar(4,6) + resp(i);
                    case incents(5)
                        freqTar(5,6) = freqTar(5,6) + resp(i);
                end

        end
    end

end

