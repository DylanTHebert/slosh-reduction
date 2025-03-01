function [convolved_vel, convolved_time] = convolveShapers(vel1, time1, vel2, time2)
    %{
        Convolves two shapers in an impulse-time format. Outputs a single
        shaper in an impulse-time format
        INPUTS:
            vel1: 1xn array of velocity impulses for 1st shaper
            time1: 1xn array of times for 1st shaper
            vel2: 1xm array of velocity impulses for 2nd shaper
            time2: 1xm array of times for 2nd shaper
        OUTPUTS:
            convolved_vel: 1x(n*m) array of impulses
            convovled_time: 1x(n*m) array of times
    %}
    if nargin ~= 4
        error('INCORRECT NUMBER OF ARGUMENTS')
    end
    shape1 = size(vel1);
    shape2 = size(time1);
    shape3 = size(vel2);
    shape4 = size(time2);
    if length(shape1) ~= 2 || length(shape2) ~= 2 || length(shape3) ~= 2 ||...
            length(shape4) ~= 2
        error('ONE OR MULITPLE INPUTS ARE THE WRONG SHAPE')
    elseif shape1(1) ~= 1 || shape2(1) ~= 1 || shape3(1) ~= 1 || shape4(1) ~= 1 ||...
            shape1(2) < 2 || shape2(2) < 2 || shape3(2) < 2 || shape4(2) < 2
        error('ONE OR MULTIPLE INPUTS ARE THE WRONG SHAPE')
    elseif ~isnumeric(vel1) || ~isnumeric(time1) || ~isnumeric(vel2) || ~isnumeric(time2)
        error('INPUTS MUST BE NUMERIC')
    elseif length(vel1) ~= length(time1) || length(vel2) ~= length(time2)
        error('IMPULSE AND TIME VECTORS ARE NOT THE SAME LENGTH')
    end
    convolved_vel = zeros(1, length(vel1)*length(vel2));
    convolved_time = zeros(size(convolved_vel));
    count = 1;
    for i = 1:length(vel1)
        for j= 1:length(vel2)
            convolved_vel(count) = vel1(i)*vel2(j);
            convolved_time(count) = time1(i) + time2(j);
            count = count + 1;
        end
    end
    [~, inds] = sort(convolved_time);
    convolved_time = convolved_time(inds);
    convolved_vel = convolved_vel(inds);
end