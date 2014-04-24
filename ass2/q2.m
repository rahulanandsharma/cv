clear all
clc
close all

addpath('gco-v3.0\matlab\')    
a=imread('image1.jpg');




h = GCO_Create(4,2);             % Create new object with NumSites=4, NumLabels=3
      GCO_SetDataCost(h,[0 9 2 0;      % Sites 1,4 prefer  label 1
                           3 0 3 3;      % Site  2   prefers label 2 (strongly)
                           5 9 0 5;]);   % Site  3   prefers label 3
      GCO_SetSmoothCost(h,[0 1 2;      % 
                             1 0 1;      % Linear (Total Variation) pairwise cost
                             2 1 0;]);   % 
      GCO_SetNeighbors(h,[0 1 0 0;     % Sites 1 and 2 connected with weight 1
                            0 0 1 0;     % Sites 2 and 3 connected with weight 1
                            0 0 0 2;     % Sites 3 and 4 connected with weight 2
                            0 0 0 0;]);
      GCO_Expansion(h);                % Compute optimal labeling via alpha-expansion 
      GCO_GetLabeling(h)
     
      [E D S] = GCO_ComputeEnergy(h)   % Energy = Data Energy + Smooth Energy
    
     GCO_Delete(h);                   % Delete the GCoptimization object when finished
