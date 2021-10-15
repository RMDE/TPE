%file:Dec2bin.m
%change from function dec2bin
%adding: the solution of negative integer
%the result always has 8 bits
%number: the number to change
%n: the number of bits that the result has
function res = Dec2bin( number, n )
bit=[];
bits = '00000000';
if number > 0
    temp = dec2bin(number);
    [~,l] = size(temp);
    bits(8-l+1:8) = temp(1:l);
elseif number == 0
    bits = '00000000';
else
    bit = Get(bit,-number,8);
    for i = 1 : 8
        if bit(i) == 0
            bits(i) = '1';
        else
            bits(i) = '0';
        end
    end
    bit = bin2dec(bits);
    bits= dec2bin(bit+1);
end
res(1:n) = bits(8-n+1:8);
end