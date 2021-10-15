%file: Permutation.m
%Rearrange the order of pixels within every block
%origin: the image after the adjustment process
%blocksize: the width of the block
%key: key for generating the random order for permutation
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0
%kind: 1 for permutation and -1 for de-permutation
function PmImage = Permutation(origin, blocksize, key, edge, kind)
    LIMIT = 1000;
    rng('default');
    rng(key);
    PmImage = origin;
    [M,N,C] = size(origin); 
    m = round((M - edge*2)/blocksize);
    n = round((N - edge*2)/blocksize);
    keys = uint8(randi(LIMIT,m,n));
    for chanal = 1 : 1 : C
        for i = 1 : m
            for j = 1 : n
                x = (i-1)*blocksize+1+edge;
                y = (j-1)*blocksize+1+edge;
                sub(:,:) = origin(x:x+blocksize-1, y:y+blocksize-1, chanal);
                sub = Permutate(sub, blocksize, keys(i,j), kind);
                PmImage(x:x+blocksize-1, y:y+blocksize-1, chanal) = sub(:, :);
            end
        end
    end
end