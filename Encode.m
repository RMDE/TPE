%file: Encode.m
%function: Encode the MSBs of the pixels in the adjustment area which gather all bits of the same index together for compression
%data: the data to be encoded
%MSB: number of MSBs bits
function res = Encode( data, MSB )
    [~,len] = size(data);
    res = zeros(1,len);
    for i = 1 : 1 : MSB
        res((i-1)*(len/MSB)+1:i*(len/MSB)) = data(i:MSB:len-MSB+i); 
    end
end