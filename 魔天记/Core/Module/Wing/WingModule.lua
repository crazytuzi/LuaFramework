require "Core.Module.Pattern.BaseModule"
require "Core.Module.Wing.WingMediator"
require "Core.Module.Wing.WingProxy"
WingModule = BaseModule:New();
WingModule:SetModuleName("WingModule");
function WingModule:_Start()
	self:_RegisterMediator(WingMediator);
	self:_RegisterProxy(WingProxy);
end

function WingModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

