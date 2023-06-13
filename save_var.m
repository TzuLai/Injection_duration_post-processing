%%
clc
close all
clear

%%% INPUT VALUE
file = 'G3LK4_V8evo_Conv_EU_K3_noKH';
num_Inj = 6;                     % enter how many injectors are included in the data file
num_Cyc = 4;                     % enter how many cycles for each injector

%% program start
load (file)
% name of time signal
t_HiL = Hardware_Polling__10ms_;
t_ECU = time0;


%% 1. initialization
a_and_b = cell(num_Inj, num_Cyc); % initilize struct of a and b
table = cell(num_Inj, num_Cyc+1);
%% 2. rearrange and preprocess signal
for id_Inj = 1:num_Inj %id of injector
    for id_Cyc = 1:num_Cyc %id of injection cycle
        Headers_row{1, id_Cyc} = sprintf('cycle %i', id_Cyc);
        % signal a and b of the same Inj, Cyc
        sig_a = eval(sprintf('ti%ia_l_msg__%i_',id_Cyc,id_Inj-1));
        sig_b = eval(sprintf('HDEV_Zylinder_%i_Out6_%i_',id_Inj,id_Cyc-1));
        sig_b = sig_b*1000; % switch s to ms
        % initialization deletion array
        bit_keep = []; 

        % delete indices for a, where sig_a == 0
        index_nonzero = find(sig_a~=0);
        sig_a_nonzero = sig_a(index_nonzero); % all the data left from sig_a are valid
        time_a_nonzero = t_ECU(index_nonzero);

        % delete indices for b, where sig_a == 0
        for k = 1:length(sig_b)
            t_b_k = t_HiL(k,1); % time stamp of sig_b to be checked
            flag = find(t_ECU == t_b_k); % if there is an exact match
            if isempty(flag)
                % t_b_k is not in time_0
                [close_a, id_close_a] = closest(t_b_k, t_ECU); % find the closest value in t_ECU to t_b_k

                if t_ECU(id_close_a) > t_b_k
                    % find the closest time stamps in t_ECU to t_b_k
                    bit_position = [id_close_a-1 id_close_a];
                else
                    bit_position = [id_close_a id_close_a+1];
                end

                if ismember(bit_position, index_nonzero)
                    % only keep t_b_k, when both closest time stamps are in index_nonzero
                    bit_keep(end+1) = k;
                else
                    % delete k
                end

            else
                % exact time match
                if ismember(flag, index_nonzero)
                    % sig_a(t_b_k) not 0 -> keep k
                    bit_keep(end+1) = k;
                else
                    % sig_a(t_b_k) is 0 -> delete k
                end
            end
        end

        % execute deletion
        sig_b_nonzero = sig_b(bit_keep);
        time_b_nonzero = t_HiL(bit_keep);


        % downsample a, so that a and b have unified time axis
        interp_a = interp1(time_a_nonzero, sig_a_nonzero, time_b_nonzero,'linear',404); % fail-safe: extrapolation error by label 404

        % delete extrapolated data in a and b
        index_extrap = find(interp_a~=404);
        sig_a_valid = interp_a(index_extrap);
        sig_b_valid = sig_b_nonzero(index_extrap);
        time_valid = time_b_nonzero(index_extrap);

        % read a, b and time into struct
        a_and_b{id_Inj,id_Cyc} = [sig_a_valid sig_b_valid time_valid];

    end
end
save('a_and_b_K1.mat')

function [minVal, idx] = closest(n, array)
% find element in array which is closest to n
[val,idx]=min(abs(array-n));
minVal=array(idx);
end