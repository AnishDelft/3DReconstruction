%%
cd (fileparts(matlab.desktop.editor.getActiveFilename))

%% Part I - Feature Descriptors
matches_cell = cell(1,16); % frames = size(matches,2);

for i=1:16
    fprintf('\n Index : %d', i);
    try
        if (i == 16)
            filename1 = sprintf('data/TeddyBearPNG/obj02_%03d.png.haraff.sift', i);
            filename2 = sprintf('data/TeddyBearPNG/obj02_%03d.png.haraff.sift', 1);
        else
            filename1 = sprintf('data/TeddyBearPNG/obj02_%03d.png.haraff.sift', i);
            filename2 = sprintf('data/TeddyBearPNG/obj02_%03d.png.haraff.sift', i+1);
        end
        
        [feat1,desc1,~,~] = loadFeatures(filename1);
        [feat2,desc2,~,~] = loadFeatures(filename2);
        fprintf('\n  --> Pulled descriptors');
        [matches, ~]      = vl_ubcmatch(desc1, desc2); % [2,N_matches]
        fprintf('\n  --> Found matches');
        X1                = feat1(1:2,matches(1,:));
        X2                = feat2(1:2,matches(2,:));
        matches_cell{i}   = matches;    
    catch
        fprintf('\n[Err] Index : %d', i);        
    end
end

%% Part II - Chaining and PointView-Matrix
matches_cell = load('data/matches_cell_final.mat');
PV           = chainimages(matches_cell.matches_cell.matches_cell);

%% Lab4 - SFM


