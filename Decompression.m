%file: Decompression.m
%function: decompressing the data in order to reduce the space required to store
%length: the original length of the uncompressed part of the data
%data: the data to be decompressed
%type: 1 means the big compression while 0 means the little compression
function res = Decompression( length, data, type )
    [~,l] = size(data);
    index = 1; %index of the data
    res = zeros(1,length);
    count = 1; %index of the res
    if type == 1
        if data(1) == 1 || data(1) == 0
            while count <= length
                n = data(index)*64+data(index+1)*32+data(index+2)*16+data(index+3)*8+data(index+4)*4+data(index+5)*2+data(index+6);
                res(count:count+n-1) = data(index+7); 
                count = count + n;
                index = index + 8;
            end
        elseif data(1) == '1' || data(1) == '0'
            while count <= length
                n = (data(index)-'0')*64+(data(index+1)-'0')*32+(data(index+2)-'0')*16+(data(index+3)-'0')*8+(data(index+4)-'0')*4+(data(index+5)-'0')*2+data(index+6)-'0';
                res(count:count+n-1) = data(index+7); 
                count = count + n;
                index = index + 8;
            end
        end
    elseif type == 0
        if data(1) == 1 || data(1) == 0
            while count <= length
                n = data(index)*4+data(index+1)*2+data(index+2);
                res(count:count+n-1) = data(index+3); 
                count = count + n;
                index = index + 4;
            end
        elseif data(1) == '1' || data(1) == '0'
            while count <= length
                n = (data(index)-'0')*4+(data(index+1)-'0')*2+data(index+2)-'0';
                res(count:count+n-1) = data(index+3); 
                count = count + n;
                index = index + 4;
            end
        end
    end
    res(count:count+l-index) = data(index:l);
end