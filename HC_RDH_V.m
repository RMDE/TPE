%file: HC_RDH_V.m
%function: the variant of the first data hiding method to embedding the data for recovery
%origin: the original image
%data: the data to be embeded
%locatex & locatey: the location of first pixel in embedding block

function res = HC_RDH_V( origin, data, locatex, locatey)
    res = origin;
    tmp = '00000000000000000000000000000000';
    [~,number] = size(locatex);
    [~,~,C] = size(origin);
    locate_map = zeros(C,number);
    [~,limit] = size(data);
    % dividing the data into three parts for three chanal respectively
    for chanal = 1 : 1 : C-1
        tail_len(chanal) = floor(limit/C);
        tail(chanal,1:tail_len(chanal)) = data(floor(limit/C)*(chanal-1)+1:floor(limit/C)*chanal);
    end
    tail_len(C) = floor(limit/C) + mod(limit,C);
    tail(C,1:tail_len(C)) = data(floor(limit/C)*(C-1)+1:limit);
    for chanal = 1 : 1 : C
        no = 1; % index of the bits
        bits = '0';
        for index = 1 : 1 : number
            % the first pixel value of each block for prediction
            pred = origin(locatex(index),locatey(index),chanal);
            bits(no:no+7) = Dec2bin(pred,8);
            no = no + 8;
            d1 = Diff(pred,origin(locatex(index),locatey(index)+1,chanal));
            d2 = Diff(pred,origin(locatex(index)+1,locatey(index),chanal));
            d3 = Diff(pred,origin(locatex(index)+1,locatey(index)+1,chanal));
            d = d1;
            if d2 > d
                d = d2;
            end
            if d3 > d
                d = d3;
            end
            md = 8 - d; % the max number of the same bits from MSB that all pixels in one block 
            % if md = 1, there is no extra space to store the embedding data
            if md == 0
                locate_map(chanal,index) = 1;
                continue;
            end
            md = md - 1;
            md = Dec2bin(md,3);
            bits(no:no+2) = md(1:3);
            c1 = Dec2bin(origin(locatex(index),locatey(index)+1,chanal),8);
            bits(no+3:no+2+d) = c1(8-d+1:8);
            c2 = Dec2bin(origin(locatex(index)+1,locatey(index),chanal),8);
            bits(no+3+d:no+2+2*d) = c2(8-d+1:8);
            c3 = Dec2bin(origin(locatex(index)+1,locatey(index)+1,chanal),8);
            bits(no+3+2*d:no+2+3*d) = c3(8-d+1:8);
            no = no + 3 + 3*d;
        end
        % compress the locate_map of each chanal respectively
        ori_data = '';
        map = Compression(number,locate_map(chanal,1:number),0);
        [~,len] = size(map);
        % ori_data includes: length of the locate_map(24bits) + locate_map + prediction result of 
        % every 2x2 block in the embedding area + information of adjustment area for recovery
        ori_data(1:24) = Dec2bin(len,24);  
        ori_data(25:24+len) = char(map(1:len)+'0');
        [~,l] = size(bits);
        ori_data(25+len:24+len+l) = bits(1:l);
        ori_data(25+len+l:24+len+l+tail_len(chanal)) = tail(chanal,1:tail_len(chanal));
        ori_data(25+len+l+tail_len(chanal)) = '1';
        [~,len] = size(ori_data)
        if mod(len,32) ~= 0
            ori_data(len+1:ceil(len/32)*32) = tmp(1:ceil(len/32)*32-len);
        end
        [~,len] = size(ori_data);
        no = 1; % index of the ori_data
        for index = 1 : 1 : number
            if no > len
                res(locatex(index),locatey(index),chanal) = 0;
                res(locatex(index),locatey(index)+1,chanal) = 0;
                res(locatex(index)+1,locatey(index),chanal) = 0;
                res(locatex(index)+1,locatey(index)+1,chanal) = 0;
                continue;
            end
            res(locatex(index),locatey(index),chanal) = bin2dec(ori_data(no:no+7));
            res(locatex(index),locatey(index)+1,chanal) = bin2dec(ori_data(no+8:no+15));
            res(locatex(index)+1,locatey(index),chanal) = bin2dec(ori_data(no+16:no+23));
            res(locatex(index)+1,locatey(index)+1,chanal) = bin2dec(ori_data(no+24:no+31));
            no = no + 32;
        end
    end
end