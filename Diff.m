%file: Diff.m
%function: to calculate the max index of bit of two pixels that are different
%a: the first pixel
%b: the second pixel
function res = Diff(a, b)
    if a == b
        res = 0;
        return;
    end
    a = dec2bin(a);
    b = dec2bin(b);
    [~,l1] = size(a);
    [~,l2] = size(b);
    ra = zeros(1,8);
    rb = zeros(1,8);
    ra(8-l1+1:8) = a(1:l1);
    rb(8-l2+1:8) = b(1:l2);
   for index = 1 : 1 : 8
       if ra(index) ~= rb(index)
           res = 9-index;
           break;
       end
   end
end