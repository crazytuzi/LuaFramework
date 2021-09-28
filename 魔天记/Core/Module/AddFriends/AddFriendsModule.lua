require "Core.Module.Pattern.BaseModule"
require "Core.Module.AddFriends.AddFriendsMediator"
require "Core.Module.AddFriends.AddFriendsProxy"
AddFriendsModule = BaseModule:New();
AddFriendsModule:SetModuleName("AddFriendsModule");
function AddFriendsModule:_Start()
	self:_RegisterMediator(AddFriendsMediator);
	self:_RegisterProxy(AddFriendsProxy);
end

function AddFriendsModule:_Dispose()
	self:_RemoveMediator();
	self:_RemoveProxy();
end

