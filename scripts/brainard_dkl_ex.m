% DKL Example
%
% MATLAB program to compute the example
% used for the space in Appendix Part IV.
%
% MATLAB is a registered trademark of the
% MathWorks, Inc.
%
% 7/6/95 dhb Wrote it.
% STEP 1: Set the background vector for
% the conversion
bg=[2 4 3]';
% STEP 2: Set the vector we wish to convert
diffcone_coords = [2 -2.5 1]';

% STEP 3: Set M_raw as in equation A.4.9.
% This is found by inserting the background
% values into equation A.4.8. Different
% backgrounds produce different matrices.
% The MATLAB notation below just
% fills the desired 3-by-3 matrix.
M_raw = [ 1 1 0; ...
1 -bg(1)/bg(2) 0; ...
-1 -1 (bg(1)+bg(2))/bg(3) ];

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
isochrom_raw_pooled = norm(isochrom_raw./bg);
rgisolum_raw_pooled = norm(rgisolum_raw./bg);
sisolum_raw_pooled = norm(sisolum_raw./bg);

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
lum_resp = M*isochrom_unit;
l_minus_m_resp = M*rgisolum_unit;
s_minus_lum_resp = M*sisolum_unit;

% STEP 10: Compute the inverse of M to obtain
% the matrix in equation A.4.12.
M_inv = inv (M) ;

% STEP 11: Multiply the vector we wish to
% convert byM to obtain its DKL coordinates.
DKL_coords = M*diffcone_coords;

% STEP 12: convert to spherical coordinates.
% According to the conventions in the original DKL
% paper azimuth of 0 is along our rgisolum axis,
% azimuth of 90 is along our negative sisolum
% axis. The isochromatic axis has an elevation
% of 90 degrees. To do the conversion. we flip the
% sign of the sisolum coordinate and then do a
% standard conversion to polar coordinates. •
RADS_TO_DEGS = 360/(2*pi);
azimuth_rads = atan(-DKL_coords(3)/DKL_coords(2));
isolum_len = sqrt(DKL_coords(2)^2 + DKL_coords(3)^2);
elevation_rads = atan(DKL_coords(1)/isolum_len);
azimuth = RADS_TO_DEGS*azimuth_rads;
elevation = RADS_TO_DEGS*elevation_rads;

