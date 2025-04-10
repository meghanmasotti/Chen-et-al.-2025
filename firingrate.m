%code takes voltage data stored in allData_wThresholdInfo.mat file and performs spike rate
%calculations

%allData_wThresholdInfo.mat file contains user defined
%threshold information to find a spike for a given AD file collected using
%ScanImage, the threshold information will be fed into "findpeaks" function in matlab to find
%action potentials

%allData.mat file contains raw current or voltage data as well as
%information about the type of experiment conducted, such as IV curve or
%voltage clamp, pulse number or amount of current injected, epoch, etc.

%load allData_wThresholdInfo.mat file and compile voltage/current data 

load('allData_wThresholdInfo.mat')
load('allData.mat')

%divide data based on data type/cycle
blankIDX1=find(contains(string(allData(:,4)),'blank'));
blankIDX2=find(contains(string(allData(:,4)),'CC_RC'));
blankIDX=[blankIDX1;blankIDX2];
allData=table2cell(allData);
excitIDX=find(contains(string(allData(:,4)), 'IV')); %filter for files that contain current clamp IV curve data

excitData=allData(excitIDX,:);
excitThresholdData=allData_wThresholdInfo(excitIDX,:);
baselineSpontData=allData(blankIDX,:);
baselineThresholdData=allData_wThresholdInfo(blankIDX,:);
%starting with excitability/IV curve data
%step 1: create master table where all spike calculations will be stored
%and then can be later averaged across pulses
%step 2: calculate "simple" spike excitability paramters including peak
%height, number of spikes, ISI, latency, and AP width


allSpikeCalc=cell(length(excitData),14); %step 1

%step 2
for i=1:length(excitData)
    totalNumPulses=max(cell2mat(excitData(:,3)));
    datatoAnalyze=cell2mat(excitData(i,1));
    [pks locs widths proms]=findpeaks(datatoAnalyze,'MinPeakHeight',cell2mat(allData_wThresholdInfo(i,3)),'MinPeakProminence',...
        cell2mat(allData_wThresholdInfo(i,4)));
    locs=locs./20000; %convert all locs into seconds, sampling rate it 20,000 
    numSpikes=length(pks);
    restingPotential=mean(movmean(datatoAnalyze(1:4000),100));   %resting potential is approximated as moving average prior to pulse stim
    avgpeakHeight=mean(pks);    %calculate the average spike height (mV)
    avgAPwidth=mean(widths)/20;   %calculate the average AP width in ms
    if isempty(locs)==0
        latency_ms=[locs(1)-.2].*1000;    %this calculation provides latency to first spike in ms... the latency is determined by the time of first spike minus when the stimulus was provided (at 200 ms)
    else
        latency_ms=NaN;
    end
     if length(locs)>2
         firstISI_ms=[locs(2)-locs(1)]*1000;   %this calculates first interspike interval (i.e. time difference between first and second spike)and provides calculation in units of milliseconds( at 1s)
         lastISI_ms=[locs(end)-locs(end-1)]*1000; %calculate the last interspike interval in ms
         avgISI_ms= mean(diff(locs))*1000;
     else 
         firstISI_ms=NaN;
         lastISI_ms=NaN;
         avgISI_ms=NaN;
     end
     
    allSpikeCalc(i,1)=excitData(i,5);
    allSpikeCalc{i,2}=strcat('Pulse_',num2str(excitData{i,3}));
    allSpikeCalc{i,3}=strcat('Epoch_',num2str(excitData{i,2}));
    allSpikeCalc{i,4}=numSpikes;
    allSpikeCalc{i,5}=restingPotential;
    allSpikeCalc{i,6}= avgpeakHeight;
    allSpikeCalc{i,7}= avgAPwidth;
    allSpikeCalc{i,8}= latency_ms;
    allSpikeCalc{i,9}= firstISI_ms;
    allSpikeCalc{i,10}= lastISI_ms;
    allSpikeCalc{i,11}= avgISI_ms;  
end 
