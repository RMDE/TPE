%file: RA_RDH.m
%function: the fourth data hiding method to compress some bit-plane in order to reserve the whole highest bit-plane for adjustment 
%origin: the original image

function res = RA_RDH( origin )
    res = origin;
    [M,N,C] = size(origin);
    for channel = 1 : 1 : C
        bits = [];
        [bits,~] = Processing(bits,0,origin(:,:,channel));
        [~,l] = size(bits);
        bits(M*N*8-l+1:M*N*8) = bits(1:l);
        bits(1:M*N*8-l) = 0;
        streams = zeros(M*N,8);
        for i = 1 : 1 : 8
            streams(:,9-i) = bits((i-1)*M*N+1:i*M*N);
        end
        res(:,:,channel) = Merge(streams,M,N);
    end
end

%function:the framework of compressing each bit-plane and reserving room for adjustment process
%bits: store the information for recovery
%k: the current interation number
%I: the half-processed image
function [bits,I] = Processing( bits, k, I )
    [M,N] = size(I); 
    if k < 6
        [Lloc, Lval] = MED(k,I);
%         for i = 1 : 1 : M*N
%             if Lloc(i) ~=0
%                 i,Lloc(i)
%             end
%         end
        [~,l1] = size(Lval);
        if l1 >= floor((M*N-25)/(8-k))
            for i = k : 7
                [~,l] = size(bits);
                bits(l+1:l+M*N) = Disperse(I,i,1); 
                bits(l+M*N+1) = 0; % means not marked
            end
            [~,l] = size(bits);
            bits(l+1:l+8) = dec2bin(I(1,1),8)-'0';
            return;
        else
            I = Adoptation(I,k,Lloc,Lval);
            % change the storing formation of Lval values to make the negative value into positive
            for i = 1 : 1 : l1
                if Lval(i) < 0
                    Lval(i) = Lval(i) + 2^(8-k);
                end
            end
            Lval = dec2bin(Lval,8-k)-'0';
            Lval = Lval';
            Lval = Lval(:);
            [~,l] = size(bits);
            [length,~] = size(Lval);
            bits(l+1:l+length) = Lval(1:length);
            len = Dec2bin(length,24)-'0';
            bits(l+length+1:l+length+24) = len(1:24);
            bits(l+length+25) = 1; % means marked
            [bits,I] = Processing(bits,k+1,I);
        end
    else
        [~,l] = size(bits);
        bits(l+1:l+M*N) = Disperse(I,1,1);
        bits(l+M*N+1) = 0; % means not marked
        [~,l] = size(bits);
        bits(l+1:l+M*N) = Disperse(I,0,1);
        bits(l+M*N+1) = 0; % means not marked
        [~,l] = size(bits);
        bits(l+1:l+8) = dec2bin(I(1,1),8)-'0';
    end 
end

%function: changing the low 8-k bits for recover process
%I: the original image
%Lloc: judge whether the cooresponding pixel should be adopted
%Lval: the value of adopting
function I = Adoptation(I,k,Lloc,Lval)
    [M,N] = size(I);
    index = 1; % index of the Lval
    for j = 1 : 1 : N
        for i = 1 : 1 : M
            if Lloc((j-1)*M+i) ~= 0
                if abs(Lval(index)) ~= 2^(6-k)+1
                    I(i,j) = mod(int32(I(i,j)) + int32(Lval(index)),256);
                end
                index = index + 1;
            end
        end
    end
end

%function: MED prediction
%k: the n0. of the current bit-plane to compress
%I: the original image
function [Lloc, Lval] = MED(k,I)
    [M,N] = size(I);
    Lloc = zeros(1,M*N);
    Lval = [];
    nol = 2; % index of the Lloc 
    nov = 1; % index of the nov
    for j = 1 : 1 : N
        for i = 1 : 1 : M
            if i == 1 && j == 1
                continue;
            end
%             if i == 726 && j == 135
%                 i
%             end
            tmp = dec2bin(I(i,j),8);
            tmp(1:k) = '0';
            p = bin2dec(tmp);
            if i == 1
                pred = Prediction(I,i,j,1,k);
            elseif j == 1
                pred = Prediction(I,i,j,0,k);
            else
                pred = Prediction(I,i,j,2,k);
            end
            inv = bitxor(p,2^(7-k));
            delta = abs(pred - p);
            deltai = abs(pred - inv);
            if delta<deltai && (delta~=2^(6-k) || deltai~=2^(6-k)+2^(7-k))
                Lloc(nol) = 0;
                nol = nol + 1;
            elseif delta>deltai && (delta~=2^(6-k)+2^(7-k) || deltai~=2^(6-k))
%                 Lloc(nol) = 1;
                if p < 2^(7-k)
                    if pred <= inv
                        x = pred - p - 2^(6-k);
                        Lloc(nol) = 1;
                    else
                        x = pred - inv - 2^(6-k);
                        Lloc(nol) = 2;
                    end
                else
                    if pred >= inv
                        x = pred - p + 2^(6-k);
                        Lloc(nol) = 3;
                    else
                        x = pred - inv + 2^(6-k);
                        Lloc(nol) = 4;
                    end
                end
                nol = nol + 1;
                Lval(nov) = x;
                nov = nov + 1;
            else
%                 Lloc(nol) = 1;
                if p < 2^(7-k)
                    x = -(2^(6-k)+1);
                    Lloc(nol) = 5;
                else
                    x = 2^(6-k)+1;
                    Lloc(nol) = 6;
                end
                nol = nol + 1;
                Lval(nov) = x;
                nov = nov + 1;
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