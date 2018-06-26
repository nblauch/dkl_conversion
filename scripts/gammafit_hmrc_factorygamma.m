
%NOTE: what they call an inverse gamma table is what i usually refer to as
%a gamma table. their terminology is probably better, since the gamma table
%inverts the gamma function fit to experimental data in order to linearize
%the output's luminance w.r.t input intensity.

dkl_conversion_dir = fileparts(which('dkl_example'));

load([dkl_conversion_dir,'/cal_tables/hmrc-factory-8bitInvGammaLUT.mat'])
%save it in our terminology for future use
gammaTable = InvGammaTable;
save([dkl_conversion_dir,'/cal_tables/gammaTable-hmrc-factory-rgb.mat'],'gammaTable')
%copy phosphors for use with 'hmrc-factory' monitor
copyfile([dkl_conversion_dir,'/cal_tables/phosphors-hmrc.mat'],[dkl_conversion_dir,'/cal_tables/phosphors-hmrc-factory.mat'])

invtable255 = uint8(255*InvGammaTable);

%invert gamma table to get predicted normalized readings
pred_norm_readings = zeros(256,3);
for ii = 1:256
[~, pred_norm_readings(ii,:)] = min(abs((ii-1) - invtable255));
end
pred_norm_readings = (pred_norm_readings-1)./255;

%fit a gamma model to these predicted normalized readings
fo = fitoptions('(x^g)','Lower',1,'Upper',3);
g = fittype('(x^g)','options',fo);
displayGamma = zeros(1,3);
for channel = 1:3
    fittedmodel = fit((linspace(0,1,256))',pred_norm_readings(:,channel),g);
    displayGamma(channel) = fittedmodel.g;
end

%now fit an a*x^g model to unnormalized readings with g set to above
load([dkl_conversion_dir,'/data/readings_4-4-bold-no-gc.mat'])
readings = readings - min(readings,[],2);
displayConstant = zeros(1,3);
for channel = 1:3
    fo = fitoptions('a*(x^g)','Lower',[1,displayGamma(channel)],'Upper',[400,displayGamma(channel)]);
    g = fittype('a*(x^g)','options',fo);
    fittedmodel = fit((linspace(0,1,length(readings)))',readings(channel,:)',g);
    displayConstant(channel) = fittedmodel.a;
end
save([dkl_conversion_dir,'/cal_tables/gammaFit-hmrc-factory'])

oldfit = load([dkl_conversion_dir,'/cal_tables/gammaFit-hmrc']);

figure
subplot(2,1,1)
hold on
title('Fit from factory gamma table and measurements')
plot(linspace(0,1,256),(displayConstant.*(repmat(linspace(0,1,256),[3,1])'.^displayGamma)))
plot(linspace(0,1,length(readings)),readings,'--')
ylim([0,25])
subplot(2,1,2)
hold on
title('Fit from measurements only')
plot(linspace(0,1,256),(oldfit.displayConstant.*(repmat(linspace(0,1,256),[3,1])'.^oldfit.displayGamma)))
plot(linspace(0,1,length(readings)),readings,'--')
ylim([0,25])

%{
the factory fit appears to fit the data worse but may still be more
trustworthy for future application. just as the spline model overfits the
noise in our measurements, the gammafit may overfit the noise too. this
would explain why the measured gammas are so different between phosphors,
when really, they should be quite similar as in the factory table.
%}



