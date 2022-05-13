%Modified from: https://www.mathworks.com/matlabcentral/fileexchange/68314-statistical-significance-line

function sig_line(xs,lbl,h,yv)
%SIGLINE plots a line of statistical significance on the current axis
%   sigline(xs) plots a significance line between the value in the 2D
%   vector xs along the x-coordinate. 
% 
%   sigline(xs,lbl) places a text lbl beside the significance line.
% 
%   sigline(xs,lbl,h) attempts to plot the significance line above a
%   highest value in a graphics object with handle h. If h is not a
%   graphics handle, the line will be plotted above the value of h. 
% 
%   sigline(xs,...,vy) give a way to specify that the line be plotted above
%   vy which should not be assumed to be a graphics object. This is
%   optional and overrides h; but probaly won't ever be needed. The vy is a
%   value on the y-axis above which the sig line is plotted. It is only
%   useful for a possibly, rare occurance of a given y in h unwantedly
%   matching a graphic object in value.
% 
%   Examples #1: Plot 5 random points and add a significance line between
%   point 2 and 4.
%   plot(rand(5,1))
%   sigline([2,4])
% 
%   Examples #3: Plot 5 random points as bar chart and add a significance
%   line between point 2 and 3 and print p=0.05 beside it.
%   bar(rand(5,1))
%   sigline([2,3],'p=0.05')
% 
%   Examples #4: Plot 5 random points and add a significance line between
%   point 2 and 4 and specify the handle to be used to obtaine the value
%   above which the line will be plotted.
%   h=plot(rand(5,1))
%   sigline([2,4],[],h)
% 
%   Examples #5: Plot 5 random points and add a significance line between
%   point 2 and 4 and a value above which the line will be plotted.
%   plot(rand(5,1))
%   sigline([2,4],[],0.9)
%
%   TODO: To avoid messing up legend, we should redo this function using
%   drawing rather than plots? A work aroound for now is to plot legends b4
%   calling this function.
%
% EDITS
%   4/27/22 HJ
%       Made sigline less bold, ensured sig dot was also LineWidth 0.5 
%       Clarified lbl plot comment
%       Changed so that will not plot a * if the lbl is "n.s" or equivalent.
%           But will plot a white(invis) * in this case so that the axes update correctly.
%   5/11/22 HJ
%       Added check if first values of lbl are 'n.s' of somesort.
if nargin==1
    y=gety(gca);
    lbl=num2str([]); %must be a char or str to compare to "n.s"
elseif nargin==2
    y=gety(gca);
elseif nargin==3
    y=gety(h);
elseif nargin==4
    y=yv;
end
% Now plot the sig line on the current axis
hold on
xs=[xs(1);xs(2)];
plot(xs,[1;1]*y*1.1,'-k', 'LineWidth',0.5);%line
charlbl=char(lbl);                                       %Must be a char to index the first few values.
if charlbl(1:3) ~= "N.S" && charlbl(1:3) ~= "n.s" && charlbl(1:3) ~= "N.s"    %Don't plot the * sign if the label is n.s.
    plot(mean(xs), y*1.14, '*k')% the sig star sign      %I think this is already line width 0.5.
else
    plot(mean(xs), y*1.14, '*w')% plot a white (invis) sig star so the axes adjust right.
end
if exist('lbl','var')
    text(mean(xs)*1.1, y*1.14, lbl,'FontSize',9)% plot lbl next to the sig star sign
end
plot([1;1]*xs(1),[y*1.05,y*1.1],'-k', 'LineWidth',0.5);%left edge drop
plot([1;1]*xs(2),[y*1.05,y*1.1],'-k', 'LineWidth',0.5);%right edge drop
hold off
%--------------------------------------------------------------------------
% Helper function that Returns the largest single value of ydata in a given
% graphic handle. It returns the given value if it is not a graphics
% handle. 
function y=gety(h)
    %Returns the largest single value of ydata in a given graphic handle
    %h= figure,axes,line. Note that y=h if h is not a graphics
    if isgraphics(h) 
        switch(get(h,'type'))
            case {'line','hggroup','patch'},
                y=max(get(h,'ydata'));
                return;
            otherwise
                ys=[];
                hs=get(h,'children');
                for n=1:length(hs)
                    ys=[ys,gety(hs(n))];
                end
                y=max(ys(:));
        end
    else
        y=h;
    end
end
end
