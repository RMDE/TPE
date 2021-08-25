%file: Adjust.m
%to adjust the MSB of NUM pixel in adjustment area in order to keep the thumbnail the same
%origin: the image after room reserving and encipher progress
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels that the adjustment area contains
%value: store the average pixel in every block of the original image

function sub = Adjust(origin, blocksize, MSB, NUM, value)
    sub = origin;
    dir_sum = value*blocksize*blocksize;
    location_x = zeros(1,NUM);
    location_y = zeros(1,NUM);
    k = 1;
    % select the location of pixels that are to be adjusted later
    for i = 1 : blocksize
        if k > NUM
            break;
        end
        for j = 1 : blocksize
            if k > NUM
                break;
            end
            location_x(k) = i;
            location_y(k) = j;
            k = k+1;
        end
    end
    % covering the high MSB of pixels in the adjustment area with '0'
    for i = 1 : NUM
        sub(location_x(i),location_y(i)) = Calcu(origin(location_x(i),location_y(i)),MSB);
    end
    % calculate the present sum of the block
    diff = dir_sum - double(sum(sum(sub(:,:))));
    diff = diff - mod(diff, 2^(8-MSB)); 
    if diff < 0
        return ;
    end
    if diff > (2^8 - 2^(8-MSB)) * NUM
        diff = (2^8 - 2^(8-MSB)) * NUM;
    end
    % calculate the number of bits that should be '1' for adjusting
    number = Generate(MSB);
    [~,count] = size(number);
    chan = zeros(1,count);
    for i = 1 : count
        if i == count
            res = diff / number(i);
            chan(i) = res;
            break;
        end
        % randomly select the count of 1 in ith bit of the pixels
        up = floor(diff / number(i));
        if up > NUM
            up = NUM;
        end
        low = ceil((diff - (2^(8-i)- 2^(8-MSB))*NUM) / number(i));
        if low < 0
            low = 0;
        end
        res = round(rand(1)*(up-low))+low;
        chan(i) = res;
        diff = diff - res * number(i);
        if diff < 0
            break;
        end 
    end
    
    % coving the high MSB bits of pixels in the adjustment area with suitable value
    for j = 1 : count
        sel = randperm(NUM,chan(j)); % randomly select the pixel to change the value
        for i = 1 : chan(j)
            sub(location_x(sel(i)),location_y(sel(i))) = sub(location_x(sel(i)),location_y(sel(i))) + number(j);
        end
    end
    
end