--[[
--踢出
ly
2014年11月25日8:33:12
]]
_G.UnionCommandKickOut = {}
UnionCommandKickOut.CName = 'UnionCommandKickOut'
function UnionCommandKickOut:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandKickOut:ExecuteCommand(data)
	FTrace(data, 'UnionCommandKickOut:ExecuteCommand()')
	
	if not data.targetRoleId then FPrint('没有找到要踢出的玩家') return end
	UnionController:ReqKickGuildMem(data.targetRoleId)
end

UnionCommandManager:AddCommand(UnionCommandKickOut.CName, UnionCommandKickOut:New())