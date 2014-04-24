% Stitching two images together using the method from:
% N. Gracias, M. Mahoor, S. Negahdaripour & A. Gleason, "Fast image
% blending using watersheds and graph cuts", Image and Vision
% Computing 27(5):597-607, 2009. doi:10.1016/j.imavis.2008.04.014
%
% Cris Luengo, July 2009.
%
% Requires the maxflow package by Miki Rubinstein, available at
% the MATLAB Central File Exchange:
% http://www.mathworks.com/matlabcentral/fileexchange/21310
%
% Requires the DIPimage toolbox: http://www.diplib.org/


% Note: Before DIPimage 2.1, the SMOOTH command used here did not
% keep the color information in the images. You can use
%   a = iterate('smooth',a,1);
% instead of
%   a = smooth(a,1);
% if you are using an older version of DIPimage. Or better yet,
% upgrade!

% Read in the images & down-sample
a = readim('BigSur1.JPG');
a = smooth(a,1);
a = a(0:4:imsize(a,1)-1,0:4:imsize(a,2)-1);
b = readim('BigSur2.JPG');
b = smooth(b,1);
b = b(0:4:imsize(b,1)-1,0:4:imsize(b,2)-1);

   %writeim(a,'bigsur1.jpg','jpeg')
   %writeim(b,'bigsur2.jpg','jpeg')

% Please note that the images 'bigsur1.jpg' and 'bigsur2.jpg' you
% can find on my blog page are these downsampled images, not the
% original ones. Please skip the 6 lines above, and just read them
% in with:
%  a=readim('bigsur1.jpg');
%  b=readim('bigsur2.jpg');

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
size a
size a(0:imsize(a,1)+s(1)-1,:)
a = a(0:imsize(a,1)+s(1)-1,:);
b = b(0:imsize(b,1)+s(1)-1,:);
if s(2)>0
   a = a(:,s(2):imsize(a,2)-1);
   b = b(:,s(2):imsize(b,2)-1);
else
   a = a(:,0:imsize(a,2)-s(2)-1);
   b = b(:,0:imsize(b,2)-s(2)-1);
end

   %writeim(a,'bigsur1x.jpg','jpeg')
   %writeim(b,'bigsur2x.jpg','jpeg')

% Difference image
d = 255 - max(abs(a-b));
d(0:sz(1)-1+s(1),:) = 0;
d(sz(1):imsize(d,1)-1,:) = 0;

   %writeim(d,'bigsur_diff.jpg','jpeg')

% Watershed of the blurred inverse
w = dip_watershed(d,[],1,50,1e9,0);

   %writeim((w==0)*255,'bigsur_watershed.jpg','jpeg')

% Make the graph & measure edges
labs = unique(double(w));
labs(1) = []; % labs == 0 doesn't count
N = length(labs);
V = zeros(N,N); % vertices
for ii=1:length(labs)
   m = w==labs(ii);
   l = unique(double(w(bdilation(m,2,1,0))));
   l(1) = []; % l == 0 doesn't count
   l(l==labs(ii)) = [];
   for jj=1:length(l)
      kk = find(l(jj)==labs);
      if V(ii,kk) == 0
         n = w==l(jj);
         n = closing(m|n,2,'rectangular') - m - n;
         if ~any(n)
            V(ii,kk) = 0.01;
         else
            V(ii,kk) = sum(d(n));
         end
         V(kk,ii) = V(ii,kk);
      end
   end
end

% Graph cut
N1 = double(w(1,1));
N2 = double(w(end-1,1));
kk1 = find(labs==N1);
kk2 = find(labs==N2);
T = [V(:,kk1),V(:,kk2)];
V([kk1,kk2],:) = [];
V(:,[kk1,kk2]) = [];
T([kk1,kk2],:) = [];
labs([kk1,kk2]) = [];
[flow,L] = maxflow(sparse(V),sparse(T));

% Color
w = setlabels(w,labs(L==0),N1);
w = setlabels(w,labs(L==1),N2);
w = dip_growregions(w,[],[],1,0,'low_first');
w = w==N2;

   %writeim(w*255,'bigsur_mask.jpg','jpeg')

% Compose
out = a;
out(w) = b(w);

   %writeim(out,'bigsur.jpg','jpeg')

stitch3 = out(sz(1)+s(1):sz(1)-1,:);

% Alternative: simple compose
m = newim(w,'bin');
m(round(imsize(m,1)/2):end,:) = 1;
out = a;
out(m) = b(m);

   %writeim(out,'bigsur_simple.jpg','jpeg')

stitch1 = out(sz(1)+s(1):sz(1)-1,:);

% Alternative: simple compose with blur
m = gaussf(m,3);
out = a*(1-m) + b*m;

   %writeim(out,'bigsur_simpleblur.jpg','jpeg')

stitch2 = out(sz(1)+s(1):sz(1)-1,:);

% Side-by-side comparison of stitchings
stitch = iterate('cat',1,stitch1,stitch2,stitch3);
stitch = stitch(:,round(imsize(stitch,2)/2):imsize(stitch,2)-1);

   %writeim(stitch,'bigsur_3stitches.jpg','jpeg')