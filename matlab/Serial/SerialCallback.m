function SerialCallback(obj, event)
    i=1;
    obj.BytesAvailable
    
    while (obj.BytesAvailable > 0)
       A(i)=256*fread(obj,1)+fread(obj,1);
       i=i+1;
    end
    
    plot(A)
    fclose(obj);
    delete(obj);    
    clear obj;
 
end