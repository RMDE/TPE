%file: Merge.m
%function: to merge eight bit-plane bitstreams into one plane of the channal
%origin: the image to disperse
%M: the height of the image
%N: the width of the image
function res = Merge( origin, M, N )
    res = zeros(M,N);
    [~,n] = size(origin);
    count = 1; % index of origin
    for i = 1 : 1 : M
        for j = 1 : 1 : N
            for p = 0 : 1 : n-1
                res(i,j) = res(i,j) + origin(count,p+1)*2^p;
            end
            count = count + 1;
        end
    end
end