% %file: main.m
% %function: run the entire code
% clear;
% origin = imread("original.png","png");
% [M,N,C] = size(origin);
% % origin = gpuArray(origin);
% % origin = origin(1:8,1:8,1);
% % origin =[214,214,220,239,194,209,206,212;218,225,241,215,215,194,229,197;226,253,248,223,241,215,255,201;239,197,250,193,238,222,249,110;199,45,223,85,159,76,141,46;232,12,208,137,244,9,54,19;205,242,92,104,199,59,203,130;167,195,195,129,204,133,247,74];
% % % origin = zeros(3,3);
% blocksize = 8;
% MSB = 2; 
% if M<N 
%     min = M;
% else
%     min = N;
% end
% NUM = 31;
% % NUM = 2*(int32(0.09*min)/2);
% type = 3;
% edge = 0 ;
% key = 1 ;
% method = 3;
% tic
% EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge);
% toc
% EnImage = Encryption(EmbImage, key);
% AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
% PerImage = Permutation(AdImage, blocksize, key, edge, 1);
% %     % 
% DepImage = Permutation(PerImage, blocksize, key, edge, -1);
% DecImage = Encryption(DepImage, key);
% res = Recovery(DecImage, blocksize, MSB, NUM, method, type, edge);
% for chanal = 1 : C
%     for i = 1 : M
%         for j = 1 : N
%             if res(i,j,chanal)~=origin(i,j,chanal)
%                 i,j,chanal
%                 return
%             end
%         end
%     end
% end
% % imwrite(EnImage,"D:\Project\TPE\Latex\resource\tra.png","png");
% test.m
clear;
PATH1 = "D:\Project\dataset\Corel5K\Jing\";
PATH2 = "D:\Project\TPE\experiment\Corel5K\Jing\";
flag = 0;
methods = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3];
region = [0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3];
blocks = [8,8,8,16,16,16,32,32,32,64,64,64,8,8,8,16,16,16,32,32,32,64,64,64,8,8,8,16,16,16,32,32,32,64,64,64,8,8,8,16,16,16,32,32,32,64,64,64,8,8,8,16,16,16,32,32,32,64,64,64,8,8,8,16,16,16,32,32,32,64,64,64];
rho = [1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3,1,2,3];
SUM = [0.06,0.15,0.22,0.06,0.15,0.22,0.06,0.15,0.22,0.06,0.15,0.22,39,31,14,188,124,97,720,496,328,3076,2180,2049,0,0,0,0,0,0,0,0,0,0,0,0,0.04,0.12,0.20,0.04,0.12,0.20,0.04,0.12,0.20,0.04,0.12,0.20,47,31,22,200,147,75,818,612,424,3321,2502,1733,0,0,0,0,0,0,0,0,0,0,0,0];
parfor i = 1 : 60
for no = 1 :1: 900
    file = strcat(PATH1,int2str(no),".png");
    origin = imread(file,"png");
%     origin = origin(:,:,1);
%     origin = origin(1:18,1:18,1);
    [M,N,C] = size(origin);
    if M<N 
        min = M;
    else
        min = N;
    end
    
    method = methods(i);
    type = region(i);
    blocksize = blocks(i) ;
    MSB = rho(i);
% %     NUM = 2*(int32(0.20*min)/2);
%     NUM = blocksize*blocksize;
%     edge = 0;%NUM;
    if type == 0
        edge = 2*(int32(SUM(i)*min)/2);
        NUM = edge;
    elseif type == 1
        edge = 0;
        NUM = SUM(i);
    else
        edge = 0;
        NUM = blocksize*blocksize;
    end
    key = 1 ;
%     tic
%     EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge); 
%     toc
    EnImage = Encryption(origin, key);
    AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
    PerImage = Permutation(AdImage, blocksize, key, edge, 1);
%     % %     DepImage = Permutation(PerImage, blocksize, key, edge, -1);
%     DecImage = Encryption(DepImage, key);
%     for chanal = 1 : C
%         for i = 1 : M
%             for j = 1 : N
%                 if (i>edge && i<=M-edge) && (j>edge &&j <=N-edge)
%                     continue;
%                 end
%                 if EmbImage(i,j,chanal)~=DecImage(i,j,chanal)
%                     i,j,chanal
%                     return
%                 end
%             end
%         end
%     end
%     res = Recovery(EmbImage, blocksize, MSB, NUM, method, type, edge);
%     for chanal = 1 : C
%         for i = 1 : M
%             for j = 1 : N
%                 if res(i,j,chanal)~=origin(i,j,chanal)
%                     i,j,chanal
% %                     return
%                 end
%             end
%         end
%     end
    file = strcat(PATH2,int2str(i),"\",int2str(no),".png");
    imwrite(PerImage,file,"png");
end
end
