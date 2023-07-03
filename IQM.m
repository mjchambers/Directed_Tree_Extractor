% interquartile mean of a vector
function [mean]=IQM(A)

n = length(A); % n=number of data entries
B = sort(A); % B=data sorted in ascending order

Q = floor(n/4);
R = rem(n,4)/4;
if R == 0
    R = 1;
end

B(n-Q+1:n) = [];
B(1:Q) = [];

weighted = B(1)+B(end);
num = sum(B(2:end-1))+(R*weighted);
den = length(B)-2+(R*2);

mean = num/den;

end