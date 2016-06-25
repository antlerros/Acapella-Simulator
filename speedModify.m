function [newY] = speedModify(audiodata, speedRatio, frame)

if nargin < 3
    frame = 1024;
end

newY = pvoc(audiodata, speedRatio, frame);
% newLength = length(Y);