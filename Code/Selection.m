%file: Selection.m
%function: select all the data in the adjustment area that may change in the adjusting process
%origin: the original image
%blocksize: no meaning for type 0 and the width of every block in the image for type 1
%MSB: the number of every bit in adjustment area used for adjustment
%NUM: the number of pixels that the adjustment area contains (type==1)
%     no meaning (type==0)
%type: illustrate the distribution of the adjustment areas. 
%      1 means the embedding areas are in every block
%      0 means unblocking and the whole block can be adjusted
%edge: in order to distinguish between the two distribution of areas, 0 for type 1 and others for type 0

function data = Selection( origin, blocksize, MSB, NUM, type, edge )
    data = [];
    if type == 2
        return
    end
    [M,N,C] = size(origin);
    % all MSB of every pixel in adjustment area are seleted  
    if type == 0
        for chanal = 1 : 1 : C
            for i = edge+1 : 1 : M-edge
                for j = edge+1 : 1 : N-edge
                    data = Get(data, origin(i,j,chanal), MSB);
                end
            end
        end
    end
    if type == 1
       data = [];
       m = M/blocksize;
       n = N/blocksize;
       for chanal = 1 : 1 : C
          for i = 1 : 1 : m
             for j = 1 : 1 : n
                 count = 0;
                 for x = (i-1)*blocksize+1 : 1 : i*blocksize
                    if count >= NUM
                        break;
                    end
                    for y = (j-1)*blocksize+1 : 1 : j*blocksize
                        if count >= NUM
                            break;
                        end
                        data = Get(data,origin(x,y,chanal),MSB);
                        count = count + 1;
                    end
                 end
             end
          end
       end
    end
end