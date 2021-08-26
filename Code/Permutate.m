%file: Permate.m
%Rearrange the order of pixels in the block
%origin: the block after the adjustment process
%blocksize: the width of the block
%key: key for generating the random order for permutation

function sub = Permutate(origin, blocksize, key)
    sub = origin;
    rng('default');
    rng(key);
    order = randperm(blocksize*blocksize);
    for i = 1 : blocksize
        for j = 1 : blocksize
            k = (i-1)*blocksize+j;
            x = ceil(order(k)/blocksize);
            y = mod(order(k),blocksize);
            if y == 0
                y = blocksize;
            end
            sub(i,j) = origin(x,y);
        end
    end
end