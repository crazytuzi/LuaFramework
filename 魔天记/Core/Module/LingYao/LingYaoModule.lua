require "Core.Module.Pattern.BaseModule"
require "Core.Module.LingYao.LingYaoMediator"
require "Core.Module.LingYao.LingYaoProxy"
LingYaoModule = BaseModule:New();
LingYaoModule:SetModuleName("LingYaoModule");
function LingYaoModule:_Start()
	self:_RegisterMediator(LingYaoMediator);
	self:_RegisterProxy(LingYaoProxy);
end

function LingYaoModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

