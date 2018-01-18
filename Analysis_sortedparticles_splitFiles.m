%% Contrast value import, analysis and plotting 
% This script imports contrast values from sorted particles files, plots 
% the individual events for comparison, combines the values and plots 
% combined histogram. It also saves the resulting figures as .fig and .png 
% files in current folder, with name specified in the variable 'Full_name'
% below, and 'separate'/'combined' as appropriate.

% Make sure you are in the right directory containing Event# folders, and
% change the Full_name accordingly.

Full_name = 'ADH 10nM Standard, lower frame bin, T001'; %Details for the figure names & plot titles

%% Data location & loading
%pwd is current directory, **/* means all subfolders included, searching
%for any files containing "sorted particles". 'Files' lists all the file properties in a struct:
files=dir(fullfile(pwd, '**/*', '*sorted particles')); 
allfolders = cell(1,size(files,1));

for b=1:size(files,1)
    allfolders{b} = files(b).folder;
end

NumEvents = length(unique(allfolders)); %number of events in the directory
Contrast = cell(1,NumEvents); %preallocating cell array for contrast values
DataSize = zeros(1, NumEvents); %preallocating a vector for event particle counts

for i=1:NumEvents
    cd(strcat('event', num2str(i-1))) %changing directory to event#a
    SortPart=dir(fullfile(pwd,'*sorted particles')); %Number of files with 'sorted particles' within event
    if length(SortPart) == 1 
        temp = load(files(i).name); %loading sorted particles file
    elseif length(SortPart) > 1
        temp=[];
        for k=1:length(SortPart)
            temp1 = load(SortPart(k).name);
            temp = [temp; temp1];
            clear('temp1')
        end
    else 
        sprintf('Check the files something is probably wrong with them')
    end
    Contrast{i} = temp(:,1); %taking first column from file = contrast values
    DataSize (1,i) = size(temp,1); 
    cd .. 
end
%clear('i','temp','temp1','k','b')

%% Choosing Histogram Parameters
Upper_limit = 0.02; %upper limit for particle contrast value 
NumBins = 100; %number of steps in histogram
StepSize = Upper_limit/NumBins;
%create a vector of the histogram bins centres 
Bins=(0+StepSize/2):StepSize:(Upper_limit-StepSize/2); 

%preallocating for histogram values and all values combined:
h = cell(1, NumEvents); 
CombinedVal = zeros(sum(DataSize),1); 

%% Analysis of individual events and combination to one matrix
for j=1:NumEvents %number of events
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
clear('j','Event','bottom','topval','b')

%% I'm making separate folder for the figures so they dont interfere with
% the analysis in case of multiple split sorted particles files per event
cd ..
dirct1 = strcat(pwd,'/Figures');
if exist(dirct1,'dir')~=7
   mkdir Figures
end
cd Figures

%% Figure(1): individual events histograms + saving figures
xlabel('Particle contrast')
ylabel('Particle count')
grid on 
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

cd (dirct1); cd ..

dirct1 = strcat(pwd,'\Contrasts');
if exist(dirct1,'dir')~=7
   mkdir Contrasts
end
cd Contrasts

hist_comb = zeros(length(Bins), NumEvents+1);
for i=1:NumEvents
    Contrast_event = table(Contrast{1,i});
    filename = strcat(Full_name,'- contrast',num2str(i-1));
    writetable(Contrast_event, filename)
    
    hist_comb(:,i) = h{1,i}; 
end
CombinedVal = CombinedVal(CombinedVal<Upper_limit);
Comb = array2table(CombinedVal);
filename = strcat(Full_name, '- contrasts combined.mat');
save(filename, 'CombinedVal');

hist_comb(:,i+1) = ht;
Hist_c = array2table(hist_comb);
filename_table = strcat(Full_name, ' - histograms combined');
writetable(Hist_c, filename_table);

cd ..



