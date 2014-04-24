

a = readim('bigsur1.jpg');
% a=imread('hut.jpg');
% a=imresize(a,[200 300]);
% imwrite(a,'hut.jpg');
% a=imread('mountain.jpg');
% a=imresize(a,[200 300]);
% imwrite(a,'mountain.jpg');
b = readim('bigsur2.jpg');
% a = readim('hut.jpg');
% 
% b = readim('mountain.jpg');

sz = imsize(a);

% Figure out how images align
if 0
   dipshow(1,a);
   ca = dipgetcoords(1,1);
   dipshow(1,b);
   cb = dipgetcoords(1,1);
else
   % (I clicked on the same rock in both pictures, these are the results)
   ca = [764,227];
   cb = [103,215];
end
s = ca - (cb+[sz(1),0]);

% Extend images -- assuming [a,b] is the general alignment
z = newim(sz);
a = iterate('cat',1,a,z);
b = iterate('cat',1,z,b);

% Align images
b = iterate('dip_wrap',b,s);

% Crop images
a = a(0:imsize(a,1)+s(1)-1,:);
b = b(0:imsize(b,1)+s(1)-1,:);
if s(2)>0
   a = a(:,s(2):imsize(a,2)-1);
   b = b(:,s(2):imsize(b,2)-1);
else
   a = a(:,0:imsize(a,2)-s(2)-1);
   b = b(:,0:imsize(b,2)-s(2)-1);
end

   

% Difference image
d = max(abs(a-b));
d(0:sz(1)-1+s(1),:) = 0;
d(sz(1):imsize(d,1)-1,:) = 0;

   % As 'bigsur_diff.jpg', but without the inversion.

% Seeds image
c = newim(d,'sint8');
c(0:sz(1)+s(1),:) = 1;
c(sz(1)-1:imsize(d,1)-1,:) = 2;

% Ordered region growing -- more or less the same as watershed + graph cut
c = dip_growregions(c,d,[],1,0,'high_first');
w = c==2;

   %writeim(w*255,'bigsur_mask_new.jpg','jpeg')

% Compose
out = a;
out(w) = b(w);

   %writeim(out,'bigsur_new.jpg','jpeg')
   dipshow(1,out);

stitch4 = out(sz(1)+s(1):sz(1)-1,:);

% Alternative: simple compose
m = newim(w,'bin');
m(round(imsize(m,1)/2):end,:) = 1;
out = a;
out(m) = b(m);
stitch1 = out(sz(1)+s(1):sz(1)-1,:);

% Alternative: simple compose with blur
m = gaussf(m,3);
out = a*(1-m) + b*m;
stitch2 = out(sz(1)+s(1):sz(1)-1,:);

% Alternative: the composition I made in the original blog post
out = readim('bigsur.jpg');
stitch3 = out(sz(1)+s(1):sz(1)-1,:);

% Side-by-side comparison of stitchings
stitch = iterate('cat',1,stitch2,stitch3,stitch4);
stitch = stitch(:,round(imsize(stitch,2)/2):imsize(stitch,2)-1);

   %writeim(stitch,'bigsur_3stitches_new.jpg','jpeg')