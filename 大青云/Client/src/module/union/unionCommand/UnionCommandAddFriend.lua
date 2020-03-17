--[[
--添加好友
ly
2014年11月25日8:33:12
]]
_G.UnionCommandAddFriend = {}
UnionCommandAddFriend.CName = 'UnionCommandAddFriend'
function UnionCommandAddFriend:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandAddFriend:ExecuteCommand(data)
	FTrace(data, 'UnionCommandAddFriend:ExecuteCommand()')
	
	if not data.targetRoleId then FPrint('没有找到要添加好友的玩家') return end
	
	FriendController:AddFriend(data.targetRoleId)
end

UnionCommandManager:AddCommand(UnionCommandAddFriend.CName, UnionCommandAddFriend:New())