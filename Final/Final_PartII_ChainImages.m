%   function [PV] = chainimages(matches)
%   Construct the point-view matrix with the matches found between
%   consecutive frames. This matrix has tracked points as columns and
%   views/frames as rows, and "contains the indices of the descriptor for
%   each frame". Therefore, if a certain descriptors can be seen in all
%   frames, their columns are completely filled. Similarly, if it can be 
%   matched only between frame 1 and 2, only the first 2 rows of the columns 
%   will be non-zero.
%
% Inputs:
% - matches: cell array containing matches, with descriptor indices for the
%   1st image in the 1st row, indices for the 2nd image in the 2nd row.
%   Each cell contains one frame pair (1-2, 2-3, 3-4, ... , 11-1).
%
% Outputs:
% - PV: matrix containing matches between consecutive frames

function [PV] = Final_PartII_ChainImages(matches, verbose, plot)
    tic;
    % number of views
    frames = size(matches,2);

    % Initialize PV
    % We add an extra row to process the match between frame_last and frame_1.
    % This extra row will be deleted at the end.
    PV = zeros(frames+1,0);

    %disp(matches)
    %fprintf('\n ======================================== ');
    
    %  Starting from the first frame
    for i=1:frames
        newmatches = matches{i}; %[2, N_matchpoints]
        if (verbose == 1)
            fprintf('\n [i=%d][PV] = [%d %d] || NewMatches : [%d %d]', i, size(PV), size(newmatches));
        end
        
        % For the first pair, simply add the indices of matched points to the same
        % column of the first two rows of the point-view matrix.
        if i==1
            % newmatches = [2,1879] % Subscripted assignment dimension mismatch. 
            PV(1:2,1:size(newmatches,2)) = newmatches;
        else
            % Find already found points using intersection on PV(i,:) and newmatches 
            frame_i_idx      = newmatches(1,:);
            frame_iplus_idx  = newmatches(2,:);
            [~, idx_PV, idx_frame]      = intersect(PV(i,:), frame_i_idx);
            PV(i+1,idx_PV)              = frame_iplus_idx(idx_frame);
            %fprintf('\n  --> [Common btw PV(%d,:) and frame=%d] : %d', i, i, size(idx_PV,1))
            %fprintf('\n  --> [PV] = [%d %d] ', size(PV));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Find new matching points that are not in the previous match set using setdiff.
            if (0)
                % [diffA, ~] = setdiff(frame_i_idx    , PV(i,:));
                [diffB, IB] = setdiff(frame_iplus_idx, PV(i+1,:));
                %fprintf('\n  --> [Vals in frame=%d not in PV(%d,:)] : %d / %d', i+1, i+1, size(IB,1), size(frame_iplus_idx,2));

                % Grow the size of the point view matrix each time you find a new match.
                start = size(PV,2)+1;
                PV    = [PV zeros(frames+1, size(diffB,2))]; 
                PV(i  , start:end) = frame_i_idx(1,IB);
                PV(i+1, start:end) = diffB;
            else
                [diffA, IA] = setdiff(frame_i_idx    , PV(i,:));
                % [diffB, IB] = setdiff(frame_iplus_idx, PV(i+1,:));
                %fprintf('\n  --> [Vals in frame=%d not in PV(%d,:)] : %d / %d', i+1, i+1, size(IB,1), size(frame_iplus_idx,2));

                % Grow the size of the point view matrix each time you find a new match.
                start = size(PV,2)+1;
                PV    = [PV zeros(frames+1, size(diffA,2))]; 
                PV(i  , start:end) = diffA;
                PV(i+1, start:end) = frame_iplus_idx(1,IA);
            end
        end
        % fprintf('\n');
    end
    %fprintf('\n\n  --> [Final PV] = [%d %d] \n', size(PV));
    
    % Process the last frame-pair. This part is already completed by TAs.
    % The last frame-pair, consisting of the last and first frames, requires special treatment.
    % Move matches between last & 1st frame to their corresponding columns in
    % the 1st frame, to prevent multiple columns for the same point.
    [~, IA, IB]      = intersect(PV(1, :), PV(end, :));
    if (verbose == 1)
        fprintf('\n [Debug] Intersection between PV(1) and PV(end) : %d', size(IA));
    end
    PV(:, IA(2:end)) = PV(:, IA(2:end)) + PV(:, IB(2:end));  % skip 1st index (contains zeros)
    PV(:, IB(2:end)) = [];  % delete moved points in last frame

    % Copy the non zero elements from the last row which are not in the first row to the first row. 
    nonzero_last  = find(PV(end, :));
    nonzero_first = find(PV(1, :));
    no_member     = ~ismember(nonzero_last, nonzero_first);
    nonzero_last  = nonzero_last(no_member); % [Note] unique in laPVst row
    tocopy        = PV(:, nonzero_last);

    % Place these points at the very beginning of PV
    PV(:, nonzero_last) = [];
    PV                  = [tocopy PV];

    % Copy extra row elements from last row to 1st row and delete the last row
    PV(1 ,1:size(tocopy, 2)) = PV(end, 1:size(tocopy, 2));
    PV                       = PV(1:frames,:); 
    
    if (plot == 1)
        figure;
        tmp          = PV;
        tmp(tmp > 0) = 255;
        imagesc(tmp);
        title('PV Matrix');
    end
    
    % disp(strcat(int2str(size(PV,2)), ' points in pointview matrix so far'));
    %toc;
end
