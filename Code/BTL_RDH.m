%file: BTL_RDH.m
%function: the third data hiding method to embedding the data for recovery
%origin: the original image
%blocksieze: the blocksize for embedding (type==1)
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0 or type==2)
%type: illustrate the distribution of the adjustment areas. 
%      2 means others
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0
%data: the data to be embeded

function res = BTL_RDH( origin, blocksize, type, MSB, NUM, edge, data)
    res = origin;
    alpha = 3;
    beta = 2;
    if alpha <= beta
        labels = dec2bin(1:2^alpha-1);
    else
        labels = dec2bin(2^(alpha-beta):2^alpha-1);
    end 
    [M,N,C] = size(origin);
    for channel = 1 : 1 : C
        locatex = [];
        locatey = [];
        bits = [];
        origin_c = origin(:,:,channel);
        if type == 0
            for i = 2 : M
                x0 = origin_c(i,1);x1 = origin_c(i-1,1);x2 = 0;x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                [locatex,locatey,bits,res(i,1,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,1,0,beta,labels,locatex,locatey,bits);
            end
            for j = 2 : N
                x0 = origin_c(1,j);x1 = 0;x2 = 0;x3 = origin_c(1,j-1);x4 = 0;x5 = 0;x6 = 0;
                [locatex,locatey,bits,res(1,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,1,j,2,beta,labels,locatex,locatey,bits);
            end
            for i = 2 : M
                for j = 2 : edge
                    x0 = origin_c(i,j);x1 = origin_c(i-1,j);x2 = 0;x3 = origin_c(i,j-1);x4 = 0;x5 = origin_c(i-1,j-1);x6 = 0;
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for i = 2 : edge
                for j = edge+1 : N-edge+1
                    x0 = origin_c(i,j);x1 = origin_c(i-1,j);x2 = 0;x3 = origin_c(i,j-1);x4 = 0;x5 = origin_c(i-1,j-1);x6 = 0;
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for j = edge+1 : N-edge
                x0 = origin_c(M-edge+1,j);x1 = 0;x2 = 0;x3 = origin_c(M-edge+1,j-1);x4 = 0;x5 = 0;x6 = 0;
                [locatex,locatey,bits,res(M-edge+1,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,M-edge+1,j,2,beta,labels,locatex,locatey,bits);
            end
            for i = edge+1 : M-edge+1
                x0 = origin_c(i,N-edge+1);x1 = origin_c(i-1,N-edge+1);x2 = 0;x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                [locatex,locatey,bits,res(i,N-edge+1,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,N-edge+1,0,beta,labels,locatex,locatey,bits);
            end
            for i = M-edge+2 : M
                for j = edge+1 : N-edge+1
                    x0 = origin_c(i,j);x1 = origin_c(i-1,j);x2 = 0;x3 = origin_c(i,j-1);x4 = 0;x5 = origin_c(i-1,j-1);x6 = 0;
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for i = 2 : M
                for j = N-edge+2 : N
                    x0 = origin_c(i,j);x1 = origin_c(i-1,j);x2 = 0;x3 = origin_c(i,j-1);x4 = 0;x5 = origin_c(i-1,j-1);x6 = 0;
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
        elseif type == 1
            % the special condition (the pixels are locating at the boundary)
            m = M/blocksize;
            n = N/blocksize;
            for p = 1 : 1 : m
                for q = 1 : 1 : n
                    % the location of the right down pixel in the block
                    x = p * blocksize;
                    y = q * blocksize;
                    if mod(NUM,blocksize) == 0
                        a = x - blocksize + NUM/blocksize + 1;
                    else
                        a = x - blocksize + ceil(NUM/blocksize);
                    end
                    for i = x-1 : -1 : a
                         x0 = origin_c(i,y);x1 = 0;x2 = origin_c(i+1,y);x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                        [locatex,locatey,bits,res(i,y,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,y,1,beta,labels,locatex,locatey,bits);
                    end
                    for j = y-1 : -1 : y-blocksize+1
                        x0 = origin_c(x,j);x1 = 0;x2 = 0;x3 = 0;x4 = origin_c(x,j+1);x5 = 0;x6 = 0;
                        [locatex,locatey,bits,res(x,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,x,j,3,beta,labels,locatex,locatey,bits);
                    end
                    % the common condition
                    count = 2*blocksize-floor(NUM/blocksize);
                    for i = x-1 : -1 : x-blocksize+1
                        if count > blocksize*blocksize-NUM
                            break;
                        end
                        for j = y-1 : -1 : y-blocksize+1
                            if count > blocksize*blocksize-NUM
                                break;
                            end
                            x0 = origin_c(i,j);x1 = 0;x2 = origin_c(i+1,j);x3 = 0;x4 = origin_c(i,j+1);x5 = 0;x6 = origin_c(i+1,j+1);
                            [locatex,locatey,bits,res(i,j,channel)] = Prediction(x0,x1,x2,x3,x4,x5,x6,i,j,5,beta,labels,locatex,locatey,bits);
                            count = count + 1;
                        end
                    end
                end
            end
        end
        data = Encode(data,MSB);
        [~,l] = size(data);
        data = Compression(l,data,1);
        [~,l1] = size(data);
        [~,l2] = size(bits);
        data(l1+1:l1+l2) = bits(1:l2); % the whole information to be embedded
        [~,len] = size(locatex);
        capacity = len*(8-alpha); % caculate the embedding capacity
        capacity,l1+l2
        % padding the data into length being the same as the capacity
        data (l1+l2+1) = '1';
        data(l1+l2+2:capacity) = '0';
        % embedding the information into marked pixels
        no = 1; % index of the data
        for index = 1 : 1 : len
            temp = Dec2bin(res(locatex(index),locatey(index),channel),8);
            temp(alpha+1:8) = data(no:no+7-alpha);
            res(locatex(index),locatey(index),channel) = bin2dec(temp);
            no = no + 8-alpha;
        end
    end
end
function [locatex, locatey, bits, res] = Prediction(x0,x1,x2,x3,x4,x5,x6, x, y, type, beta, labels, locatex, locatey, bits)
    x0_d = double(x0);
    x1_d = double(x1);
    x2_d = double(x2);
    x3_d = double(x3);
    x4_d = double(x4);
    x5_d = double(x5);
    x6_d = double(x6);
    if type == 0 % x-1 -> x
        error = x0_d - x1_d;
    elseif type == 1 % x+1 -> x
        error = x0_d - x2_d;
    elseif type == 2 % y-1 -> y
        error = x0_d - x3_d;
    elseif type == 3 % y+1 -> y
        error = x0_d - x4_d;
    elseif type == 4
        min = x1;
        max = x3;
        if min > x3
            min = x3;
            max = x1;
        end
        if x5 < min
            pred = max;
        elseif x5 > max
            pred = min;
        else
            pred = x1_d + x3_d - x5_d;
        end
        error = x0_d - double(pred);  
    elseif type == 5
        min = x2;
        max = x4;
        if min > x4
            min = x4;
            max = x2;
        end
        if x6 < min
            pred = max;
        elseif x6 > max
            pred = min;
        else
            pred = x2_d + x4_d - x6_d;
        end
        error = x0_d - double(pred);
    end
    [range,alpha] = size(labels);
    if ceil(-range/2) <= error && error <= floor((range-1)/2)
        index = error - ceil(-range/2) + 1;
        label = labels(index,:);
        tmp = '00000000';
        tmp(1:alpha) = label(:);
        res = bin2dec(tmp);
        [~,no] = size(locatex);
        locatex(no+1) = x;
        locatey(no+1) = y;
    else
        [~,l] = size(bits);
        tmp = Dec2bin(x0,8);
        bits(l+1:l+beta) = tmp(1:beta);
        tmp(1:beta) = '0';
        res = bin2dec(tmp);
    end  
end


