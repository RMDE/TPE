%file: RA_RDH_r.m
%function: recovery process of the foruth data hiding method  
%origin: the decrypted image

function res = RA_RDH_r( origin )
    res = origin;
    res(:,:,:) = 0;
    [M,N,C] = size(origin);
    bits = [];
    for channel = 1 : 1 : C
        for i = 7 : -1 : 0
            [~,l] = size(bits);
            bits(l+1:l+M*N) = Disperse(origin(:,:,channel),i,1)+'0'; 
        end
        [~,l] = size(bits);
        res(1,1,channel) = bin2dec(char(bits(l-7:l)));
        bits = bits(1:l-8);
        res(:,:,channel) = Processing(bits,7,res(:,:,channel));
    end
end

%function:the framework of recovery process
%bits: store the information for recovery
%k: the current interation number
%I: the half-processed image
function I = Processing( bits, k, I )
    if k == -1
        return;
    end
    [~,l] = size(bits);
    flag = bits(l);
    if flag == 49 % means marked
        length = bin2dec(char(bits(l-24:l-1)));
        Lval = char(bits(l-24-length:l-25));
        bits = bits(1:l-25-length);
        temp = zeros(length/(8-k),8-k);
        count = 1;
        for i = 1 : 8-k : length
            temp(count,:) = Lval(i:i+7-k);
            count = count + 1;
        end
        Lval = bin2dec(char(temp));
        I = Reconstruction(I,Lval,k);
    else
        [M,N] = size(I);
        streams = bits(l-M*N:l-1);
        bits = bits(1:l-M*N-1);
        count = 1; % index of the streams
        for i = 1 : 1 : M
            for j = 1 : 1 : N
                pixel = dec2bin(I(i,j),8);                 
                pixel(k+1) = streams(count);
                count = count + 1;
                I(i,j) = bin2dec(pixel);
            end
        end
    end
    I = Processing(bits,k-1,I);
end

%function: recover the image using Lval
%I: the image to recovery
%Lval: the information for recovery
%k: the current bit-plane
function I = Reconstruction(I, Lval, k)
    [M,N] = size(I);
    [l,~] = size(Lval);
    for i = 1 : 1 : l
        if Lval(i) > 2^(7-k)
            Lval(i) = Lval(i) - 2^(8-k);
        end
    end
    index = 1; %index of the Lval
    for j = 1 : 1 : N
        for i = 1 : 1 : M
            if i==1 && j==1
                continue;
            end
%             if i == 726 && j == 135
%                 i
%             end
            tmp = dec2bin(I(i,j),8);
            tmp = tmp(k+2:8);
            p = bin2dec(tmp);
            p0 = p;
            p1 = p + 2^(7-k);
            if i == 1
                pred = Prediction(I,i,j,1,k);
            elseif j == 1
                pred = Prediction(I,i,j,0,k);
            else
                pred = Prediction(I,i,j,2,k);
            end
            delta0 = abs(pred-p0);
            delta1 = abs(pred-p1);
            if (delta0==2^(6-k)&&delta1==2^(6-k)) || (delta0==2^(6-k)&&delta1==2^(6-k)+2^(7-k)) || (delta1==2^(6-k)&&delta0==2^(6-k)+2^(7-k))
%             if (delta0~=2^(6-k)||delta1~=2^(6-k)+2^(7-k)) && (delta0~=2^(6-k)+2^(7-k)||delta1~=2^(6-k)) && (delta0~=2^(6-k)||delta1==2^(6-k)) && (delta0==2^(6-k)||delta1~=2^(6-k))
                if abs(Lval(index)) ~= 2^(6-k)+1
                    p0 = mod(int32(p0)-int32(Lval(index)),2^(8-k));
                    p1 = mod(int32(p1)-int32(Lval(index)),2^(8-k));
                    delta0 = abs(pred-p0);
                    delta1 = abs(pred-p1);
                    if delta0 > delta1
                        I(i,j) = p0;
                    else
                        I(i,j) = p1;
                    end
                else
                    if Lval(index) == -(2^(6-k)+1)
                        I(i,j) = p0;
                    else
                        I(i,j) = p1;
                    end
                end
                index = index + 1;
            else    
                if delta0 < delta1
                    I(i,j) = p0;
                else
                    I(i,j) = p1;
                end
            end
        end
    end
end

%function: predicting pixels using middle error prediction
%origin: the origin image
%x,y: the location of the pixel to be predicted
%type: the prediction type according to the location in the image
%k: the current iteration
function pred = Prediction(origin, x, y, type, k)
    if type == 0 % x-1 -> x
        tmp = dec2bin(origin(x-1,y),8);
        tmp(1:k) = '0';
        pred = bin2dec(tmp);
    elseif type == 1 % y-1 -> y
        tmp = dec2bin(origin(x,y-1),8);
        tmp(1:k) = '0';
        pred = bin2dec(tmp);
    elseif type == 2
        tmp = dec2bin(origin(x-1,y),8);
        tmp(1:k) = '0';
        a = bin2dec(tmp);
        tmp = dec2bin(origin(x,y-1),8);
        tmp(1:k) = '0';
        b = bin2dec(tmp);
        if a > b
            min = b;
            max = a;
        else
            min = a;
            max = b;
        end
        tmp = dec2bin(origin(x-1,y-1),8);
        tmp(1:k) = '0';
        c = bin2dec(tmp);
        if c < min
            pred = max;
        elseif c > max
            pred = min;
        else
            pred = double(a) + double(b) - double(c);
        end
    end
end