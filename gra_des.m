clear all
close all
clc
x=-10:1:10;
y=-10:1:10;
alpha=0.02;
[X Y] = meshgrid(x,y);
Z = X.^2 + Y.^2;
surf(X,Y,Z,'FaceAlpha','flat','AlphaDataMapping','scaled','AlphaData',gradient(Z))
hold on;
colormap(gray);
meshgrid off
x0 = zeros(1000,2);
%x0(1,:) = randint(1,2,10);
x0(1,:) = [10 10];
x0(1,:)
plot3(x0(1,1),x0(1,2),(x0(1,1).^2 + x0(1,2).^2),'m*','MarkerSize',20);
i=2;
while(1)
    pause
    % Gradient descent equation..
    x0(i,:) = x0(i-1,:) - alpha.*2.*(x0(i-1,:));
    x0(i,:)
    plot3(x0(i,1),x0(i,2),(x0(i,1).^2 + x0(i,2).^2),'m*','MarkerSize',20)
    i=i+1;    
end