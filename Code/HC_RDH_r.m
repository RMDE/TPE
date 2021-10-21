%file: HC_RDH.m
%function: extracting the embedded data and recover the embedding area
%origin: the image after decryption process
%locatex & locatey: the location of first pixel in embedding block
% locate_map: record whether the cooresponding block has embedded extra data
function [data,res] = HC_RDH_r(origin, locatex, locatey, locate_map)
    res = origin;
    [~,~,C] = size(origin);
    [~,len] = size(locatex);
    data = [];
    count = 1; % index of the embedded data
    for chanal = 1 : 1 : C
        [~,l] = size(locate_map);
        for i = l : -1 : 1
            if locate_map(chanal,i) == 1
                locate_map(chanal,i:l) = 0;
                break;
            end
        end
        locate_map(chanal,:) = Decompression(len,locate_map(chanal,:),0);        
        for index = 1 : 1 : len
            % judge wheather the block has embedded the extra data
            % 1 means the block has no extra data embedded
            if locate_map(chanal,index) == 1
                continue;
            end
            pred = Dec2bin(origin(locatex(index),locatey(index),chanal),8);
            bits(1:8) = Dec2bin(origin(locatex(index),locatey(index)+1,chanal),8);
            bits(9:16) = Dec2bin(origin(locatex(index)+1,locatey(index),chanal),8);
            bits(17:24) = Dec2bin(origin(locatex(index)+1,locatey(index)+1,chanal),8);
            md = bin2dec(bits(1:3))+1;
            e1 = bits(4:3+(8-md));
            e2 = bits(4+(8-md):3+2*(8-md));
            e3 = bits(4+2*(8-md):3+3*(8-md));
            data(count:count+20-3*(8-md)) = bits(4+3*(8-md):24);
            count = count + 21-3*(8-md);
            pred(md+1:8) = e1(1:(8-md));
            res(locatex(index),locatey(index)+1,chanal) = bin2dec(pred);
            pred(md+1:8) = e2(1:(8-md));
            res(locatex(index)+1,locatey(index),chanal) = bin2dec(pred);
            pred(md+1:8) = e3(1:(8-md));
            res(locatex(index)+1,locatey(index)+1,chanal) = bin2dec(pred);
        end
    end
    [~,len] = size(data);
    for i = len : -1 : 1
        if data(i) == '1'
            data = data(1:i-1);
            break;
        end
    end
end
