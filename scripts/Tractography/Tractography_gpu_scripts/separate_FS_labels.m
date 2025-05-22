function separate_FS_labels(StudyFolder,SubjectId, OutFolder)
%separate_FS_labels(StudyFolder,SubjectId, OutFolder)
%Divides standard FreeSurfer cortical parcellations to left and
%right hemisphere parcels

addpath //matlab/wb
addpath //matlab
addpath //matlab/surfops/
addpath //matlab/CIFTIMatlabReaderWriter_old/
Caret7_command='//scratch/workbench/bin_linux64/wb_command';

fsAvg32k=[StudyFolder '/' num2str(SubjectId) '/MNINonLinear/fsaverage_LR32k/' num2str(SubjectId)];

%Standard FreeSurfer Parcellation
OutFilename=[OutFolder '/' num2str(SubjectId) '.aparc.32k_fs_LR_sep.dlabel.nii'];
Maxn_labels_Filename=[fsAvg32k '.aparc.32k_fs_LR.dlabel.nii'];
[Label_D,Label_BM]=open_wbfile(Maxn_labels_Filename);

%for each of the two hemispheres
NewData=zeros(size(Label_D.cdata));
Labelcount=1;
for i=1:2
    ind=zeros(str2num(Label_BM{i}.IndexCount),1); 
    ind=Label_D.cdata(Label_BM{i}.DataIndices,:);
    UniqInd=unique(ind(ind~=0));       %Unique non-zero labels for the particular structure
    Nlabels=length(UniqInd); 
    for n=1:Nlabels   %which nodes belong to every label
        NewData(find(ind==UniqInd(n))+str2num(Label_BM{i}.IndexOffset))=Labelcount;
        StructureParcels(Labelcount)=i; Labelcount=Labelcount+1;
    end;
end;

Labelcount=Labelcount-1; %disp(Labelcount);
psize=zeros(Labelcount,1);
for i=1:Labelcount  %Find size of new parcels
    psize(i)=length(find(NewData==i));
end

%write dlabel CIFTI
fid = fopen([OutFolder '/test.bin'], 'w');
fwrite(fid, NewData, 'single');
fclose(fid);
save([OutFolder '/' num2str(SubjectId) '.aparc.32k_fs_LR_sep_StructIndex.txt'],'-ascii','StructureParcels');  
save([OutFolder '/' num2str(SubjectId) '.aparc.32k_fs_LR_sep_size.txt'],'-ascii','psize');  
unix([Caret7_command ' -cifti-convert -to-gifti-ext ' Maxn_labels_Filename ' ' OutFolder '/testlabels.gii']);
unix([Caret7_command ' -cifti-convert -from-gifti-ext ' OutFolder '/testlabels.gii ' OutFolder '/test.dtseries.nii -replace-binary ' OutFolder '/test.bin']);
unix([Caret7_command ' -cifti-label-import ' OutFolder '/test.dtseries.nii "" '  OutFilename]);
unix(['rm ' OutFolder '/test*']);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Finer FreeSurfer Parcellation
OutFilename=[OutFolder '/' num2str(SubjectId) '.aparc.a2009s.32k_fs_LR_sep.dlabel.nii'];
Maxn_labels_Filename=[fsAvg32k '.aparc.a2009s.32k_fs_LR.dlabel.nii'];
[Label_D,Label_BM]=open_wbfile(Maxn_labels_Filename);

%for each of the two hemispheres
NewData=zeros(size(Label_D.cdata));
Labelcount=1; clear StructureParcels;
for i=1:2
    ind=zeros(str2num(Label_BM{i}.IndexCount),1); ind=Label_D.cdata(Label_BM{i}.DataIndices,:);
    UniqInd=unique(ind(ind~=0));       %Unique non-zero labels for the particular structure
    Nlabels=length(UniqInd); 
    for n=1:Nlabels   %which nodes belong to every label
        NewData(find(ind==UniqInd(n))+str2num(Label_BM{i}.IndexOffset))=Labelcount;
        StructureParcels(Labelcount)=i; Labelcount=Labelcount+1;
    end;
end;

Labelcount=Labelcount-1; %disp(Labelcount);
psize=zeros(Labelcount,1);
for i=1:Labelcount  %Find size of new parcels
    psize(i)=length(find(NewData==i));
end

%write dlabel CIFTI
fid = fopen([OutFolder '/test.bin'], 'w');
fwrite(fid, NewData, 'single');
fclose(fid);
save([OutFolder '/' num2str(SubjectId) '.aparc.a2009s.32k_fs_LR_sep_StructIndex.txt'],'-ascii','StructureParcels');  
save([OutFolder '/' num2str(SubjectId) '.aparc.a2009s.32k_fs_LR_sep_size.txt'],'-ascii','psize');  
unix([Caret7_command ' -cifti-convert -to-gifti-ext ' Maxn_labels_Filename ' ' OutFolder '/testlabels.gii']);
unix([Caret7_command ' -cifti-convert -from-gifti-ext ' OutFolder '/testlabels.gii ' OutFolder '/test.dtseries.nii -replace-binary ' OutFolder '/test.bin']);
unix([Caret7_command ' -cifti-label-import ' OutFolder '/test.dtseries.nii "" '  OutFilename]);
unix(['rm ' OutFolder '/test*']);