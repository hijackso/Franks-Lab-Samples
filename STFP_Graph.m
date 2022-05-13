% STFP Experiment Overview:
%      WITHOUT being cued, Control mice are allowed to choose to consume either food of the cued flavor or food of the other flavor.
%         These flavors are on opposite sides of an arena. Control mouse food consumption and body placement preferences 
%         (Zone preference) are calculated. These values are considered mice's baseline preference for the cued and uncued flavor.
%      With no prior exposure to either flavor, Test mice learn an unfamiliar mouse ate the cued flavor. Test mice then undergo the  
%         same flavor preference test. Test mice are expected to prefer the cued flavor and cued Zone more than Control mice 
%         because they were cued.
%      This graph helps visualize Control vs Test mouse performance (via grams eaten or seconds in Zone) and calculates 
%         preference statistics.

%NOTES
%   Legand: C = Control, T = Test, cf = cued flavor, of = other flavor.
%   vartestn variance graphs are suppressed. Delete the Display, off inputs if want to see them.
%   STFP_Graph is clearest if dataT and dataC are matrices with roughly 2-15 rows and 2 columns. Typically, matrices are 8x2.
%   "Grams" data values should be [0.1,0.9]. "Seconds" data should be [800,4500]
%   Example "Grams" dataC: [0.23 0.28; 0.58 0.83; 0.31 0.22; 0.62 0.76; 0.65 0.53; 0.70 0.90; 0.36 0.26; 0.17 0.45]
%   Example "Grams" dataT: [0.67 0.41; 0.64	0.47; 0.50 0.32; 0.60 0.32; 0.55 0.46; 0.74 0.53; 0.59 0.58; 0.66 0.34]
%   Example "Seconds" dataC: [3555 3114; 1499 3686; 3341 1100; 1478 4238; 2163 3670]
%   Example "Seconds" dataT: [1635 5085; 1927 4095; 1373 2755; 1437 3210; 2895 3518]

%INPUTS: 
%   dataC:       a vector containing the grams eaten/seconds in zone of each flavor for each CONTROL mouse. Cued flavor data in 1st column.   
%   dataT:       a vector containing the grams eaten/seconds in Zone of each flavor for each TEST mouse. Cued flavor data in 1st column.
%   meanType:    a string "geom" or "mean" indicating the mean type to use in this graph. Use "" NOT ''.
%   ylab:        will be used as the yaxis label. Must be "Seconds" or "Grams". Use "" NOT ''.
%   cf:          the cued flavor, input as "string" or 'char'
%   of:          the cued flavor, input as "string" or 'char'
%   conc:        "string"/'char' containing concentrations of each flavor. Ex: '1.5% Cumin, 0.75% Thyme'.

%OUTPUTS: Plots a graph showing the averages, with SEM error bars, for each food/zone for both mouse test groups.
%         Data points for each mouse are also shown. Data points from the same mouse are connected with a line.

%3/30/22 HJ
%      Made a more similar to other STFP functions I wrote --> consistency.
%      Condensed code.
%4/21/22 HJ
%      Added ability to graph Zone pref data
%      Suppressed vartestn output graphs
%      Will now plot a "n.s" sigline

function STFP_Graph(dataC, dataT, meanType, ylab, cf, of, conc)
%ERROR CATCHING
  %dataC and dataT must have the same number of columns (same # conditions).
    if size(dataC,2) ~= size(dataT,2)
       error('dataC and dataC do not have the same number of columns')
    end
  %meanType must be exactly "geom" or "mean"
    if meanType ~= "geom" && meanType ~= "mean"
       error('meanType must be "mean" or "geom"');
    end
  %ylab must be exactly "Grams" or "Seconds" b/c used to set x-axes labels
    if ylab ~= "Grams" && ylab ~= "Seconds"
       error('ylab must be "Grams" or "Seconds". CAPITAL G or S in "", not two apostophes');
    end
  %cf, of, and conc must all be strings
    if (~isa(cf,'char') && (~isa(cf,'string') || ~isa(of,'char') && ~isa(of,'string') || ~isa(conc,'char')) && ~isa(conc,'string'))
        error('ylab, cf, of, and conc must all be chars or strings (labels in single or double quotes)')
    end
%PREPROSSESSING
  %Add NaNs to make data sets the same size. Won't add if they match.
    dataC = [dataC;NaN((size(dataT,1)-size(dataC,1)),size(dataC,2))]; 
    dataT = [dataT;NaN((size(dataC,1)-size(dataT,1)),size(dataT,2))];
  %Concatenate
    data=[dataC,dataT];
  %No 0 values
    data=data+.0000001;
%GET STATS
  %Std for Ccf,Cof,Tcf,Tof
    stdev=std(data,"omitnan");                      
  %Means 
    if meanType == "geom"                           %Note: cannot use geom if have negative (or 0 values).
        dmean=geomean(data,"omitnan");
    elseif meanType == "mean"
        dmean=mean(data,"omitnan");   
    end
  %Check and print normality for Ccf,Cof,Tcf,Tof
    [~,pCcf]=swtest(dataC(:,1));
    [~,pCof]=swtest(dataC(:,2));
    [~,pTcf]=swtest(dataT(:,1));
    [~,pTof]=swtest(dataT(:,2));
    fprintf('Ccf normality p=%f.\nCof normality p=%f.\nTcf normality p=%f.\nTof normality p=%f.\n', pCcf,pCof,pTcf,pTof)
  %Get p-value  
    %If NORMAL and HOMOGENIOUS, run MIXED ANOVA. Use cut off of p=.04 and Levene's test to allow for slight deviations.
    %Note: not testing homogen of COVARIANCE MATRICES (b/c only 1 dep var) or SPHERICITY (b/c always satisfied w/ 2 w/in factor levels).
    if vartestn([dataC,dataT],'TestType','LeveneAbsolute','Display','off')>.04 && pCcf>.04 && pCof>.04 && pTcf>.04 && pTof>.04
      datamat=[dataC;dataT];                        %ALL subject data in two columns (1 for each flavor).
      between_factors = ones(size(datamat,1),1);    %Create a subject label array (#mice X 1). All mice are labeled "1".
      between_factors(1:size(dataC,1))=0;           %Change the label of all Control mice to 0.
      within_factor_name={'Flavor'};                
      between_factor_name={'ExpGrp'};               
      [tab]=simple_mixed_anova(datamat, between_factors, within_factor_name, between_factor_name);
      %Run 2-tailed paired t-tests if there's an interaction.
      if tab{5,'pValue'}<.05                        %ExpGrp:Flavor -> if interaction, ttest comparing of & cf w/in Test and Control.
          [~,pCtrl]=ttest(dataC(:,1),dataC(:,2));   
          [~,pTest]=ttest(dataT(:,1),dataT(:,2));
          fprintf(['Control data t-test comparison p=%f\nTest data t-test comparison p=%f\n'],pCtrl,pTest)
      else
          fprintf('There was not an interaction between ExpGrp and Flavor. p=%f\n',tab{5,'pValue'})
      end
    else
    %If NOT NORMAL and HOMOGENIOUS, run ranksum/t-tests comparing CvC & TvT flavor data and TcfVCcf data.  
        [pCtrl, pTest] = p_Calc(dataC,dataT);
    end

%PLOT IT
errorbar([1 2 3 4],dmean,stdev/sqrt(length(data)),'b.'); %Plot means (Ccf,Cof,Tcf,Tof) with SEM error bars as black points.
hold on                                             %add to current fig until say otherwise
plot([1 2],dataC,'.-');                             %Plot all CONTROL mouse data for each flavor in CONTROL flavor column.
plot([3 4],dataT,'.-');                             %Plot all TEST mouse data for each flavor in TEST flavor column.
title("Cued Flavor: "+cf+newline+conc);
ylabel(ylab);                                       %ylim will automatically update to include all siglines.

%Appropriately set-up x-axis
 xlim([0 size(data,2)+1]);                          %xlim is 1 more than the number of labels.
 if ylab=="Grams"                                   %(below) Place labels under correct tick.
     set(gca,'XTick',[1 2 3 4],'XTickLabel',{"Control "+cf,"Control "+of,"Test "+cf,"Test "+of}) %w/out XTick, labels _repeat_. 
 elseif ylab=="Seconds"
     set(gca,'XTick',[1 2 3 4],'XTickLabel',{"Control "+cf+" Zone","Control "+of+" Zone","Test "+cf+" Zone","Test "+of+" Zone"})    
 end

%Add significance lines.
if exist('pCtrl','var') && pCtrl<.05; sig_line([1,2], "p="+num2str(round(pCtrl,3))); %Place significance line over Control data? 
    else; sig_line([1,2], "n.s, p="+num2str(round(pCtrl,3))); end %else n.s line.
if exist('pTest','var') && pTest<.05; sig_line([3,4], "p="+num2str(round(pTest,3))); %Place significance line over Test data?  
    else; sig_line([3,4], "n.s, p="+num2str(round(pTest,3))); end %else n.s line.
end
