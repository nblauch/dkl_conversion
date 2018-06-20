
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
monitor = 'hmrc'; 
stim_intensity = 128;
bg_intensity = stim_intensity; %not guaranteed to converge if bg_intensity != stim_intensity
linearize = 0; %perform gamma correction later
resolution_steps = 120; %larger for higher resolution

dkl_plane = find_max_dkl_disc(monitor,stim_intensity, bg_intensity, linearize, resolution_steps,1,1,'disc');

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
load(['cal_tables/gammaTable-',monitor,'-rgb'])
LUT = linearize_image(1:255,mean(gammaTable,2));
stim_intensity_gc = find(LUT == stim_intensity); 
dkl_plane_gc= find_max_dkl_disc(monitor,stim_intensity_gc, stim_intensity_gc, 1, resolution_steps,1,1,'disc');

% and see that even gamma-corrected is not fully isoluminant (though much
% closer)
dkl_plane_gc_iso = correct_illuminance_img(dkl_plane_gc,monitor,0,1,1);

%% get an isoluminant set of colors
n_colors = 12;
stim_intensity = 128;
bg_intensity = stim_intensity; %not guaranteed to converge if bg_intensity != stim_intensity
linearize = 0;
plot_disc = 0; 
plot_colors = 1;
plot_illum_preds = 1; %we want to see the illuminance predictions
post_gc = 0; %for this example we assume there will be no gamma correction applied at the monitor (psychtoolbox or other)
phase = 0; %pick colors starting from phase deg counterclockwise from horizontal

%not yet isoluminant...
rgb_dkl = get_n_dkl_colors(n_colors,0,1,monitor,bg_intensity,stim_intensity,linearize,plot_disc,plot_colors);

%do gamma-based illuminance correction
rgb_dkl_iso = correct_illuminance(rgb_dkl,monitor,post_gc,plot_illum_preds);
plot_n_dkl_colors(rgb_dkl_iso,phase,bg_intensity)

% compare what was just produced with a gamma-corrected "isoluminant" set
linearize = 1;
%keep brightness roughly the same by applying inverse gamma correction to find a
%new input background intensity. after illuminance correction the illuminance differs
%slightly from that of above since it corrects to the minimum value.
load(['cal_tables/gammaTable-',monitor,'-rgb'])
LUT = linearize_image(1:255,mean(gammaTable,2));
stim_intensity_gc = find(LUT == stim_intensity); 
bg_intensity_gc = stim_intensity_gc;
rgb_dkl_gc = get_n_dkl_colors(n_colors,0,1,monitor,bg_intensity_gc,stim_intensity_gc,linearize,plot_disc,plot_colors);

% and see that even gamma-corrected is not fully isoluminant (though much
% closer)
rgb_dkl_gc_iso = correct_illuminance(rgb_dkl_gc,monitor,post_gc,plot_illum_preds);
plot_n_dkl_colors(rgb_dkl_gc_iso,phase,bg_intensity)

%% run check_illuminance with a light meter to check for iso-(il)luminance
% lx_readings = check_illuminance(rgb_dkl_iso,1);

