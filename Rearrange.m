%file: Rearrange.m
%function: to rearrange the bits in every bit-plane for compression
%origin: the image to rearrange
%blocksize: the width of the block
%type: decide the order of bits in the same block and between blocks
function res = Rearrange( origin, blocksize, type )
    [M,N,~] = size(origin);
    res = zeros(1,M*N);
    count = 1; % index of the res
    % inside block: line first; between blocks: line first 
    if type == "00" 
        for i = 1 : 1 : M/blocksize
            for j = 1 : 1 : N/blocksize
                for x = (i-1)*blocksize+1 : 1 : i*blocksize
                    for y = (j-1)*blocksize+1 : 1 : j*blocksize
                        res(count) = origin(x,y);
                        count = count + 1;
                    end
                end
            end
        end
    end
    % inside block: line first; between blocks: column first 
    if type == "01" 
        for j = 1 : 1 : N/blocksize
            for i = 1 : 1 : M/blocksize
                for x = (i-1)*blocksize+1 : 1 : i*blocksize
                    for y = (j-1)*blocksize+1 : 1 : j*blocksize
                        res(count) = origin(x,y);
                        count = count + 1;
                    end
                end
            end
        end
    end
    % inside block: column first; between blocks: line first 
    if type == "10" 
        for i = 1 : 1 : M/blocksize
            for j = 1 : 1 : N/blocksize
                for y = (j-1)*blocksize+1 : 1 : j*blocksize
                    for x = (i-1)*blocksize+1 : 1 : i*blocksize
                        res(count) = origin(x,y);
                        count = count + 1;
                    end
                end
            end
        end
    end
    % inside block: column first; between blocks: column first 
    if type == "11" 
        for j = 1 : 1 : N/blocksize
            for i = 1 : 1 : M/blocksize
                for y = (j-1)*blocksize+1 : 1 : j*blocksize
                    for x = (i-1)*blocksize+1 : 1 : i*blocksize
                        res(count) = origin(x,y);
                        count = count + 1;
                    end
                end
            end
        end
    end
end