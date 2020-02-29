%% Part 0 - Read image
cd (fileparts(matlab.desktop.editor.getActiveFilename))
im1 = im2double(imread('boat/img1.pgm'));
im2 = im2double(imread('boat/img2.pgm'));
% disp(size(im1))
% disp(size(im2))

im3 = im2double(imread('left.jpg')); % Train Image1
im4 = im2double(imread('right.jpg'));% Train Image2

figure;
imshow(im3);
figure;
imshow(im4);

%% Part 1
format long g;
% [affine_transform, match1, match2] = imageAlign(im1, im2, 0, 1);
% [affine_transform, match1, match2] = imageAlign(rgb2gray(im3), rgb2gray(im4), 0, 1);

%% Part2 - Image Stitching
%imgout = mosaic('boat/img1.pgm', 'boat/img2.pgm');
imgout = mosaic('left.jpg', 'right.jpg');