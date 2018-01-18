files=dir(fullfile(pwd, '**/*', '*.mat'));
contrasts = cell(2,size(files,1));

for i=1:length(files)
    addpath(files(i).folder)
    temp = importdata(files(i).name);
    contrasts{1,i} = temp;
    contrasts{2,i} = files(i).name;
end