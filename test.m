% Getting Started examples for animateGraDes
%       Copyright 2021 The MathWorks, Inc.

% Example 1: Simplest
%--------------------
agd = animateGraDes();                          % instantiate. Draw 3D
agd.funcStr='x^2+2*x*y+3*y^2+4*x+5*y+6';        % cost function is required
agd.animate();                                  % start

% Example 2:  Alpha overshooting
%-------------------------------
agd = animateGraDes();                          % instantiate, draw2D contour
agd.funcStr='x^2+2*x*y+3*y^2+4*x+5*y+6';        % cost function is required
% other optional parameters
agd.alpha = 0.2;                                % big alpha
agd.drawContour = true;                         % contour plot
agd.animate(); 
% 
% Example 3: saddle point
%------------------------
agd = animateGraDes();                          % draw2D contour
agd.alpha=0.15;                                 % learning rate
agd.funcStr='x^4-2*x^2+y^2';                    % special function with saddle points
agd.startPoint=[1.5 1.5];                       % point not on the ridge
agd.drawContour = true;                         % contour plot
agd.xrange=-2:0.1:2;                            % xrange covers local min and start point
agd.yrange=-2:0.1:2;                            % yrange covers local min and start point
agd.animate();

% Example 4: Compare different learning rates
%--------------------------------------------
agd = animateGraDes();                          % draw2D contour
agd.alpha = [0.05 0.18 0.22];                   % compare four alpha values
agd.funcStr='x^4-2*x^2+y^2';                    % special function with saddle points
agd.startPoint=[1.5 1.5];                       % point not on the ridge
agd.drawContour = true;                         % contour plot
agd.xrange=-2:0.1:2;                            % xrange covers local min and start point
agd.yrange=-2:0.1:2;                            % yrange covers local min and start point
agd.outfile = 'threeAlphas.gif';                % generate animation gif
agd.animate();
