
function [isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,background_grey, stim_grey, linearize, n_steps, plot,extension_factor,plot_cond)
% [isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,background_grey, stim_grey, linearize, n_steps, plot,extension_factor,plot_cond)
%
%   finds the maximum isoluminant disc in DKL space
%
%   ARGS:
%       monitor: which monitor (e.g. 'cemnl' or other monitor.) requires
%           that your monitor has been calibrated to produce a phosphors and gammaTable file 
%       background_grey: value of the grey background
%       stim_grey: 0:255; i.e. the brightness: the value of the grey point at origin of isoluminant plane
%       linearize: 0 or 1. 1 for gamma-correction to be applied
%       n_steps: e.g. 60; number of increments from origin to perimeter
%       plot: 0 or 1
%       extension_factor: >=1; use >1 if you wish to have space around
%           circle on plot
%       plot_cond: 'disc', 'annulus' - how you want to show the plot
%
%   OUTPUTS:
%       isolum_plane: the isoluminant plane image 
%       inc_dkl_lm_chrom: the increment along the (l-m) axis
%       inc_dkl_s_chrom: the increment along the s-(l+m) axis
%       dkl_origin: origin of dkl space in [(l+m), (l-m), s-(l+m)]
%
%   NOTES:
%
%   2/7/18 nmb: wrote it
%   3/1/18 nmb: added usage info


%% load relevant information and set background

load(['gammaTable-',monitor,'-rgb'])
load('SMJfundamentals')
load(['phosphors-',monitor])

rgb_bg = repmat(background_grey,[1,3]);
rgb_grey_stim = repmat(stim_grey,[1,3]);

rgb_bg_gc = linearizeOutput(repmat(background_grey,[1,3]),gammaTable);
rgb_grey_stim_gc = linearizeOutput(repmat(stim_grey,[1,3]),gammaTable);

%% acquire conversion matrices and gray_stim DKL coords
[lms_bg, M, M_inv] = get_dkl_conversion_mats(rgb_bg, monitor,linearize); 

% if linearize
%     lms_grey_stim = rgb2lms(phosphors,fundamentals,rgb_grey_stim_gc); 
% else
%     lms_grey_stim = rgb2lms(phosphors,fundamentals,rgb_grey_stim);
% end

lms_grey_stim = rgb2lms(phosphors,fundamentals,rgb_grey_stim);

dkl_origin = M*(lms_grey_stim - lms_bg); %is all zeros if stim_grey == background_grey

%% find maximum coordinates along the positive dkl_lm_chrom axis
nudge = .001;
while 1
    try        
        fun = @(x)dkl_min_fun(x, dkl_origin(2), dkl_origin(3), lms_bg, M_inv, phosphors, fundamentals);
        dkl_lm_chrom_0 = dkl_origin(2) + nudge;
        
        %options = optimset('PlotFcns',@optimplotfval);
        [dkl_lm_chrom_max,fval_fminx] = fminsearch(fun,dkl_lm_chrom_0);
        inc_dkl_lm_chrom = abs(dkl_lm_chrom_max-dkl_lm_chrom_0)./n_steps;
        
        diffcone_coords_stim_lmmod = M_inv*[dkl_origin(1),dkl_lm_chrom_max, dkl_origin(3)]';
        lms_stim_lm_chrom_mod = diffcone_coords_stim_lmmod + lms_bg;
        rgb_stim_lm_chrom_mod = lms2rgb(phosphors,fundamentals,lms_stim_lm_chrom_mod);
        if fval_fminx < 5 && ~((any(rgb_stim_lm_chrom_mod)>255) || (any(rgb_stim_lm_chrom_mod)<0))
            break
        end
    catch ME
    end
    assert(~(nudge>10 &&((any(rgb_stim_lm_chrom_mod)>255) || (any(rgb_stim_lm_chrom_mod)<0))),'dkl_lm minimization led to invalid rgb')
    assert(nudge<10,'dkl_lm could not converge')
    nudge = nudge*2;
end

%% find maximum coordinates along the positive dkl_s_chrom axis
nudge = .001;
while 1
    try
        fun = @(x)dkl_min_fun(dkl_origin(1), x, dkl_origin(3), lms_bg, M_inv, phosphors, fundamentals);
        dkl_s_chrom_0 = dkl_origin(3) + nudge;
        
        %options = optimset('PlotFcns',@optimplotfval);
        [dkl_s_chrom_max,fval_fminx] = fminsearch(fun,dkl_s_chrom_0);
        inc_dkl_s_chrom = abs(dkl_s_chrom_max-dkl_s_chrom_0)./n_steps;
        
        diffcone_coords_stim_smod = M_inv*[dkl_origin(1), dkl_origin(2),dkl_s_chrom_max]';
        lms_stim_s_chrom_mod = diffcone_coords_stim_smod + lms_bg;
        rgb_stim_s_chrom_mod = lms2rgb(phosphors,fundamentals,lms_stim_s_chrom_mod);
        if fval_fminx < 5 && ~((any(rgb_stim_s_chrom_mod)>255) || (any(rgb_stim_s_chrom_mod)<0))
            break
        end
    catch ME
    end
    assert(~(nudge>10 &&((any(rgb_stim_s_chrom_mod)>255) || (any(rgb_stim_s_chrom_mod)<0))),'dkl_lm minimization led to invalid rgb')
    assert(nudge<10,'dkl_s could not converge')
    nudge = nudge*2;
end

%% find max disc within the isoluminant plane
count = 0;
for rho = n_steps:-1:0
    count = count + 1;
    saveRadius = rho;
    count1 = 0;
    broken = 0;
    for theta = 0:15:360
        count1 = count1 + 1;
        [dkl_lm_chrom,dkl_s_chrom] = dkl_polar2cart(rho,theta,inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin);
        diffcone_coords = M_inv*[dkl_origin(1),dkl_lm_chrom,dkl_s_chrom]';
        lms = diffcone_coords + lms_bg;
        rgb = lms2rgb(phosphors,fundamentals,lms);
        if(any(rgb(:)>255) || any(rgb(:)<0))
            broken = 1; %break if any color is invalid, return to loop and decrease value
            break
        end
    end
    if broken ==0 %if not broken, all points are valid so break and save info
        break
    end
end

%update increments such that stepRadius increments yields max radius
inc_dkl_lm_chrom = (saveRadius/n_steps)*inc_dkl_lm_chrom;
inc_dkl_s_chrom = (saveRadius/n_steps)*inc_dkl_s_chrom;

lm_chrom_radius = n_steps*inc_dkl_lm_chrom;
s_chrom_radius = n_steps*inc_dkl_s_chrom;

dkl_lm_chrom_axis = dkl_origin(2)-extension_factor*lm_chrom_radius:inc_dkl_lm_chrom:dkl_origin(2) + extension_factor*lm_chrom_radius;
dkl_s_chrom_axis = dkl_origin(3)-extension_factor*s_chrom_radius:inc_dkl_s_chrom:dkl_origin(3) + extension_factor*s_chrom_radius;

%% produce isoluminant plane

[lm_grid,s_grid] = meshgrid(dkl_lm_chrom_axis,dkl_s_chrom_axis);

isolum_plane = zeros([size(lm_grid),3]);

for ii = 1:length(dkl_lm_chrom_axis)
    for jj = 1:length(dkl_s_chrom_axis)
        diffcone_coords = M_inv*[dkl_origin(1), lm_grid(ii,jj), s_grid(ii,jj)]';
        lms_stim = diffcone_coords + lms_bg;
            isolum_plane(ii,jj,:) = lms2rgb(phosphors,fundamentals,lms_stim);
        if (any(isolum_plane(ii,jj,:)>255) || any(isolum_plane(ii,jj,:)<0))
            isolum_plane(ii,jj,:) = rgb_bg;
        end
      [~, testRadius] = dkl_cart2polar(lm_grid(ii,jj),s_grid(ii,jj),inc_dkl_lm_chrom,inc_dkl_s_chrom,dkl_origin);
        switch plot_cond
            case 'disc'
                if testRadius>n_steps
                    isolum_plane(ii,jj,:) = rgb_bg;
                end
            case 'annulus'
                if testRadius<(n_steps-.1*n_steps) || testRadius>n_steps
                    isolum_plane(ii,jj,:) = rgb_bg;
                end
        end
    end
end

isolum_plane = uint8(isolum_plane);

if linearize
    isolum_plane = linearize_image(isolum_plane,gammaTable);
end

if plot
    figure
    imshow(isolum_plane)
    set(gca,'YDir','normal')
    title(['Isoluminant DKL disc: bg intensity-',num2str(background_grey),'stim intensity-',num2str(stim_grey)])
end



