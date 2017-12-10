close all
clear all
clc

x0_var = [5, 3];
options = optimset();

% noisy image with awgn std = 20
im = double(imread('test_im_20.pgm'));
func_var = @(x)fun_var(x, im);

lb= [0 1.05];  %Any lb > 1.05 should work
ub = [];
tic
noise_level = fminsearchbnd( func_var , x0_var, lb, ub, options );
noise_level = noise_level(1);


function f_val = fun_var(xx, im)
window = fspecial('gaussian', 7, 7/6); % can use any window size
window = window/sum(sum(window));
f_val = 0; 
N=8;
x=(0:N-1)';
C=cos((2*x+1)*x'*pi/(2*N))*sqrt(2/N);
C(:,1)=C(:,1)/sqrt(2);
count = 1;
for i=1:8
    for j=1:8
        if i+j == 2
            continue
        end       
        aa=C(:,i);
        bb=C(:,j)';
        X=aa*bb;
        im_dct = filter2(X, im, 'same');
        mu = sqrt(filter2(window, im_dct,'same'));
        sigma  = sqrt(abs(filter2(window, im_dct.*im_dct, 'same')-mu.^2));
        im_dct_norm = im_dct./(eps+sigma);
        sigma_org_est = sqrt(abs(mean2(sigma.^2) - xx(1).^2)); 
        f_val =  f_val + abs(...
            var(sigma(:).*im_dct_norm(:))./mean2(sigma_org_est).^2 ...
            - (xx(1).^2./mean2(sigma_org_est).^2)...
            - xx(2)); 
       count = count+1;
       
    end 
end
end


