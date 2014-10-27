
file = fopen('filelist.tcl','w+');

for i = 1: 4
	a = filelist{1,i};
	fprintf(file,'%6d%2c',a);
	fprintf(file,'.smc.rm.bp.a.pad \n');
end

fclose(file);