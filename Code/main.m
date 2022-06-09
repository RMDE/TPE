%file: main.m
%function: run the entire code
clear;
origin = imread("original.png","png");
[M,N,C] = size(origin);
% origin = gpuArray(origin);
% origin = origin(1:8,1:8,1);
% origin =[214,214,220,239,194,209,206,212;218,225,241,215,215,194,229,197;226,253,248,223,241,215,255,201;239,197,250,193,238,222,249,110;199,45,223,85,159,76,141,46;232,12,208,137,244,9,54,19;205,242,92,104,199,59,203,130;167,195,195,129,204,133,247,74];
% % origin = zeros(3,3);
blocksize = 8;
MSB = 2; 
if M<N 
    min = M;
else
    min = N;
end
NUM = 31;
% NUM = 2*(int32(0.09*min)/2);
type = 1;
edge = 0 ;
key = 1 ;
method = 2;
tic
EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge);
toc
EnImage = Encryption(EmbImage, key);
AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
PerImage = Permutation(AdImage, blocksize, key, edge, 1);
%     % 
DepImage = Permutation(PerImage, blocksize, key, edge, -1);
DecImage = Encryption(DepImage, key);
res = Recovery(DecImage, blocksize, MSB, NUM, method, type, edge);
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
% imwrite(EnImage,"D:\Project\TPE\Latex\resource\tra.png","png");
