%file: RoomReserving
%function: select the high MSB bits of pixels in the adjustment area and embedding them into the embedding area
%origin: the original image
%blocksize: the blocksize of embedding area for type 0, and the blocksize of adjustment area for type 1
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0)
%type: illustrate the distribution of the adjustment areas. 
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0

function res = RoomReserving( origin, blocksize, MSB, NUM, type, edge )
    res = origin;
    data = Selection( origin, blocksize, MSB, NUM, type, edge ); % get all the data in the adjustment area that may change in the adjusting process
    
end