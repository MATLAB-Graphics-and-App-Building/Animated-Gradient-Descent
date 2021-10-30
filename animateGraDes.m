classdef animateGraDes < matlab.graphics.chartcontainer.ChartContainer
    % Copyright 2021 The MathWorks, Inc.
    
    properties (Access=public)
        funcStr;                % Function of x, y in String
        alpha;                  % alpha(s) for gradient descent
        startPoint;             % start point for gradient descent
        maxStepCount;           % Stop after # steps even if min is smaller than threshold
        stopThreshold;          % when distance is smaller than this, stop
        drawContour;            % true for drawing 2D contour, false (default) for 3D 
        fillContour;            % use contourf instead of contour for contour plot

        xrange;                 % x range for showing funcStr
        yrange;                 % y range for showing funStr
        showAnnotation;         % show annotation or not

        stepsPerSecond;         % advance # steps each second
        outfile;                % output an animation GIF if set to a filename
    end
        
    % protected properties for internal use only
    properties (Access=protected)
        func;                   % function handler of funcStr
        xPartial;               % x partial derivative of func
        yPartial;               % y partial derivative of func
        doneGraDes;             % gradient descent finished
        readyUpdate;            % All inited, ready for update
        
        FuncPlot;               % 3D surface or 2D Contour
        PathPlots;              % Gradient Descent path plot
        Annot;                  % Annotation
    end

    methods(Access=protected)
        function setup(~)
            % noop
        end
        function update(~)
            % noop
        end
        function setupChartContainer(obj)
            newcolors = [0.99 0.00 0.00     % red
                         0.48 0.77 0.18     % green
                         0.99 0.00 0.99     % magenta
                         0.00 0.99 0.99];   % cyan
         
            colororder(newcolors);
            ax = getAxes(obj);
            pathCount = length(obj.alpha);
            obj.doneGraDes = false(1, pathCount);
            if obj.drawContour
                % 2D contour and 2D path plot
                if obj.fillContour
                    [~, obj.FuncPlot] = contourf(ax, [], [], [], 'ShowText', 'on');
                else
                    [~, obj.FuncPlot] = contour(ax, [], [], [], 'ShowText', 'on');
                end
                hold(ax, 'on');
                for i=1:pathCount
                    obj.PathPlots = [obj.PathPlots plot(ax, NaN, NaN, '-*')];
                end
                hold(ax, 'off');
            else
                % 3D surface and 3D path plot
                obj.FuncPlot = surf(ax, [], [], []);
                alpha(obj.FuncPlot, 0.5);
                hold(ax, 'on');
                for i=1:pathCount
                    obj.PathPlots = [obj.PathPlots, plot3(ax, NaN, NaN, NaN, '-*')];
                end
                hold(ax, 'off');
            end
        end

        function moveOneStep(obj)
            if ~isempty(obj.func) && obj.readyUpdate
                if isscalar(obj.PathPlots)
                    obj.doneGraDes = obj.updateApathPlot(obj.PathPlots, obj.alpha);
                else
                    numPaths = length(obj.alpha);
                    for i=1:numPaths
                        if ~obj.doneGraDes(i)
                            obj.doneGraDes(i) = obj.updateApathPlot(obj.PathPlots(i), obj.alpha(i));
                        end
                    end
                end
                % update animation gif if necessary
                obj.updateGIF();
            else
                % Not ready to update yet
            end
        end
        
        function initApathPlot(obj, plot)            
            xStart = obj.startPoint(1);
            yStart = obj.startPoint(2);
            zStart = obj.func(xStart, yStart);
            plot.XData = xStart;
            plot.YData = yStart;
            if ~obj.drawContour
                plot.ZData = zStart;
            end
        end
        
        function done = updateApathPlot(obj, plot, alpha)
            done = false;
            xStart = plot.XData(end);
            yStart = plot.YData(end);
            zStart = obj.func(xStart, yStart);
            xEnd = double(xStart - obj.getXpartial(xStart, yStart, alpha));
            yEnd = double(yStart - obj.getYpartial(xStart, yStart, alpha));
            zEnd = double(obj.func(xEnd, yEnd));
            plot.XData = [plot.XData xEnd];
            plot.YData = [plot.YData yEnd];
            if ~obj.drawContour
                plot.ZData = [plot.ZData zEnd];
            end
            
            if obj.checkStop(xStart, xEnd, yStart, yEnd, zStart, zEnd)
                done = true;
            end
        end
        
        function initGIF(obj)
            if ~isempty(obj.outfile)
                [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                imwrite(img,map,obj.outfile,'gif','DelayTime',0.5);
            end
        end
        
        function updateGIF(obj)
            pauseInSec = 1/obj.stepsPerSecond;
            if ~isempty(obj.outfile)
                [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                imwrite(img,map,obj.outfile,'gif','writemode', 'append','delaytime',pauseInSec);
            else
                pause(pauseInSec);
            end
        end
        
        function showResult(obj, i)
            pauseInSec = 1/obj.stepsPerSecond;
            if obj.showAnnotation
                if ~isempty(obj.Annot)
                    if length(obj.PathPlots) == 1
                        xEnd = obj.PathPlots.XData(end);
                        yEnd = obj.PathPlots.YData(end);
                        zEnd = double(obj.func(xEnd, yEnd));
                        strDisplay = {['\alpha : '  num2str(obj.alpha)], ...
                            ['step count: ' num2str(i)], ...
                            ['Min: (' num2str(xEnd) ', ' num2str(yEnd) ', ' num2str(zEnd) ')']};
                    else
                        strDisplay = {};
                        colors = {'red', 'green', 'magenta', 'cyan'};
                        numColors = length(colors);
                        for i=1:length(obj.PathPlots)
                            color = colors{mod(i-1, numColors)+1};
                            xEnd = obj.PathPlots(i).XData(end);
                            yEnd = obj.PathPlots(i).YData(end);
                            zEnd = double(obj.func(xEnd, yEnd));
                            strDisplay{end+1} = ['\color{' color '}\alpha: ' num2str(obj.alpha(i)) '; min: ' num2str(zEnd)]; %#ok<AGROW> 
                        end
                    end
                    obj.Annot.String = strDisplay;
                end
            
                if ~isempty(obj.outfile)
                    [img, map] = rgb2ind(frame2im( getframe(gcf)),256);
                    imwrite(img,map,obj.outfile,'gif','writemode', 'append','delaytime',pauseInSec);
                end
            end
        end
        % template method design pattern for subclass
        function preGraDes(obj)
            % no op
        end
    end
    
    methods(Access=public)
        function agd = animateGraDes()
            clf
            % set default values. User can overwrite after instantiation
            agd.drawContour = false;
            agd.stepsPerSecond = 5;
            agd.alpha = 0.1;
            agd.startPoint = [5 5];
            agd.xrange = -10:1:10;
            agd.yrange = -10:1:10;
            agd.maxStepCount = 100;
            agd.stopThreshold = 1E-10;
            agd.showAnnotation = true;
            agd.outfile = [];
            agd.doneGraDes = false;
            agd.Annot = [];
            agd.fillContour = false;
        end
  
        function animate(obj)
            obj.setupChartContainer();
            obj.initGIF();
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
            
            
            [X, Y] = meshgrid(obj.xrange, obj.yrange);
            Z = obj.computeZ(X, Y);

            obj.FuncPlot.XData = X;
            obj.FuncPlot.YData = Y;
            obj.FuncPlot.ZData = Z;

            if isscalar(obj.PathPlots)
                obj.initApathPlot(obj.PathPlots);
            else
                numPaths = length(obj.alpha);
                for i=1:numPaths
                    obj.initApathPlot(obj.PathPlots(i));
                end
            end
            
            if obj.showAnnotation
                dim = [0.05 0.81 0.38 0.13];
                strDisplay = 'Running ...';
                obj.Annot = annotation('textbox', dim, ...
                    'String', strDisplay,'BackgroundColor','white', ...
                    'FitBoxToText', 'on',...
                    'interpreter', 'tex');
            end
            obj.preGraDes();
            obj.readyUpdate = true;
            for i=0:obj.maxStepCount
                obj.moveOneStep();
                if all(obj.doneGraDes)
                    break;
                end
                if obj.showAnnotation
                    obj.Annot.String = ['Running '  num2str(i) '/' num2str(obj.maxStepCount)];
                end
            end

            obj.showResult(i);
        end
        
        % Utility functions
        function zValue = getYpartial(obj, xIn, yIn, alpha)
            syms x y
            x = xIn;
            y = yIn;
            zValue = alpha*subs(obj.yPartial);
        end
        
        function zValue = getXpartial(obj, xIn, yIn, alpha)
            syms x y
            x = xIn;
            y = yIn;
            zValue = alpha*subs(obj.xPartial);
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
