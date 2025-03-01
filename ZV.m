function [shaped_pos, shaped_vel, shaped_time, shaped_impulses] = ZV(pos, vel, T, z)
    %{
        Takes a single point-to-point move in a position-and-velocity
        format and outputs a ZV shaped trajectory
        INPUTS:
        pos: 2x3 array containing two 3D points
        vel: speed
        T: period of ocilation in sec
        z (optional): damping ratio of the system
        OUTPUTS:
        shaped_pos: 4x3 array containing 4 3D points
        shaped_vel: 4x1 array containing speeds
        shaped_time: 4x1 array containing the time each point is reached
                     assuming step-like velocity
        shaped_impulses: 2x2 array [A; t] format of unit-sum impulses and times
    %}
    if nargin == 3
       z = 0; 
    elseif nargin == 4
        shape = size(z);
        if length(shape) > 2 || length(shape) < 2 || shape(1) ~= 1 || shape(2) ~= 1
            error('Z IS THE INCORRECT SHAPE')
        end
    elseif nargin > 4
        error('TOO MANY INPUT ARGUMENTS')
    elseif nargin < 3
        error('NOT ENOUGH INPUT ARGUMENTS')
    end
    shape = size(pos);
    if length(shape) > 2 || length(shape) < 2 || shape(1) ~= 2 || shape(2) ~= 3
        error('POS IS THE INCORRECT SHAPE')
    end
    shape = size(vel);
    if length(shape) > 2 || length(shape) < 2 || shape(1) ~= 1 || shape(2) ~= 1
        error('VEL IS THE INCORRECT SHAPE')
    end
    shape = size(T);
    if length(shape) > 2 || length(shape) < 2 || shape(1) ~= 1 || shape(2) ~= 1
        error('T IS THE INCORRECT SHAPE')
    end
    if ~isnumeric(vel) || ~isnumeric(T) || ~isnumeric(z) || ~isnumeric(pos)
        error('ALL ARGUMENTS MUST BE NUMERIC')
    end
    
    K = exp((-z*pi)/sqrt(1-z^2));
    distance = norm(pos(2,:)-pos(1,:));
    direction = (pos(2,:)-pos(1,:))./distance;
    time = distance/vel;
    shaped_time = [0, .5*T, time, time + .5*T];
    shaped_vel = [0, (1/(1+K))*vel, vel, vel-((1/(1+K))*vel)];
    shaped_pos = [zeros(1,3); shaped_vel(2)*shaped_time(2)*direction;...
        shaped_vel(2)*shaped_time(2)*direction + shaped_vel(3)*...
        (shaped_time(3)-shaped_time(2))*direction; pos(2,:)];
    shaped_impulses = [(1/(1+K)), (1/(1+k)); 0, .5*T];
    
end