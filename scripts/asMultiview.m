function asMultiview(in, info)

for i = 1 : length(in)
    if nargin > 1
        tit = [];
        if isfield(info{1},'meanAF');
            tit = ['af=',num2str( info{i}.meanAF)];
        end              
        as(in{i}, 'info',info{i},'title',tit);
    else
         as(in{i});
    end

end