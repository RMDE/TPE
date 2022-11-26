clear;
clc
PATH1 = "D:\Project\TPE\Evaluation\SizeExpansion\origin\";
PATH2 = "D:\Project\TPE\Evaluation\SizeExpansion\result\BBRD\64-1\";
flag = 0;
time = 0.0;
for no = 93 :1: 100
    file = strcat(PATH1,int2str(no),".png");
    origin = imread(file,"png");
    [M,N,C] = size(origin);
    if M<N 
        min = M;
    else
        min = N;
    end
    
    method = 1;
    type = 3;
    blocksize = 64 ;
    MSB = 3;

    NUM = blocksize*blocksize;
    edge = 0;
    key = 1 ;
    t1 = clock;
    EmbImage = RoomReserving(origin, blocksize, MSB, NUM, method, type, edge); 
%     toc
    EnImage = Encryption(origin, key);
    AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
    PerImage = Permutation(AdImage, blocksize, key, edge, 1);
    t2 = clock;
    time = time + etime(t2,t1);
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
    file = strcat(PATH2,"\",int2str(no),".png");
    imwrite(PerImage,file,"png");
end
time/100

