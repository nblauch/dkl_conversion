
function y = dkl_min_fun(dkl_lm_chrom,dkl_s_chrom,dkl_lum,lms_bg,M_inv,phosphors,fundamentals)
% y = DKL_MIN_FUN(dkl_lm_chrom,dkl_s_chrom,dkl_lum,lms_bg,M_inv,phosphors,fundamentals)
%
%   a function to minimize in finding the maximum isoluminant DKL plane
%   the max chromatic modulation should max out at least one of the R,G,B channels
%   thus, the objective function y = min((any(abs(RGB-255))
%   i.e. it reports how close the function is to reaching max gamut at the
%   relevant R,G,B channel. 
%
%   NOTES:
%
%   2/6/2018 nmb: wrote it

diffcone_coords = M_inv*[dkl_lum,dkl_lm_chrom,dkl_s_chrom]';
lms_stim = diffcone_coords + lms_bg;
rgb_stim = lms2rgb(phosphors,fundamentals,lms_stim);

y = min([abs(rgb_stim(1) - 255), abs(rgb_stim(2) - 255), abs(rgb_stim(3) - 255)]);

end
