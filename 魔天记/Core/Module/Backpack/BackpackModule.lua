require "Core.Module.Pattern.BaseModule"
require "Core.Module.Backpack.BackpackMediator"
require "Core.Module.Backpack.BackpackProxy"
BackpackModule = BaseModule:New();
BackpackModule:SetModuleName("BackpackModule");
function BackpackModule:_Start() 
    self:_RegisterMediator(BackpackMediator);
    self:_RegisterProxy(BackpackProxy);
end

function BackpackModule:_Dispose()
    self:_RemoveMediator();
    self:_RemoveProxy();
end




