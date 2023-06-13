%%
clc
close all
clear
%%% INPUT VALUES
type = 2;           % all data together: 1
                    % one output for the same injector: 2
                    % one output for the same cycle: 3
                    % all separate: 4
cus_modelt = 0.25;  % only can input one value!
n = 2;              % case 1: input model value get ECU value
                    % case 2: input ECU value get model value
                    
data_file = 'a_and_b_K1.mat';

%% program start
load(data_file)
% all together
if type == 1
    data = cat(1, a_and_b{:});
    [t_ECU, t_HiL, t_ECU_cali, t_model_cali, idx_rm, y] = cali_points(data, cus_modelt, n);
    
    scatter(t_ECU, t_HiL, '.')
    hold on
    scatter(t_ECU_cali, t_model_cali, '.')
    scatter(t_ECU(idx_rm),t_HiL(idx_rm))
    title('All in One')
    legend(sprintf('original data: %i', numel(t_ECU)), sprintf('calibrated data: %i', numel(t_ECU_cali)), sprintf('outliers: %i', numel(t_ECU(idx_rm))))
    xlabel('injection duration from ECU/ms')
    ylabel('injection duration from model/ms')
    switch n
        case 1
            fprintf('predicted injection duration from ECU: %f(ms)\n', y)
        case 2
            fprintf('predicted injection duration from model: %f(ms)\n', y)
    end
end

% one output for the same injector
if type == 2
    [inj, cyc] = size(a_and_b);
    figure
    for i = 1:inj
        fig_sub = subplot(inj/2,2,i);
        data = a_and_b(i, :);
        data = cat(1, data{:});
        [t_ECU, t_HiL, t_ECU_cali, t_model_cali, idx_rm, y] = cali_points(data, cus_modelt, n);
        scatter(t_ECU, t_HiL, '.')
        hold on
        scatter(t_ECU_cali, t_model_cali, '.')
        scatter(t_ECU(idx_rm),t_HiL(idx_rm))
        title(sprintf('injector %i', i))
        legend(sprintf('original data: %i', numel(t_ECU)), sprintf('calibrated data: %i', numel(t_ECU_cali)), sprintf('outliers: %i', numel(t_ECU(idx_rm))))
        xlabel('injection duration from ECU/ms')
        ylabel('injection duration from model/ms')
        switch n
            case 1
                fprintf('predicted injection duration from ECU of injector %i: %f(ms)\n', i, y)
            case 2
                fprintf('predicted injection duration from model of injector %i: %f(ms)\n', i, y)
        end
    end
end

% one output for the same cycle
if type == 3
    [inj, cyc] = size(a_and_b);
    figure
    for i = 1:cyc
        fig_sub = subplot(cyc/2,2,i);
        data = a_and_b(:, i);
        data = cat(1, data{:});
        [t_ECU, t_HiL, t_ECU_cali, t_model_cali, idx_rm, y] = cali_points(data, cus_modelt, n);
        scatter(t_ECU, t_HiL, '.')
        hold on
        scatter(t_ECU_cali, t_model_cali, '.')
        scatter(t_ECU(idx_rm),t_HiL(idx_rm))
        title(sprintf('cycle %i', i))
        legend(sprintf('original data: %i', numel(t_ECU)), sprintf('calibrated data: %i', numel(t_ECU_cali)), sprintf('outliers: %i', numel(t_ECU(idx_rm))))
        xlabel('injection duration from ECU/ms')
        ylabel('injection duration from model/ms')
        switch n
            case 1
                fprintf('predicted injection duration from ECU of cycle %i: %f(ms)\n', i, y)
            case 2
                fprintf('predicted injection duration from model of cycle %i: %f(ms)\n', i, y)
        end
    end
end

% all separate
if type == 4
    
    [inj, cyc] = size(a_and_b);
    for i = 1:inj
        figure
        sgtitle(sprintf('injector %i', i))
        for j = 1:cyc
            fig_sub = subplot(size(a_and_b,2)/2,2,j);
            data = a_and_b{i,j};
            [t_ECU, t_HiL, t_ECU_cali, t_model_cali, idx_rm, y] = cali_points(data, cus_modelt, n);
            scatter(t_ECU, t_HiL, '.')
            hold on
            scatter(t_ECU_cali, t_model_cali, '.')
            scatter(t_ECU(idx_rm),t_HiL(idx_rm))
            title(sprintf('cycle %i', j))
            legend(sprintf('original data: %i', numel(t_ECU)), sprintf('calibrated data: %i', numel(t_ECU_cali)), sprintf('outliers: %i', numel(t_ECU(idx_rm))))
            xlabel('injection duration from ECU/ms')
            ylabel('injection duration from model/ms')
            switch n
                case 1
                    fprintf('predicted injection duration from ECU of injector %i cycle %i: %f(ms)\n', i, j, y)
                case 2
                    fprintf('predicted injection duration from model of injector %i cycle %i: %f(ms)\n', i, j, y)
            end

        end
    end
end



function [t_ECU, t_HiL, t_ECU_cali, t_model_cali, idx_rm, y] = cali_points(data, cus_modelt, n)
    t_ECU = data(:, 1);
    t_HiL = data(:, 2);
    delta_t = t_ECU - t_HiL;
    [delta_t_rm, idx_rm] = rmoutliers(delta_t,'mean');
    t_final = t_HiL(~idx_rm);
    delta_t_final = delta_t(~idx_rm);
    x = (max(t_final)+min(t_final))/2;
    idx1 = find(t_final<x);
    idx2 = find(t_final>=x);
    t_final_1 = t_final(idx1);
    
    delta_t_final_1 = delta_t_final(idx1);
    t_final_2 = t_final(idx2);
    delta_t_final_2 = delta_t_final(idx2);
    
    mdl1 = fitlm(t_final_1,delta_t_final_1);
    mdl2 = fitlm(t_final_2,delta_t_final_2);
    predicty1 = predict(mdl1, t_final_1);
    predicty2 = predict(mdl2, t_final_2);
    
    t_ECU_final = t_ECU(~idx_rm);
    t_ECU_cali = [t_ECU_final(idx1);t_ECU_final(idx2)];
    t_model_cali = [t_final_1+predicty1;t_final_2+predicty2];
    if cus_modelt < x
        mdl = mdl1;
    else
        mdl = mdl2;
    end
    
    switch n
        case 1
            y = predict(mdl, cus_modelt) + cus_modelt;
        case 2
            y = (cus_modelt - mdl.Coefficients.Estimate(1))./(mdl.Coefficients.Estimate(2)+1);
    end

end