function [col,pprev]=sortmd(val,rowOfBinCenters, adapt,pprevrow,trend,c)
% DOESN'T HANDLE VECTORS
% bin cennters are sorted
 % if col is longer than 1 && adapt==1 then bin centers adapt
            % create bins based on bin centers
            % create col as matrix of matching bins for each element in val
            % rewrite col rows with val elements
            % rewrite pprevrow as pprew
            %shouldn't it be averaging instead???????
            s=0.5;
        col=nan(length(val),length(rowOfBinCenters));
                pprev=pprevrow;
            if adapt
                bins=rowOfBinCenters;
                for i=1:length(val) 
                    [col(i,:),pprev]=sortmd(val(i,:),bins, 0, pprev,trend,c);
                    if abs(pprev(1)-pprev(2))>0.001
                    bins=pprev;
                    end
                end
            else
        conditions=zeros(length(val),length(rowOfBinCenters),2);
        ss=size(conditions);
        t=(3-trend)/2; %2 for dec, 1.5 for const., 1 for inc.
            for i=1:length(rowOfBinCenters) % doesn' handle vectors
                a=i-1;
                b=i-length(rowOfBinCenters);
                if ~a || rowOfBinCenters(i)-rowOfBinCenters(i-1)>s*c
conditions(:,i,1)=(val-rowOfBinCenters(i)>-c) && (a || val<rowOfBinCenters(i));
                else
                    conditions(:,i,1)=(val-(rowOfBinCenters(i)+rowOfBinCenters(i-1))/2>0);
                end
                if ~b || rowOfBinCenters(i+1)-rowOfBinCenters(i)>s*c
conditions(:,i,2)=(val-rowOfBinCenters(i)<=c) && (b || val>rowOfBinCenters(i));
                else
                    conditions(:,i,2)=(val-(rowOfBinCenters(i)+rowOfBinCenters(i+1))/2<=0);
                end
            end
            for i=1:ss(1)
                cond=[conditions(i,:,1); conditions(i,:,2)];
            sc=union(find(cond(1:2:end)), find(cond(2:2:end)));
        col(i,sc)=val(i);
        if isscalar(sc)
            diff=pprev+val(i)-pprev(sc);
            pprev(1)=min([max([abs(diff(1))/2 diff(1)]) mean(pprev)]);
            pprev(2)=max([diff(2) mean(pprev)]);
        end
            end
            end
end