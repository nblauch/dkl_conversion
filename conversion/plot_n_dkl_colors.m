    
function plot_n_dkl_colors(rgb_dkl,phase,grey_bg)
%  plot_n_dkl_colors(rgb_dkl,phase,grey_bg)
%
% simple function to plot a selection of DKL colors in rgb coordinates
% a phase may be specified to shift the locations of colors
% grey_bg may also be specified to show colors against a disc of the
% background grey.

if max(rgb_dkl(:))>1 && strcmp(class(rgb_dkl),'uint8')
   rgb_dkl = double(rgb_dkl)./255; 
end

n_colors = size(rgb_dkl,1);
color_angles = linspace(0,360-(360/n_colors),n_colors);
color_angles = color_angles + phase;

figure
hold on
if exist('grey_bg')
    scatter(0,0,100000,repmat(grey_bg./255,[1,3]),'filled');
end
for i = 1:n_colors
    scatter(cosd(color_angles(i)),sind(color_angles(i)),(200*24/n_colors),rgb_dkl(i,:),'filled')
end
axis equal
ylim([-1.2 1.2])
xlabel('l-m')
ylabel('s - (l+m)')
title([num2str(n_colors),' hues along perimeter of isoluminant DKL disc'])
hold off

end
