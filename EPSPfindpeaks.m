%code is designed to go through one current sweep at a time 
%all current sweeps need to be in same folder
load("AD0_1.mat");
data=AD0_1.data;
data_full=data';

%params 
dig=20000 %digitizing rate 
time=1/dig;%time index
Time_full=0:time:5-time;
plot(Time_full, data_full) 

%select time after current sweep
Time =Time_full(35000:75000)';
data= data(35000:75000)';
binWidth= length(Time)/dig
plot(Time, data) 
ylim([-75,-65])
hold on

%smooth data using gaussian filter to reduce noise peaks
data_smooth = smoothdata(data,'gaussian',500);
plot(Time, data_smooth);
ylim([-75 -65])
hold on

% Find peaks where prom is greater than 0.3 mV
findpeaks(data_smooth,Time,'MinPeakProminence',0.3, 'Annotate','extents')
ylim([-75,-65])
hold on
[pks, locs, width, proms]=findpeaks(data_smooth,Time,'MinPeakProminence',0.4,'Annotate','extents')

xlabel('Time (s)');
ylabel('Signal Amplitude');
title('Peak Rise Time Calculation');
grid on;

results=[locs,pks,proms]
numRows= size(results, 1)% Number of rows in the results
freq = numRows / binWidth % per second 

% Create replicate file, each replicate in the data set will 
% append to existing file 
fileID = fopen('output.txt', 'a');
fprintf(fileID, 'Prominences: %.2f\n', proms);
fprintf(fileID, 'Peaks: %.2f\n', pks);
fprintf(fileID, 'Locations: %s\n', num2str(locs));  
fprintf(fileID, 'Frequency: %s\n', num2str(freq));
fclose(fileID);




