%file: RA_RDH_r.m
%function: recovery process of the foruth data hiding method  
%origin: the decrypted image

function res = RA_RDH_r( origin )
    [~,~,C] = size(origin);
    bits = [];
    for channel = 1 : 1 : C
        for i = 7 : -1 : 0
            [~,l] = size(bits);
            bits(l+1:l+M*N) = Disperse(origin,i,1); 
        end
        res = Processing(bits,7,origin);
    end
end

%function:the framework of recovery process
%bits: store the information for recovery
%k: the current interation number
%I: the half-processed image
function I = Processing( bits, k, I )
    [~,l] = size(bits);
    flag = bits(l);
    if k == -1
        return;
    end
    if flag == 1 % means marked
        I(1,1) = bin2dec(bits(l-8:l-1));
        length = bin2dec(bits(l-32:l-9));
        Lval = bits(l-32-length:l-33);
        bits = bits(1:l-33-length);
        temp = zeros(length/(7-k),7-k);
        count = 1;
        for i = 1 : 7-k : length
            temp(count,:) = Lval(i:i+6-k);
            count = count + 1;
        end
        Lval = bin2dec(char(temp));
        I = Reconstruction(I,Lval,k);
    else
        [M,N] = size(I);
        streams = bits(l-M*N:l-1);
        bits = bits(1:l-M*N-1);
        count = 0; % index of the streams
        for j = 1 : 1 : N
            for i = 1 : 1 : M
                pixel = Dec2bin(I(i,j),8);                 
                pixel(k+1) = streams(count);
                count = count + 1;
                I(i,j) = bin2dec(pixel);
            end
        end
    end
    I = Procesing(bits,k-1,I);
end

%function: recover the image using Lval
%I: the image to recovery
%Lval: the information for recovery
%k: the current bit-plane
function I = Reconstruction(I, Lval, k)
    [~,l] = size(Lval);
    for i = 1 : 1 : l
        if Lval(i) > 2^(6-k)
            Lval(i) = Lval(i) - 2^(7-k);
        end
    end
    index = 1; %index of the Lval
    for j = 1 : 1 : N
        for i = 1 : 1 : M
            if i==1 && j==1
                continue;
            end
            tmp = dec2bin(origin(i.j),8);
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
            if (delta0~=2^(6-k)&&delta1~=2^(6-k)) || (delta0~=2^(6-k)&&delta0~=2^(6-k)+2^(7-k)) || (delta1~=2^(6-k)||delta1~=2^(6-k)+2^(7-k))
                if delta0 < delta1
                    I(i,j) = p0;
                else
                    I(i,j) = p1;
                end
            else
                if abs(Lval(index)) ~= 2^(6-k)+1
                    p0 = mod(p0-Lval(index),2^(8-k));
                    p1 = mod(p1-Lval(index),2^(8-k));
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