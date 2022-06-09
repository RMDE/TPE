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
        res_c = res(:,:,channel);
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
            count = 0;
            for index = 1 : 1 : no-1
                bin = dec2bin(origin(locatex(index),locatey(index),channel),8);
                com(1:beta) = '0';
                if strcmp(bin(1:beta),com(1:beta)) ~= 1
                    count = count + 1;
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
                x0 = res_c(i,1);x1 = res_c(i-1,1);x2 = 0;x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                [no,res_c(i,1)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 0, beta, labels, bits, no);
            end
            for j = 2 : N
                x0 = res_c(1,j);x1 = 0;x2 = 0;x3 = res_c(1,j-1);x4 = 0;x5 = 0;x6 = 0;
                [no,res_c(1,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 2, beta, labels, bits, no);
            end
            for i = 2 : M
                for j = 2 : edge
                    x0 = res_c(i,j);x1 = res_c(i-1,j);x2 = 0;x3 = res_c(i,j-1);x4 = 0;x5 = res_c(i-1,j-1);x6 = 0;
                    [no,res_c(i,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 4, beta, labels, bits, no);
                end
            end
            for i = 2 : edge
                for j = edge+1 : N-edge+1
                    x0 = res_c(i,j);x1 = res_c(i-1,j);x2 = 0;x3 = res_c(i,j-1);x4 = 0;x5 = res_c(i-1,j-1);x6 = 0;
                    [no,res_c(i,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 4, beta, labels, bits, no);
                end
            end
            for j = edge+1 : N-edge
                x0 = res_c(M-edge+1,j);x1 = 0;x2 = 0;x3 = res_c(M-edge+1,j-1);x4 = 0;x5 = 0;x6 = 0;
                [no,res_c(M-edge+1,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 2, beta, labels, bits, no);
            end
            for i = edge+1 : M-edge+1
                x0 = res_c(i,N-edge+1);x1 = res_c(i-1,N-edge+1);x2 = 0;x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                [no,res_c(i,N-edge+1)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 0, beta, labels, bits, no);
            end
            for i = M-edge+2 : M
                for j = edge+1 : N-edge+1
                    x0 = res_c(i,j);x1 = res_c(i-1,j);x2 = 0;x3 = res_c(i,j-1);x4 = 0;x5 = res_c(i-1,j-1);x6 = 0;
                    [no,res_c(i,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 4, beta, labels, bits, no);
                end
            end
            for i = 2 : M
                for j = N-edge+2 : N
                    x0 = res_c(i,j);x1 = res_c(i-1,j);x2 = 0;x3 = res_c(i,j-1);x4 = 0;x5 = res_c(i-1,j-1);x6 = 0;
                    [no,res_c(i,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 4, beta, labels, bits, no);
                end
            end
        elseif type == 1
            length = NUM * MSB * M/blocksize * N/blocksize;
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
                        bin = Dec2bin(origin(i,y,channel),8);
                        com(1:beta) = '0';
                        if strcmp(bin(1:beta),com(1:beta)) ~= 1
                            [~,l] = size(bits);
                            bits(l+1:l+8-alpha) = bin(alpha+1:8);
                        end
                    end
                    for j = y-1 : -1 : y-blocksize+1
                        bin = Dec2bin(origin(x,j,channel),8);
                        com(1:beta) = '0';
                        if strcmp(bin(1:beta),com(1:beta)) ~= 1
                            [~,l] = size(bits);
                            bits(l+1:l+8-alpha) = bin(alpha+1:8);
                        end
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
                            bin = Dec2bin(origin(i,j,channel),8);
                            com(1:beta) = '0';
                            if strcmp(bin(1:beta),com(1:beta)) ~= 1
                                [~,l] = size(bits);
                                bits(l+1:l+8-alpha) = bin(alpha+1:8);
                            end
                            count = count + 1;
                        end
                    end
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
                        x0 = res_c(i,y);x1 = 0;x2 = res_c(i+1,y);x3 = 0;x4 = 0;x5 = 0;x6 = 0;
                        [no,res_c(i,y)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 1, beta, labels, bits, no);
                    end
                    for j = y-1 : -1 : y-blocksize+1
                        x0 = res_c(x,j);x1 = 0;x2 = 0;x3 = 0;x4 = res_c(x,j+1);x5 = 0;x6 = 0;
                        [no,res_c(x,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 3, beta, labels, bits, no);
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
                            x0 = res_c(i,j);x1 = 0;x2 = res_c(i+1,j);x3 = 0;x4 = res_c(i,j+1);x5 = 0;x6 = res_c(i+1,j+1);
                            [no,res_c(i,j)] = Reduction(x0,x1,x2,x3,x4,x5,x6, 5, beta, labels, bits, no);
                            count = count + 1;
                        end
                    end
                end
            end
        end
        res(:,:,channel) = res_c;
        [~,l] = size(datas);
        datas(l+1:l+length) = data(1:length);
    end
end

function [no,res] = Reduction(x0,x1,x2,x3,x4,x5,x6, type, beta, labels, bits, no)
    x1_d = double(x1);
    x2_d = double(x2);
    x3_d = double(x3);
    x4_d = double(x4);
    x5_d = double(x5);
    x6_d = double(x6);
    res = x0;
    [range,alpha] = size(labels);
    bin = Dec2bin(x0,8);
    com(1:beta) = '0';
    if strcmp(bin(1:beta),com(1:beta)) == 1
        bin(1:beta) = bits(no:no+beta-1);
        res = bin2dec(bin);
        no = no + beta;
    else
        error = double(bin2dec(bin(1:alpha))) - double(bin2dec(labels(1,:))) + double(ceil(-range/2));
        if type == 0 % x-1 -> x
            res = x1_d + error;
        elseif type == 1 % x+1 -> x
            res = x2_d + error;
        elseif type == 2 % y-1 -> y
            res = x3_d + error;
        elseif type == 3 % y+1 -> y
            res = x4_d + error;
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
            res = double(pred) + error;  
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
            res = double(pred) + error;
        end
    end
end
