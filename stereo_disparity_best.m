function [Id] = stereo_disparity_best(Il, Ir, bbox)
% STEREO_DISPARITY_BEST Alternative stereo correspondence algorithm.
%
%  Id = STEREO_DISPARITY_BEST(Il, Ir, bbox) computes a stereo disparity image 
%  from left stereo image Il and right stereo image Ir.
%
%  Inputs:
%  -------
%   Il    - Left stereo image, m x n pixels, colour or greyscale.
%   Ir    - Right stereo image, m x n pixels, colour or greyscale.
%   bbox  - Bounding box, relative to left image, top left corner, bottom
%           right corner (inclusive). Width is v.
%
%  Outputs:
%  --------
%   Id  - Disparity image (map), m x v pixels, greyscale.

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
%{
Similar to stereo_disparity_fast, except use rank test as the matching cost.
Method is described in more details here: https://www.hindawi.com/journals/js/2016/8742920/
Essentially, compute the rank of each point using
Rank(x,y) = sum(L(i,j))
L(i,j) = 0 if I(i,j) < I(x,y); = 1 otherwise
Also added a medium filter at the end to smooth out discontinuities.
%}

% Convert to double to perform computations
Il = double(Il);
Ir = double(Ir);

% Parameters
padSize = 3;
maxDisp = 63;

% Initialize Id
Id = zeros(bbox(2, 2)-bbox(2, 1)+1, bbox(1, 2)-bbox(1, 1)+1); 
% Initialize a matrix that is 3 dimensional, contains also a third dimension to store 
% SSD values of every single disparity from [0, 63]
IdCopy = zeros(size(Id, 1), size(Id, 2), maxDisp+1); 

m = padSize; % Rank pad size

% Pad Il and Ir with zeros
padIl = zeros(size(Il, 1)+padSize*2, size(Il, 2)+padSize*2);
padIl(padSize+1:padSize+size(Il, 1), padSize+1:padSize+size(Il, 2)) = Il;
padIr = zeros(size(Ir, 1)+padSize*2, size(Ir, 2)+padSize*2);
padIr(padSize+1:padSize+size(Ir, 1), padSize+1:padSize+size(Ir, 2)) = Ir;

% Compute rank(x, y) of each coordinate for both images
% First, compare I(i, j) of neighbouring coordinates against the middle point
% If intensity is greater or equal, set the value to be 1
% Sum up all the binary numbers in the patch, subtract 1 in the end to remove the pixel of interest
rankIl = Il;
rankIr = Ir;
for i = m+1:size(Il, 2)+m
    for j = m+1:size(Il, 1)+m
        rankIl(j-m, i-m) = sum(padIl(j-m:j+m, i-m:i+m)>=padIl(j, i)*ones(padSize*2+1, padSize*2+1), 'all')-1;
        rankIr(j-m, i-m) = sum(padIr(j-m:j+m, i-m:i+m)>=padIr(j, i)*ones(padSize*2+1, padSize*2+1), 'all')-1;
    end
end


for k = 0:maxDisp
    % Shift the right image, replace shifted columns with 0's
    shiftedIr = [zeros(size(Il, 1), k) rankIr(:, 1:size(Il, 2)-k)];
    % Calculate the absolute difference between ranks
    absDiff = abs(rankIl - shiftedIr);
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
ind = ind - 1;

m = 6; % Median pad size
% Apply median filter
for i = m+1:size(ind, 2)-m
    for j = m+1:size(ind, 1)-m
        ind(j, i) = median(ind(j-m:j+m, i-m:i+m), 'all');
    end
end

Id = uint8(ind);
%imshow(Id);

end