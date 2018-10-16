clc, clear all

delete(instrfind({'port'},{'COM11'})); 
s = serial('COM11');
s.BaudRate = 230400;
s.BytesAvailableFcnCount = 2^14;
s.BytesAvailableFcnMode = 'byte';
s.InputBufferSize = 2^14;
s.BytesAvailableFcn = @SerialCallback;

fopen(s);

fprintf(s,'%c',[51 10])