
function [dkl_lm_chrom,dkl_s_chrom] = dkl_polar2cart(rho,theta,inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin)
% [dkl_lm_chrom,dkl_s_chrom] = polar2dkl_chrom((ho,theta,inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin_coords)
%
%   transforms a 2D chromatic DKL representation from polar to cartesian
%   units
%
%   NOTES:
%
% 2/7/2018: nmb: wrote it

    theta = deg2rad(theta);
    [numStepsX, numStepsY] = pol2cart(theta,rho);
    dkl_lm_chrom = dkl_origin(2) + numStepsX*inc_dkl_lm_chrom;
    dkl_s_chrom = dkl_origin(3) + numStepsY*inc_dkl_s_chrom;
return