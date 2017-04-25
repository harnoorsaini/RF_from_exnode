clear

%==========================================================================
% Extract information from sequential exnode files and plot them
% currently setup for summing RF over nodes in 2D
% can ideally be easily extended to extract any and all information from
% exnode files
%
% - Exnode files should be placed in a "exnode_files" child directory
% - They should sequentlly iterate, starting from 1
% HARD CODED:
% - fname_rootL and fname_rootR
% - total number of files
% - ID locations for the force fields
%
% Harnoor Saini
% Stuttgart
% April 2017
%==========================================================================


num_files = 5; % TODO: make automatic...

fname_rootL = 'UniaxialExtension2D_';
fname_rootR = '.part0.exnode';

% The location of the force values for at each node
Force_x_ID = 5;
Force_y_ID = 6;
Force_z_ID = 7; % currently only 2D

% Nodes of interest (sum over these nodes)
Nset_interest = [1,3];
num_noi = size(Nset_interest,2);

% Parse all exnode files into a cell array
Exnode_raw_data{num_files} = zeros;
for i = 1:num_files
    fname_curr = strcat('exnode_files/',fname_rootL,num2str(i),fname_rootR);
    formatSpec = '%s%*s%*s%*s%[^\n\r]';
    fileID = fopen(fname_curr,'r');
    dataArray = textscan(fileID, formatSpec, 'ReturnOnError', false);
    fclose(fileID);
    Exnode_raw_data{i} = dataArray{:, 1};
end

% Find Node of interest
num_lines = size(Exnode_raw_data{1},1);
k = 1;
F_x(num_files)=zeros;
F_y(num_files)=zeros;

% loop over all time-steps
for j = 1:num_files
    N_total = 0;
    % for a given time step, loop over all nodes
    for i = 1:num_lines
        % actually find the lines with node entries
        if strcmp(Exnode_raw_data{j}{i},'Node:')
            N_total = N_total+1;
            % compare each node to all of the nodes to be summed over
            for n = 1:num_noi
                % if the current node = one of the nodes of interest then
                % sum
                if N_total == Nset_interest(n)
                    % add the nodal force to any existing normal force
                    F_x(j)=F_x(j)+str2double(Exnode_raw_data{j}{i+Force_x_ID});
                    F_y(j)=F_y(j)+str2double(Exnode_raw_data{j}{i+Force_y_ID});
                end
            end
        end
    end
end


% Create figure
figure1 = figure;
% Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    % Create plot
    plot(F_x);
    hold on
    plot(F_y);
    % Create xlabel
    xlabel('Increment');
    % Create title
    title('Sum of RF over Nodes of Interest');
    % Create ylabel
    ylabel('Force (M*L/T^2)');
    box(axes1,'on');
    % legend
    legend('RFx','RFy','RFz')
