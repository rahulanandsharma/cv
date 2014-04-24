a = readim('bigsur1.jpg');
b = readim('bigsur2.jpg');
sz = imsize(a);
dipshow(1,a);  
ca = dipgetcoords(1,1);
dipshow(1,b);
cb = dipgetcoords(1,1);
s = ca - cb - [sz(1),0];
z = newim(sz);

a = iterate('cat',1,a,z);
b = iterate('cat',1,z,b);

b = iterate('dip_wrap',b,s);
d = 255 - max(abs(a-b));
d(0:sz(1)-1+s(1),:) = 0;

d(sz(1):imsize(d,1)-1,:) = 0;
w = dip_watershed(d,[],1,50,1e9,0);
labs = unique(double(w));
labs(1) = [];     % labs == 0 doesn't count
N = length(labs);

V = zeros(N,N);   % vertices
length(labs)
for ii=1:length(labs)
 ii
    m = w==labs(ii);
   l = unique(double(w(bdilation(m,2,1,0))));
   l(1) = [];     % l == 0 doesn't count
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
w = setlabels(w,labs(L==0),N1);
w = setlabels(w,labs(L==1),N2);
w = dip_growregions(w,[],[],1,0,'low_first');
w = w==N2;
out = a;
out(w) = b(w);
m = newim(w,'bin');
m(round(imsize(m,1)/2):end,:) = 1;
out_dumb = a;
out_dumb(m) = b(m);

m = gaussf(m,3);
out_common = a*(1-m) + b*m;