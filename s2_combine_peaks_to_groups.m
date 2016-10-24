
%% plot ppTime
close all
ms2pt = 1000/si;
pt2ms = 1/ms2pt;
upLimit = 20;
allPpTime = zeros(1,length(peaks)-1);
for ii = 1:length(peaks)-1
    allPpTime(ii) = (peaks(ii+1).startH - peaks(ii).endH + 1)*pt2ms;
end
%allPpTime = [upLimit allPpTime];
allPpTimePlot = allPpTime;
allPpTimePlot(allPpTimePlot>=upLimit) = [];
hist((allPpTimePlot),100);
%% things to set
% upLimit = 6;
% lowLimit = 1.5;
upLimit = 9;
lowLimit = 2;
groupN = 3;
%% find peak groups
allFiles = dir('*.mat');
events = [];    events = NPeak;
kthEvt = 1;
peaks = [];
for kthFile = 1:length(allFiles)
    load (allFiles(kthFile).name);
    if isempty(peaks)
        continue;
    end
    if isempty(peaks(end).startH)
        peaks(end) = [];
    end
%     for ii = 1:length(peaks)
%         peaks(ii).startH = peaks(ii).start;
%         peaks(ii).endH = peaks(ii).end;
%     end
    allPpTime = zeros(1,length(peaks)-1);
    for ii = 1:length(peaks)-1
        allPpTime(ii) = (peaks(ii+1).startH - peaks(ii).endH + 1)*pt2ms;
    end
    allPpTime = [upLimit allPpTime];
    for ii = 1:length(peaks) - groupN
        isGroup = 1;
        eventTemp = NPeak;
        eventTemp.peakGroup = Peak;
        for jj = 1:groupN-1
            if allPpTime(ii+jj) > upLimit || allPpTime(ii+jj) < lowLimit
                isGroup = 0;
                break;
            end
        end
        if allPpTime(ii) < upLimit || allPpTime(ii+groupN) < upLimit
            isGroup = 0;
        end
        if isGroup == 1
            amps = zeros(1,groupN);
            durations = zeros(1,groupN);
            for jj = 1:groupN
                eventTemp.peakGroup(jj).amp = peaks(ii+jj-1).amp;
                eventTemp.peakGroup(jj).dwell = peaks(ii+jj-1).duration;
                eventTemp.peakGroup(jj).base = peaks(ii+jj-1).bl;
                eventTemp.peakGroup(jj).pStart = peaks(ii+jj-1).startH*pt2ms;
                eventTemp.peakGroup(jj).pEnd = peaks(ii+jj-1).endH*pt2ms;
                amps(jj) = peaks(ii+jj-1).amp;
                durations(jj) = peaks(ii+jj-1).duration;
            end
            eventTemp.ppTime = allPpTime(ii+1:ii+groupN-1);
            eventTemp.aveAmp = mean(amps);
            eventTemp.aveDwell = mean(durations);
            events(kthEvt) = eventTemp;
            kthEvt = kthEvt + 1;
        end
    end
end
%%
% save 01-PC.mat events
% save 02-ES.mat events
% save 03-EX.mat events
% save 04-WB.mat events
% save 05-PC-CB.mat events
% save 06-EX-CB.mat events
% save 07-WB-CB.mat events

% save 11-PC-300mM.mat events
% save 12-ES-300mM.mat events
% save 13-EX-300mM.mat events
% save 14-WB-300mM.mat events
% save 15-PC-CB-300mM.mat events
% save 16-EX-CB-300mM.mat events
% save 17-WB-CB.mat events

% save 21-PC-4M.mat events
% save 22-ES-4M.mat events
% save 23-EX-4M.mat events
% save 24-WB-4M.mat events
% save 25-PC-CB-4M.mat events
% save 26-EX-CB-4M.mat events
% save 27-WB-CB-4M.mat events

% save ('42-ES-1M KOAc.mat', 'events');
% save ('43-EX-1M KOAc.mat', 'events');
% save ('44-WB-1M KOAc.mat', 'events');

% save ('52-ES-0.3M KOAc.mat', 'events');
% save ('53-EX-0.3M KOAc.mat', 'events');
% save ('54-WB-0.3M KOAc.mat', 'events');

% save ('52-ES-EX-0.3M KOAc.mat', 'events');
% save ('52-ES-EX-0.3M-2 KOAc.mat', 'events');
% save ('54-WB-EX-0.3M KOAc.mat', 'events');

% save ('42-ES-EX-1M KOAc.mat', 'events');
% save ('42-ES-EX-1M KOAc-2.mat', 'events');
% save ('44-WB-EX-1M KOAc.mat', 'events');

% save ('12-ES-EX-300mM NaCl.mat', 'events');
% save ('14-WB-EX-300mM NaCl.mat', 'events');

% save ('12-ES-EX-0.3M NaCl.mat', 'events');
% save ('22-ES-EX-1M NaCl.mat', 'events');
% save ('32-ES-EX-4M NaCl.mat', 'events');

% save ('62-ES-EX-300mM NH4OAc.mat', 'events');
% save ('64-WB-EX-300mM NH4OAc.mat', 'events');

% save ('72-ES-EX-1M NH4OAc.mat', 'events');
% save ('74-WB-EX-1M NH4OAc.mat', 'events');



% save ('11-capsid-1M NaCl-2.mat', 'events');
% save ('12-pacman-1M NaCl.mat', 'events');
% save ('12-test.mat', 'events');

% save ('12-HBV-1M NaCl-400mV.mat', 'events');
% save ('22-HBV-1M NaCl-600mV.mat', 'events');
% save ('32-HBV-1M NaCl-900mV.mat', 'events');
% save ('42-HBV-1M NaCl-800mV-b=0.1.mat', 'events');
% save ('52-HBV-1M NaCl-800mV-2.mat', 'events');
% save ('62-HBV-1M NaCl-800mV-b=0.1-2.mat', 'events');
% save ('32-HBV-1M NaCl-600mV-2.mat', 'events');