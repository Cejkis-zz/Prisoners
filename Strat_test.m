%%Test ill count23

history =[1 1;1 1;1 1];
global threeCounter;

threeCounter=0;

for n=1:20
usrin=input('Defect or coop? (0 or 1)');
 tactout=IllCountToThreeButMayForget(history)
 history=[history;tactout usrin;];
 history(end-3:end,:)
end