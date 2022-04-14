%file: BC_RDH.m
%function: the second data hiding method to compress all bit-plane in order to reserve the whole highest bit-plane for adjustment 
%origin: the original image
%blocksize: the blocksize for rearrangement process
%L: the length that decide whether compress continuously the same bits or not

function res = BC_RDH( origin, blocksize, L )
    if(~exist('L','var'))
        L = 4;  % 如果未出现该变量，则对其进行赋值
    end
    res = origin;
    % prediction for simplifing pixels
    % the first line and the first column remain unchange
    [M,N,C] = size(origin);
    for chanal = 1 : 1 : C
        error = zeros(M,N);
        locate_map = zeros(1,M*N); % recording whether the prediction of the pixel is overflow (error not in [-127,127]) 
        error(1,1) = origin(1,1,chanal); % the pixel remain unchange for predicting other pixels
        for j = 2 : 1 : N
            temp = double(origin(1,j,chanal)) - double(origin(1,j-1,chanal));
            if temp < -127 || temp > 127
                error(1,j) = origin(1,j,chanal);
                locate_map(j) = 1;
            else
                % in order to improve the efficiency of compression, we make the LSB for symbol to judge whether the prediction error is >0 or not 
                if temp < 0
                    temp = dec2bin(-temp,7);
                    temp(8) = '1';
                    temp = bin2dec(temp);
                else
                    temp = dec2bin(temp,7);
                    temp(8) = '0';
                    temp = bin2dec(temp);
                end
                error(1,j) = temp;
            end
        end
        for i = 2 : 1 : M
            temp = double(origin(i,1,chanal)) - double(origin(i-1,1,chanal));
            if temp < -127 || temp > 127
                error(i,1) = origin(i,1,chanal);
                locate_map((i-1)*blocksize+1) = 1;
            else
                if temp < 0
                    temp = dec2bin(-temp,7);
                    temp(8) = '1';
                    temp = bin2dec(temp);
                else
                    temp = dec2bin(temp,7);
                    temp(8) = '0';
                    temp = bin2dec(temp);
                end
                error(i,1) = temp;
            end
        end
        % middle prediction
        for i = 2 : 1 : M
            for j = 2 : 1 : N
                min = origin(i-1,j,chanal);
                max = origin(i,j-1,chanal);
                if min > origin(i,j-1,chanal)
                    min = origin(i,j-1,chanal);
                    max = origin(i-1,j,chanal);
                end
                if origin(i-1,j-1,chanal) < min
                    pred = max;
                elseif origin(i-1,j-1,chanal) > max
                    pred = min;
                else
                    pred = double(origin(i-1,j,chanal)) + double(origin(i,j-1,chanal)) - double(origin(i-1,j-1,chanal));
                end
                temp = double(origin(i,j,chanal)) - double(pred);
                if temp < -127 || temp > 127
                    error(i,j) = origin(i,j,chanal);
                    locate_map((i-1)*N+j) = 1;
                else
                    if temp < 0
                        temp = dec2bin(-temp,7);
                        temp(8) = '1';
                        temp = bin2dec(temp);
                    else
                        temp = dec2bin(temp,7);
                        temp(8) = '0';
                        temp = bin2dec(temp);
                    end
                    error(i,j) = temp;
                end
            end
        end
        planes = Disperse(error,8,0); % disperse the channal into eight bit-planes 
        comp = zeros(1,M*N*8); % store the compressed bit planes
        temp = zeros(1,M*N); % store the current compressed bit-plane without auxiliary information
        count = 0; % record the number of the continuously same bits
        % store the locate_map
        locate_map = Compression(M*N,locate_map,1);
        [~,l] = size(locate_map);
        comp(M*N*8-31:M*N*8) = dec2bin(l,32)-'0';
        comp(M*N*8-31-l:M*N*8-32) = locate_map(:);
        ci = M*N*8 - 64 - l; %index of the comp
        for i = 1 : 1 : 8
            index = 1; % index of the streams
            no = 1; % index of the temp
            streams = Rearrange(planes(:,:,i), blocksize,"01");
            % compress the bit-planes
            while index <= M*N
                if streams(index) == 0
                    while index<=M*N && streams(index)==0 
                        count = count+1;
                        index = index + 1;
                    end
                    flag = 0;
                elseif streams(index) == 1
                    while index<=M*N && streams(index)==1 
                        count = count+1;
                        index = index+1;
                    end
                    flag = 1;
                end
                if count < L
                    index = index - count;
                    count = 0;
                    temp(no) = 0;
                    if index+L-1 <= M*N
                        temp(no+1:no+L) = streams(index:index+L-1);
                        index = index + L;
                        no = no + L +1;
                    else
                        temp(no+1:no+M*N-index+1) = streams(index:M*N);
                        no = no+M*N-index+2;
                        index = M*N+1;
                    end
                else
                    no = no - 1;
                    Lpre = floor(log2(count));
                    Lmid = dec2bin(count - 2^Lpre,Lpre)-'0';
                    temp(no+1:no+Lpre-1) = 1;
                    temp(no+Lpre) = 0;
                    temp(no+Lpre+1:no+2*Lpre) = Lmid(:);
                    temp(no+2*Lpre+1) = flag;
                    no = no + 2*Lpre + 2;
                    count = 0;
                end 
            end
            if no-1 >= M*N
                comp(ci) = 0;
                for line = 1 : 1 : M
                    comp(ci-line*N : ci-(line-1)*N-1 ) = planes(line,N:-1:1,i);
                end
                ci = ci - M*N - 1;
            else
                comp(ci) = 1;
                comp(ci-2:ci-1) = [0,1];
                comp(ci-no-1:ci-3) = temp(no-1:-1:1);
                ci = ci - no - 2;
            end
        end
        % embed the total length of the compressed bit-planes into the end of the planes 
        comp(M*N*8-63-l:M*N*8-32-l) = dec2bin(M*N*8-64-l-ci,32)-'0';
        capacity = M*N*8
        length = M*N*8-ci
        streams = zeros(M*N,8);
        for i = 1 : 1 : 8
            streams(:,9-i) = comp((i-1)*M*N+1:i*M*N);
        end
        res(:,:,chanal) = Merge(streams,M,N); % merge eight bit-plane bitstreams into one plane of the channal 
    end
end

