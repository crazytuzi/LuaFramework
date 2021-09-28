require "Core.Module.Pattern.BaseModule"
require "Core.Module.OtherInfo.OtherInfoMediator"
require "Core.Module.OtherInfo.OtherInfoProxy"
require "Core.Module.OtherInfo.OtherInfoNotes"

OtherInfoModule = BaseModule:New();
OtherInfoModule:SetModuleName("OtherInfoModule");
function OtherInfoModule:_Start()
	self:_RegisterMediator(OtherInfoMediator);
	self:_RegisterProxy(OtherInfoProxy);
end

function OtherInfoModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end
