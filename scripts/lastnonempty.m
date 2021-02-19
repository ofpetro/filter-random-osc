function lne=lastnonempty(inputcell)
i=1;
going=1;
while going
    if i>length(inputcell) || isempty(inputcell{i})
        lne=i-1;
        going=0;
    else
        i=i+1;
    end
end