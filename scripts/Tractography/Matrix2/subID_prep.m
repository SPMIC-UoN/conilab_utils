fID=fopen('/data/Q1200/Diffusion/comp_fsl_autoPtx');
tline=fgetl(fID);
i=0;
while ischar(tline)
    i=i+1;
    line=strsplit(tline);
    subs{i}=line{1};
    tline=fgetl(fID);
end
fclose(fID);


fId=fopen('sub_IDs_M2.txt','w');
[nrows,ncols] = size(subs);
for row = 1:nrows
    fprintf(fID,'%s\n',subs{row,:});
end
fclose(fID);