clc, clear all, close all
%% test Polak-Ribiere algorithm

%% Start algorithm

tol = 1e-5;

syms x y
v(x,y) = 100*(y-x^2)^2 + (1-x)^2;


figure
ezcontour(v, [-1 2 -2 2]);
hold on
plot(1,1,'ro', 'linewidth', 3);

maxIter = 1000;
tol = 1e-6;

clear x y
x = [-3/4;1];
d(1:2,1) = [-1;1];
k = 1;

err = Inf;

tol=1e-6;
step=0.1;    % Initial step
x0=[-3/4;1];  % Initial point. Example: [-5e-6 1e-6]
p=[x0(1,1), x0(2,1); x0(1,1)-step, x0(2,1); x0(1,1)-step/2 x0(2,1)+sqrt(3)/2*step];    % Vector that contains the three triangle's vertices

% Initial points of the triangle

P = [x0(1,1), x0(2,1);
     x0(1,1)-step, x0(2,1);
     x0(1,1)-step/2, x0(2,1)+step*sqrt(3)/2];
% plot([P(:,1)', P(1,1)], [P(:,2)', P(1,2)], 'g');
while step > tol
    
    F = [f(P(1,1), P(1,2));
         f(P(2,1), P(2,2));
         f(P(3,1), P(3,2))];
     
    
    %% Get worst point
    [~, w] = sort(F);
    F_worst = F(w(end));
    
    Pord = P(w,:); % Sorts the vector 
    
    Pnew = [Pord(3,1) + 2*((Pord(1,1) + Pord(2,1))/2 - Pord(3,1)), Pord(3,2) + 2*((Pord(1,2) + Pord(2,2))/2 - Pord(3,2))];
    
    % Now evaluate if the point if good
    if f(Pnew(1,1), Pnew(1,2)) <= F_worst
        P(w(end), :) = Pnew(1,:);
        plot([P(:,1)', P(1,1)], [P(:,2)', P(1,2)], 'g');
        pause(0.05);
    else
        % Check second worst point
        F_worst2 = F(w(end-1));
        Pnew=[Pord(2,1)+2*((Pord(1,1)+Pord(3,1))/2-Pord(2,1)), Pord(2,2)+2*((Pord(1,2)+Pord(3,2))/2-Pord(2,2))];
        if f(Pnew(1,1), Pnew(1,2)) <= F_worst2
            P(w(end-1),:) = Pnew(1,:);
            plot([P(:,1)', P(1,1)], [P(:,2)', P(1,2)], 'g');

            pause(0.05);
        else
            P=[Pord(1,1) Pord(1,2); (Pord(2,1)-Pord(1,1))/2+Pord(1,1) (Pord(2,2)-Pord(1,2))/2+Pord(1,2); (Pord(3,1)-Pord(1,1))/2+Pord(1,1) (Pord(3,2)-Pord(1,2))/2+Pord(1,2)];
            step=step/2;
            plot([P(:,1)', P(1,1)], [P(:,2)', P(1,2)], 'r--');
            pause(0.05)
        end
    end
%     V=[f(p(1,1),p(1,2)); f(p(2,1),p(2,2)); f(p(3,1),p(3,2))];   % Objective function's values in the simplex's points
%     [V_ord, ind]=sort(V);   % Calculates the worst point: p(ind(3)) it is the point to reverse
%     V_pegg=V(ind(3));   %Calculating the function in the point of maximum value
%     p_ord=p(ind,:);     %Sorts the vector
%     p_new=[p_ord(3,1)+2*((p_ord(1,1)+p_ord(2,1))/2-p_ord(3,1)) p_ord(3,2)+2*((p_ord(1,2)+p_ord(2,2))/2-p_ord(3,2))];    % It reverse the worst point
%     if f(p_new(1,1),p_new(1,2))<=V_pegg
%         p(ind(3),:)=p_new(1,:);     %Checks if the function's value in the new point is smaller than the previous. In the positive case, it saves the new point
% 
%     else
% 
%         V_pegg2=V(ind(2));      % If the reversed point returned a worst result, it reverse the second worst point
%         p_new=[p_ord(2,1)+2*((p_ord(1,1)+p_ord(3,1))/2-p_ord(2,1)) p_ord(2,2)+2*((p_ord(1,2)+p_ord(3,2))/2-p_ord(2,2))];
%         if f(p_new(1,1),p_new(1,2))<=V_pegg2
%             p(ind(2),:)=p_new(1,:);
% 
%         else 
% 
%             % If the first reversed point and the second reversed point
%             % returned a worst value, it contracts the simplex
%             p=[p_ord(1,1) p_ord(1,2); (p_ord(2,1)-p_ord(1,1))/2+p_ord(1,1) (p_ord(2,2)-p_ord(1,2))/2+p_ord(1,2); (p_ord(3,1)-p_ord(1,1))/2+p_ord(1,1) (p_ord(3,2)-p_ord(1,2))/2+p_ord(1,2)];    %Se anche il secondo punto peggiore ha restituito un valore pi? alto, ritorno al simplesso precedente e dimezzo il passo (lato del simplesso)
%             step=step/2;  % Contracts the simplex dimension
% 
%         end
%     end
    
    % It calculates the output variables
%     valFunc=f(P(1,1),p(1,2));
    var_min=[P(1,1);P(1,2)];
    
    x(:,k+1) = var_min;
    
    k=k+1;    % Increases the iterations number
end

%% PLOT %%
figure
ezcontour(v, [-5 5 -5 5]), axis equal
hold on

% Because some methods gives too many points, we will plot just some points
% and not all of them
span = 2:k;
if k > 100 % To many points!
    span = 2:20:k-1;
end
for i = span
    plot([x(1,i-1), x(1,i)], [x(2,i-1), x(2, i)], 'ko-')
end
% Plot last point
plot([x(1,end-1), x(1,end)], [x(2,end-1), x(2,end)], 'ko-')

% Plot the optimal point
plot(1, 1, 'ro-', 'linewidth', 4);
%% 

%% PLOT COST

figure
plot(1:k, log((x(1,:) - 1).^2 + (x(2,:) - 1).^2))
xlabel('K');
ylabel('Jk');
title('Cost for Simplex Method')

function ret = f(x,y)
    ret = 100*(y-x^2)^2 + (1-x)^2;
end