%file: Recovery.m
%to recover the image 
%origin: the adjusted image 
%blocksize: size of block
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels in the adjustment area
function ReImage = Recovery( origin, key, blocksize, MSB, NUM )
    DeImage = Encryption(origin, key);
    % TODO
end