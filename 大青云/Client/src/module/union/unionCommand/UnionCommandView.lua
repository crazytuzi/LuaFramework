--[[
--查看资料
ly
2014年11月25日8:33:12
]]
_G.UnionCommandView = {}
UnionCommandView.CName = 'UnionCommandView'
function UnionCommandView:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandView:ExecuteCommand(data)
	FTrace(data, 'UnionCommandView:ExecuteCommand()')
	
	if not data.targetRoleId then FPrint('没有找到要查看资料的玩家') return end
	
	RoleController:ViewRoleInfo(data.targetRoleId)
end

UnionCommandManager:AddCommand(UnionCommandView.CName, UnionCommandView:New())