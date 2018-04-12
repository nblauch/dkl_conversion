
%{
to produce monitor-calibrated isoluminant colors requires an initial
calibration step. see scripts/calibrate_rgb_gamma_table.m
the necessary files should be placed in cal_tables/ and are:
gammaTable-[monitor]
gammaFit-[monitor]
phosphors-[monitor]
%}

%% get an isoluminant plane

addpath(genpath(pwd))
set(0,'DefaultFigureWindowStyle','docked')

%set params
%choose monitor for which there are corresponding calibration files
monitor = 'cemnl'; 
dkl_intensity = 128;
bg_intensity = dkl_intensity; %not guaranteed to converge if bg_intensity != dkl_intensity
linearize = 0; %perform gamma correction later
resolution_steps = 120; %larger for higher resolution

dkl_plane = find_max_dkl_disc('cemnl',dkl_intensity, bg_intensity, linearize, resolution_steps,1,1,'disc');

%{
the disc just plotted is not actually isoluminant. gamma correction will
get you most of the way there. instead of performing explicit gamma
correction, we can also preserve the dynamic range of the space by
performing gamma-based illuminance correction instead of the typical LUT
method. 
%}

post_gamma_correction = 0;
dkl_plane_iso = correct_illuminance_img(dkl_plane,monitor,post_gamma_correction,1,1);

% compare what was just produced with a gamma-corrected isoluminant plane
dkl_plane_gc= find_max_dkl_disc('cemnl',50, 50, 1, resolution_steps,1,1,'disc');

% and see that even gamma-corrected is not fully isoluminant (though much
% closer)
dkl_plane_gc_iso = correct_illuminance_img(dkl_plane_gc,monitor,0,1,1);

%% get an isoluminant set of colors
n_colors = 12;
monitor = 'cemnl';
bg_grey = 128;
stim_grey = bg_grey;
linearize = 0;

%not yet isoluminant...
rgb_dkl = get_n_dkl_colors(n_colors,0,1,monitor,bg_grey,stim_grey,linearize,0,1);

%do gamma-based illuminance correction
rgb_dkl_iso = correct_illuminance(rgb_dkl,monitor,0,1);
plot_n_dkl_colors(rgb_dkl_iso,0,bg_grey)


