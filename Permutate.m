%file: Permate.m
%Rearrange the order of pixels in the block
%origin: the block after the adjustment process
%blocksize: the width of the block
%key: key for generating the random order for permutation
%kind: 1 for permutation and -1 for de-permutation
function sub = Permutate( origin, blocksize, key, kind)
    sub = origin;
    rng('default');
    rng(key);
    order = randperm(blocksize*blocksize);
    if kind == 1
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
    if kind == -1
        for i = 1 : blocksize
            for j = 1 : blocksize
                k = (i-1)*blocksize+j;
                x = ceil(order(k)/blocksize);
                y = mod(order(k),blocksize);
                if y == 0
                    y = blocksize;
                end
                sub(x,y) = origin(i,j);
            end
        end
    end
end