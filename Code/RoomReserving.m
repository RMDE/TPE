%file: RoomReserving.m
%function: select the high MSB bits of pixels in the adjustment area and embedding them into the embedding area
%origin: the original image
%blocksize: the blocksize of embedding area for type 0, and the blocksize of adjustment area for type 1
%MSB: the number of every bit in adjustment area used for adjustment
%     (method==1: the value of Lfix)
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0 or type==2)
%method: using different data hiding method to reserve room 0-3
%type: illustrate the distribution of the adjustment areas. 
%      2 means others
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0

function res = RoomReserving( origin, blocksize, MSB, NUM, method, type, edge )
    res = origin;
    [M,N,C] = size(origin);
    % High Capacity Reversible Data Hiding in Encrypted Image Based on Adaptive MSB Prediction
    if method == 0 
       %selecting the location of the first pixel in each block of embedding area 
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
           %data hiding using the method 1
           for channel = 1 : 1 : C
               data = Selection( origin(:,:,channel), blocksize, MSB, NUM, type, edge ); % get all the data in the adjustment area that may change in the adjusting process
               data = Encode(data,MSB); % change the order of the MSBs
               data = Compression((M-edge*2)*(N-edge*2)*MSB,data,1);
               capacity = (M*N-(M-edge*2)*(N-edge*2))*8
               res(:,:,channel) = HC_RDH_V(origin(:,:,channel), data, locatex, locatey);
           end
       end
       if type == 1
           data = Selection( origin, blocksize, MSB, NUM, type, edge ); % get all the data in the adjustment area that may change in the adjusting process
           data = Encode(data,MSB); % change the order of the MSBs
           m = M/blocksize;
           n = N/blocksize;
           count = 1;
           h = ceil(NUM/blocksize); % the height of the adjustment area
           length =  floor((blocksize-h)/2)*floor(blocksize/2)*m*n;
           locatex = zeros(1,length);
           locatey = zeros(1,length);
           for i = 1 : 1 : m
               for l = h+1 : 2 :blocksize-1
                   for j = 1 : 2 : N-1
                       locatex(count) = l+(i-1)*blocksize;
                       locatey(count) = j;
                       count = count + 1;
                   end
               end
           end
           % reserve the space for storing the locate_map in every block
           for chanal = 1 : 1 : C
               for i = 1 : 1 : m
                   for j = 1 : 1 : n
                       for p = (j-1)*blocksize+mod(NUM,blocksize)+1 : 1 : j*blocksize
                           data = Get(data,origin((i-1)*blocksize+h,p,chanal),8);
                       end
                   end
               end
           end
           %data hiding using the method 1
           data = Compression(NUM*MSB*m*n*C,data,1);
           [~,limit] = size(data);
           data(limit+1) = '1'; % adding the ending flag
           data(limit+2) = '0';
           len = limit
           [locate_map,res] = HC_RDH(origin, data, locatex, locatey);
           [~,len] = size(locate_map);
           len_locatemap = len
           cap_locatemap = m*n*(blocksize - mod(NUM,blocksize))*8
           % store each chanal's locate_map into Er in every big block
           for chanal = 1 : 1 : C
               no = 1; % index of the locate_map
               for i = 1 : 1 : m
                   for j = 1 : 1 : n
                       for p = (j-1)*blocksize+mod(NUM,blocksize)+1 : 1 : j*blocksize
                           if no < len
                               res((i-1)*blocksize+h,p,chanal) = locate_map(chanal,no)*(2^7)+locate_map(chanal,no+1)*(2^6)+locate_map(chanal,no+2)*(2^5)+locate_map(chanal,no+3)*(2^4)+locate_map(chanal,no+4)*(2^3)+locate_map(chanal,no+5)*(2^2)+locate_map(chanal,no+6)*(2^1)+locate_map(chanal,no+7)*(2^0);
                               no = no + 8;
                           else
                               res((i-1)*blocksize+h,p,chanal) = 0;
                           end
                       end
                   end
               end
           end
       end 
    end
    if method == 1
        res = BC_RDH( origin, blocksize);
    end
    if method == 2
        for i = 1 : 1 : C
            data = Selection( origin(:,:,i), blocksize, MSB, NUM, type, edge );
            res(:,:,i) = BTL_RDH( origin(:,:,i), blocksize, type, MSB, NUM, edge, data);
        end
    end
    if method == 3
        res = RA_RDH( origin );
    end   
end