%file: Compression.m
%function: compressing the data in order to reduce the space required to store
%data: the data to be compressed
%length: the length that should be compressed, keeping the rest part unchanged
%type: 1 means the big compression while 0 means the little compression
function res = Compression( length, data, type )
    i = 1;%the index of data
    count = 0;%to store the number of '0' or '1'
    res = [];%store the compression result, every progress result in one byte and the LSB is the type of number counted('0' or '1')
    l = 1;%index of res
    flag = 0;%means the number now to calculate is '0'
    if length == 0 
        return;
    end
    if type == 1 % the maximum number of consecutive identical bits is 127
        if data(1)=='0' || data(1)=='1'
            while i <= length
                if data(i) == '0'
                    while i<=length && data(i)=='0' && count<127  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 0;
                elseif data(i) == '1'
                    while i<=length && data(i)=='1' && count<127  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 1;
                end
                t = Dec2bin(count,7);
                res(l:l+6) = t(1:7);
                res(l+7) = flag + '0';
                l = l+8;
                count = 0;
            end
        elseif data(1)==0 || data(1)==1
            while i <= length
                if data(i) == 0
                    while i<=length && data(i)==0 && count<127  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 0;
                elseif data(i) == 1
                    while i<=length && data(i)==1 && count<127  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 1;
                end
                t = Dec2bin(count,7)-'0';
                res(l:l+6) = t(1:7);
                res(l+7) = flag;
                l = l+8;
                count = 0;
            end
        end
    end
    if type == 0 % the maximum number of consecutive identical bits is 7
        if data(1)=='0' || data(1)=='1'
            while i <= length
                if data(i) == '0'
                    while i<=length && data(i)=='0' && count<7  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 0;
                elseif data(i) == '1'
                    while i<=length && data(i)=='1' && count<7  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 1;
                end
                t = Dec2bin(count,3);
                res(l:l+2) = t(1:3);
                res(l+3) = flag + '0';
                l = l+4;
                count = 0;
            end
        elseif data(1)==0 || data(1)==1
            while i <= length
                if data(i) == 0
                    while i<=length && data(i)==0 && count<7  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 0;
                elseif data(i) == 1
                    while i<=length && data(i)==1 && count<7  %calculate the number of '0'
                        count = count+1;
                        i = i+1;
                    end
                    flag = 1;
                end
                t = Dec2bin(count,3)-'0';
                res(l:l+2) = t(1:3);
                res(l+3) = flag;
                l = l+4;
                count = 0;
            end
        end
    end
    [~,len] = size(data);
    res(l:l+len-length-1) = data(length+1:len);
end