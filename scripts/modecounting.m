function processedmodes=modecounting(processed)
processedmodes=cell(1,lastnonempty(processed));
for i=1:length(processedmodes)
procdi=processed{i};
[~,freq,modecount]=mode(procdi);
mcs=size(modecount);
mcm=nan(mcs(2:end));
for j=1:length(modecount(1,1,:))
vector=modecount{1,1,j};
if isscalar(vector)
[modes,smf,mc]=mode(procdi(procdi(:,1,j)~=vector,1,j));
if smf>0.51*freq(1,1,j) && modes<vector
vector=mc{1};
end
end
mcm(1,j)=mean(vector(~isnan(vector)));
vector=modecount{1,2,j};
if isscalar(vector)
[modes,smf,mc]=mode(procdi(procdi(:,2,j)~=vector,2,j));
if smf>0.51*freq(1,2,j) && modes<vector
vector=mc{1};
end
end
mcm(2,j)=mean(vector(~isnan(vector)));
end
processedmodes{i}=mcm;
end