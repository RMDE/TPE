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
    if flag == 1 % means marked
        I(1,1) = bin2dec(bits(l-8:l-1));
        length = bin2dec(bits(l-32:l-9));
        Lval = bits(l-32-length:l-33);
        bits = bits(1:l-33-length);
        % TODO:process Lval bits to integer
        I = Reconstruction(I,Lval);
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