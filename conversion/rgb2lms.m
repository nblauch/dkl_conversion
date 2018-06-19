
function [lms] = rgb2lms(phosphors,fundamentals,rgb)
%   [lms] = rgb2lms(phosphors,fundamentals,rgb)
%   
%   computes lms from rgb.
%
%   INPUT:
%       phosphors: n by 3 matrix containing the three spectral power distributions of the display device
%       fundamentals: n x 3 matrix containing the cone spectral senstivities
%       rgb: the rgb coordinates
%
%   OUTPUT:
%       lms: the cone activations corresponding to the rgb coordinates
%           these are usually then transformed to cone differential
%           coordinates by subtracting off lms_bg
%

if isrow(rgb)
    rgb = rgb';
end

% Compute lms from rgb.
rgbTOlms = fundamentals'*phosphors; 
lms      = rgbTOlms * rgb;
