clc, clear all

delete(instrfind({'port'},{'COM8'})); 
s = serial('COM8');
s.BaudRate = 230400;
s.BytesAvailableFcnCount = 2^14;
s.BytesAvailableFcnMode = 'byte';
s.InputBufferSize = 2^14;
s.BytesAvailableFcn = @SerialCallback;

fopen(s);

fprintf(s,'%c',[51 10])