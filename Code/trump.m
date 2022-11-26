% test.m
clear;
PATH1 = "D:\Project\dataset\trump\IBRD-64-1\";
PATH2 = PATH1; %"D:\Project\dataset\trump\IBRD-8-1\";
flag = 0;
% list = dir(strcat(PATH1,'*.png'));
for no = 1 : 4
    file1 = strcat(PATH1,int2str(no),"-res.png")
    origin = imread(file1,"png");
    [M,N,C] = size(origin);
    blocksize = 64;
    MSB = 1;
    if M<N 
        min = M;
    else
        min = N;
    end
    m = M/blocksize;
    n = N/blocksize;
%     NUM = 2*(int32(0.06*min)/2);
%     NUM = 47;
%     type = 1;
%     edge = 0 ;
%     key = 1 ;
%     method = 0;
%     EnImage = Encryption(origin, key);
%     AdImage = Adjustment(EnImage, origin, blocksize, MSB, NUM, type);
%     PerImage = Permutation(AdImage, blocksize, key, edge, 1);
result1 = origin;
for chanal = 1:C
for i = 1 : m
        for j = 1 : n
            x = (i-1)*blocksize+1;
            y = (j-1)*blocksize+1;
            sub1(1:blocksize,1:blocksize) = origin(x:x+blocksize-1,y:y+blocksize-1,chanal);
            value1 = mean2(sub1);
            for p = x : x+blocksize-1
                for q = y : y+blocksize-1
                    result1(p,q,chanal) = value1;
                end
            end
        end 
end
end
    file2 = strcat(PATH2,int2str(no),"-th.png");
    imwrite(result1,file2,"png");
end