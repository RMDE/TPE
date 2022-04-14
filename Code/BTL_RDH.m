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
        if type == 0
            for i = 2 : M
                [locatex,locatey,bits,res(i,1,channel)] = Prediction(origin(:,:,channel),i,1,0,beta,labels,locatex,locatey,bits);
            end
            for j = 2 : N
                [locatex,locatey,bits,res(1,j,channel)] = Prediction(origin(:,:,channel),1,j,2,beta,labels,locatex,locatey,bits);
            end
            for i = 2 : M
                for j = 2 : edge
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(origin(:,:,channel),i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for i = 2 : edge
                for j = edge+1 : N-edge+1
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(origin(:,:,channel),i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for j = edge+1 : N-edge
                [locatex,locatey,bits,res(M-edge+1,j,channel)] = Prediction(origin(:,:,channel),M-edge+1,j,2,beta,labels,locatex,locatey,bits);
            end
            for i = edge+1 : M-edge+1
                [locatex,locatey,bits,res(i,N-edge+1,channel)] = Prediction(origin(:,:,channel),i,N-edge+1,0,beta,labels,locatex,locatey,bits);
            end
            for i = M-edge+2 : M
                for j = edge+1 : N-edge+1
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(origin(:,:,channel),i,j,4,beta,labels,locatex,locatey,bits);
                end
            end
            for i = 2 : M
                for j = N-edge+2 : N
                    [locatex,locatey,bits,res(i,j,channel)] = Prediction(origin(:,:,channel),i,j,4,beta,labels,locatex,locatey,bits);
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
                        [locatex,locatey,bits,res(i,y,channel)] = Prediction(origin(:,:,channel),i,y,1,beta,labels,locatex,locatey,bits);
                    end
                    for j = y-1 : -1 : y-blocksize+1
                        [locatex,locatey,bits,res(x,j,channel)] = Prediction(origin(:,:,channel),x,j,3,beta,labels,locatex,locatey,bits);
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
                            [locatex,locatey,bits,res(i,j,channel)] = Prediction(origin(:,:,channel),i,j,5,beta,labels,locatex,locatey,bits);
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
        capacity,length = l1+l2
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

function [locatex, locatey, bits, res] = Prediction(origin, x, y, type, beta, labels, locatex, locatey, bits)
    if type == 0 % x-1 -> x
        error = double(origin(x,y)) - double(origin(x-1,y));
    elseif type == 1 % x+1 -> x
        error = double(origin(x,y)) - double(origin(x+1,y));
    elseif type == 2 % y-1 -> y
        error = double(origin(x,y)) - double(origin(x,y-1));
    elseif type == 3 % y+1 -> y
        error = double(origin(x,y)) - double(origin(x,y+1));
    elseif type == 4
        min = origin(x-1,y);
        max = origin(x,y-1);
        if min > origin(x,y-1)
            min = origin(x,y-1);
            max = origin(x-1,y);
        end
        if origin(x-1,y-1) < min
            pred = max;
        elseif origin(x-1,y-1) > max
            pred = min;
        else
            pred = double(origin(x-1,y)) + double(origin(x,y-1)) - double(origin(x-1,y-1));
        end
        error = double(origin(x,y)) - double(pred);  
    elseif type == 5
        min = origin(x+1,y);
        max = origin(x,y+1);
        if min > origin(x,y+1)
            min = origin(x,y+1);
            max = origin(x+1,y);
        end
        if origin(x+1,y+1) < min
            pred = max;
        elseif origin(x+1,y+1) > max
            pred = min;
        else
            pred = double(origin(x+1,y)) + double(origin(x,y+1)) - double(origin(x+1,y+1));
        end
        error = double(origin(x,y)) - double(pred);
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
        tmp = Dec2bin(origin(x,y),8);
        bits(l+1:l+beta) = tmp(1:beta);
        tmp(1:beta) = '0';
        res = bin2dec(tmp);
    end  
end