%file: Adjustment.m
%to adjust the MSB of pixel in adjustment area in order to keep the Thumbnail the same
%origin: the image after room reserving and encipher progress
%value: store the average pixel in every block of the original image
%MSB: the number of every bit in adjustment area used for adjustment
function AjImage = Adjustment( origin, blocksize, value, MSB, NUM)

AjImage = origin;
[M,N,C] = size(AjImage);
m = M/blocksize;
n = N/blocksize;
sub = zeros(blocksize);
for chanal = 1 : 1 : C
    for i = 1 : m
        for j = 1 : n
            x = (i-1)*blocksize+1;
            y = (j-1)*blocksize+1;
            sub(:,:) = origin(x:x+blocksize-1, y:y+blocksize-1, chanal);
            sub = Adjust(sub, blocksize, MSB, NUM, value(i,j,chanal));
            AjImage(x:x+blocksize-1, y:y+blocksize-1, chanal) = sub(:, :);
        end
    end
end

end