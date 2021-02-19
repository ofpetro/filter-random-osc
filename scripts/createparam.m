function [unp,tv,processed,tvp]=createparam(path,indices, aux, input, trend, tolerance,pround)
elemnum=20000;
maxnum=0;
for i=1:length(indices)
    if isnumeric(indices{i})
%         index=indices{i};
        indexstring=num2str(indices{i});
    else
%         index=i;
        indexstring=indices{i};
    end
filename=createfilename(path,indexstring,aux); %
[wl, fsb, rpm, fftpts,ts, s1, s2, s3, S0, S1, S2, S3, az, ell, dop, dolp, docp, p, pp,pu, logp, logpp, logpu, psr, phi]=importltm(filename{:});
maxnum=max(length(ts),maxnum);
vt=nan(elemnum,1); 
vt(1:length(ts))=ts;
tv(:,i)=vt;
try
param=eval(input);
catch
    error('param names: wl=entered wavelength\nfsb=base sampling frequency\nrpm=revolutions per measurement\nfftpts=number of points in fft\nts=timestamps\ns1,s2,s3=normailzed Stokes parameters\nS0,S1,S2,S3=Stokes parameters\naz=azimuth angle\nell=ellipticity angle\ndop,dolp,docp=degree of total, linear or circular polarization\np,pp,pu=total, polarized or unpolarized power\nlogp,logpp,logpu=powers in dBm\npsr=power split ratio\nphi=phase difference');
end
vt(1:length(param))=param;
unp(:,i)=vt;
end
tv=tv(1:maxnum,:);
unp=unp(1:maxnum,:);
[tvp,processed]=smoothsweeps(trend,tolerance,pround,i,fsb, unp,tv);