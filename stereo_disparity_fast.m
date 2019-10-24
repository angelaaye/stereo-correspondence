function [Id] = stereo_disparity_fast(Il, Ir, bbox)
% STEREO_DISPARITY_FAST Fast stereo correspondence algorithm.
%
%  Id = STEREO_DISPARITY_FAST(Il, Ir, bbox) computes a stereo disparity image
%  from left stereo image Il and right stereo image Ir.
%
%  Inputs:
%  -------
%   Il    - Left stereo image, m x n pixels, colour or greyscale.
%   Ir    - Right stereo image, m x n pixels, colour or greyscale.
%   bbox  - Bounding box, relative to left image, top left corner, bottom
%           right corner (inclusive). Height is u, width is v.
%
%  Outputs:
%  --------
%   Id  - Disparity image (map), u x v pixels, greyscale.

% Hints:
%
%  - Loop over each image row, computing the local similarity measure, then
%    aggregate. At the border, you may replicate edge pixels, or just avoid
%    using values outside of the image.
%
%  - You may hard-code any parameters you require (e.g., disparity range) in
%    this function.
%
%  - Use whatever window size you think might be suitable.
%
%  - Don't optimize for runtime, optimize for clarity.

%--- FILL ME IN ---

% Code goes here...
  
%------------------


% Convert to double to perform computations
Il = double(Il);
Ir = double(Ir);

% Parameters
padSize = 5;
maxDisp = 63;

% Initialize Id
Id = zeros(bbox(2, 2)-bbox(2, 1)+1, bbox(1, 2)-bbox(1, 1)+1); 
% Initialize a matrix that is 3 dimensional, contains also a third dimension to store 
% SSD values of every single disparity from [0, 63]
IdCopy = zeros(size(Id, 1), size(Id, 2), maxDisp+1); 

for k = 0:maxDisp
    % Shift the right image, replace shifted columns with 0's
    shiftedIr = [zeros(size(Il, 1), k) Ir(:, 1:size(Il, 2)-k)];
    % Calculate the absolute difference
    absDiff = abs(Il - shiftedIr);
    % Compute the integral sum
    intSum = cumsum(cumsum(absDiff), 2);
    % Loop through left image coordinates and find the sum of absolute difference using
    % Sum(A,B,C,D) = D + A - B - C, where D, A are the lower right and upper left corners of the box,
    % and B, C are the other two diagonals
     for i = bbox(1, 1) : bbox(1, 2)  % x = rows
        for j = bbox(2, 1) : bbox(2, 2)  % y = cols
            patchSum = intSum(j-padSize, i-padSize) + intSum(j+padSize, i+padSize) - intSum(j+padSize, i-padSize) - intSum(j-padSize, i+padSize);
            % Store the SAD values in the matrix
            IdCopy(j-bbox(2, 1)+1, i-bbox(1, 1)+1, k+1) = patchSum;
        end
    end
end

% Compute the minimum SAD value for each pixel
[~, ind] = min(IdCopy, [], 3);
% Subtract one because MATLAB index starts from 1 (but disparity starts at 0)
Id = uint8(ind-1);
%imshow(Id)



end
