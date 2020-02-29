%% 0 - cd
cd (fileparts(matlab.desktop.editor.getActiveFilename));

%% 1 - Read images
img1 = rgb2gray(imread('images/landscape-a.jpg'));
img2 = rgb2gray(imread('images/landscape-b.jpg'));

%% 2 - Find matches
point_matching_distance_threshold = 0.8; %% (i.e. 1/0.8 = 1.23)
[match1, match2] = findMatches(img1, img2, point_matching_distance_threshold,1);