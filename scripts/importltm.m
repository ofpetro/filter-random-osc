function [wl, fsb, rpm, fftpts,tsv, s1, s2, s3, S0, S1, S2, S3, az, ell, dop, dolp, docp, p, pp,pu, logp, logpp, logpu, psr, phi]=importltm(filename)
%% Initialize variables.
delimiter = ';';
startRow = 5;
endRow = 7;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r','n','UTF-8');
% Skip the BOM (Byte Order Mark).
fseek(fileID, 3, 'bof');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'ReturnOnError', false);


%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
raw=cell2mat(raw);
wl = raw(1, 1);
fsb= raw(2,1);
rpm=raw(3,1);
fftpts = raw(3, 2);

startRow = 9;

%% Format string for each line of text:
%   column1: datetimes (%{yyyy-MM-dd HH:mm:ss.SS}D)
%	column3: double (%f)
%   column4: double (%f)
%	column5: double (%f)
%   column6: double (%f)
%	column7: double (%f)
%   column8: double (%f)
%	column9: double (%f)
%   column10: double (%f)
%	column11: double (%f)
%   column12: double (%f)
%	column13: double (%f)
%   column14: double (%f)
%	column15: double (%f)
%   column16: double (%f)
%	column17: double (%f)
%   column18: double (%f)
%	column19: double (%f)
%   column20: double (%f)
%	column21: double (%f)
%   column22: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%*s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%*s%[^\n\r]';


%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Allocate imported array to column variable names
ts = dataArray{:, 1};
s1 = dataArray{:, 2};
s2 = dataArray{:, 3};
s3 = dataArray{:, 4};
S0 = dataArray{:, 5};
S1 = dataArray{:, 6};
S2 = dataArray{:, 7};
S3 = dataArray{:, 8};
az = dataArray{:, 9};
ell = dataArray{:, 10};
dop = dataArray{:, 11};
docp = dataArray{:, 12};
dolp = dataArray{:, 13};
p = dataArray{:, 14};
pp = dataArray{:, 15};
pu = dataArray{:, 16};
logp = dataArray{:, 17};
logpp = dataArray{:, 18};
logpu = dataArray{:, 19};
psr = dataArray{:, 20};
phi = dataArray{:, 21};

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).
tsv=nan(length(ts),1);
for it=1:length(ts)
    temp=ts{it};
    tsv(it)=(str2double(temp(6:7))*60+str2double(temp(9:10)))*1000+str2double(temp(12:14));
end

%% Clear temporary variables
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;
end