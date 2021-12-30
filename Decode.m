%file: Decode.m
%function: Decode the MSBs of the pixels in the adjustment area which gather all bits of the same pixel together 
%data: the data to be decoded
%MSB: number of MSBs bits
function res = Decode( data, MSB )
    [~,len] = size(data);
    res = zeros(1,len);
    for i = 1 : 1 : MSB
        res(i:MSB:len-MSB+i) = data((i-1)*(len/MSB)+1:i*(len/MSB)); 
    end
end