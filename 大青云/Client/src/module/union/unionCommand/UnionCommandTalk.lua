--[[
--私聊
ly
2014年11月25日8:33:12
]]
_G.UnionCommandTalk = {}
UnionCommandTalk.CName = 'UnionCommandTalk'
function UnionCommandTalk:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandTalk:ExecuteCommand(data)
	FTrace(data, 'UnionCommandTalk:ExecuteCommand()')
	
	if not data.targetRoleId then FPrint('没有找到要私聊的玩家') return end
	ChatController:OpenPrivateChat(data.targetRoleId, data.targetRoleName,data.roleIcon, data.roleLv,data.roleVipLv)
end

UnionCommandManager:AddCommand(UnionCommandTalk.CName, UnionCommandTalk:New())