clear all
clc
close all
load feature.mat
addpath('libsvm-3.17\libsvm-3.17\matlab\')
bestcv = 0;
for log2c = -1:3,
  for log2g = -4:1
      log2c
      log2g
    cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g)];
    cv = svmtrain(labels,feature, cmd);
    if (cv >= bestcv),
      bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
    end
    fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
  end
end
cmd = ['-t 2 -c ', num2str(bestc), ' -g ', num2str(bestg)];
model = svmtrain(labels,feature, cmd);