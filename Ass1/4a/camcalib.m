function [P,K, R, t] = camcalib(fname,npts)
if nargin==1
    npts=Inf;
end
fid = fopen(fname);
total=[];
count=1;
for j=1:8
    tline = fgetl(fid);
    C = strsplit(tline)
    
    temp=zeros(str2double(C(1,2)),5);
    size(temp)
    i=1;
    len=str2double(C(1,2));
    while(i<=len)
        
        tline = fgetl(fid);
        C=strsplit(tline);
        total(count,:)=str2double(C);
        temp(i,:)=str2double(C);
        count=count+1;
        i=i+1;
    end
    switch j
        case 1
            x0=temp;
        case 2
            x1=temp;
        case 3
            x2=temp;
        case 4
            x3=temp;
        case 5
            x4=temp;
        case 6
            x5=temp;
        case 7
            x6=temp;
        case 8
            x7=temp;
        case 9
            x8=temp;
    end
end


[m b]=size(total);
if(npts > m)
    npts=m;
end
display(npts);
display('Using normalized DLT(direct linear transformation).');
P=CalibNormDLT(total(1:npts,1:2),total(1:npts,3:5));
display('calculate intrinsic and extrinsic parameters');
[K1,R1,t1] = DecompPMat(P)
display('Using QR Decomposition to calculate intrinsic and extrinsic parameters');
[K,R,t] = DecompPMatQR(P)


fclose(fid);
end