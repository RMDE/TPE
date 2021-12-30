%file: Disperse.m
%function: to rearrange the bits in every bit-plane for compression
%origin: the image to disperse
%number: the number of bit-planes( type 0 ); the no. of the bit-plane 0~7 (type1)
%type: 0 means all bit-planes are required; 1 means the number-th bit-plane is required
function res = Disperse( origin, number, type )
    [M,N] = size(origin);
    if type == 0
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
    else
        res = zeros(1,M*N);
        count = 1;
        for i = 1 : 1 : M
            for j = 1 : 1 : N
                tmp = Dec2bin(origin(i,j),8);
                tmp = tmp(8-number);
                res(count) = tmp;
                count = count + 1;
            end
        end
    end
end