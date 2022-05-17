function [table] = createTable(varnames)
% function to create an output table, takes as input cell array with
% variable names

table = cell2table(cell(0,numel(varnames)), 'VariableNames', varnames);


end
