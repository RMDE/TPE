%file: BC_RDH_r.m
%function: recovery process of the second data hiding method  
%origin: the decrypted image
%blocksize: the blocksize for rearrangement process
%L: the length that decide whether compress continuously the same bits or not

function res = BC_RDH_r( origin, blocksize, L )
    if(~exist('L','var'))
        L = 4;  % 如果未出现该变量，则对其进行赋值
    end
    res = origin;
    [M,N,C] = size(origin);
    for channal = 1 : 1 : C
        planes = Disperse(origin(:,:,channal),8,0);
        % planes: [M,N,8] -> streams: [M*N*8,1,1]
        for i = 1 : 1 : 8
            for j = 1 : 1 : M
                streams((i-1)*M*N+(j-1)*N+1:(i-1)*M*N+j*N) = planes(j,1:N,9-i);
            end
        end
        len = bin2dec(char(streams(M*N*8-31:M*N*8)+'0')); % length of the compressed locate_map
        locate_map = Decompression(M*N,streams(M*N*8-31-len:M*N*8-32),1);
        length = bin2dec(char(streams(M*N*8-63-len:M*N*8-32-len)+'0')); % the total length of the compressed bit-planes
        streams = streams(M*N*8-63-len-length:M*N*8-64-len);
%         extract = length+len+64
        % decompression process 
        index = length; % index of the streams
        planes = zeros(M*N,8);
        for i = 1 : 1 : 8
            % the bit plane has not been compressed
            if streams(index) == 0
                planes(:,i) = streams(index-1:-1:index-M*N);
                index = index - M*N - 1;
            else
                type = char(streams(index-2:index-1)+'0'); % type of rearrangement
                index = index - 3;
                no = 1; % index of the planes(:,i)
                while no <= M*N
                    if streams(index) == 0 % the bit-plane is not compressed
                        if no+L-1>M*N
                            planes(no:M*N,i) = streams(index-1:-1:index-1+no-M*N);
                            index = index - 2 + no - M*N;
                            no = M*N+1;
                        else
                            planes(no:no+L-1,i) = streams(index-1:-1:index-L);
                            no = no + L;
                            index = index - L - 1;
                        end
                    else
                        count = 0;
                        while streams(index)== 1
                            count = count + 1;
                            index = index - 1;
                        end
                        Lpre = count + 1;
                        l = 2^Lpre + bin2dec(char(streams(index-1:-1:index-Lpre)+'0'));
                        planes(no:no+l-1,i) = streams(index-Lpre-1);
                        no = no + l;
                        index = index - Lpre - 2;
                    end
                end
                planes(:,i) = Dearrange(planes(:,i),blocksize,M,N,type);
            end
        end
        res(:,:,channal) = Merge(planes,M,N); % error image
        % the process of the restoring the pixels by known prediction 
        for j = 2 : 1 : N
            if locate_map(j) == 0 
                temp = dec2bin(res(1,j,channal),8);
                if temp(8) == '1' % the error is negative
                    res(1,j,channal) = res(1,j-1,channal) - bin2dec(temp(1:7));
                else
                    res(1,j,channal) = res(1,j-1,channal) + bin2dec(temp(1:7));
                end
            end
        end
        for i = 2 : 1 : M
            if locate_map((i-1)*N+1) == 0 
                temp = dec2bin(res(i,1,channal),8);
                if temp(8) == '1' % the error is negative
                    res(i,1,channal) = res(i-1,1,channal) - bin2dec(temp(1:7));
                else
                    res(i,1,channal) = res(i-1,1,channal) + bin2dec(temp(1:7));
                end
            end
        end
        for i = 2 : 1 : M
            for j = 2 : 1 : N
                if locate_map((i-1)*N+j) == 0 
                    a = res(i-1,j,channal);
                    b =  res(i,j-1,channal);
                    c = res(i-1,j-1,channal);
                    x = res(i,j,channal);
                	min = a;
                    max = b;
                    if min > b
                        min = b;
                        max = a;
                    end
                    if c < min
                        pred = max;
                    elseif c > max
                        pred = min;
                    else
                        pred = double(a) + double(b) - double(c);
                    end
                    temp = dec2bin(x,8);
                    if temp(8) == '1' % the error is negative
                        res(i,j,channal) = pred - bin2dec(temp(1:7));
                    else
                        res(i,j,channal) = pred + bin2dec(temp(1:7));
                    end
                end
            end
        end     
    end
end