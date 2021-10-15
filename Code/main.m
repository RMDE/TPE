%file: main.m
%function: run the entire code
origin = uint8(round(rand(32,32)*0));
size(origin)
MSB = 2;
NUM = 38;
blocksize = 8;
type = 1;
key = 1;
edge = 0; 
% EmbImage = Roomreserving(origin, blocksize, MSB, NUM, method, type, edge) 
% EnImage = Encryption(origin, key);
% AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
% PerImage = Permutation(AdImage, blocksize, key, 1);

% DepImage = Permutation(PerImage, blocksize, key, -1);
% DecImage = Encryption(origin, key);
% RecImage = Recovery(origin, blocksize, MSB, NUM, method, type, edge);