function [record]=processAccelerogram(recordName,saveFlag,short)
	a = pwd;
	data=importdata(strcat(a,'\NGArecords\',recordName),' ',4);
	metadata=data.textdata;
	step= textscan(metadata{4},'%s','delimiter','    ','multipleDelimsAsOne',1);
	step=str2double(step{1}(2));

	values = data.data;
    counter=1;    
    record=zeros(1,2);
		for i=1:length(values)
			lineValues = values(i,:);
			for j=1:length(lineValues)
				if isnan(lineValues(j))
				break 
			end
				record(counter,2)=lineValues(j);
				record(counter,1)=counter*step;    
				counter=counter+1;
			end
		end
  
		if saveFlag == 2
			duration = step*length(record);
			t=0:0.01:duration;
			accs = interp1(record(:,1),record(:,2),t,'linear','extrap');
			if short == 2;
				limit = 0.05*max(abs(accs));
				first_t = find(abs(accs)>limit,1,'first');
				last_t = find(abs(accs)>limit,1,'last');
				filtered_accs = accs(first_t:last_t);
				t = 0:0.01:(length(filtered_accs)-1)*0.01;
			else filtered_accs = accs;
			end
			record = [t' filtered_accs'];
		end
	end 