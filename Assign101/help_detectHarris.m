function [coord, descriptor] = help_detectHarris(im, thresh_harris)

% Find features and make descriptor of image 2
loc                  = help_DoG(im, 0.01);
[r, c, sigma]      = help_harris(im, loc, thresh_harris, 0);
orient               = zeros(size(sigma));
[coord, descriptor] = vl_sift(single(im), 'frames', [c'; r'; sigma'; orient']);

end