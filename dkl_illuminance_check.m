
% short PTB script to check illuminance/luminance values across an arbitrary set of colors (requires photometer)
% calls check_illuminance

%% set colors and other options
measure = 1; % 1 if want to type/save illuminance readings
n_steps = 60;
background_intensity = 54;

set(0,'DefaultFigureWindowStyle','docked')
for background_intensity = 5:5:100
    [isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc('cemnl',25, background_intensity, 1, n_steps, 1,1,'disc');
end

[isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc('cemnl',128, 128, 0, n_steps, 1,1,'disc');
[isolum_plane, inc_dkl_lm_chrom,inc_dkl_s_chrom, dkl_origin] = find_max_dkl_disc('cemnl',25, 25, 1, n_steps, 1,1,'disc');

rgb_dkl = get_n_dkl_colors(12,'cemnl',128,128,0,0,1);

colors = cat(1,squeeze(isolum_plane(end,n_steps+1,:))', ...
    squeeze(isolum_plane(10,n_steps+1,:))', ...
    squeeze(isolum_plane(n_steps+1,n_steps+1,:))');

rgb_dkl = get_n_dkl_colors(12,'cemnl',128,128,0,0,0);
ntsc_dkl = rgb2ntsc(rgb_dkl);
ntsc_dkl(:,1) = mean(ntsc_dkl(:,1));
rgb_dkl_iso = ntsc2rgb(ntsc_dkl);
plot_n_dkl_colors(rgb_dkl_iso);

ntsc_isolum_plane = rgb2ntsc(isolum_plane);
ntsc_isolum_plane(:,1) = mean(mean(ntsc_isolum_plane(:,:,1)));
isolum_plane_iso = ntsc2rgb(ntsc_isolum_plane);
figure; subplot(2,1,1); imagesc(isolum_plane_iso); subplot(2,1,2); imagesc(isolum_plane_iso)

%% call check_illuminance


 Screen('Preference', 'SkipSyncTests', 1);
readings = check_illuminance(rgb_dkl,0);



 