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
        [~,res] = Processing(bits,7,origin);
    end
end

%function:the framework of recovery process
%bits: store the information for recovery
%k: the current interation number
%I: the half-processed image
function [bits,I] = Processing( bits, k, I )
    [~,l] = size(bits);
    
end