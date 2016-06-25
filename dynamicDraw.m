function dynamicDraw(obj, event, recObj, h, cursor, duration, fs, isTimeLimit)
    
    y = getaudiodata(recObj, 'double');
    a = zeros(fs*duration, 1);
    if isTimeLimit == 1
        l = length(y);
        a(1:l) = a(1:l) + y;
        set(h, 'ydata', a);
        set(cursor, 'XData', (l/fs)*[1 1], 'YData', [1 -1]);
    else
        l = round(fs*duration/2);
        if length(y) >= l
            a(1:l) = a(1:l) + y(length(y)-l+1:length(y));
        else
            a(1:length(y)) = a(1:length(y)) + y;
        end
        set(h, 'ydata', a);
        set(cursor, 'XData', (l/fs)*[1 1], 'YData', [1 -1]);
    end
    drawnow
