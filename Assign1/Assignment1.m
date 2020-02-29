clc
clear all 
close all

imgname = 'zebra.png'
% imgname = 'pn1.jpg';  %blocky effects more pronounced
img = imread(imgname);
img = img(:,:,1);
imshow(img);

%% Q1
G = gaussian_me(1);

%% Q2
% imOut_me = gaussianConv('zebra.png', 1,1);
% imOut_me = gaussianConv('zebra.png', 3,3);
imOut_me = gaussianConv(imgname, 3,3);
% [Gx, Gy] = gaussianConv('zebra.png', 1,1);

subplot(1,2,1);
imshow(img);
subplot(1,2,2)
imshow(uint8(imOut_me));

%% Q3
imOut_me = gaussianConv(imgname, 2,2);
G        = fspecial('gaussian',13,2); %size = 6*sigma + 1
imOut    = conv2(img,G,'same');

% contour(G);

figure;
subplot(1,3,1);
imshow(img);
subplot(1,3,2);
imshow(uint8(imOut_me));
subplot(1,3,3);
imshow(uint8(imOut));

%% Q4
Gd = gaussianDer(G, 2);
figure;
subplot(1,2,1);
contour(G);
subplot(1,2,2);
contour(Gd); %% Hmm...weird

%% Q5
[magnitude , orientation] = gradmag(img, 10);

% figure;
% imshow(orientation , [-pi,pi])
% colormap(hsv);
% colorbar;

imshow(magnitude < 5)

%% Q6




