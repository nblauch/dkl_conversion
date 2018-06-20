
function img_iso = correct_illuminance_img(img_orig,monitor,post_gc,plot_figs,invert,illuminance_lx)
% rgb_dkl_isolum = correct_illuminance(rgb_dkl_orig,monitor,post_gc,plot_figs)
%
%   Applies gamma model-based isoluminance correction to an RGB image.
%
%   Illuminance correction is designed to preserve hue, by modifying the
%   RGB value of each phosphor according to its individual scaled gamma function
%
%   this is NOT explicit "gamma-correction". We use this method to preserve
%   the saturation of colors, as standard gamma-correction results in very
%   washed out colors.
%
%   input arg post_gc can be set to 1 if correction should be done assuming
%   automatic gamma correction (e.g. within Psychtoolbox, or in software of
%   HMRC BOLDscreen). 
%
%   author: Nicholas Blauch
%
%   notes:
%   2/20/18 nmb: wrote it
%   2/21 nmb: added illuminance_lx input arg for equating to a specific
%   value. if unset, will equate to mean predicted illum of img_orig
%   5/18: nmb: n_iters set to 1 if check_spline_model=0. this is only for
%   clarity, and does not change the results.
%   6/20: nmb: MAKE NOTE: HMRC no longer performs in-house gamma
%   correction. set post_gc=0. added some minimal notes.

load(['gammaFit-',monitor])
check_spline_model = 0; % could set to 1 if you trust the spline model over the gamma model

if check_spline_model
    n_iters = 4; 
else
    n_iters = 1; %all the correction takes place in first iteration due to the application of an analytical solution
end

if ~post_gc
    for iter = 1:n_iters
        if iter==1
            img = img_orig;
        else
            img = img_iso;
        end
        Vin = img;
        Vout = zeros(size(Vin));
        if check_spline_model
            for chan = 1:3
                for ii = 1:size(Vin,1)
                    for jj = 1:size(Vin,2)
                        Vout(ii,jj,chan) = displaySplineModel(Vin(ii,jj,chan)+1,chan);
                    end
                end
            end
        else
            Vin = double(Vin)./255;
            for chan = 1:3
                Vout(:,:,chan) = (Vin(:,:,chan).^(displayGamma(chan)))*(displayConstant(chan));
            end
        end
        Vout_sum = sum(Vout,3);
        
        if (iter == 1) && plot_figs
            figure; imagesc(Vout_sum); colorbar; 
            if invert; set(gca,'YDir','normal'); end
            title('Pre-correction')
        end
        
        if exist('illuminance_lx')
            h = illuminance_lx./Vout_sum; %per pixel scaling factor
        else
            h = mean(Vout_sum(:))./Vout_sum; %per pixel scaling factor
        end
        %scaling factor must be taken to the 1/gamma for proper correction
        %since we computed a per-phosphor gamma model, we correct with it
        h_gamma = zeros(size(Vin));
        for chan = 1:3
            h_gamma(:,:,chan) = h.^(1/displayGamma(chan));
        end
        
        img_iso = double(img).*(h_gamma);
        
        if check_spline_model
            Vin = img_iso;
            Vout = zeros(size(Vin));
            for chan = 1:3
                for ii = 1:size(Vin,1)
                    for jj = 1:size(Vin,2)
                        Vout(ii,jj,chan) = displaySplineModel(uint8(Vin(ii,jj,chan)+1),chan);
                    end
                end
            end
        else
            Vin = double(img_iso)./255;
            Vout = zeros(size(Vin));
            for chan = 1:3
                Vout(:,:,chan) = (Vin(:,:,chan).^displayGamma(chan))*displayConstant(chan);
            end
        end
        
        Vout_sum = sum(Vout,3);
        
        if (iter == n_iters) && plot_figs
            figure; imagesc(Vout_sum); colorbar; 
            if invert; set(gca,'YDir','normal'); end
            title('Post-correction')
        end
        img_iso = uint8(img_iso);
    end
    
else %if do post_gc (e.g. on BOLDscreen)
    for iter = 1:n_iters
        
        if iter==1
            img = img_orig;
        else
            img = img_iso;
        end
        Vin = img;
        Vout = zeros(size(Vin));
        Vin = double(Vin)./255;
        for chan = 1:3
            Vout(:,:,chan) = Vin(:,:,chan).*(displayConstant(chan));
        end
        
        Vout_sum = sum(Vout,3);
        if (iter == 1) && plot_figs
            figure; imagesc(Vout_sum); colorbar; 
            if invert; set(gca,'YDir','normal'); end
            title('Pre-correction')
        end
        
        if exist('illuminance_lx')
            h = illuminance_lx./Vout_sum;
        else
            h = mean(Vout_sum(:))./Vout_sum;
        end
        
        h_gamma = zeros(size(Vin));
        for chan = 1:3
            h_gamma(:,:,chan) = h;
        end
        img_iso = double(img).*(h_gamma);
        
        if check_spline_model
            Vin = img_iso;
            Vout = zeros(size(Vin));
            for chan = 1:3
                for ii = 1:size(Vin,1)
                    for jj = 1:size(Vin,2)
                        Vout(ii,jj,chan) = displaySplineModel(uint8(Vin(ii,jj,chan)+1),chan);
                    end
                end
            end
        else
            Vin = double(img_iso)./255;
            Vout = zeros(size(Vin));
            for chan = 1:3
                Vout(:,:,chan) = Vin(:,:,chan)*displayConstant(chan);
            end
        end
        
        Vout_sum = sum(Vout,3);
        
        if (iter == n_iters) && plot_figs
            figure; imagesc(Vout_sum); colorbar; 
            if invert; set(gca,'YDir','normal'); end
            title('Post-correction')
        end
        img_iso = uint8(img_iso);
    end
    
end

if plot_figs
    figure; imagesc(img_orig); 
    if invert; set(gca,'YDir','normal'); end
    title('Pre-correction')
    
    figure; imagesc(img_iso); 
    if invert; set(gca,'YDir','normal'); end
    title('Post-correction')
    
end
