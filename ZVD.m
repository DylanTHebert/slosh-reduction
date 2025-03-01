function [shaped_pos, shaped_vel, shaped_time, shaped_impulses] = ZVD(pos, vel, T, z)
    %{
        Takes a single point-to-point move in a position-and-velocity
        format and outputs a ZVD shaped trajectory
        INPUTS:
        pos: 2x3 array containing two 3D points
        vel: speed
        T: period of ocilation in sec
        z (optional): damping ratio of the system
        OUTPUTS:
        shaped_pos: 6x3 array containing 4 3D points
        shaped_vel: 6x1 array containing speeds
        shaped_time: 6x1 array containing the time each point is reached
                     assuming step-like velocity
        shaped_impulses: 2x3 array [A; t] format of unit-sum impulses and
                         times
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
    shaped_time = [0, .5*T, T, time, time + .5*T, time + T];
    C = 1 + 2*K + K^2;
    shaped_vel = [0, (1/C)*vel, (1/C)*vel+((2*K)/C)*vel, vel, vel-((1/C)*vel),...
        vel-((1/C)*vel)-((2*K)/C)*vel];
    shaped_pos = zeros(6, 3);
    shaped_pos(2, :) = shaped_vel(2)*shaped_time(2)*direction;
    shaped_pos(3, :) = shaped_pos(2) + shaped_vel(3)*shaped_time(3)*direction;
    shaped_pos(4, :) = shaped_pos(3) + shaped_vel(4)*shaped_time(4)*direction;
    shaped_pos(5, :) = shaped_pos(4) + shaped_vel(5)*shaped_time(5)*direction;
    shaped_pos(6, :) = shaped_pos(5) + shaped_vel(6)*shaped_time(6)*direction;
    shaped_impulses = [(1/C), (2*K)/C, 1/C; 0, .5*T, T];
end

