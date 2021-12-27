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
        if l1 >= (M*N-6)*8
            for i = k : 7
                [~,l] = size(bits);
                bits(l+1:L+M*N) = Disperse(I,i,1); 
                bits(l+M*N+1) = 0; % means not marked
            end
            return;
        else
            I = Adoptation(I,k,Lloc,Lval);
            [~,l] = size(bits);
            [~,length] = size(Lval);
            bits(l+1:l+length) = Lval(1:length);
            len = Dec2bin(length,24);
            bits(l+length+1) = bin2dec(len(1:8));
            bits(l+length+2) = bin2dec(len(8:16));
            bits(l+length+3) = bit2dec(len(17:24));
            bits(l+length+4) = 1; % means marked
            [bits,I] = Processing(bits,k+1,I);
        end
    else
        [~,l] = size(bits);
        bits(l+1:l+M*N) = Disperse(I,7,1);
        bits(l+M*N+1) = 0; % means not marked
    end 
end