%file: HC_RDH.m
%function: the first data hiding method to embedding the data for recovery
%origin: the original image
%data: the data to be embeded
%locatex & locatey: the location of first pixel in embedding block

function [locate_map, result] = HC_RDH( origin, data, locatex, locatey)
    result = origin;
    tmp = '000000000000000000000';
    [~,number] = size(locatex);
    [~,~,C] = size(origin);
    locate_map = zeros(C,number);
    [~,limit] = size(data);
    count = uint32(1); %record the index of the data to be embedded
    for chanal = 1 : 1 : C
        ori = origin(:,:,chanal);
        res = ori;
        for index = 1 : 1 : number
            % the first pixel value of each block for prediction
            x = locatex(index);
            y = locatey(index);
            c1 = ori(x,y+1);
            c2 = ori(x+1,y);
            c3 = ori(x+1,y+1);
            pred = ori(x,y);
            d1 = Diff(pred,c1);
            d2 = Diff(pred,c2);
            d3 = Diff(pred,c3);
            d = d1;
            if d2 > d
                d = d2;
            end
            if d3 > d
                d = d3;
            end
            md = 8 - d; % the max number of the same bits from MSB that all pixels in one block 
            bits = '000000000000000000000000';
            % if md = 1, there is no extra space to store the embedding data
            if md == 0
                locate_map(chanal,index) = 1;
                continue;
            end
            md = md - 1;
            md = Dec2bin(md,3);
            bits(1:3) = md(1:3);
            c1 = Dec2bin(c1,8);
            bits(4:3+d) = c1(8-d+1:8);
            c2 = Dec2bin(c2,8);
            bits(4+d:3+2*d) = c2(8-d+1:8);
            c3 = Dec2bin(c3,8);
            bits(4+2*d:3+3*d) = c3(8-d+1:8);
            if d < 7
                % all the data has been embedded
                if count >= limit
                   bits(4+3*d:24) = tmp(1:21-3*d);
                else
                    if count+20-3*d > limit && limit > count
                        data(limit+1:count+20-3*d) = tmp(1:count+20-3*d-limit);
                        limit = count+20-3*d;
                    end
                    bits(4+3*d:24) = data(count:count+20-3*d);
                end
                count = count + 20-3*d + 1;
            end
            res(x,y+1) = bin2dec(bits(1:8));
            res(x+1,y) = bin2dec(bits(9:16));
            res(x+1,y+1) = bin2dec(bits(17:24));
        end
        result(:,:,chanal) = res(:,:);
        % compress the locate_map of each chanal respectively
        map = Compression(number,locate_map(chanal,1:number),0);
        [~,len] = size(map);
        locate_map(chanal,1:len) = map(1:len);
        locate_map(chanal,len+1) = 1;
        len = len + 1;
        if mod(len,8) ~= 0
            locate_map(chanal,len+1:ceil(len/8)*8) = tmp(1:ceil(len/8)*8-len)-'0';
        end
        [~,l] = size(locate_map);
        locate_map(chanal,ceil(len/8)*8+1:l) = 0;
    end
    capacity = count
end