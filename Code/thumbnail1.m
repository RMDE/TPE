blocksizes = [8,16,32,64];
for ff = 1 : 4
PATH2 = "D:\Project\TPE\experiment\Corel5K\Jing\";
PATH1 = "D:\Project\TPE\experiment\Corel5K\Jing\";
flag = 0;
for no = 1 :1: 700
    file = strcat(PATH1,int2str(no),".png");
    whole = imread(file,"png");
    [M,N,C] = size(whole);
    blocksize = blocksizes(ff);
    m = M/blocksize;
    n = N/blocksize;
    values = zeros(m,n);%store the original average pixel of every block
    sub1 = zeros(blocksize);
    sub2 = zeros(blocksize);
    result1 = whole;
    for chanal = 1:C
    for i = 1 : m
            for j = 1 : n
                x = (i-1)*blocksize+1;
                y = (j-1)*blocksize+1;
                sub1(1:blocksize,1:blocksize) = whole(x:x+blocksize-1,y:y+blocksize-1,chanal);
                value1 = mean2(sub1);
                for p = x : x+blocksize-1
                    for q = y : y+blocksize-1
                        result1(p,q,chanal) = value1;
                    end
                end
            end 
    end
    end
    file = strcat(PATH2,int2str(no+ff*700),".png");
    imwrite(result1,file,"png");
end
end