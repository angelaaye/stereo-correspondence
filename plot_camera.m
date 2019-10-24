function [h] = plot_camera(Hwc, scale, hFOV, vFOV)
% PLOT_CAMERA Plot camera object.
%
%   [h] = PLOT_CAMERA(Hwc, scale, hFOV, vFOV) creates a patch object that
%   looks like a camera (well, a square pyramid, actually), with horizontal
%   field of view 'hFOV' and vertical field of view 'vFOV'.  
%
%   The camera is placed at pose 'Hwc', which is a 4x4 homogeneous pose 
%   matrix; the pose follows the computer vision convention, where the 
%   camera's optical axis is aligned with the z axis.
%
%   The optional scale parameter will scale the object size - the default
%   is 1, which corresponds to a 10cm^3 "camera" approximately.
%
%   Inputs:
%   -------
%    Hwc     - 4x4 homogeneous pose matrix, camera frame wrt world frame.
%   [scale]  - Patch scale. Default is 1 unit.
%   [hFOV]   - Horizontal FOV (degrees).
%   [vFOV]   - Vertical FOV (degrees, default is same as horizontal).
%
%   Outputs:
%   --------
%    h  - Handle to patch object.

% Defaults.
if nargin == 1
  scale = 1;
end

if nargin <= 2
  hFOV = 50;
end

if nargin <= 3
  vFOV = hFOV;
end

% Compute corner points based on field of view.
urx =  tand(hFOV/2);
ury = -tand(vFOV/2);
ulx = -urx;
uly =  ury;
lrx =  urx;
lry = -ury;
llx = -urx;
lly = -ury;

% Z is depth axis.  Focal length is 0.1*scale units.
f = 1;

verts = scale*0.1*[ 
    0,   0,   0; ...
  ulx, uly,   1; ...
  urx, ury,   1; ...
  lrx, lry,   1; ...
  llx, lly,   1];

faces = [
  1, 2, 3, NaN; ...
  1, 3, 4, NaN; ...
  1, 4, 5, NaN; ...
  1, 5, 2, NaN; ...
  1, 5, 4, NaN; ...
  2, 3, 4, 5];

colors = [
  1, 0, 0; ...
  1, 0, 0; ...
  1, 0, 0; ...
  1, 0, 0; ...
  1, 0, 0; ...
  0, 0, 1];

% Transform to desired pose.
verts = repmat(Hwc(1:3, 4), 1, size(verts, 1)) + Hwc(1:3, 1:3)*verts';
verts = verts';

h = patch('Vertices', verts,         ...
          'Faces', faces,            ...
          'FaceVertexCData', colors, ...
          'FaceColor', 'flat',       ...
          'FaceLighting','phong',    ...
          'BackFaceLighting', 'lit');