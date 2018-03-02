
% script to measure the phosphor SPDs of your monitor
% requires spectrophotometer
% after readings are taken, must compile into one 341x3 matrix and save as
% ['phosphors-',monitor] where monitor is a string naming the monitor

screens=Screen('Screens');
screenNumber=max(screens);

PsychDefaultSetup(2);

% Open a double-buffered fullscreen window:
w=Screen('OpenWindow',screenNumber);

for channel_i = 1:3
    RGB = zeros(1,3);
    RGB(channel_i) = 255;
    Screen('FillRect',w, RGB);
    Screen('Flip',w)
    WaitSecs(0.2);
    KbStrokeWait;
end
Screen('CloseAll')


