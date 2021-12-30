%test.m
origin = imread("original.png","png");
blocksize = 8;
MSB = 1;
NUM = 28;
type = 1;
edge = 16;
key = 1 ;
method = 2;
EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge); 
% EnImage = Encryption(EmbImage, key);
% AdImage = Adjustment(EnImage, origin, blocksize, 1, NUM, 1);
% PerImage = Permutation(AdImage, blocksize, key, edge, 1);
% 
% DepImage = Permutation(PerImage, blocksize, key, edge, -1);
% DecImage = Encryption(DepImage, key);
res = Recovery(EmbImage, blocksize, MSB, NUM, method, type, edge);
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
% imwrite(PerImage,"result.png","png");
