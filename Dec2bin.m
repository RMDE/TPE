%file:Dec2bin.m
%change from function dec2bin
%adding: the solution of negative integer
%number: the number to change
%n: the number of bits that the result has    n<=32
function res = Dec2bin( number, n )
bit=[];
bits = '00000000000000000000000000000000';
if number > 0
    temp = dec2bin(number);
    [~,l] = size(temp);
    bits(n-l+1:n) = temp(1:l);
elseif number == 0
    bits = '00000000000000000000000000000000';
else
    bit = Dec2bin(-number,n);
    for i = 1 : n
        if bit(i) == '0'
            bits(i) = '1';
        else
            bits(i) = '0';
        end
    end
    bits = bits(1:n);
    bit = bin2dec(bits);
    bits= Dec2bin(bit+1,n);
end
res(1:n) = bits(1:n);
end