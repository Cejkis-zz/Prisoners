
close all;
global isEvil;

isEvil=0;

tst=zeros(1,100);
for n=1:100
   
    tst(1,n)= turnEvil([1 1]);
end

%Plot the series

plot(1:100,tst);
