classdef animateGraDes < handle
    % Copyright 2021 The MathWorks, Inc.
    
    properties (Access=public)
        funcStr;                % Function of x, y in String
        alpha;                  % alpha for gradient descent
        startPoint;             % start point for gradient descent
        maxStepCount;           % Stop after # steps even if min is smaller than threshold
        stopThreshold;          % when distance is smaller than this, stop
 
        xrange;                 % x range for showing funcStr
        yrange;                 % y range for showing funStr
        showAnnotation;         % show annotation or not

        drawContour;            % drawContour instead of 3D surface

        stepsPerSecond;         % advance # steps each second
        outfile;                % output an animation GIF if set to a filename
    end
    
    % private properties for internal use only
    properties (Access=private)
        func;                   % function handler of funcStr
        xPartial;               % x partial derivative of func
        yPartial;               % y partial derivative of func
    end

    methods(Access=public)
        function agd = animateGraDes()
            % set default values. User can overwrite after instantiation
            agd.stepsPerSecond = 5;
            agd.alpha = 0.1;
            agd.startPoint = [5 5];
            agd.xrange = -10:1:10;
            agd.yrange = -10:1:10;
            agd.maxStepCount = 100;
            agd.stopThreshold = 1E-10;
            agd.showAnnotation = true;
            agd.outfile = [];
        end

        function animate(obj)
            clf
            try
                obj.func = str2func(['@(x, y)' obj.funcStr]);
                symFunc = sym(obj.func);
                syms x y
                obj.xPartial = diff(symFunc, x);
                obj.yPartial = diff(symFunc, y);
            catch ME
                disp(ME);
                return;
            end
            pauseInSec = 1/obj.stepsPerSecond;
            [X, Y] = meshgrid(obj.xrange, obj.yrange);
            Z = obj.computeZ(X, Y);
            if obj.drawContour
                contour(X, Y, Z, 20);
            else
                surf(X,Y,Z);
                alpha 0.5
            end
            hold on
            xStart = obj.startPoint(1);
            yStart = obj.startPoint(2);

            if ~isempty(obj.outfile)
                [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                imwrite(img,map,obj.outfile,'gif','DelayTime',0.5);
            end
            ann = [];
            if obj.showAnnotation
                dim = [0.05 0.81 0.38 0.13];
                strDisplay = 'Running ...';
                ann = annotation('textbox', dim, 'String', strDisplay,'BackgroundColor','white', 'FitBoxToText','on');
            end
            for i=0:obj.maxStepCount
                zStart = obj.func(xStart, yStart);
                xEnd = double(xStart - obj.getXpartial(xStart, yStart));
                yEnd = double(yStart - obj.getYpartial(xStart, yStart));
                zEnd = double(obj.func(xEnd, yEnd));
                if obj.drawContour
                    plot([xStart xEnd], [yStart, yEnd], 'r-*');
                else
                    plot3([xStart xEnd], [yStart yEnd], [zStart zEnd],'r-*');
                end
                if obj.checkStop(xStart, xEnd, yStart, yEnd, zStart, zEnd)
                    break;
                end

                xStart = xEnd;
                yStart = yEnd;
                if ~isempty(obj.outfile)
                    [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                    imwrite(img,map,obj.outfile,'gif','writemode', 'append','delaytime',pauseInSec);
                else
                    pause(pauseInSec);
                end
                ann.String = ['Running '  num2str(i) '/' num2str(obj.maxStepCount)];
            end
            if obj.showAnnotation
                if ~isempty(ann)
                strDisplay = {['\alpha: '  num2str(obj.alpha)], ...
                    ['step count: ' num2str(i)], ...
                    ['Min: (' num2str(xEnd) ', ' num2str(yEnd) ', ' num2str(zEnd) ')']};
                ann.String = strDisplay;
                end
            
                if ~isempty(obj.outfile)
                    [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                    imwrite(img,map,obj.outfile,'gif','writemode', 'append','delaytime',pauseInSec);
                end
            end
        end
        function zValue = getYpartial(obj, xIn, yIn)
            syms x y
            x = xIn;
            y = yIn;
            zValue = obj.alpha*subs(obj.yPartial);
        end
        function zValue = getXpartial(obj, xIn, yIn)
            syms x y
            x = xIn;
            y = yIn;
            zValue = obj.alpha*subs(obj.xPartial);
        end
        function Z = computeZ(obj, X, Y)
            sz = size(X);
            Z = zeros(sz(1), sz(2));

            for i=1:sz(1)
                for j=1:sz(2)
                    Z(i, j) = obj.func(X(i, j), Y(i, j));
                end
            end

        end
        function done = checkStop(obj, xStart, xEnd, yStart, yEnd, zStart, zEnd)
            done = false;
            dis = (xStart-xEnd)^2+(yStart-yEnd)^2+(zStart-zEnd)^2;
            if dis <obj.stopThreshold
                done = true;
            end
        end
    end
end
