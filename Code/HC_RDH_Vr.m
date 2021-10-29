%file: HC_RDH_Vr.m
%function: extracting the embedded data and recover the embedding area
%origin: the image after decryption process
%locatex & locatey: the location of first pixel in embedding block
% locate_map: record whether the cooresponding block has embedded extra data
function [data,res] = HC_RDH_Vr( origin, locatex, locatey )
    res = origin;
    [~,~,C] = size(origin);
    [~,len] = size(locatex);
    data = [];
    count = 1; % index of the bits
    for chanal = 1 : 1 : C
        for index = 1 : 1 : len
            bits(count:count+7) =  dec2bin(origin(locatex(index),locatey(index),chanal));
            bits(count+8:count+15) =  dec2bin(origin(locatex(index),locatey(index)+1,chanal));
            bits(count+16:count+23) =  dec2bin(origin(locatex(index)+1,locatey(index),chanal));
            bits(count+24:count+31) =  dec2bin(origin(locatex(index)+1,locatey(index)+1,chanal));
            count = count + 32;
        end
        [~,l] = size(bits);
        for i = l : -1 : 1
            if bits(i) == '1'
                bits = bits(1:i-1);
                break;
            end
        end
        length = bin2dec(bits(1:24));
        locate_map = Decompression(length,bits(25:24+length),0);
        count = 25+length; % index of prediction result
        for index = 1 : 1 : len
            if locate_map(index) == '1'
                res(locatex(index),locatey(index),chanal) = bin2dec(bits(count:count+7));
                res(locatex(index),locatey(index)+1,chanal) = bin2dec(bits(count+8:count+15));
                res(locatex(index)+1,locatey(index),chanal) = bin2dec(bits(count+16:count+23));
                res(locatex(index)+1,locatey(index)+1,chanal) = bin2dec(bits(count+24:count+32));
                count = count + 32;
            else
                pred = bits(count:count+7);
                md = bin2dec(bits(count+8:count+10)) + 1;
                res(locatex(index),locatey(index),chanal) = bin2dec(pred);
                pred(md+1:8) = bits(count+11:count+10+d);
                res(locatex(index),locatey(index)+1,chanal) = bin2dec(pred);
                pred(md+1:8) = bits(count+11+d:count+10+2*d);
                res(locatex(index)+1,locatey(index),chanal) = bin2dec(pred);
                pred(md+1:8) = bits(count+11+2*d:count+10+3*d);
                res(locatex(index)+1,locatey(index)+1,chanal) = bin2dec(pred);
                count = count + 8 + md + 3*(8-md); 
            end 
        end
        [~,l] = size(bits);
        data = bits(count:l);
    end
end
