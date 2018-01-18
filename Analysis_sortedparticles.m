%% Contrast value import, analysis and plotting 
% This script imports contrast values from sorted particles files, plots 
% the individual events for comparison, combines the values and plots 
% combined histogram. It also saves the resulting figures as .fig and .png 
% files in current folder, with name specified in the variable 'Full_name'
% below, and 'separate'/'combined' as appropriate.

% Make sure you are in the right directory containing Event# folders, and
% change the Full_name accordingly.

Full_name = 'DDM (38uM) in Tris, T0.002'; %Details for the figure names & plot titles

%% Data location & loading
directory=pwd; %the folder with events must be the current folder!
Filename=('*sorted particles'); 
files=dir(fullfile(directory, '**/*', Filename)); %lists all the file properties in a struct
NumFiles = length(dir)-2; %number of files i.e. events
Contrast = cell(1,NumFiles); %preallocating cell array for contrast values
DataSize = zeros(1, NumFiles); %preallocating a vector for event particle counts

for i=1:NumFiles
    cd(strcat('event', num2str(i-1))) %changing directory to event#a
    if length(dir)==4
        temp = load(files(i).name); %loading sorted particles file
    elseif length(dir)>4
        temp = [];
        for k=1:(length(dir)/2-1)
            temp1 = load(files(k).name);
            temp = [temp; temp1];
        end
    else 
        sprintf('Check the files something is probably wrong with them')
    end
    Contrast{i} = temp(:,1); %taking first column from file = contrast values
    DataSize (1,i) = size(temp,1); 
    cd .. 
end
clear('i','temp','temp1','k')

%% Choosing Histogram Parameters
Upper_limit = 0.02; %upper limit for particle contrast value 
NumBins = 50; %number of steps in histogram
StepSize = Upper_limit/NumBins;
%create a vector of the histogram bins centres 
Bins=(0+StepSize/2):StepSize:(Upper_limit-StepSize/2); 

%preallocating for histogram values and all values combined:
h = cell(1, NumFiles); 
CombinedVal = zeros(sum(DataSize),1); 

%% Analysis of individual events and combination to one matrix
for j=1:NumFiles %number of events
    Event = Contrast{1,j}; %selecting individual events
    h{j}=hist(Event,Bins); %h is array of all histogram values paired to x
    if (DataSize(j) == length(Event)) %this makes sure both we have the right event
        if j == 1 
            CombinedVal(1:DataSize(j)) = Event; %adds Event0 values to the beginning
        elseif  j>1
            %the topval and bottom calculate where the previous data ended
            %within the CombinedVal vector and how much space the new data requires
            bottom = sum(DataSize(1:(j-1)))+1;
            topval = bottom+sum(DataSize(j))-1;
            CombinedVal(bottom:topval)= Event; 
        end
    else
        sprintf('Error: Cannot combine data') 
    end
    figure(1);
    plot(Bins,h{j}) 
    hold on
end
clear('j','Event','bottom','topval')

%% I'm making separate folder for the figures so they dont interfere with
% the analysis in case of multiple split sorted particles files per event
cd ..
if exist('Figures','dir')~=7
   mkdir Figures
end
cd Figures
mkdir(Full_name); cd(Full_name)

%% Figure(1): individual events histograms + saving figures
xlabel('Particle contrast')
ylabel('Particle count')
grid on %I just like this on the graph, comment out if not needed
title(sprintf('Event comparison for %s', Full_name))
legend('show') %Data0 = Event0 etc.

%save figure in matlab-readable .fig format for later adjustments
savefig(figure(1),sprintf('%s separate.fig', Full_name)) 
%and in .png (or anything else) for all other uses
saveas(figure(1), sprintf('%s separate', Full_name), 'png')

%% Figure(2): combined data plotting and saving
figure(2);
[ht] = hist (CombinedVal, Bins); %creating all values histogram 
bar(Bins, ht) %this makes it look like an actual histogram

xlabel('Particle contrast')
ylabel('Particle count')
grid on

title(sprintf('Combined data for %s', Full_name))
savefig(figure(2),sprintf('%s combined.fig', Full_name)) 
saveas(figure(2), sprintf('%s combined', Full_name), 'png') 

cd (directory)