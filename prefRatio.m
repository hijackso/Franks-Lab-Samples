% Graph of preference ratios (% Eaten or Preference Index) for Test vs Control mice for the cued food
%   This is comparing the normalized ratio of the cued flavor eaten between Test and Control mice.

% NOTE: dataC and dataT are of the same data as use in STFP_Graph.

%INPUTS
%   dataC:       [[cf],[of]] matrix containing data (g food eaten or s in Zone) for each Control mouse. Cf each mouse in 1st column. 
%   dataT:       [[cf],[of]] matrix containing data (g food eaten or s in Zone) for each Test mouse. Cf each mouse in 1st column. 
%   meanType:    a string "geom" or "mean" >> calc geometric mean or regular mean. Use "" NOT ''.
%   ratioType:   a string "index" or "%" >> calc cf preference index score OR % cf of food eaten. Use "" NOT ''. 
%   cf:          a "string" or 'char' containing the cued flavor.

%OUTPUTS: Includeds data points for each mouse and the means with SEM error bars.

%3/29/22 HJ
%      Added if statements for what to do under different condions ('index' vs '%', sig vs N.S.).
%      Added sigline grounder. Made cf appear automatically in all labels.
%4/27/22 HJ
%      Added Error Catching
%      Changed to calc % and pref index in fcn

function prefRatio(dataC,dataT,meanType,ratioType,cf)
%ERROR CATCHING
  %dataC and dataT must have the same number of columns (same # conditions).
    if size(dataC,2) ~= size(dataT,2)
       error('dataC and dataC do not have the same number of columns')
    end
  %meanType must be exactly "geom" or "mean"
    if meanType ~= "geom" && meanType ~= "mean"
       error('meanType must be "mean" or "geom"');
    end
  %ratioType must be exactly "index" or "%"
    if ratioType ~= "index" && ratioType ~= "%"
       error('ratioType must be exactly "index" or "%"');
    end
%PREPROSESSING
  %Calculate index or % values
    if ratioType == "index"
        dataC=(dataC(:,1)-dataC(:,2))./(dataC(:,1)+dataC(:,2));
        dataT=(dataT(:,1)-dataT(:,2))./(dataT(:,1)+dataT(:,2));
    elseif ratioType == "%"
        dataC=dataC(:,1)./(dataC(:,1)+dataC(:,2))*100;
        dataT=dataT(:,1)./(dataT(:,1)+dataT(:,2))*100;
    end
  %Add NaNs to the smaller dataset matrix to make both sets the same size. Won't change either if they match.
    dataC = [dataC;NaN((size(dataT,1)-size(dataC,1)),size(dataC,2))]; 
    dataT = [dataT;NaN((size(dataC,1)-size(dataT,1)),size(dataT,2))];
  %Concatenate    
    data=[dataC,dataT];
  %No 0 values
    data=data+.0000001;
%STATS  
  %Get Means 
    if meanType == "geom"                         %Note: cannot use geom if have negative (or 0 values).
        dmean=geomean(data,"omitnan");
    elseif meanType == "mean"
        dmean=mean(data,"omitnan");
    end
  %Get STD  
    stdev=std(data,"omitnan");                     %Get std for each group
  %Get p-value
    if swtest(data(:,1),.04)==0 && swtest(data(:,2),.04)==0 %If both the Control and Test data are normal (p=.04).
       [~,p]=ttest2(data(:,1),data(:,2));          %get p value from a 2-tailed unpaired t-test
       fprintf('A students t-test was used. p=%f',p) %Disp to Command Win. %f for float (keeps in .00xx form, not xxe-02 w/ %d).
    else                                           %At least one of the data sets is not normal
        p=ranksum(data(:,1),data(:,2));            %get p value from a U-test
        fprintf('A Wilcoxon rank sum test was used. p=%f',p) %print to the command window.
    end
%GRAPH DATA
    errorbar(dmean,stdev/sqrt(length(data)),'b.'); %line graph, error bars (SEM), plot as black points.
    hold on                                        %add to, don't overwrite the current figure
    scatter(1:(size(data,2)),data);                %Stand alone points in data columns (not connected like with plot()).
    title("Preference for "+cf);                   %Cued flavor in the title.
    set(gca,'XTick',1:(size(data,2)),'XTickLabel',{'Control','Test'}) %Labels under correct data column (w/out XTick, label repeats)
    xlim([0 size(data,2)+1]);                      %xmax is one bigger than the number of flavors there are
  %Set y range. Give enough space for sigline.
    if ratioType == "index"                        
        ylim([-1.3 1.3]);
    elseif ratioType == "%"
        ylim([0 130]);
    end
  %Label y axis
    if ratioType == "index"                            
        ylabel(cf+" Preference Index");
    elseif ratioType == "%"
        ylabel("% Food Eaten that was "+cf);
    end
  %Draw "no preference" line and give something for sigline to map on to.
    if ratioType == "index"
        yline(0,'--','No Preference')
        plot(1:size(data,2),[1.05,1.05],'w')        
    elseif ratioType == "%"
        yline(50,'--','No Preference')
        plot(1:size(data,2),[105,105],'w')        
    end
  %Add significance lines
    if p<.05                                        %If the flavors are significantly different
        sig_line([1,2], "p="+num2str(round(p,3)))                      
    else                                            %Else label them as not significantly different
        sig_line([1,2],"n.s, p="+num2str(round(p,3)))
    end
end