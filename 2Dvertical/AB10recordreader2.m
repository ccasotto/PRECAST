function [ahist, prepad, postpad ] = AB10recordreader2(filename,dt,saveFlag)
%UNTITLED Summary of this function goes here
%   Function to read and interpret European strong motion records
% from AB10

in1 = importdata(filename,'\n');

if isstruct(in1)
    % Error in classification
    dummy1 = in1.textdata;
    dummy2 = in1.data;
    clear in1
    in1 = cell(length(dummy1)+1,1);
    for i =1:length(dummy1)
        in1{i,1} = dummy1{i,1};
    end
    if dummy2<0
       in1{length(dummy1)+1,1} = num2str(dummy2,'%10.2E');
    else
        in1{length(dummy1)+1,1} = num2str(dummy2,'%11.2E');
    end
end

if isempty(str2num(in1{69,1})) %#ok<ST2NM>
    % File starts at 70
    id1 = (70:size(in1,1));
    n1 = length(id1);
else
    id1 = (69:size(in1,1));
    n1 = length(id1);
end

% Need to determine how many zeros are added
% cell numbers 51 & 55
dum1 = in1{51,1};
a1 = regexp(dum1,'\D','split');
% na1 = length(a1);
ii1 = 1;
eck = 0;
while eck~=1
    if isempty(a1{1,ii1})==0
        prepad = str2double(a1{1,ii1});
        eck = 1;
    else
        ii1 = ii1+1;
    end
end

% prepad = a1{1,18};
dum2 = in1{55,1};
a2 = regexp(dum2,'\D','split');
ii1 = 1;
eck = 0;
while eck~=1
    if isempty(a2{1,ii1})==0
        postpad = str2double(a2{1,ii1});
        eck = 1;
    else
        ii1 = ii1+1;
    end
end

%postpad = a2{1,18};


for i = 1:n1
    input1 = in1{id1(i),1};
    dummy1 = zeros(8,1);
   
    if i==n1
        % check to see how many elements in final row
        nck = floor(length(input1)/10);
        % if not divisable by ten then pad with spaces
        test1 = abs(round(length(input1)/10)-(length(input1)/10));
        if test1>1E-4
            while test1>1E-4
                % if not divisable by ten then pad with spaces
                input1 = horzcat(' ',input1); %#ok<AGROW>
                test1 = abs(round(length(input1)/10)-(length(input1)/10));
            end
            nck = floor(length(input1)/10);
        end    
        if nck==0
            nck = 1;
            dummy1(1) = str2double(input1);
        else
            tt = 1;
            for j = 1:nck
                dummy1(j) = str2double(input1(tt:tt+9));
                tt = tt+10;
            end
        end
        dummy1(nck+1:length(dummy1)) = [];
    else 
        tt = 1;
        for j = 1:8
            if (tt+9)>length(input1)
                dummy1(j) = str2double(input1(tt:length(input1)));
            else
                dummy1(j) = str2double(input1(tt:tt+9));
            end
            tt = tt+10;
        end
    end
    if i == 1
        temphist = dummy1;
    else
        temphist = [temphist; dummy1]; %#ok<AGROW>
    end
end

l1 = length(temphist);
t1 = cumsum(dt*ones(l1,1))-dt;
ahist = [t1 temphist];

    if saveFlag == 2
        duration = dt*length(ahist);
        t=0:0.01:duration;
        accs = interp1(t1,temphist,t,'linear','extrap');
        limit = 0.05*max(abs(accs));
        first_t = find(abs(accs)>limit,1,'first');
        last_t = find(abs(accs)>limit,1,'last');
        filtered_accs = accs(first_t:last_t);
		duration = 0.01*length(filtered_accs);
		t=0:0.01:(duration-0.01);
		ahist = [t' filtered_accs'];
        dlmwrite('gmr.tcl',filtered_accs','delimiter','	');
	else 
		dlmwrite('gmr.tcl',temphist,'delimiter','	');
	end    

end

