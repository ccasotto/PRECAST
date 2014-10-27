function [maxSteps]=parseAccelerogram3D(j,NGA,saveFlag)
	a = pwd;
	lengths=zeros(1,3);
for k = 0:1:2 %k=0 is the Z component of the record, k=1 and 2 are the component in X and Y
	recordName = NGA(2+j+k,1).name;
	data=importdata(strcat(a,'/NGArecords/',recordName),' ',4);
	metadata=data.textdata;
	step= textscan(metadata{4},'%s','delimiter','    ','multipleDelimsAsOne',1);
	step=str2double(step{1}(2));

	values = data.data;
    counter=1;    
    record=zeros(1,2);
		for i=1:length(values)
			lineValues = values(i,:);
			for w=1:length(lineValues)
				if isnan(lineValues(w))
				break 
			end
				record(counter,2)=lineValues(w);
				record(counter,1)=counter*step;    
				counter=counter+1;
			end
		end

		if saveFlag == 2
			duration = step*length(record);
			t=0:0.01:duration;
			accs = interp1(record(:,1),record(:,2),t,'linear','extrap');
			limit = 0.05*max(abs(accs));
			first_t = find(abs(accs)>limit,1,'first');
			last_t = find(abs(accs)>limit,1,'last');
			filtered_accs = accs(first_t:last_t);
			lengths(k+1)= length(filtered_accs);
			title = horzcat('gmr',num2str(k),'.tcl');
			dlmwrite(title,filtered_accs','delimiter','	');
			t=0.01:0.01:lengths(k+1)*0.01;
		end
	end 
	maxSteps = max(lengths);
end