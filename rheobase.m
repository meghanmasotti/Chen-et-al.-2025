%code is designed to go through one current sweep at a time 
%all current sweeps need to be in same folder
load("AD0_1.mat")
data=AD0_1.data;

%set params (dig, time)
time=1/20000;
Time=0:time:5-time;
MinThreshold=-45
restingPotential=mean(data(100:400)))%determine region to average membrane potential 
plot(Time, data) 
combinedMatrix = [Time', data'];

%find first derivative, and time in which derivate change notes relfective
%point 
test1 = gradient(data, Time) 
test1_len = length(test1)
results = zeros(1, test1_len)
first_one = 0
for i = 1:test1_len
    results(i) = test1(i) ;
    if results(i) > 1e4
        if first_one == 0
            first_one = i ;
            first_time = Time(first_one) ; 
        end
    end
    
end

targetTime = first_time;  

% Find the index of the row where Time equals the targetTime
index = find(combinedMatrix(:, 1) == targetTime);

% Retrieve the corresponding value in the data column
if ~isempty(index)
    threshold = combinedMatrix(index, 2);  % Assign the data value to 'threshold'
else
    disp(['No data found for time ', num2str(threshold)]);
end

%calculate rheo base based on 300pA/1 second current ramp starting 1 second after
%start of trace 
Rheo=(first_time-1)*300%time in seconds, current in pA
disp(restingPotential)

% Create replicate file, each replicate in the data set will 
% append to existing file 
fileID = fopen('output.txt', 'a');
fprintf(fileID, 'Threshold: %.2f\n', threshold);
fprintf(fileID, 'Resting Potential: %.2f\n', restingPotential);
fprintf(fileID, 'Rheobase: %.2f\n', Rheo);




