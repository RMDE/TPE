%file: Recovery.m
%to recover the image 
%origin: the original image
%blocksize: the blocksize of embedding area for type 0, and the blocksize of adjustment area for type 1
%MSB: the number of every bit in adjustment area used for adjustment
%     (method==1: the value of Lfix)
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0)
%method: using different data hiding method to reserve room 0-3
%type: illustrate the distribution of the adjustment areas. 
%      2 means others
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0
function res = Recovery( origin, blocksize, MSB, NUM, method, type, edge )
    %DeImage = Encryption(origin, key);
    
    [M,N,C] = size(origin);
    % High Capacity Reversible Data Hiding in Encrypted Image Based on Adaptive MSB Prediction
    if method == 0 
       % selecting the location of the first pixel in each block of embedding area 
       if type == 0
           length = (2*edge*N+2*edge*(M-2*edge))/4;
           locatex = zeros(1,length);
           locatey = zeros(1,length);
           count = 1;
           for j = 1 : 2 : N
               for i = 1 : 2 : edge
                   locatex(count) = i;
                   locatey(count) = j;
                   count = count + 1;
               end
               for i = M-edge+1 : 2 : M
                   locatex(count) = i;
                   locatey(count) = j;
                   count = count + 1;
               end
           end
           for i = edge+1 : 2 : M-edge
               for j = 1 : 2 : edge
                   locatex(count) = i;
                   locatey(count) = j;
                   count = count + 1;
               end
               for j = N-edge+1 : 2 : N
                   locatex(count) = i;
                   locatey(count) = j;
                   count =count + 1;
               end
           end
           % data hiding using the method 1
           [data,ExtImage] = HC_RDH_Vr(origin, locatex, locatey); 
           data = Decompression((M-edge*2)*(N-edge*2)*MSB*C,data,1);
           data = Decode(data,MSB);
       end
       if type == 1
           m = M/blocksize;
           n = N/blocksize;
           h = ceil(NUM/blocksize); % the height of the adjustment area
           length = (blocksize-h)*blocksize*m*n/4;
           locatex = zeros(1,length); % store location of the the first pixel in the bock of the embedding area
           locatey = zeros(1,length);
           count = 1;
           for i = 1 : 1 : m
               for l = h+1 : 2 :blocksize
                   for j = 1 : 2 : N
                       locatex(count) = l+(i-1)*blocksize;
                       locatey(count) = j;
                       count = count + 1;
                   end
               end
           end
           % get the locate_map
           locate_map = zeros(C,(blocksize-mod(NUM,blocksize))*8);
           for chanal = 1 : 1 : C
               no = 1; % index of the locate_map
               for i = 1 : 1 : m
                   for j = 1 : 1 : n
                       for p = (j-1)*blocksize+mod(NUM,blocksize)+1 : 1 : j*blocksize
                           locate_map(chanal,no:no+7) = Get([],origin((i-1)*blocksize+h,p,chanal),8) - '0';
                           no = no + 8;
                       end
                   end
               end
           end
           % data hiding using the method 1
           [data,ExtImage] = HC_RDH_r(origin, locatex, locatey, locate_map);
           [~,l] = size(data);
           for i = l : -1 : 1
               if data(i) == 1
                   data = data(1:i-1);
                   break;
               end
           end
           data = Decompression(NUM*MSB*m*n*C,data,1);
           % recover the space that stored the locate_map before
           no = NUM*MSB*m*n*C+1;
           for chanal = 1 : 1 : C
               for i = 1 : 1 : m
                   for j = 1 : 1 : n
                       for p = (j-1)*blocksize+mod(NUM,blocksize)+1 : 1 : j*blocksize
                           ExtImage((i-1)*blocksize+h,p,chanal) = bin2dec(num2str(data(no:no+7)-'0'));
                           no = no + 8;
                       end
                   end
               end
           end
           data = Decode(data(1:NUM*MSB*m*n*C),MSB);
       end
    elseif method == 1
        ExtImage = BC_RDH_r( origin, blocksize, MSB );
        data = [];
    elseif method == 2
        [data,ExtImage] = BTL_RDH_r( origin, blocksize, type, NUM, edge);
    end
    % recover the adjustment area
    res = Distribution( ExtImage, blocksize, MSB, NUM, type, edge, data );
end