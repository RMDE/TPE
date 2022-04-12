%file: Adjustment.m
%to adjust the MSB of pixel in adjustment area in order to keep the Thumbnail the same
%origin: the image after room reserving and encipher progress
%compare: the original image for calculating the average pixel values of blocks
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels that the adjustment area contains (type==1)
%     the width of the embedding area at the edge of the image (type==0)
%type: illustrate the distribution of the adjustment areas. 
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole embedding area is at the edge of the image
function AjImage = Adjustment( origin, compare, blocksize, MSB, NUM, type)
AjImage = origin;
[M,N,C] = size(AjImage);
    
if type == 1
    m = M/blocksize;
    n = N/blocksize;
    sub = zeros(blocksize);
    for chanal = 1 : 1 : C
        for i = 1 : m
            for j = 1 : n
                x = (i-1)*blocksize+1;
                y = (j-1)*blocksize+1;
                sub(:,:) = compare(x:x+blocksize-1, y:y+blocksize-1, chanal);
                value = mean2(sub);
                sub(:,:) = origin(x:x+blocksize-1, y:y+blocksize-1, chanal);
                sub = Adjust(sub, blocksize, MSB, NUM, value, type);
                AjImage(x:x+blocksize-1, y:y+blocksize-1, chanal) = sub(:, :);
            end
        end
    end
end

if type == 0 
    height = double(M - NUM*2);
    width = double(N - NUM*2);
    m = floor(height/blocksize);
    n = floor(width/blocksize);
    for chanal = 1 : 1 : C
        for i = 1 : m
            for j = 1 : n
                x = (i-1)*blocksize+1+NUM;
                y = (j-1)*blocksize+1+NUM;
                sub(:,:) = compare(x:x+blocksize-1, y:y+blocksize-1, chanal);
                value = mean2(sub);
                sub(:,:) = origin(x:x+blocksize-1, y:y+blocksize-1, chanal);
                sub = Adjust(sub, blocksize, MSB, NUM, value, type);
                AjImage(x:x+blocksize-1, y:y+blocksize-1, chanal) = sub(:, :);
            end
        end
    end
end

end