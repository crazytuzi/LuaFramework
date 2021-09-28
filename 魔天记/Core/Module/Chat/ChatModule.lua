require "Core.Module.Pattern.BaseModule"
require "Core.Module.Chat.ChatMediator"
require "Core.Module.Chat.ChatProxy"
ChatModule = BaseModule:New();
ChatModule:SetModuleName("ChatModule");
function ChatModule:_Start()
	self:_RegisterMediator(ChatMediator);
	self:_RegisterProxy(ChatProxy);
end

function ChatModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

