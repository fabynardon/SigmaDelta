fid=fopen('cic_stimulus.txt','wt');

formato='%d\n' ;

for i=1:size(sigma_delta_out,1);

    fprintf(fid,formato,sigma_delta_out(i));

end

fclose(fid)