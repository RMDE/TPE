%file: BC_RDH_r.m
%function: recovery process of the second data hiding method  
%origin: the decrypted image
%blocksize: the blocksize for rearrangement process
%L: the length that decide whether compress continuously the same bits or not

function res = BC_RDH_r( origin, blocksize, L )
    res = origin;
    [M,N,C] = size(origin);
    for channal = 1 : 1 : C
        planes = Disperse(origin(:,:,channal),8,0);
        % planes: [M,N,7] -> streams: [M*N*7,1,1]
        for i = 1 : 1 : 7
            for j = 1 : 1 : M
                streams((i-1)*M*N+(j-1)*N+1:(i-1)*M*N+j*N) = planes(j,1:N,i);
            end
        end
        length = bin2dec(char(streams(M*N*7-23:M*N*7)+'0')); % the total length of the compressed bit-planes
        len = bin2dec(char(streams(1:24)+'0')); % length of the compressed locate_map
        locate_map = Decompression(M*N,streams(25:24+len),1);
        streams = streams(25+len:length);
        % decompression process 
        index = 1; % index of the streams
        planes = zeros(M*N,8);
        for i = 1 : 1 : 8
            % the bit plane has not been compressed
            if streams(index) == 0
                planes(:,i) = streams(index+1:index+M*N);
                index = index + M*N +1;
            else
                type = char(streams(index+1:index+2)+'0'); % type of rearrangement
                index = index + 3;
                no = 1; % index of the planes(:,i)
                while no < M*N
                    if streams(index) == 0 % the bit-plane is not compressed
                        planes(no:no+L-1,i) = streams(index+1:index+L);
                        no = no + L;
                        index = index + L + 1;
                    else
                        count = 0;
                        while streams(index)== 1
                            count = count + 1;
                            index = index + 1;
                        end
                        Lpre = count + 1;
                        l = 2^Lpre + bin2dec(char(streams(index+1:index+Lpre)+'0'));
                        planes(no:no+l-1,i) = streams(index+Lpre+1);
                        no = no + l;
                        index = index + Lpre + 2;
                    end
                end
                planes(:,i) = Dearrange(planes(:,i),blocksize,M,N,type);
            end
        end
        res(:,:,channal) = Merge(planes,M,N); % error image
        % the process of the restoring the pixels by known prediction 
        for j = 2 : 1 : N
            if locate_map(j) == 0 
                temp = Dec2bin(res(1,j,channal),8);
                if temp(8) == '1' % the error is negative
                    res(1,j,channal) = res(1,j-1,channal) - bin2dec(temp(1:7));
                else
                    res(1,j,channal) = res(1,j-1,channal) + bin2dec(temp(1:7));
                end
            end
        end
        for i = 2 : 1 : M
            if locate_map((i-1)*blocksize+1) == 0 
                temp = Dec2bin(res(i,1,channal),8);
                if temp(8) == '1' % the error is negative
                    res(i,1,channal) = res(i-1,1,channal) - bin2dec(temp(1:7));
                else
                    res(i,1,channal) = res(i-1,1,channal) + bin2dec(temp(1:7));
                end
            end
        end
        for i = 2 : 1 : M
            for j = 2 : 1 : N
                if locate_map((i-1)*blocksize+j) == 0 
                    min = res(i-1,j,channal);
                    max = res(i,j-1,channal);
                    if min > res(i,j-1,channal)
                        min = res(i,j-1,channal);
                        max = res(i-1,j,channal);
                    end
                    if res(i-1,j-1,channal) < min
                        pred = max;
                    elseif res(i-1,j-1,channal) > max
                        pred = min;
                    else
                        pred = double(res(i-1,j,channal)) + double(res(i,j-1,channal)) - double(res(i-1,j-1,channal));
                    end
                    temp = Dec2bin(res(i,j,channal),8);
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