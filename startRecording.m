function [new_time, new_y]= startRecording(obj, event, time, y)

disp('start');
new_time = time + 0.1;
new_y = y;
new_y(1) = 0;
disp(new_y(1));
disp(new_time);
