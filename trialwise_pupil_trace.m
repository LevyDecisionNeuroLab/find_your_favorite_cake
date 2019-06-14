clearvars

%% Load data
data_path = 'D:\Ruonan\Projects in the lab\favourite_cake\MoneyRev_3\MoneyRev_3';
load(fullfile(data_path, 'MoneyRev_1560361239_3.mat'));

% clean data table
etData = etData(19:size(etData,1), :);

%% plot raw pupil trace, left and right eye
plot(etData(:,17));
hold on
plot(etData(:,43));
hold off

%% get trialwise trace
total_trial = 30;

pupil_left = zeros(663, total_trial);
pupil_right = zeros(663, total_trial);

% get trialwise pupil trace left and right eyes
for trialnum = 1:total_trial
    pupil_left(1:sum(etData(:,1) == trialnum),trialnum) = etData(etData(:,1) == trialnum, 24);
    pupil_right(1:sum(etData(:,1) == trialnum),trialnum) = etData(etData(:,1) == trialnum, 43);
end

% trim to 11 second
pupil_left = pupil_left(1:663,:)'; %dimension trialnumber x duration
pupil_right = pupil_right(1:663,:)';

% get rid of values of zero
for trial_num = 1:total_trial
    pupil_left(trial_num, pupil_left(trial_num, :) == 0) = NaN;
    pupil_right(trial_num, pupil_right(trial_num, :) == 0) = NaN;
end

% creat timestamp
timestamp = 1:size(pupil_left,2);
timestamp = timestamp';

% plot raw pupil trace for a single trial
figure
plot(timestamp, pupil_left(15,:)')

%% preprocessing

% filter setup
filter = struct;
filter.filterType = 'sgolay';
filter.order = 3; % order of polynomial for sgolay filter?
filter.framelen = 21; % length of window? must be odd number
filter.clearWin = 2; % delete the n surrounding data points of a blink
filter.velThreshold = 2; % de-blinking relative velocity threshold
graph = true; % suppress figure output

% dblink, interpolate and smooth data(preprocessing). 
% creat empty variables
pupil_filtered=zeros(size(pupil_left));
pupil_left_filtered=zeros(size(pupil_left));
pupil_right_filtered=zeros(size(pupil_left));
pupil_z_filtered=zeros(size(pupil_left));
velocity=zeros(size(pupil_left));

% pre-process each trial
for trial_num=1:3
    [pupil_filtered(trial_num,:),pupil_left_filtered(trial_num,:),pupil_right_filtered(trial_num,:),pupil_z_filtered(trial_num,:),velocity(trial_num,:)]=...
        combineLeftRight(pupil_left(trial_num,:),pupil_right(trial_num,:),timestamp,filter,graph);  
end

%% which cake
% get trial index for each cake
fruit_idx = [21];
blackforest_idx = [13];
truffle_idx = [15];

% average trials for each cake
pupil_fruit = nanmean(pupil_z_filtered(fruit_idx,:),1);
pupil_blackforest = nanmean(pupil_z_filtered(blackforest_idx,:),1);
pupil_truffle = nanmean(pupil_z_filtered(truffle_idx,:),1);

% plot three averaged traces
figure
plot(timestamp/60, pupil_fruit, 'Color', [201,148,199]/255, 'LineStyle', '-', 'LineWidth', 3, 'Marker','none');
hold on
plot(timestamp/60, pupil_blackforest, 'Color', [99,99,99]/255, 'LineStyle', '-', 'LineWidth', 3, 'Marker','none');
hold on
plot(timestamp/60, pupil_truffle, 'Color', [222, 184, 135]/255, 'LineStyle', '-', 'LineWidth', 3, 'Marker','none');

ax = gca;
ax.XTick = [0:0.5:11];
ax.YTick = [];
ax.FontSize = 16;


