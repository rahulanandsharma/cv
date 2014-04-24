close all
clear all
clc
run('vlfeat-0.9.18\toolbox\vl_setup.m');

i=imread('image1.jpg');
i=double(i);
j = vl_imintegral(i); 