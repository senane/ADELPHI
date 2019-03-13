rng(1);     % For reproducibility
x1 = wblrnd(1,1,1,500);
x2 = wblrnd(1.1,1.1,1,500);
[h,p] = kstest2(x1,x2,'Alpha',0.01)



rng(1);     % For reproducibility
x1 = wblrnd(1,1,1,50000);
x2 = wblrnd(1.01,1.01,1,50000);
[h,p] = kstest2(x1,x2,'Alpha',0.01)