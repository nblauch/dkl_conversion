
% short PTB script to check illuminance/luminance values across an arbitrary set of colors (requires photometer)
% calls check_illuminance

%% set colors and other options
measure = 1; % 1 if want to type/save illuminance readings
n_steps = 120;
background_intensity = 54;
monitor = 'hmrc';

[isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,128, 128, 1, n_steps, 1,1,'disc');

%apply gamma correction and then luminance normalization
rgb_dkl_gc = get_n_dkl_colors(8,0,1,monitor,45,45,1,1,1);
rgb_dkl_gc_iso = correct_illuminance(rgb_dkl_gc,monitor,0,0);
plot_n_dkl_colors(rgb_dkl_gc_iso,0,50)

%apply luminance normalization only
rgb_dkl = get_n_dkl_colors(8,0,1,monitor,128,128,0,1,1);
rgb_dkl_iso = correct_illuminance(rgb_dkl,monitor,0,0);
plot_n_dkl_colors(rgb_dkl_iso,0,50)

%% call check_illuminance

Screen('Preference', 'SkipSyncTests', 1);
readings = check_illuminance(rgb_dkl_iso,0);


%% other
set(0,'DefaultFigureWindowStyle','docked')
for background_intensity = 5:5:100
    [isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,20, 55, 1, n_steps, 1,1,'disc');
end

[isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,50, 128, 0, n_steps, 1,1,'disc');
[isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc(monitor,55, 55, 1, n_steps, 1,1,'disc');
