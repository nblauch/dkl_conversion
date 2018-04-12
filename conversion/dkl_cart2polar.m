
function [theta,rho] = dkl_cart2polar(dkl_lm_chrom,dkl_s_chrom,inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin)
% [theta,rho] = dkl_cart2polar(dkl_lm_chrom,dkl_s_chrom,inc_dkl_lm_chrom,inc_dkl_s_chrom,origin)
%   
%   transforms a DKL representation from cartesian to polar units
%   dkl_origin contains the full DKL cartesian coordinates:
%   [(l+m),(l-m),(s-(l+m)] or [dkl_lum,dkl_lm,dkl_s]
%
%   NOTES:
%   2/7/2018: nmb: wrote it

steps_lm = (dkl_lm_chrom - dkl_origin(2))./inc_dkl_lm_chrom;
steps_s = (dkl_s_chrom - dkl_origin(3))./inc_dkl_s_chrom;
[theta, rho] = cart2pol(steps_lm,steps_s);
theta = rad2deg(theta);

return
