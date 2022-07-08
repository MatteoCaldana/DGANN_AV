function [cells] = map_to_cell(map)
    keys = map.keys;
    cells = cell(2*map.Count, 1);
    for i = 1:length(keys)
        cells{2*i - 1} = keys{i};
        cells{2*i} = map(keys{i});
    end
end