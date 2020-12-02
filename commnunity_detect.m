clear;clc;close all;
cd("D:\Code_Bambi\repulicate\A mechanistic model of connector hubs")
load rest_allsession_norm


commnunity_detect
% modularity_und
% High participation coefficient,connector hub. 
%   Participation coefficient is a measure of diversity of intermodular
%   connections of individual nodes.
% P = participation_coef(W,Ci)
%
% High within-community strength,local hub
% within-community strength measures how well-connected node i is to 
% other nodes in the community relative to other nodes in the community.


[CIs, part_coefs, incomm_stres] = deal(zeros(132,30)); % 同时初始化
Qs = zeros(30,1);

for i = 1:30
    temp = squeeze(rest0_norm(i,:,:));
    [ci,q] = modularity_und(temp);
    P=participation_coef(temp,ci);
    Z = Within_community_strength(temp,ci);
    
    [CIs(:,i), part_coefs(:,i), incomm_stres(:,i), Qs(i)] = deal(ci, P, Z, q);
end


hub diversity and locality, modularity and network connectivity
% extract connector hub index
connect_hub = cell(30,1); % 存放每个被试的每个团块的connector hub
for i = 1:30
    ci = CIs(:,i);
    part_coef = part_coefs(:,i);
    inds = zeros(1,max(ci))
    % 被试内
    for j = 1:max(ci)
        [~,ind] = max(part_coef .* (ci == j));
        disp(ind)
        inds(1,j) = ind;
    end
    connect_hub{i,1} = inds;
end

% extract local hub index

local_hub = cell(30,1); % 存放每个被试的每个团块的local hub的index
for i = 1:30
    ci = CIs(:,i);
    incomm_stre = incomm_stres(:,i);
    inds = zeros(1,max(ci))
    % 被试内
    for j = 1:max(ci)
        [~,ind] = max(incomm_stre .* (ci == j));
        disp(ind)
        inds(1,j) = ind;
    end
    local_hub{i,1} = inds;
end

save commu_index Qs CIs part_coefs incomm_stres

