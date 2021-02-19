function [to,pP]=smoothsweeps(trend,tolerance,pround,maxindex,Fs, pv,tv)
warning('off','MATLAB:mode:EmptyInput');
    figure;
    if isprime(maxindex) && maxindex~=2
        mi=maxindex+1;
    else
        mi=maxindex;
    end
    sppar=factor(mi);
    spdim={mi/sppar(end), sppar(end)};
    pPc={};
maxsize=0;
for i=1:maxindex
    wlv=[45 8 1];
    tt=tv(~isnan(tv(:,i)),i);
    t=1:tt(end)*Fs/1000; % ms time unit
    t=t';
    
    if length(t)>maxsize
        maxsize=length(t);
        to=t;
    end
    subplot(spdim{:},i);
    hold on
    scatter(tv(47:end-1,i)/10,pv(47:end-1,i));
pv(1:length(tt),i)=round(pv(1:length(tt),i),pround);
[p,pc, ~]=sortrec(pv(1:length(tt),i),tt,Fs, wlv,sort([pv(wlv(1)-1,i) pv(wlv(1),i)]),trend,pround,tolerance);
pP=nan;
    for j=1:length(p(1,:))
try pP(1:length(t),j)=resample(p(:,j),t);
catch
    if length(t)==length(p)-1
        t=[t;t(end)+1];
        pP(1:length(t),j)=resample(p(:,j),t);
    else
    pP(:,j)=NaN;
    end
end

    end
    pcP=resample(pc(1:length(t)), t);
%     pF=fft(pP);
%     pcF=fft(pcP);
    %subplot(length(dBms),2, 2*i-1);
    plot( t, p(1:length(t)), 'x',...   
           t, pc(1:length(t)), 'o',... 
   t, pP(1:length(t),:),'--');%,...
    %plot(t, dc,'x',t, dcP,'-', t, d, 'o',t, dP, '.-');
    %subplot(length(dBms),2, 2*i);
    %plot(pcP,dcP);
    %plot(log10(t), log10(abs(pF)),log10(t), log10(abs(pcF)));
    pPc=[pPc(:)',{pP}];
end
pP=nan(maxsize, 2, maxindex);
for i=1:maxindex
    psize=size(pPc{i});
    pP(1:psize(1),:,i)=pPc{i};
end
warning('on','MATLAB:mode:EmptyInput');