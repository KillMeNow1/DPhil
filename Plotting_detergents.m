files=dir(fullfile(pwd, '**/*', '*.mat'));
contrasts = cell(2,size(files,1));

for i=1:length(files)
    addpath(files(i).folder)
    temp = importdata(files(i).name);
    contrasts{1,i} = temp;
    contrasts{2,i} = files(i).name;
end

his = cell(2,length(files));

for j=1:3
   for k=j:3:length(files)
       his{1,k} = hist(contrasts{1,k},NumBins);
       his{2,k} = files(k).name;
       figure(j)
       plot(Bins,his{1,k})
       if k>6
           legend(his{2,j:3:length(files)})
       end
       hold on
   end
end  