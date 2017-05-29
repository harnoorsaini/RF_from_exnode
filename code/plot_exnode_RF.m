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

num_files = 50; % TODO: make automatic...

fname_rootL = 'Case1_1b/ActiveStrain_TransIso_';
fname_rootR = '.part0.exnode';

% The location of the force values for at each node
Force_x_ID = 22;
Force_y_ID = 23;
Force_z_ID = 24; 

% Nodes of interest (sum over these nodes)
Nset_interest = [21:21:735];

% Biceps ----

% TA ----
% top TA
%Nset_interest = [66,67,127,206,213,217,221,254,255,262,263,290,291,297,299,340,341,344,345,347,363];
% bottom TA
%Nset_interest = [57,58,107,229,230,231,232,232,234,281,282,283,284,326,327,328,329,330,331,360,361];
% side TA
%Nset_interest = [484,485,500,220,222,261,486,487,501,214,251,265,488,489,502,216,218,267,490,491,503, ...
%   209,240,269,492,493,504,212,219,276,494,495,505,224,228,278,496,497,506,225,227,280, ...
%   538,540,542,233,498,499,507,539,541,543];
% all TA
%Nset_interest = [66,67,127,206,213,217,221,254,255,262,263,290,291,297,299,340,341,344,345,347,363, ...
%	57,58,107,229,230,231,232,232,234,281,282,283,284,326,327,328,329,330,331,360,361, ...
%    484,485,500,220,222,261,486,487,501,214,251,265,488,489,502,216,218,267,490,491,503, ...
%    209,240,269,492,493,504,212,219,276,494,495,505,224,228,278,496,497,506,225,227,280, ...
%    538,540,542,233,498,499,507,539,541,543];

num_noi = size(Nset_interest,2);

% Parse all exnode files into a cell array
Exnode_raw_data{num_files} = zeros;
for i = 1:num_files
    fname_curr = strcat('exnode_files_SA_concepts/',fname_rootL,num2str(i),fname_rootR);
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
if (Force_z_ID > 0)
    F_z(num_files)=zeros;
end

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
                    F_x(j)=F_x(j)+abs(str2double(Exnode_raw_data{j}{i+Force_x_ID}));
                    F_y(j)=F_y(j)+abs(str2double(Exnode_raw_data{j}{i+Force_y_ID}));
                    F_z(j)=F_z(j)+abs(str2double(Exnode_raw_data{j}{i+Force_z_ID}));
                    if j == 1 % store all nodal forces only for a given time step 
                        F_xstore(k,j)=str2double(Exnode_raw_data{j}{i+Force_x_ID});
                        F_ystore(k,j)=str2double(Exnode_raw_data{j}{i+Force_y_ID});
                        F_zstore(k,j)=str2double(Exnode_raw_data{j}{i+Force_z_ID});
                        k = k+1;
                    end
                end
            end
        end
    end
end

% Active force at all nodes at the given time step
Fa=sqrt(F_xstore.^2+F_ystore.^2+F_zstore.^2);

% Create figure
figure1 = figure;
% Create axes
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    % Create plot
    plot(F_x);
    hold on
    plot(F_y);
    plot(F_z);
    plot(sqrt(F_x.^2+F_y.^2+F_z.^2))
    % Create xlabel
    xlabel('Increment');
    % Create title
    title('Sum of RF over Nodes of Interest');
    % Create ylabel
    ylabel('Force (M*L/T^2)');
    box(axes1,'on');
    % legend
    legend('RFx','RFy','RFz', 'RFmag')
