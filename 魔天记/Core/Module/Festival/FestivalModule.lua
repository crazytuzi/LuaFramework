require "Core.Module.Pattern.BaseModule"
require "Core.Module.Festival.FestivalProxy"
local FestivalMediator = require "Core.Module.Festival.FestivalMediator"
local FestivalModule = BaseModule:New();
FestivalModule:SetModuleName("FestivalModule");
function FestivalModule:_Start()
	self:_RegisterMediator(FestivalMediator);
	self:_RegisterProxy(FestivalProxy);
end

function FestivalModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return FestivalModule