clear;
clc
PATH1 = "D:\Project\TPE\Evaluation\SizeExpansion\origin\";
PATH2 = "D:\Project\TPE\Evaluation\SizeExpansion\result\BBRD\32-3\";
flag = 0;
time = 0.0;
for no = 1 :1: 100
    file = strcat(PATH1,int2str(no),".png");
    origin = imread(file,"png");
    [M,N,C] = size(origin);
    if M<N 
        min = M;
    else
        min = N;
    end
    
    method = 3;
    type = 3;
    blocksize = 32 ;
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

    file = strcat(PATH2,"\",int2str(no),".png");
    imwrite(PerImage,file,"png");
end
time/100

