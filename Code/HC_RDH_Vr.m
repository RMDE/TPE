%file: HC_RDH_Vr.m
%function: extracting the embedded data and recover the embedding area
%origin: the image after decryption process
%locatex & locatey: the location of first pixel in embedding block
% locate_map: record whether the cooresponding block has embedded extra data
function [data,result] = HC_RDH_Vr( origin, locatex, locatey )
    result = origin;
    [~,~,C] = size(origin);
    [~,len] = size(locatex);
    data = [];
    for chanal = 1 : 1 : C
        ori = origin(:,:,chanal);
        res = ori;
        count = 1; %index of bits
        bits = '';
        for index = 1 : 1 : len
            x = locatex(index);
            y = locatey(index);
            bits(count:count+7) = dec2bin(ori(x,y),8);
            bits(count+8:count+15) = dec2bin(ori(x,y+1),8);
            bits(count+16:count+23) = dec2bin(ori(x+1,y),8);
            bits(count+24:count+31) = dec2bin(ori(x+1,y+1),8);
            count = count + 32;
        end
        [~,l] = size(bits);
        for i = l : -1 : 1
            if bits(i) == '1'
                bits = bits(1:i-1);
                extract = i-1
                break;
            end
        end
        length = bin2dec(bits(1:24));
        locate_map = Decompression(len,bits(25:24+length),0);
        count = 25+length; % index of prediction result
        for index = 1 : 1 : len
            x = locatex(index);
            y = locatey(index);
            if locate_map(index) == '1'
                res(x,y) = bin2dec(bits(count:count+7));
                res(x,y+1) = bin2dec(bits(count+8:count+15));
                res(x+1,y) = bin2dec(bits(count+16:count+23));
                res(x+1,y+1) = bin2dec(bits(count+24:count+31));
                count = count + 32;
            else
                pred = bits(count:count+7);
                md = bin2dec(bits(count+8:count+10)) + 1;
                d = 8 - md;
                res(x,y) = bin2dec(pred);
                pred(md+1:8) = bits(count+11:count+10+d);
                res(x,y+1) = bin2dec(pred);
                pred(md+1:8) = bits(count+11+d:count+10+2*d);
                res(x+1,y) = bin2dec(pred);
                pred(md+1:8) = bits(count+11+2*d:count+10+3*d);
                res(x+1,y+1) = bin2dec(pred);
                count = count + 8 + 3 + 3*(8-md);
            end 
        end
        [~,l1] = size(bits);
        [~,l2] = size(data);
        data(l2+1:l1-count+l2+1) = bits(count:l1);
        result(:,:,chanal) = res(:,:);
    end
end
