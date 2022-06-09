%file: HC_RDH_r.m
%function: extracting the embedded data and recover the embedding area
%origin: the image after decryption process
%locatex & locatey: the location of first pixel in embedding block
% locate_map: record whether the cooresponding block has embedded extra data
function [data,result] = HC_RDH_r(origin, locatex, locatey, locate_map)
    result = origin;
    [~,~,C] = size(origin);
    [~,len] = size(locatex);
    data = [];
    count = 1; % index of the embedded data
    for chanal = 1 : 1 : C
        ori = origin(:,:,chanal);
        res = ori;
        [~,l] = size(locate_map);
        for i = l : -1 : 1
            if locate_map(chanal,i) == 1
                locate_map(chanal,i) = 0;
                flag = i-1;
                break;
            end
        end
        locate_map(chanal,1:len) = Decompression(len,locate_map(chanal,1:flag),0);        
        for index = 1 : 1 : len
            % judge wheather the block has embedded the extra data
            % 1 means the block has no extra data embedded
            if locate_map(chanal,index) == 1
                continue;
            end
            x = locatex(index);
            y = locatey(index);
            pred = dec2bin(ori(x,y),8);
            bits(1:8) = dec2bin(ori(x,y+1),8);
            bits(9:16) = dec2bin(ori(x+1,y),8);
            bits(17:24) = dec2bin(ori(x+1,y+1),8);
            md = bin2dec(bits(1:3))+1;
            e1 = bits(4:3+(8-md));
            e2 = bits(4+(8-md):3+2*(8-md));
            e3 = bits(4+2*(8-md):3+3*(8-md));
            data(count:count+20-3*(8-md)) = bits(4+3*(8-md):24);
            count = count + 21-3*(8-md);
            pred(md+1:8) = e1(1:(8-md));
            res(x,y+1) = bin2dec(pred);
            pred(md+1:8) = e2(1:(8-md));
            res(x+1,y) = bin2dec(pred);
            pred(md+1:8) = e3(1:(8-md));
            res(x+1,y+1) = bin2dec(pred);
        end
        result(:,:,chanal) = res(:,:);
    end
    [~,len] = size(data);
    for i = len : -1 : 1
        if data(i) == '1' 
            data = data(1:i-1);
            extract = i-1
            break;
        end
    end
end
