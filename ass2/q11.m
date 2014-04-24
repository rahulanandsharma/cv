clear all
close all 
clc
name='data\caltech-101\';
listing = dir(name);
[a b]=size(listing);
labels=[]
lab=0;
labcnt=1;
feature=[];
imgurdata=[];
numfiles=10;
for i=3:a
   dd=listing(i).name
   l=strcat(name,dd)
  files = dir(fullfile(l, '*.jpg'));

    for j = 1:size(files,1)
        if(j>=numfiles)
            break;
        end
        l=strcat(l,'\');
       fulname=strcat(l,files(j,1).name);
       z=imread(fulname);
       z=imresize(z,[400 300]);

       z=single(z);
    cellSize = 8 ;
    if(mod(labcnt,15)==0)
        labcnt
    end
hog = vl_hog(z, cellSize, 'variant', 'dalaltriggs') ;
rofl=hog(:);
   feature(labcnt,:)=rofl';
   labels(labcnt,1)=lab;
labcnt=labcnt+1;
        % do something
     
    end
    lab=lab+1
   
end


