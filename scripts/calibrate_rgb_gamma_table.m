
%% measure intensity values for some number of measurements for each phosphor individually

<<<<<<< HEAD:scripts/calibrate_rgb_gamma_table.m
monitor = 'cemnl';
=======
monitor = 'hmrc';

>>>>>>> parent of e7b48df... Revert "Merge branch 'master' of https://github.com/nblauch/dkl_conversion":calibrate_rgb_gamma_table.m

screens=Screen('Screens');
screenNumber=max(screens);

PsychDefaultSetup(2);

% Open a double-buffered fullscreen window:
w=Screen('OpenWindow',screenNumber);

numMeasures = 18;
intensity_vals = 0:1/(numMeasures-1):1;
readings = zeros(3,numMeasures);

for channel_i = 1:3
    for intensity_j = 1:numMeasures
        RGB = zeros(1,3);
        RGB(channel_i) = intensity_vals(intensity_j);
        Screen('FillRect',w, 255*RGB);
        Screen('Flip',w)
        readings(channel_i,intensity_j) = GetNumber;
    end
end
Screen('CloseAll')

%% fit the gamma and spline models - importantly, fit the constant term for use in illuminance-normalization

displayGamma = zeros(1,3);
displayConstant = zeros(1,3);
gammaTable = zeros(256,3);
displaySplineModel = zeros(256,3);

for channel = 1:3
    
    %Substract baseline (background) illuminance. Do not normalize.
    displayBaseline = min(readings(channel,:));
    chan_vals = (readings(channel,:) - displayBaseline);
    
    %Gamma function fitting
    fo = fitoptions('a*(x^g)','Lower',[0,1],'Upper',[400,3]);
    g = fittype('a*(x^g)','options',fo);
    fittedmodel = fit(intensity_vals',chan_vals',g);
    displayGamma(channel) = fittedmodel.g;
    displayConstant(channel) = fittedmodel.a;
    gammaTable(:,channel) = ((([0:255]'/255))).^(1/fittedmodel.g); %#ok<NBRAK>
    
    firstFit = fittedmodel([0:255]/255); %#ok<NBRAK>
    
    %Spline interp fitting
    fittedmodel = fit(intensity_vals',chan_vals','splineinterp');
    displaySplineModel(:,channel) = fittedmodel([0:255]/255); %#ok<NBRAK>
    
    figure;
    plot(255*intensity_vals', chan_vals', '.', [0:255], firstFit, '--', [0:255], displaySplineModel(:,channel), '-.'); %#ok<NBRAK>
    legend('Measures', 'Gamma model', 'Spline interpolation');
    title(sprintf('Gamma model x^{%.2f} vs. Spline interpolation', displayGamma(channel)));
    
end

%% save the models if you wish
save(['gammaTable-',monitor,'-rgb'],'gammaTable')
save(['gammaFit-',monitor],'displayGamma','displayConstant','readings','intensity_vals')

