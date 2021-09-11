% Getting Started examples for animateGraDes
%       Copyright 2021 The MathWorks, Inc.

% Example 1: Simplest
%--------------------
agd = animateGraDes();                          % instantiate
agd.funcStr='x^2+2*x*y+3*y^2+4*x+5*y+6';        % cost function is required
agd.animate();                                  % start

% Example 2:  Alpha overshooting
%-------------------------------
agd = animateGraDes();                          % instantiate
agd.funcStr='x^2+2*x*y+3*y^2+4*x+5*y+6';        % cost function is required
% other optional parameters
agd.alpha = 0.2;                                % big alpha
agd.drawContour = true;                         % contour plot
agd.animate(); 

% Example 3: saddle point
%------------------------
agd = animateGraDes();
agd.alpha=0.15;
agd.funcStr='x^4-2*x^2+y^2';                    % special function with saddle points
agd.startPoint=[1.5 1.5];                       % point not on the ridge
agd.drawContour=true;                           % draw contour. Set to false if want 3D instead

agd.xrange=-2:0.1:2;                            % xrange covers local min and start point
agd.yrange=-2:0.1:2;                            % yrange covers local min and start point
agd.animate();
