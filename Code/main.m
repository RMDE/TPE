%file: main.m
%function: run the entire code
origin = imread("original.png","png");
% origin = origin(:,:,1);
% origin = zeros(3,3);
blocksize = 64;
MSB = 3;
NUM = 150;
type = 0;
edge = NUM ;
key = 1 ;
method = 0;
EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge); 
EnImage = Encryption(EmbImage, key);
AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
PerImage = Permutation(AdImage, blocksize, key, edge, 1);
% 
DepImage = Permutation(PerImage, blocksize, key, edge, -1);
DecImage = Encryption(DepImage, key);
res = Recovery(DecImage, blocksize, MSB, NUM, method, type, edge);
[M,N,C] = size(origin);
for chanal = 1 : C
    for i = 1 : M
        for j = 1 : N
            if res(i,j,chanal)~=origin(i,j,chanal)
                i,j,chanal
                return
            end
        end
    end
end
imwrite(PerImage,"result.png","png");
