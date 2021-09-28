require "Core.Module.Pattern.BaseModule"
require "Core.Module.Lot.LotProxy"
local LotMediator = require "Core.Module.Lot.LotMediator"
local LotModule = BaseModule:New();
LotModule:SetModuleName("LotModule");
function LotModule:_Start()
	self:_RegisterMediator(LotMediator);
	self:_RegisterProxy(LotProxy);
end

function LotModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

return LotModule