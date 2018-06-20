
function rgb_dkl = get_n_dkl_colors(n_colors,phase,frac_radius,monitor,background_grey,stim_grey,linearize,plot_disc,plot_colors)
%   rgb_dkl = get_n_dkl_colors(n_colors,monitor,background_grey,stim_grey,linearize,plot_disc,plot_colors)
%
%   Acquire (and plot) n colors chosen along the perimeter of an isoluminant DKL disc.
%
%   INPUT
%       n_colors: number of colors to select
%       phase: on range 0,360; 0 for no shift, >0 to shift angles
%       frac_radius: on range 0,1; how saturated? 1 for maximum saturation
%       monitor: e.g. 'cemnl' or other calibrated monitor.
%       background_grey: background grey intensity
%       stim_grey: essentially brightness; gray value of origin of isolum
%           plane
%       linearize: 0 or 1, to gamma-correct 
%       plot_disc: 0 or 1
%       plot_colors: 0 or 1
%
%   OUTPUT
%       rgb_dkl: an n_colors x 3 matrix of the equally spaced dkl colors
%
%   NOTES
%   2/7/18 nmb: wrote it
%   3/1/18 nmb: added helpful info

n_steps = 120;

load(['phosphors-',monitor])
load('SMJfundamentals')

%compute angles for n colors
color_angles = linspace(0,360-(360/n_colors),n_colors);
color_angles = color_angles + phase;

%find the DKL disc - don't linearize. will do later.
[~, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,background_grey, stim_grey, 0, n_steps, 0,1,'disc');

%plot if desired
[~, ~,~, ~] = find_max_dkl_disc(monitor,background_grey, stim_grey, linearize, n_steps, plot_disc,1,'disc');

%get DKL<->cone differential conversion matrices
[lms_bg, M, M_inv ] = get_dkl_conversion_mats(repmat(background_grey,[1,3]), monitor,0);

grey_diffcone_coords = M_inv*[dkl_origin(1),0,0]';
grey_bg = lms2rgb(phosphors,fundamentals,lms_bg + grey_diffcone_coords);

%compute rgb values for chosen color angles
count = 0;
for theta = color_angles
    count = count + 1;
    [dkl_lm_chrom, dkl_s_chrom] = dkl_polar2cart(frac_radius*n_steps,theta,inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin);
    diffcone_coords = M_inv*[dkl_origin(1),dkl_lm_chrom, dkl_s_chrom]';
    lms = diffcone_coords + lms_bg;
    rgb_dkl(count,:) = lms2rgb(phosphors,fundamentals,lms);
end
rgb_dkl = rgb_dkl./255;

if linearize
    load(['gammaTable-',monitor,'-rgb'])
    rgb_dkl = linearize_image(rgb_dkl,gammaTable);
    try
        load(['gammaTable-',monitor])
    catch
        gammaTable = mean(gammaTable,2); %if grayscale gammaTable doesn't exist, take mean across r,g,b channels
    end
    grey_bg = linearize_image(grey_bg,gammaTable);
end

grey_bg = double(grey_bg)./255;

if plot_colors
    figure
    hold on
    scatter(0,0,100000,grey_bg,'filled');
    for i = 1:n_colors
        scatter(cosd(color_angles(i)),sind(color_angles(i)),(200*24/n_colors),rgb_dkl(i,:),'filled')
    end
    axis equal
    ylim([-1.2 1.2])
    xlabel('l-m')
    ylabel('s - (l+m)')
    title([num2str(n_colors),' hues along perimeter of isoluminant DKL disc. origin intensity: ',num2str(background_grey)])
    hold off
end
