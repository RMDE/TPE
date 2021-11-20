%file: Disperse.m
%function: to rearrange the bits in every bit-plane for compression
%origin: the image to disperse
%number: the number of bit-planes
function res = Disperse( origin, number )
    [M,N] = size(origin);
    res = zeros(M,N,number);
    for i = 1 : 1 : M
        for j = 1 : 1 : N
            for p = number-1 : -1 : 0
                tmp = floor(double(origin(i,j))/2^p);
                origin(i,j) = origin(i,j) - tmp*2^p;
                res(i,j,p+1) = uint8(tmp);
            end
        end
    end
end