% ***See STFP_Graph for an overview of the experiment paradigm 
% Caluculates p values comparing Control cf vs of, Test cf vs of, and Control cf vs Test cf.
% cf = cued flavor, of = other flavor

%INPUTS
%   dataC:    [[cued flavor],[other flavor]] matrix containing test data (ex g food eaten) for each Control mouse.
%   dataT:    [[cf],[of]] matrix containing test data (ex g food eaten) for each Test mouse.
%OUTPUTS
%   pCtrl:    p value for a test comparing cf Control data to of Control data.
%   pTest:    p value for a test comparing cf Test data to of Test data.
%   pcfComp:  p value for a test comparing cf Control data to cf Test data.
%   Will also print the swtest (normality) p values and skewness scores for Ccf, Cof, Tcf, and Tof to the Command Window.

function [pCtrl, pTest, pcfComp] = p_Calc(dataC,dataT)
    %Add NaNs to make data sets the same size. Won't add if they match.
    dataC = [dataC;NaN((size(dataT,1)-size(dataC,1)),size(dataC,2))]; 
    dataT = [dataT;NaN((size(dataC,1)-size(dataT,1)),size(dataT,2))];
    
    %Check normality and skewness of (Ccf,Cof,Tcf,Tof)
    [~,pCcf]=swtest(dataC(:,1));
    skewCcf=skewness(dataC(:,1));

    [~,pCof]=swtest(dataC(:,2));
    skewCof=skewness(dataC(:,2));
    
    [~,pTcf]=swtest(dataT(:,1));
    skewTcf=skewness(dataT(:,1));
    
    [~,pTof]=swtest(dataT(:,2));
    skewTof=skewness(dataT(:,2));
    
    %Homogeneity of variance for unpaired t-test using Levene's Test (not default Bartlett).
    p_cfvar=vartestn([dataC(:,1),dataT(:,1)],'TestType','LeveneAbsolute','Display','off'); %Suppress output of vartestn graphs
    
    %Print skew p and homogenaeity of varienaces p. STFPgraph is printing normality.
    fprintf(['Ccf skewness=%f.\nCof skewness=%f.\nTcf skewness=%f.\nTof skewness=%f. \nHomogeneity of variences p val for ' ...
        'Cued Falvor data = %f\n'],skewCcf,skewCof,skewTcf,skewTof,p_cfvar) 
    
    %Control data pval
    if pCcf>.04 && pCof>.04                                %data are normal
        [~,pCtrl]=ttest(dataC(:,1),dataC(:,2));            %2-tailed paired t-test
        fprintf('Control data t-test comparison p=%f\n',pCtrl)
    elseif -0.5<skewCcf && skewCcf<0.5 && -0.5<skewCof && skewCof<.5 %data are symmetric but not normal
        pCtrl=signrank(dataC(:,1),dataC(:,2));             %2-tailed paired U-test
        fprintf('Control data ranksum comparison p=%f\n',pCtrl)
    else                                                   %Paired, but all else failed!
        pCtrl=signtest(dataC(:,1),dataC(:,2));             %2-tailed sign test
        fprintf('Control data sign test comparison p=%f\n',pCtrl)
    end
    
    %Test data pval
    if pTcf>.04 && pTof>.04                                %data are normal
        [~,pTest]=ttest(dataT(:,1),dataT(:,2));            %2-tailed paired t-test
        fprintf('Test data t-test comparison p=%f\n',pTest)
    elseif -0.5<skewCcf && skewTcf<0.5 && -0.5<skewTof && skewTof<.5 %data are symmetrical (not skewed but not normal)
        pTest=signrank(dataT(:,1),dataT(:,2));             %2-tailed paired U-test
        fprintf('Test data ranksum comparison p=%f\n',pTest)
    else                                                   %Paired, but all else failed!
        pTest=signtest(dataT(:,1),dataT(:,2));             %2-tailed sign test
        fprintf('Test data sign test comparison p=%f\n',pTest)
    end

    
    %Test comp pval
    if pCcf>.04 && pTcf>.04 && p_cfvar>.04                 %data are normal and have homog varience 
        [~,pcfComp]=ttest2(dataC(:,1),dataT(:,1));         %2-tailed unpaired t-test
        fprintf('Cued flavor t-test comparison p=%f\n',pcfComp)
    else                                                   %data are not both normal                     
        pcfComp=ranksum(dataC(:,1),dataT(:,1));            %2-tailed unpaired U-test
        fprintf('Cued flavor ranksum comparison p=%f\n',pcfComp)
        if abs(skewCcf-skewTcf)>.75                        %Note that data have largely different skews.
            fprintf('Control cf and Test cf data have a skew difference of %f\n',abs(skewCcf-skewTcf))
        end
    end
end

