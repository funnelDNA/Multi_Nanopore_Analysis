%%
% this version is for either abf or tdms
%
% show_data(current,{peaks},'unit','ms','showDataT',1,'showDataDuration',10000);
clear; clc; close all;
%%
%profile on
runMode = 'tdms'; % or 'abf'
slideDis = 0.2; %unit ms; typical peak hight 0.5 ms; peaks interval: 8 ms
thresholdLevel = 5;  % (6 for WB; 10 for PC); (10 for WB; 15 for PC);
thresholdLevel2Reject = 0.5; % reject if (peaks(ii).blL - peaks(ii).blR) > thresholdLevel/thresholdLevel2Reject*sample_std)
baseCalN = 500;  %number of points used for calculate baseline on each side
time4CalSTD = 10;%use the first xx ms data for calculating std;
singleFile = 1; % 0 means not single file 14
fileStart = 1;
fileEnd = 0; % 0 means all files
smoothLevel = 1; % for WB, ES in 300 mM
startP4std = 10000;
%%
tic
f1 = figure;

allFiles = dir(['*.' runMode]);
if fileEnd == 0
    fileEnd = length(allFiles);
end
if singleFile ~= 0
    fileStart = singleFile;
    fileEnd = singleFile;
end
for kthFile = fileStart:fileEnd
    fileName = allFiles(kthFile).name(1:end-length(runMode)-1);
    disp([fileName ': loading...']);
    file2Read = [fileName '.' runMode];
    file2Save = [fileName '.mat'];
    if exist(file2Save,'file') == 2
        load (file2Save);
    else
        if strcmp(runMode, 'abf')
            [rawData, si, h]= abfload(file2Read);
            current = rawData(:,1);
            voltage = rawData(:,2);
        else
            rawData = TDMSload(file2Read);
            si = 25;        h = [];
            current = rawData(:,2);
            voltage = rawData(:,1);
        end
    end
    %%
    ms2pt = 1000/si;
    pt2ms = 1/ms2pt;
    toc
    %% remove reversed Voltages
    medianV = median(voltage);
    medianI = median(current);
    %% find peak locations
    slideP = round(slideDis*ms2pt);
    intP = current;
    intP = smooth(intP,smoothLevel);
    intPbak = current;
    intPbak = smooth(intPbak,smoothLevel);
    intP1 = intP;     intP2 = intP;     intP3 = intP;
    intP1(1:slideP) = [];
    intP2(end) = [];    intP2(1) = [];
    intP3(end-slideP+1:end) = [];
    netP = intP1-intP3;

    %sample_std = std(netP(1:time4CalSTD*ms2pt)); %use the first 1s data for calculating std;
    sample_std = std(netP(startP4std:startP4std+time4CalSTD*ms2pt))
    threshold = thresholdLevel*sample_std;
    valy = netP<-threshold;
    valyLoc = find(valy);

    kthPeak = 1;        peaks = [];         movingBL = medianI;
    while ~isempty(valyLoc)
        peakPt = valyLoc(1);
        while peakPt>0 && netP(peakPt) < 0
            peakPt = peakPt - 1;
        end
        peaks(kthPeak).start = peakPt + slideP;
        peakPt = valyLoc(1);
        while peakPt < length(netP) && netP(peakPt) < threshold/2
            peakPt = peakPt + 1;
        end
        while peakPt < length(netP) && (peaks(kthPeak).start > peakPt || netP(peakPt) < -min(netP(peaks(kthPeak).start:peakPt))/2)
            peakPt = peakPt + 1;
        end
        while peakPt < length(netP) &&  netP(peakPt) > 0
            peakPt = peakPt + 1;
        end
        peaks(kthPeak).end = peakPt;
        peaks(kthPeak).profile = intPbak(peaks(kthPeak).start:peaks(kthPeak).end);
        valyLoc(valyLoc <= peakPt) = [];    
        if peaks(kthPeak).start < peaks(kthPeak).end % && (intPbak(peaks(kthPeak).start) > mean(movingBL) - threshold)
    %         figure(f1);
    %         plot(intPbak(peaks(kthPeak).start - 1000:peaks(kthPeak).end+1000));
    %         hold on;
    %         plot(peaks(kthPeak).profile,'r');
    %         hold off;
    %         figure(f2);
    %         drawnow;
    %         plot(netP(peaks(kthPeak).start - 1000:peaks(kthPeak).end+1000));
            movingBL = [movingBL intPbak(peaks(kthPeak).start)];
            kthPeak = kthPeak + 1;
        end
        fprintf('%d/56320\n',length(valyLoc));
    end
    %%
    peaksN = length(peaks);
    delP = [];
    for ii = 1:peaksN
        if peaks(ii).start - baseCalN < 1
            peaks(ii).blL = mean(intPbak(1:peaks(ii).start));
        else
            peaks(ii).blL = mean(intPbak(peaks(ii).start - baseCalN:peaks(ii).start));
        end
        if peaks(ii).end + baseCalN > length(intPbak)
            peaks(ii).blR = mean(intPbak(peaks(ii).end:end));
        else
            peaks(ii).blR = mean(intPbak(peaks(ii).end:peaks(ii).end + baseCalN));
        end
        if abs(peaks(ii).blL - peaks(ii).blR) > thresholdLevel/thresholdLevel2Reject*sample_std
            figure(f1);
            plot(peaks(ii).profile);
            fprintf('baselines are not leveled!');
            %pause;
            continue;
        end
        peaks(ii).bl = (peaks(ii).blL + peaks(ii).blR)/2;
        [peaks(ii).butt peaks(ii).buttLoc] = min(intPbak(peaks(ii).start:peaks(ii).end));
        peaks(ii).buttLoc = peaks(ii).buttLoc + peaks(ii).start - 1;
        threshH = (peaks(ii).butt + peaks(ii).bl)/2;
        bottHalf = peaks(ii).profile < threshH;
        bottHalfLoc = find(bottHalf);
        if isempty(bottHalfLoc) || bottHalfLoc(1) <=1 || bottHalfLoc(end) >= length(peaks(ii).profile)
            delP = [ii delP];
            continue;
        end
        y2 = peaks(ii).profile(bottHalfLoc(1));
        y1 = peaks(ii).profile(bottHalfLoc(1)-1);
        peaks(ii).startH = bottHalfLoc(1) - (y2-threshH)/(y2-y1) + peaks(ii).start - 1;
        y2 = peaks(ii).profile(bottHalfLoc(end));
        y1 = peaks(ii).profile(bottHalfLoc(end) + 1);
        peaks(ii).endH = bottHalfLoc(end) + (y2-threshH)/(y2-y1) + peaks(ii).start - 1;  
        peaks(ii).duration = (peaks(ii).endH - peaks(ii).startH + 1)*pt2ms;
        peaks(ii).amp = peaks(ii).bl - peaks(ii).butt;
        peaks(ii).area = peaks(ii).bl*(peaks(ii).endH - peaks(ii).startH + 1) - sum(intPbak(int64(peaks(ii).startH:peaks(ii).endH)));
    end
    for ii = length(peaks):-1:1
        if isempty(peaks(ii).amp)
            peaks(ii) = [];
        end
    end
    %profile viewer
    %% plotting minutes as unit
    figure;
    show_data(current,{peaks},'unit','ms');
    drawnow;
    %%
    if exist([pwd '\' file2Save],'file') == 2
        save([pwd '\' file2Save],'peaks','current','voltage','si','h','-append');
    else
        save([pwd '\' file2Save],'peaks','current','voltage','si','h');
    end
    disp('done');
end
disp('all done');
% toc
% profile viewer