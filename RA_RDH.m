%file: RA_RDH.m
%function: the fourth data hiding method to compress some bit-plane in order to reserve the whole highest bit-plane for adjustment 
%origin: the original image

function res = RA_RDH( origin )
    [~,~,C] = size(origin);
    for channel = 1 : 1 : C
        [bits,~] = Processing(0,origin(:,:,channel));
        [~,l] = size(bits);
        bits(M*N*8-l+1:M*N*8) = bits(1:l);
        bits(1:M*N*8-l) = 0;
        streams = zeros(M*N,8);
        for i = 1 : 1 : 8
            streams(:,i) = bits((i-1)*M*N+1:i*M*N);
        end
        res = Merge(streams,M,N);
    end
end

%function:the framework of compressing each bit-plane and reserving room for adjustment process
%bits: store the information for recovery
%k: the current interation number
%I: the half-processed image
function [bits,I] = Processing( bits, k, I )
    [M,N] = size(I); 
    if k < 7
        [Lloc, Lval] = MED(k,I);
        [~,l1] = size(Lval);
        if l1 >= floor((M*N-33)/(7-k))
            for i = k : 7
                [~,l] = size(bits);
                bits(l+1:L+M*N) = Disperse(I,i,1); 
                bits(l+M*N+1) = 0; % means not marked
            end
            return;
        else
            I = Adoptation(I,k,Lloc,Lval);
            Lval = dec2bin(Lval,7-k);
            Lval = Lval(:);
            [~,l] = size(bits);
            [~,length] = size(Lval);
            bits(l+1:l+length) = Lval(1:length);
            len = Dec2bin(length,24);
            bits(l+length+1:l+length+24) = len(1:24);
            bits(l+length+25:l+length+32) = Dec2bin(I(1,1),8);
            bits(l+length+33) = 1; % means marked
            [bits,I] = Processing(bits,k+1,I);
        end
    else
        [~,l] = size(bits);
        bits(l+1:l+M*N) = Disperse(I,7,1);
        bits(l+M*N+1) = 0; % means not marked
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
            if Lloc((j-1)*M+i) == 1
                if Lval(index) ~= 2^(6-k)+1
                    I(i,j) = I(i,j) + Lval(index);
                    index = index + 1;
                end
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
    nol = 1; % index of the Lloc 
    nov = 1; % index of the nov
    for j = 1 : 1 : N
        for i = 1 : 1 : M
            if i == 1 && j == 1
                continue;
            end
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
            inv = xor(p,2^(7-k));
            delta = abs(pred - p);
            deltai = abs(pred - inv);
            if delta<deltai && (delta~=2^(6-k) || deltai~=2^(6-k)+2^(7-k))
                Lloc(nol) = 0;
                nol = nol + 1;
            elseif delta>deltai && (delta~=2^(6-k)+2^(7-k) || deltai~=2^(6-k))
                Lloc(nol) = 1;
                nol = nol + 1;
                if p < 2^(7-k)
                    if p <= inv
                        x = pred - p - 2^(6-k);
                    else
                        x = pred - inv - 2^(6-k);
                    end
                else
                    if p >= inv
                        x = pred - p + 2^(6-k);
                    else
                        x = pred - inv + 2^(6-k);
                    end
                end
                Lval(nov) = x;
                nov = nov + 1;
            else
                Lloc(nol) = 1;
                nol = nol + 1;
                if p < 2^(7-k)
                    x = -(2^(6-k)+1);
                else
                    x = 2^(6-k)+1;
                end
                Lval(nov) = x;
                nov = nov + 1;
            end
        end
    end
    % change the storing formation of Lval values to make the negative value into positive
    for i = 1 : 1 : nov-1
        % testing
        if Lval(i)>=2^(6-k) || Lval(i)<=-2^(6-k)
            i
        end
        
        if Lval(i) < 0
            Lval(i) = Lval(i) + 2^(7-k);
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