--[[
--禅让
ly
2014年11月25日8:33:12
]]
_G.UnionCommandChangeLeader = {}
UnionCommandChangeLeader.CName = 'UnionCommandChangeLeader'
function UnionCommandChangeLeader:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandChangeLeader:ExecuteCommand(data)
	FTrace(data, 'UnionCommandChangeLeader:ExecuteCommand()')
	
	local pos = UnionConsts.DutyLeader
	
	if not pos then FPrint('没有找到转让对应的帮派职位'..data.operId) return end
	if not data.targetRoleId then FPrint('没有找到要转让的玩家') return end
	
	-- 转让盟主
	UIConfirm:Open(StrConfig['union10'], function() UnionController:ReqChangeLeader(data.targetRoleId) end, nil)
end

UnionCommandManager:AddCommand(UnionCommandChangeLeader.CName, UnionCommandChangeLeader:New())