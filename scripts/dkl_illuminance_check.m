
% short PTB script to check illuminance/luminance values across an arbitrary set of colors (requires photometer)
% calls check_illuminance

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


%% call check_illuminance

Screen('Preference', 'SkipSyncTests', 1);
readings = check_illuminance(rgb_dkl_iso,1);



 