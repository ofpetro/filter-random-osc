% TDOD function plotsweeps(pP,dv,trend,pround, dBms,Fs,tv)
msg={'s. m. decreasing' 'approx. constant' 's. m. inc.'};
fprintf('%s\n%d digits\n', msg{trend+2},pround);
[t,dP]=smoothsweeps(trend,pround,dBms,Fs, dv,tv);
for i=1:length(dBms)
    figure;
plot(pP(:,:,i),dP(:,:,i));
end