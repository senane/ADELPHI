function [e,A,B]=cross_sampen(x,y,M,r,sflag)
%function [e,A,B]=cross_sampen(x,y,M,r,sflag);
%
%Input
%
%x,y input data
%M maximum template length
%r matching tolerance
%sflag    flag to standardize signals(default yes/sflag=1) 
%
%Output
%
%e sample entropy estimates for m=0,1,...,M-1
%A number of matches for m=1,...,M
%B number of matches for m=0,...,M-1 excluding last point

if ~exist('M')|isempty(M),M=5;end
if ~exist('r')|isempty(r),r=.2;end
if ~exist('sflag')|isempty(sflag),sflag=1;end
y=y(:);
x=x(:);
ny=length(y);
nx=length(x);
if sflag>0
   y=y-mean(y);
   sy=sqrt(mean(y.^2));   
   y=y/sy;
   x=x-mean(x);
   sx=sqrt(mean(x.^2));   
   y=y/sx;   
end

lastrun=zeros(nx,1);
run=zeros(nx,1);
A=zeros(M,1);
B=zeros(M,1);
p=zeros(M,1);
e=zeros(M,1);
for i=1:ny
   for j=1:nx
      if abs(x(j)-y(i))<r
         run(j)=lastrun(j)+1;
         M1=min(M,run(j));
         for m=1:M1           
            A(m)=A(m)+1;
            if (i<ny)&(j<nx)
               B(m)=B(m)+1;
            end            
         end
      else
         run(j)=0;
      end      
   end
   for j=1:nx
      lastrun(j)=run(j);
   end
end
N=ny*nx;
B=[N;B(1:(M-1))];
p=A./B;
e=-log(p);
