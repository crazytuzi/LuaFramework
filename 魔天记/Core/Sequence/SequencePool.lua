SequencePool = { };
SequencePool.PATH = "Core.Sequence.Item.";

function SequencePool.Create(tName, ...)
    local reqStr = SequencePool.PATH .. tName;
    
    if (_G[tName] == nil and package.loaded[reqStr] == nil) then
        require (reqStr);
    end

    local t = _G[tName];
    return t.New();
end