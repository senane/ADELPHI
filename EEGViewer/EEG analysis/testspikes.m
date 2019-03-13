load('spikes_test2.mat');

samples_per_second = 1000;
%data = spikes_test(1:60000);
data = spikes_test2;

t_ms = (0:length(data)-1)/samples_per_second;
figure;
plot(t_ms, data);
hold on;
win_smooth = 5;
dVdt = movmean(abs(diff(data))*samples_per_second, round(win_smooth*10.^-3*samples_per_second));
%plot(dVdt/20);
spikes = [];
spikes = findSpikes(data, samples_per_second, [0.4 10]);

for i=1:length(spikes)
        area([spikes(i).i_beg spikes(i).i_end]/samples_per_second, ones(1,2)*5, 'FaceAlpha', 0.2,...
       'EdgeAlpha', 0.2);
end

xlabel('Time [s]')

spikes_data = [spikes.data]';

[coeff,score,latent,tsquared,explained,mu] = pca(spikes_data);
figure;
bar(explained);
figure;
bar(coeff(:,1))
figure;
bar(coeff(:,2))
figure
bar(coeff(:,3))
figure;
% c = [ones(round(size(score,1)/2),1); zeros(round(size(score,1)/2),1)];
% c = [1:round(size(score,1)/2) 1:round(size(score,1)/2)];
scatter3(score(:,1), score(:,2), score(:,3), [], 'b', 'filled');
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')

%%
K = 4;
idc = kmeans(score(:,1:3), K);

colors = get(gca, 'colororder');
colors_scatter = zeros(size(score,1), 3);
for i=1:max(idc)
    colors_scatter(idc==i,:)=repmat(colors(i,:), [sum(idc==i),1]); 
end
figure;
s = scatter3(score(:,1), score(:,2), score(:,3), [], colors_scatter, 'filled');
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')


% spikes averages
for i=1:K
spike_mean{i} = mean(spikes_data(idc==i,:),1);
spike_std{i} = std(spikes_data(idc==i,:),1);
end


figure;
hold on;
for i=1:K
    shadedErrorBar(1:length(spike_mean{i}), spike_mean{i}, spike_std{i}, {'color', colors(i,:)}, 0.4);
end
hold off;
set(gca, 'XTick', [])
set(gca, 'YTick', [])

% calculate the delta T
deltaT = diff([spikes.i_beg])/samples_per_second;
deltaT = [deltaT deltaT(end)];
figure;
scatter3(score(:,1), score(:,2), log10(deltaT), [], colors_scatter, 'filled');
xlabel('PC1')
ylabel('PC2')
zlabel('log(\Deltat)')

figure
s1 = subplot(2,1,1);
set(gca, 'XTick', [])
set(gca, 'YTick', [])
hold on;
for i=1:length(spikes)
   plot([spikes(i).i_beg spikes(i).i_beg], [idc(i)/2-0.2 idc(i)/2+0.2], 'Color', colors(idc(i),:), 'linewidth', 1.2)
end
hold off;
s2 = subplot(2,1,2);
plot(t_ms, data)
xlabel('Time [s]')


%linkaxes([s1,s2], 'x')
