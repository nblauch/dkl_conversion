function [ lms_bg, M, M_inv ] = get_dkl_conversion_mats(rgb_bg, monitor,linearize)
%[ lms_bg, M, M_inv ] = get_dkl_conversion_mats(rgb_bg, monitor,linearize)
%
%   acquire lms_bg , M, and M_inv for DKL conversion of arbitrary stimulus
%   colors on a pretermined background.
%
%   INPUT ARGS:
%       rgb_bg: RGB coordinates of the background
%       phosphors: SPDs specified by mx3 matrix (m is usually 341 for lambda=390:730)
%       fundamentals: cone fundamentals (usually those given by Stockman, MacLeod, and Johnson (1993))
%       gammaTable(optional): to perform gamma correction within script.
%           alternatively, one can do gamma correction before inputting rgb_bg
%   OUTPUT_ARGS:
%       lms_bg: lms cone excitations of the background
%       M: matrix for converting between cone differential coordinates and DKL
%           i.e. DKL_coords = M*diffcone_coords
%       M_inv: matrix for converting between DKL and differential coordinates
%           i.e. diffcone_coords = M_inv*DKL_coords;
%
%   NOTES:
%   this code is essentially copied from Brainard (1996), in Human Color
%   Vision. thanks dhb!
%
%   2/6/2018 nmb: Wrote it

load('SMJfundamentals')
load(['phosphors-',monitor])

if linearize
    load(['gammaTable-',monitor,'-rgb'])
    rgb_bg = linearize_image(rgb_bg,gammaTable);
end

lms_bg = rgb2lms(phosphors,fundamentals,rgb_bg);

M_raw = [ 1 1 0; ...
1 -lms_bg(1)/lms_bg(2) 0; ...
-1 -1 (lms_bg(1)+lms_bg(2))/lms_bg(3) ];

% STEP 4: Compute the inverse of M for
% equation A.4.10. The MATLAB inv() function
% computes the matrix inverse of its argument.
M_raw_inv = inv(M_raw);

% STEP 5: Find the three isolating stimuli as
% the columns of M_inv_raw. The MATLAB
% notation X(:,i) extracts the i-th column
% of the matrix X.
isochrom_raw = M_raw_inv(:,1);
rgisolum_raw = M_raw_inv(:,2);
sisolum_raw = M_raw_inv(:,3);

% STEP 6: Find the pooled cone contrast of each
% of these. The MATLAB norm() function returns
% the vector length of its argument. The MATLAB
% .1 operation represents entry-by-entry division.
isochrom_raw_pooled = norm(isochrom_raw./lms_bg);
rgisolum_raw_pooled = norm(rgisolum_raw./lms_bg);
sisolum_raw_pooled = norm(sisolum_raw./lms_bg);

% STEP 7: Scale each mechanism isolating
% modulation by its pooled contrast to obtain
% mechanism isolating modulations that have unit length

isochrom_unit = isochrom_raw/isochrom_raw_pooled;
rgisolum_unit = rgisolum_raw/rgisolum_raw_pooled;
sisolum_unit = sisolum_raw/sisolum_raw_pooled;

% STEP 8: Compute the values of the normalizing
% constants by plugging the unit isolating stimuli
% into A.4.9 and seeing what we get. Each vector
% should have only one non-zero entry. The size
% of the entry is the response of the unscaled
% mechanism to the stimulus that should give unit
% response.
lum_resp_raw = M_raw*isochrom_unit;
l_minus_m_resp_raw = M_raw*rgisolum_unit;
s_minus_lum_resp_raw = M_raw*sisolum_unit;

% STEP 9: We need to rescale the rows of M_raw
% so that we get unit response. This means
% mUltiplying each row of M_raw by a constant.

% The easiest way to accomplish the multiplication
% is to form a diagonal matrix with the desired
% scalars on the diagonal. These scalars are just
% the multiplicative inverses of the non-zero
% entries of the vectors obtained in the previous
% step. The resulting matrix M provides the
% entries of A.4.11. The three _resp vectors
% computed should be the three unit vectors
% (and they are).
D_rescale = [1/lum_resp_raw(1) 0 0; ...
    0 1/l_minus_m_resp_raw(2) 0 ; ...
    0 0 1/s_minus_lum_resp_raw(3)] ;
M = D_rescale*M_raw;

% STEP 10: Compute the inverse of M to obtain
% the matrix in equation A.4.12.
M_inv = inv (M) ;

end

