%file: RoomReserving.m
%function: select the high MSB bits of pixels in the adjustment area and embedding them into the embedding area
%origin: the original image
%blocksize: the blocksize of embedding area for type 0, and the blocksize of adjustment area for type 1
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0)
%method: using different data hiding method to reserve room 0-3
%type: illustrate the distribution of the adjustment areas. 
%      2 means others
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0

function res = RoomReserving( origin, blocksize, MSB, NUM, method, type, edge )
    res = origin;
    data = Selection( origin, blocksize, MSB, NUM, type, edge ); % get all the data in the adjustment area that may change in the adjusting process
    [M,N,C] = size(origin);
    % High Capacity Reversible Data Hiding in Encrypted Image Based on Adaptive MSB Prediction
    if method == 0 
       %selecting the location of the first pixel in each block of embedding area 
       if type == 0
           length = C*(2*edge*N+2*edge*(M-2*edge))/4;
           locatex = zeros(1,length);
           locatey = zeros(1,length);
           count = 0;
           for chanal = 1 : 1 : C
               for j = 1 : 2 : N
                   for i = 1 : 1 : edge
                       locatex(count) = i;
                       locatey(count) = j;
                       count = count + 1;
                   end
                   for i = M-edge+1 : 1 : M
                       locatex(count) = i;
                       locatey(count) = j;
                       count = count + 1;
                   end
               end
               for i = edge+1 : 1 : M-edge
                   for j = 1 : 1 : edge
                       locatex(count) = i;
                       locatey(count) = j;
                       count = count + 1;
                   end
                   for j = N-edge+1 : 1 : N
                       locatex(count) = i;
                       locatey(count) = j;
                       count =count + 1;
                   end
               end
           end
       end
       if type == 1
           m = M/blocksize;
           n = N/blocksize;
           length =  (blocksize*blocksize-NUM)*m*n/4;
           locatex = zeros(1,length);
           locatey = zeros(1,length);
           count = 1;
           h = round(NUM/blocksize) + 1; % the height of the adjustment area
           for chanal = 1 : 1 : C
               for i = 1 : 1 : m
                   for l = h+1 : 1 :blocksize
                       for j = 1 : 2 : N
                           locatex(count) = h+(i-1)*blocksize;
                           locatey(count) = j;
                           count = count + 1;
                       end
                   end
               end
           end
       end
       %data hiding using the method 1
       res = HC_RDH(origin, data, locatex, locatey);
                       
    end
        
end