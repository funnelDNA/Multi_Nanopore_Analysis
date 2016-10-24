function [ hp ] = show_data( data, varargin )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

p = inputParser;

defaultPeaks = [];
defaultShowDataT = -1;
defaultShowDataDuration = 1;

defaultUnit = 'min';
validUnits = {'min','sec','ms','us'};
checkUnits = @(x) any(validatestring(x,validUnits));

addRequired(p,'data',@isnumeric);
addOptional(p,'peaks',defaultPeaks);
addOptional(p,'showDataT',defaultShowDataT,@isnumeric);
addOptional(p,'showDataDuration',defaultShowDataDuration,@isnumeric);
addParamValue(p,'unit',defaultUnit,checkUnits);
addParamValue(p,'si',25,@isnumeric);

parse(p,data,varargin{:});

switch p.Results.unit
    case 'min'
        time2pt = 1000*1000*60/p.Results.si;
    case 'sec'
        time2pt = 1000*1000/p.Results.si;
    case 'ms'
        time2pt = 1000/p.Results.si;
    case 'us'
        time2pt = 1/p.Results.si;
end

intPbak = p.Results.data;
if p.Results.showDataT == -1
    startSh = 1;
    endSh   = length(intPbak);
else
    startSh = ceil(p.Results.showDataT*time2pt)+1;
    endSh   = ceil((p.Results.showDataT+p.Results.showDataDuration)*time2pt);
end

hp = plot((startSh:endSh)/time2pt,intPbak(startSh:endSh));




peaks = p.Results.peaks;

hold on;
ii = 1;
if isempty(peaks)
    return;
end
peaks = peaks{1};
while ii < length(peaks) && peaks(ii).start < startSh
    ii = ii + 1;
end

while ii <= length(peaks) && peaks(ii).end < endSh
    plot((peaks(ii).start:peaks(ii).end)/time2pt,intPbak(peaks(ii).start:peaks(ii).end),'r');
    plot([peaks(ii).start peaks(ii).end]/time2pt,[peaks(ii).bl peaks(ii).bl],'r');
    plot([peaks(ii).buttLoc peaks(ii).buttLoc]/time2pt, [peaks(ii).butt (peaks(ii).butt + peaks(ii).bl)/2],'r');
    plot([peaks(ii).startH peaks(ii).endH]/time2pt, [peaks(ii).butt peaks(ii).butt],'r');
    %plot([peaks(ii).startH peaks(ii).startH]/time2pt,[(peaks(ii).butt + peaks(ii).bl)/2-15 (peaks(ii).butt + peaks(ii).bl)/2+15],'r');
    %plot([peaks(ii).endH peaks(ii).endH]/time2pt,[(peaks(ii).butt + peaks(ii).bl)/2-15 (peaks(ii).butt + peaks(ii).bl)/2+15],'r');
    plot([peaks(ii).startH peaks(ii).startH]/time2pt,[peaks(ii).butt peaks(ii).bl],'r');
    plot([peaks(ii).endH peaks(ii).endH]/time2pt,[peaks(ii).butt peaks(ii).bl],'r');
    ii = ii + 1;
end
set(gca,'fontsize',20);

end

