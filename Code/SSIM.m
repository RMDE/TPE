clear;
folder = dir("D:\Project\TPE\experiment\thumbnail_result\");
blocksizes = {'8','16','16','16','32','32','32','64','64','64','8','8'};
for ff = 1 : 72
    PATH2 = strcat("D:\Project\TPE\experiment\thumbnail_result\",folder(ff).name,"\");
    PATH1 = strcat("D:\Project\TPE\experiment\thumbnail_origin\",blocksizes(mod(ff,12)+1),"\");
    flag = 0;
    sum = 0.0;
    for no = 1 :1: 1500
        file1 = strcat(PATH1,int2str(no),".png");
        file2 = strcat(PATH2,int2str(no),".png");
        img1 = imread(file1,"png");
        img2 = imread(file2,"png");
        sum = sum + ssim(img1,img2);
    end
    folder(ff).name
    sum/1500
end