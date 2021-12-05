%file: BTL_RDH_r.m
%function: extracting the embedded data and recover the embedding area
%origin: the original image
%blocksieze: the blocksize for embedding (type==1)
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0 or type==2)
%type: illustrate the distribution of the adjustment areas. 
%      2 means others
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0

function [datas,res] = BTL_RDH_r( origin, blocksize, type, MSB, NUM, edge)
    res = origin;
    alpha = 3;
    beta = 2;
    if alpha <= beta
        labels = dec2bin(1:2^alpha-1);
    else
        labels = dec2bin(2^(alpha-beta):2^alpha-1);
    end 
    [M,N,C] = size(origin);
    datas = [];
    for channel = 1 : 1 : C
        locatex = []; % record the location of pixels in embedding area 
        locatey = [];
        bits = []; %  store the high beta bits of pixels belong to Pn for recovery
        if type == 0
            length = (M-edge*2) * (N-edge*2) * MSB; % the length of the uncompressed information for recovering the adjustment area
            % select the locations of the pixels in adjustment area by recovery order
            locatex(1:M-1) = 2:M;
            locatey(1:M-1) = 1;
            locatex(M:M+N-2) = 1;
            locatey(M:M+N-2) = 2:N;
            no = M+N-1; % index of the locates
            for i = 2 : M
                locatex(no:no+edge-2) = i;
                locatey(no:no+edge-2) = 2:edge;
                no = no + edge - 1;
            end
            for i = 2 : edge
                locatex(no:no+N-edge*2) = i;
                locatey(no:no+N-2*edge) = edge+1:N-edge+1;
                no = no + N-edge*2 + 1;
            end
            locatex(no:no+N-2*edge-1) = M-edge+1;
            locatey(no:no+N-2*edge-1) = edge+1 : N-edge;
            no = no + N-2*edge;
            locatex(no:no+M-2*edge) = edge+1 : M-edge+1;
            locatey(no:no+M-2*edge) = N-edge+1;
            no = no + M-edge*2 + 1;
            for i = M-edge+2 : M
                locatex(no:no+N-edge*2) = i;
                locatey(no:no+N-edge*2) = edge+1 : N-edge+1;
                no = no + N-edge*2 + 1;
            end
            for i = 2 : M
                locatex(no:no+edge-2) = i;
                locatey(no:no+edge-2) = N-edge+2 : N;
                no = no + edge - 1;
            end
            for index = 1 : 1 : no-1
                bin = Dec2bin(origin(locatex(index),locatey(index),channel),8);
                com(1:beta) = '0';
                if strcmp(bin(1:beta),com(1:beta)) ~= 1
                    [~,l] = size(bits);
                    bits(l+1:l+8-alpha) = bin(alpha+1:8);
                end
            end
            [~,l] = size(bits);
            for i = l : -1 : 1
                if bits(i) == '1'
                    bits = bits(1:i-1);
                    break;
                end
            end
            bits = Decompression(length,bits,1);
            data = Decode(bits(1:length),MSB);
            % recovering high beta bits of pixels with beta labels
            no = length+1; % index of the bits
            for i = 2 : M
                [no,res(i,1,channel)] = Reduction(res(:,:,channel), i, 1, 0, beta, labels, bits, no);
            end
            for j = 2 : N
                [no,res(1,j,channel)] = Reduction(res(:,:,channel), 1, j, 2, beta, labels, bits, no);
            end
            for i = 2 : M
                for j = 2 : edge
                    [no,res(i,j,channel)] = Reduction(res(:,:,channel), i, j, 4, beta, labels, bits, no);
                end
            end
            for i = 2 : edge
                for j = edge+1 : N-edge+1
                    [no,res(i,j,channel)] = Reduction(res(:,:,channel), i, j, 4, beta, labels, bits, no);
                end
            end
            for j = edge+1 : N-edge
                [no,res(M-edge+1,j,channel)] = Reduction(res(:,:,channel), M-edge+1, j, 2, beta, labels, bits, no);
            end
            for i = edge+1 : M-edge+1
                [no,res(i,N-edge+1,channel)] = Reduction(res(:,:,channel), i, N-edge+1, 0, beta, labels, bits, no);
            end
            for i = M-edge+2 : M
                for j = edge+1 : N-edge+1
                    [no,res(i,j,channel)] = Reduction(res(:,:,channel), i, j, 4, beta, labels, bits, no);
                end
            end
            for i = 2 : M
                for j = N-edge+2 : N
                    [no,res(i,j,channel)] = Reduction(res(:,:,channel), i, j, 4, beta, labels, bits, no);
                end
            end
        elseif type == 1
            length = NUM * MSB * M/blocksize * N/blocksize;
            % the special condition (the pixels are locating at the boundary)
            for i = M-1 : -1 : ceil(NUM/blocksize)
                bin = Dec2bin(origin(i,N,channel),8);
                com(1:beta) = '0';
                if strcmp(bin(1:beta),com(1:beta)) ~= 1
                    [~,l] = size(bits);
                    bits(l+1,l+8-alpha) = bin(alpha+1:8);
                end
            end
            for j = N-1 : -1 : 1
                bin = Dec2bin(origin(1,M,channel),8);
                com(1:beta) = '0';
                if strcmp(bin(1:beta),com(1:beta)) ~= 1
                    [~,l] = size(bits);
                    bits(l+1,l+8-alpha) = bin(alpha+1:8);
                end
            end
            % the common condition
            count = N+M-ceil(NUM/blocksize);
            for i = M-2 : -1 : 1
                if count > NUM
                        break;
                end
                for j = N-2 : -1 : 1
                    if count > NUM
                        break;
                    end
                    bin = Dec2bin(origin(1,j,channel),8);
                    com(1:beta) = '0';
                    if strcmp(bin(1:beta),com(1:beta)) ~= 1
                        [~,l] = size(bits);
                        bits(l+1,l+8-alpha) = bin(alpha+1:8);
                    end
                    count = count + 1;
                end
            end
            [~,l] = size(bits);
            for i = l : -1 : 1
                if bits(i) == '1'
                    bits = bits(1:i-1);
                    break;
                end
            end
            bits = Decompression(length,bits,1);
            data = Decode(bits(1:length),MSB);
            % recovering high beta bits of pixels with beta labels
            no = length+1; % index of the bits
            for i = M-1 : -1 : ceil(NUM/blocksize)
                [no,res(i,N,channel)] = Reduction(res(:,:,channel), i, N, 1, beta, labels, bits, no);
            end
            for j = N-1 : -1 : 1
                [no,res(M,j,channel)] = Reduction(res(:,:,channel), M, j, 3, beta, labels, bits, no);
            end
            % the common condition
            count = N+M-ceil(NUM/blocksize);
            for i = M-2 : -1 : 1
                if count > NUM
                        break;
                end
                for j = N-2 : -1 : 1
                    if count > NUM
                        break;
                    end
                    [no,res(i,j,channel)] = Reduction(res(:,:,channel), i, j, 5, beta, labels, bits, no);
                    count = count + 1;
                end
            end
        end
        [~,l] = size(datas);
        datas(l+1:l+length) = data(1:length);
    end
end

function [no,res] = Reduction(origin, x, y, type, beta, labels, bits, no)
    res = origin(x,y);
    [range,alpha] = size(labels);
    bin = Dec2bin(origin(x,y),8);
    com(1:beta) = '0';
    if strcmp(bin(1:beta),com(1:beta)) == 1
        bin(1:beta) = bits(no:no+beta-1);
        res = bin2dec(bin);
        no = no + beta;
    else
        error = double(bin2dec(bin(1:alpha))) - double(bin2dec(labels(1,:))) + double(ceil(-range/2));
        if type == 0 % x-1 -> x
            res = double(origin(x-1,y)) + error;
        elseif type == 1 % x+1 -> x
            res = double(origin(x+1,y)) + error;
        elseif type == 2 % y-1 -> y
            res = double(origin(x,y-1)) + error;
        elseif type == 3 % y+1 -> y
            res = double(origin(x,y+1)) + error;
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
            res = double(pred) + error;  
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
            res = double(pred) + error;
        end
    end
end