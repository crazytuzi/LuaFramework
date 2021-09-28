require "Core.Module.Pattern.BaseModule"
require "Core.Module.Message.MessageMediator";
require "Core.Module.Message.MessageProxy";
require "Core.Module.Message.MessageNotes";

MessageModule = BaseModule:New();
MessageModule:SetModuleName("MessageModule");
function MessageModule:_Start()
	self:_RegisterMediator(MessageMediator);
	self:_RegisterProxy(MessageProxy);
end

function MessageModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end
