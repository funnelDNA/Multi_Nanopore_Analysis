%%
% this version is for either abf or tdms
%

clear; clc; close all;
%%
f1 = figure;   f2 = figure;   %f1 = figure; 


fileName = 'Thu, Oct 20, 2016 1-41 PM.tdms';
%removeP = [2.666 inf];

removeP = [0 0.0036 7.435 7.63 9.495 9.72 15.8426 inf];


runMode = fileName(end-2:end);
if strcmp(runMode, 'abf')
    [rawData, si, h]= abfload(fileName);
    current = rawData(:,1);
    voltage = rawData(:,2);
    file2Save = [fileName(1:end-4) '.mat'];
else
    rawData = TDMSload(fileName);
    si = 25;        h = [];
    current = rawData(:,2);
    voltage = rawData(:,1);
    file2Save = [fileName(1:end-5) '.mat'];
end

figure(f1);
show_data(current);
%% use first t2satble second data to determine initial baseline and noise
t2satble = 10;
ml = [];    vl = [];
ml(1) = mean(current(1000000/si));
vl(1) = var(current(1000000/si));
previousWeight = 0.999;
ii = 2;
while ii < t2satble*1000000/si
    ml(ii) = previousWeight * ml(ii-1) + (1-previousWeight) * current(ii);    
    vl(ii) = previousWeight * vl(ii-1) + (1-previousWeight) * (current(ii)-ml(ii))^2;
    Sl     = ml(ii) - 10*sqrt(vl(ii));
    if (current(ii+1) <= Sl)
        El = ml(ii);
        Mm = ml(ii);     Vv = vl(ii);
        while ii < length(current) && current(ii+1)<El
            ii=ii+1;
            ml(ii) = Mm;     vl(ii) = Vv;
        end        
    end
    ii = ii + 1;
end
iniBL = ml(end);
iniVL = vl(end);
%% find all the places where the voltage changes, searching to both sides until the std goes back to normal as well as the baseline
cutL = [];
cutR = [];
medianV = median(voltage);
voltage1 = voltage(1:end-1);
voltage2 = voltage(2:end);
voltage3 = voltage2 - voltage1;
decVloc = find(voltage3 < -1);
incVloc = find(voltage3 > 1);
kk = 1;
vlthreshold = 1.1;
while ~isempty(decVloc) && ~isempty(incVloc)
    pt = decVloc(1);
    ml = current(pt);
    vl = iniVL*2;
    ii = 1;
    BL = iniBL;     VL = iniVL;
    while (vl(ii) > iniVL*vlthreshold || ml(ii) < BL - sqrt(VL)*8) && pt > 1
    %while (vl(ii) > iniVL*vlthreshold) && pt > 1
        pt = pt - 1;
        ii = ii + 1;
        ml(ii) = previousWeight * ml(ii-1) + (1-previousWeight) * current(pt);
        vl(ii) = previousWeight * vl(ii-1) + (1-previousWeight) * (current(pt)-ml(ii))^2;
    end
    cutL(kk) = pt;
    pt = incVloc(1);
    ml = current(pt);
    vl = iniVL*2;
    ii = 1;
    while (vl(ii) > iniVL*vlthreshold || ml(ii) < BL - sqrt(VL)*8) && pt < length(current)
    %while (vl(ii) > iniVL*vlthreshold) && pt < length(current)
        pt = pt + 1;
        ii = ii + 1;
        ml(ii) = previousWeight * ml(ii-1) + (1-previousWeight) * current(pt);
        vl(ii) = previousWeight * vl(ii-1) + (1-previousWeight) * (current(pt)-ml(ii))^2;
    end
    cutR(kk) = pt;
    decVloc(decVloc<pt) = [];
    incVloc(incVloc<pt) = [];
    BL = current(pt);
    kk = kk + 1;
end
%%
%removeP = [cutL cutR];
%removeP = removeP/60000000*si;
 % removeP = [1 1.19 1.4 1.7 3.26 inf];  % or manually type in time; unit: min
%removeP = [0.696 0.9 2 2.26 4.8 5.44 7.16 7.4 19.55 19.88];
removeP = sort(removeP);
for ii = length(removeP):-2:1
    toRemoveS = ceil(removeP(ii-1)/si*60000000);
    toRemoveE = ceil(removeP(ii)/si*60000000);
    if toRemoveS == 0
        toRemoveS = 1;
    end
    if toRemoveE == inf
        current(toRemoveS:end) = [];
        voltage(toRemoveS:end) = [];
    else
        current(toRemoveS:toRemoveE) = [];
        voltage(toRemoveS:toRemoveE) = [];
    end
end
%%
figure(f2);
show_data(current);
%%
rawData = [current,voltage];
save (file2Save,'current','voltage','si','h');
