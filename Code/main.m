%file: main.m
%function: run the entire code
origin = uint8(round(rand(32,32)*0));
size(origin)
MSB = 2;
NUM = 4;
blocksize = 8;
type = 0;
key = 1;
% EnImage = Encryption(origin,key);
% AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
% EnImage = Encryption(EnImage,key);
Permutation(origin, blocksize, key)