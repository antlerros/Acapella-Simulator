function [newY] = pitchModify(audiodata, idx)
if idx == 0
    newY = audiodata; 
    return;
elseif idx == 1
    up = 4; bot = 5;
elseif idx == 2
    up = 2; bot = 3;
elseif idx == -1
    up = 5; bot = 4;
elseif idx == -2
    up = 3; bot = 2;
end
audiodata = pvoc(audiodata, up/bot);
newY = resample(audiodata, up, bot);
% newLength = length(newY);
