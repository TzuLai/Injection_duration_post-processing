%%
clc
close all
clear

f1 = 'a_and_b_K1.mat';
f2 = 'a_and_b_K3.mat';

type = 1;           % all data together: 1
                    % one output for the same injector: 2
                    % one output for the same cycle: 3
                    % all separate: 4

d1 = load(f1);
d2 = load(f2);
set(groot, 'DefaultLegendInterpreter', 'none')
% all together
if type == 1
    data = cat(1, d1.a_and_b{:});
    [t_ECU, t_HiL, idx_rm] = get_points(data);
    data2 = cat(1, d2.a_and_b{:});
    [t_ECU2, t_HiL2, idx_rm2] = get_points(data2);
    
    scatter(t_ECU(~idx_rm), t_HiL(~idx_rm), '.', 'blue')
    hold on
    scatter(t_ECU2(~idx_rm2), t_HiL2(~idx_rm2), '.', 'cyan')

    title('All in One')
    legend(sprintf('%s data: %i', f1, numel(t_ECU)), sprintf('%s data: %i', f2, numel(t_ECU2)))
    xlabel('injection duration from ECU/ms')
    ylabel('injection duration from model/ms')
end

% one output for the same injector
if type == 2
    [inj1, cyc1] = size(d1.a_and_b);
    [inj2, cyc2] = size(d2.a_and_b);
    inj = min([inj1, inj2]);
    cyc = min([cyc1, cyc2]);
    figure
    for i = 1:inj
        fig_sub = subplot(inj/2,2,i);
        data1 = d1.a_and_b(i, :);
        data1 = cat(1, data1{:});
        data2 = d2.a_and_b(i, :);
        data2 = cat(1, data2{:});
        [t_ECU1, t_HiL1, idx_rm1] = get_points(data1);
        [t_ECU2, t_HiL2, idx_rm2] = get_points(data2);
        scatter(t_ECU1(~idx_rm1), t_HiL1(~idx_rm1), '.')
        axis equal
        xlim([0 max([t_ECU1; t_ECU2])+2])
        ylim([0 max([t_HiL1; t_HiL2])+0.5])
        hold on
        scatter(t_ECU2(~idx_rm2), t_HiL2(~idx_rm2), '.', 'c')
        title(sprintf('injector %i', i))
        legend(sprintf('%s data: %i', f1, numel(t_ECU1)), sprintf('%s data: %i', f2, numel(t_ECU2)))
        legend('Location','southeast')
        xlabel('injection duration from ECU/ms')
        ylabel('injection duration from model/ms')
        
    end
end

% one output for the same cycle
if type == 3
    [inj1, cyc1] = size(d1.a_and_b);
    [inj2, cyc2] = size(d2.a_and_b);
    inj = min([inj1, inj2]);
    cyc = min([cyc1, cyc2]);
    figure
    for i = 1:cyc
        fig_sub = subplot(cyc/2,2,i);
        data1 = d1.a_and_b(:, i);
        data1 = cat(1, data1{:});
        data2 = d2.a_and_b(:, i);
        data2 = cat(1, data2{:});
        [t_ECU1, t_HiL1, idx_rm1] = get_points(data1);
        [t_ECU2, t_HiL2, idx_rm2] = get_points(data2);
        scatter(t_ECU1(~idx_rm1), t_HiL1(~idx_rm1), '.')
        axis equal
        xlim([0 max([t_ECU1; t_ECU2])+1.5])
        ylim([0 max([t_HiL1; t_HiL2])+0.5])
        hold on
        scatter(t_ECU2(~idx_rm2), t_HiL2(~idx_rm2), '.', 'c')
        title(sprintf('cycle %i', i))
        legend(sprintf('%s data: %i', f1, numel(t_ECU1)), sprintf('%s calibrated data: %i', f2, numel(t_ECU2)))
        legend('Location','southeast')
        xlabel('injection duration from ECU/ms')
        ylabel('injection duration from model/ms')
    end
end

% all separate
if type == 4
    [inj1, cyc1] = size(d1.a_and_b);
    [inj2, cyc2] = size(d2.a_and_b);
    inj = min([inj1, inj2]);
    cyc = min([cyc1, cyc2]);

    for i = 1:inj
        figure
        sgtitle(sprintf('injector %i', i))
        for j = 1:cyc
            fig_sub = subplot(size(d1.a_and_b,2)/2,2,j);
            data1 = d1.a_and_b{i,j};
            [t_ECU1, t_HiL1, idx_rm1] = get_points(data1);
            data2 = d2.a_and_b{i,j};

            [t_ECU2, t_HiL2, idx_rm2] = get_points(data2);
            
            
            scatter(t_ECU1(~idx_rm1), t_HiL1(~idx_rm1), '.')
            axis equal
            xlim([0 max([t_ECU1; t_ECU2])+0.5])
            ylim([0 max([t_HiL1; t_HiL2])+0.5])
            hold on
            scatter(t_ECU2(~idx_rm2), t_HiL2(~idx_rm2), '.', 'c')
            title(sprintf('cycle %i', j))
            legend(sprintf('%s data: %i', f1, numel(t_ECU1)), sprintf('%s data: %i', f2, numel(t_ECU2)))
            xlabel('injection duration from ECU/ms')
            ylabel('injection duration from model/ms')
        end
    end
end



function [t_ECU, t_HiL, idx_rm] = get_points(data)
    t_ECU = data(:, 1);
    t_HiL = data(:, 2);
    delta_t = t_ECU - t_HiL;
    [delta_t_rm, idx_rm] = rmoutliers(delta_t,'mean');

end