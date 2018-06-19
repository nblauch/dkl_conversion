
function [rgb] = lms2rgb(phosphors,fundamentals,lms)
%  rgb = lms2rgb(phosphors,fundamentals,lms)
% 
%  computes rgb from lms.
%   INPUT
%       phosphors: n by 3 matrix containing the three spectral power distributions of the display device
%       fundamentals: n x 3 matrix containing cone spectral senstivities
%       lms: cone activations. typically these are cone differentials
%       between stimulus and background
%   
%   OUTPUT
%       rgb: the rgb values of the display device.
%

if ~isrow(lms)
    lms = lms';
end

rgbTOlms = fundamentals'*phosphors; 
lmsTOrgb = rgbTOlms\eye(3);
rgb      = lmsTOrgb * lms';

rgb = rgb';