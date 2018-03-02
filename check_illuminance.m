
function readings = check_illuminance(colors,take_readings,gammaTable)
% this function can be used along with a spectrophotometer in order to
% measure the illuminance of some set of colors, plotted in a full screen
% box.
%

if max(max(max(colors))) <=1
    colors = uint8(255*(colors));
end

Screen('CloseAll')
try
    screens=Screen('Screens');
    screenNumber=max(screens);
    PsychDefaultSetup(2);
    
    % Open a double-buffered fullscreen window:
    w=Screen('OpenWindow',screenNumber);
    
    if exist('gammaTable')
        Screen('LoadNormalizedGammaTable',w,gammaTable)
    end
    
    readings = zeros(size(colors,1),1);
    
    for ii = 1:size(colors,1)
        Screen('FillRect',w, colors(ii,:));
        Screen('Flip',w);
        if take_readings
            readings(ii) = GetNumber;
            fprintf('%02d deg - lum = %04d \n',(ii-1)*15,readings(ii))
        else
            KbStrokeWait;
        end
    end
    
    if exist('gammaTable')
        Screen('LoadNormalizedGammaTable',w,repmat(linspace(0,1,256)',[1,3]))
    end
    
    Screen('CloseAll')
    
catch ME
    disp(ME.message)
    disp(ME.stack)
    
    if exist('gammaTable')
        Screen('LoadNormalizedGammaTable',w,repmat(linspace(0,1,256)',[1,3]))
    end
    
    Screen('CloseAll')
end


end
