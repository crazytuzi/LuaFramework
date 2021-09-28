require "Core.Module.Pattern.BaseModule"
require "Core.Module.Friend.FriendMediator"
require "Core.Module.Friend.FriendProxy"
FriendModule = BaseModule:New();
FriendModule:SetModuleName("FriendModule");
function FriendModule:_Start()
	self:_RegisterMediator(FriendMediator);
	self:_RegisterProxy(FriendProxy);
end

function FriendModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

