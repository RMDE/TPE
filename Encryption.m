%file: Encryption.m
%to encipher the image after the room reserving progress by stream encipher
%origin: the image after room reserving progress
%key: the sub key to generate the stream key to encipher

function EnImage = Encryption( origin, key )
    EnImage = origin;
    [M,N,C] = size(origin);
    for chanal = 1 :1 :C
        rng('default');
        rng(key);
        stream = uint8(randi(256,M,N)-1);
        EnImage(:, :, chanal) = bitxor(origin(:,:,chanal), stream);
    end
end