%file: Dearrange.m
%function: to dearrange the bits in every bit-plane for recovery
%origin: the image to dearrange
%blocksize: the width of the block
%type: decide the order of bits in the same block and between blocks
function res = Dearrange( origin, blocksize, M, N, type )
    res = zeros(M,N);
    count = 1; % index of the res
    % inside block: line first; between blocks: line first 
    if type == "00" 
        for i = 1 : 1 : M/blocksize
            for j = 1 : 1 : N/blocksize
                for x = (i-1)*blocksize+1 : 1 : i*blocksize
                    for y = (j-1)*blocksize+1 : 1 : j*blocksize
                        res(x,y) = origin(count);
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
                        res(x,y) = origin(count);
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
                        res(x,y) = origin(count);
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
                        res(x,y) = origin(count);
                        count = count + 1;
                    end
                end
            end
        end
    end
    for i = 1 : 1 : M
        origin((i-1)*N+1:i*N) = res(i,:);
    end
    res = origin;
end