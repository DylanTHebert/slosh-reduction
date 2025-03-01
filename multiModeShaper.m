function [shaped_pos, shaped_vel, shaped_time, shaped_impulses] = multiModeShaper(pos, vel, shaped_impulses1, shaped_impulses2)
    %{
        Creates a multi-mode shaper from 2 shapers as an input
        INPUTS:
            pos: 2x3 array of positions
            vel: speed (double)
            shaped_impulses1: 2xn array of impulses and times from the 1st
                              shaper
            shaped_impulses2: 2xm array of impulses and times from the 2nd
                              shaper
    %}
    if nargin ~= 4
        error('INCORRECT NUMBER OF ARGUMENTS')
    end
    shape1 = size(pos);
    shape2 = size(shaped_impulses1);
    shape3 = size(shaped_impulses2);
    shape4 = size(vel);
    if length(shape1) ~= 2 || length(shape2) ~= 2 || length(shape3) ~= 2 ||...
            length(shape4) ~= 2
        error('ONE OR MULITPLE INPUTS ARE THE WRONG SHAPE')
    elseif shape2(1) ~= 2 || shape3(1) ~= 2 ||...
            shape1(2) ~= 3 || shape1(1) ~= 2 ||...
            shape4(1) ~= 1 || shape4(2) ~= 1
        error('ONE OR MULTIPLE INPUTS ARE THE WRONG SHAPE')
    elseif ~isnumeric(pos) || ~isnumeric(shaped_impulses1) ||...
            ~isnumeric(shaped_impulses2) || ~isnumeric(vel)
        error('INPUTS MUST BE NUMERIC')
    end
    
    [convolved_vel, convolved_time] = convolveShapers(shaped_impulses1(1,:), ...
        shaped_impulses1(2,:), shaped_impulses2(1,:), shaped_impulses2(2,:));
    shaped_impulses = [convolved_vel; convolved_time];
    distance = norm(pos(2,:)-pos(1,:));
    direction = (pos(2,:)-pos(2,:))./distance;
    time = distance/vel;
    shaped_time = [convolved_time, time+convolved_time];
    [shaped_time, inds] = sort(shaped_time);
    shaped_vel = zeros(1, length(convolved_vel*2));
    shaped_pos = zeros(1, length(shaped_vel));
    shaped_pos(1,:) = pos(1,:);
    for i = 2:length(shaped_vel)
        if inds(i) <= length(convolved_vel)
            s = 1;
            j = inds(i);
        else
            s = -1;
            j = inds(i) - length(convolved_vel);
        end
        shaped_vel(i) = shaped_vel(i-1) + s*convolved_vel(j)*vel;
        shaped_pos(i) = shaped_pos(i-1) + shaped_time(i)*shaped_vel(i)*direction;
    end
end

