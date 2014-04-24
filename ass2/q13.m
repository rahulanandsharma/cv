clear all
close all
clc
Folder='Validation\Images'
load svmmodel.mat
model
run('vlfeat-0.9.18-bin\vlfeat-0.9.18\toolbox\vl_setup.m');
addpath('libsvm-3.17\libsvm-3.17\matlab\')
      image = double(filename);
          cellSize = 8 ;
    image=single(image);
      hog = vl_hog(image, cellSize, 'variant', 'dalaltriggs') ;
      rofl=hog(:);
      zz=1;
[predict_label] = svmpredict(double(zz), double(rofl'), model);

 