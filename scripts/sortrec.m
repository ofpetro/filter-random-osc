function [ev,pc, modes, sand]=sortrec(data,time,Fs, wlv,prevmode,trend, pround,tolerance)
% input:
% data      - column vector of values to sort into a vector of underestimate or overestimate
% values
% time      - vector of sampling times
% Fs        - sampling freq
% wlv       - row vector of window lengths in recursive calls with closing 1
% prevmode  - pair of previously detected modes
% trend     - the expected trend of data being processed
% tolerance - measures how extreme jumps in value are accepted
% output:
% ev        - underestimate and overestimate value value pair matrix
% pc        - any value that is processed
% modes     - vector of modes for the last window
% processed
% algorithm:1. the window of data, length wlv(1), is used to calculate new modes
%           2. if no 2 distinct values with significant frequency are found then the function is called recursively
%           with the first window of data shifted 1 and wlv(2:end) as wlv,
%           else sortmd to create estimates, start phase 1 with window
%           shifted determined by trend
%           3. if trend is expected then no values and shift wlv(1)
%           4. if trend is unexpected then no values and shift 1 
dl=length(data);
assert(dl>=length(wlv(1)),'invalid window sizes');
i=1;
while i<=dl && isnan(data(i))
    i=i+1;
end
i=i-1;
assert(i~=dl,'no data');
assert(length(time)==dl,'time-value dimension mismatch');
 lm=1; % index where processing gives value
    
%     LI=li; % beginning of interval of linearity
%     LIls=0; % length of interval
%     IE=0; % end of interval
    
    mmf=[0 0];
    lk=wlv(1);
    k=lk+1;
    modes=prevmode;
    pc=nan(round(time(end)*Fs/1000),1);
    ev=repmat(pc,[1 2]);
    c=tolerance*10^-pround;
    filterlk=0;
while k<=dl
    if filterlk
    data(lk)=NaN;
    end
    filterlk=0;
        knext=k+1;
        rec=0;
        datad=data(k)-modes;
        map=min(abs(datad));
    m=lm; % index for processing
        T=time(k)*Fs/1000;
        M=min([round(T+3) length(pc)]);
    if isnan(data(k))
        m=M;
    else
        while m<M && (abs(T-m)>0.4 || map>8*c)  % skip samples which are taken with
            % too much jitter or extreme jumps in value
        % TODO implement quicker jitter check
        m=m+1;
        end
    end
if m~=M
%1. the window of data, length wlv(1), is used to calculate new modes
% possible configurations: 1 single mode, 2 modes, 1 mode and a significant
% 2nd highest frequency of a single value, the 2 values of latter cases
% being distinct, and everything else -> resp. shift 1, shift 1, shift 1,
% sortmd, recursive call
        
        mwin=data(k-wlv(1):k-1); % mwin is set to be the window before k
        mwin=mwin(~isnan(mwin));
        mmf(2)= 0; % mmf is the pair of highest frequencies
    [~,mmf(1),mmcc]=mode(mwin);% count maxes of histogram, mmcc is cell of values with highest frequency
    if mmf(1)~=length(mwin) && mmf(1)>length(mwin)/7% don't execute ift all mwin values are the same or all too different
%           2. if no 2 distinct values with significant frequency are found then the function is called recursively
%           with the first window of data and wlv(2:end) as wlv,
%           else sortmd to create estimates, start phase 1 with window
%           shifted determined by trend
        mmc=mmcc{:}; % create column of mode values
        mmcl=length(mmc);
        if mmcl==1 || mmcl==2 
        if min(trend*(mmc-modes'))+90*10^-pround>0 % compare to previous max AVOID MAGIC NUMBER (even for testing)
            [ev(m,:),modes]=sortmd(data(k),modes,0,modes,trend,c);
            if any(ev(m,:))
            pc(m)=data(k); % m is the index of data that can be fixed to jitter free time vector
            end
    lm=m;
        else % look for frequent values
            for i=1:mmcl
        mwintemp=mwin(mwin~=mmc(i));
            end
        [~,mmf(2),mmcc2]=mode(mwintemp);
        mmc=[mmc; mmcc2{:}];
        for imt=2:length(mmc)
            mwintemp=mwintemp(mwintemp~=mmc(imt));
        end
            [~,mmftemp,~]=mode(mwintemp); % find 3rd highest frequency CHECK THIS!!!
        if ~isnan(mmftemp) && mmf(1)-mmf(2)>mmf(2)-mmftemp
            mmc=mmc(1);
        end
    if length(mmc)==2 && abs(mmc(1)-mmc(2))>c % phase 2 are there 2 distinct maxima?
    [ev(m,:),modes]=sortmd(data(k),mmc,0,modes,trend,c);
    
        if any(ev(m,:))
            pc(m)=data(k); % m is the index of data that can be fixed to jitter free time vector
        end
    lm=m;
    else
        if ~isscalar(mwin)
            rec=1;
        end
    end
        end
        else
        rec=1;
        end
        if rec
            i=min([k+wlv(1) dl]);
            twin=round((time(i)-time(k))*Fs/1000)-1;
            [e, b, a,d]=sortrec(data(k:i),time(k:i)-time(k),Fs,wlv(2:end),modes,trend,pround,tolerance);
            ev(m:m+twin,:)=e;
            pc(m:m+twin)=b;
            modes=a;
            data(k:i)=d;
            knext=i+1;
        end
%     if data(k)>max(modes)+c/4 % phase 3 AVOID MAGIC NUMBER
%         knext=min([k+wlv(1)+1 dl]);
%         modes=sort([data(knext-2) data(knext-1)]);
%     end
    else
        if isscalar(mwin)
            [ev(m,:),modes]=sortmd(mwin,modes,0,modes,trend,c);
            if any(ev(m,:))
            pc(m)=mwin; % m is the index of data that can be fixed to jitter free time vector
            end
        else
            if ~any(pc)
                pc(m)=data(k);
                ev(m)=data(k);
                modes=data(k);
            end
            if lk~=k-1
            knext=min([k+wlv(1) dl]);
            data(k-wlv(1):k-1)=NaN;
            end
        end
    end
else
    if ~any(data(k-wlv(1):k-1)) && k~=dl
        knext=min([k+wlv(1)+1 dl]);
            modes=sort([data(k) data(k+1)]);
    end
    filterlk=1;
end
        lk=k;
        k=knext;
end
if length(pc(~isnan(pc)))==1
    pc(m)=data(lk);
                ev(m)=data(lk);
                modes=data(lk);
end
if filterlk
    data(lk)=NaN;
end
sand=data;