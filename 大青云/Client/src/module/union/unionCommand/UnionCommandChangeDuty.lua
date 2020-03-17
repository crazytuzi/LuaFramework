--[[
--改变职位
ly
2014年11月25日8:33:12
]]
_G.UnionCommandChangeDuty = {}
UnionCommandChangeDuty.CName = 'UnionCommandChangeDuty'
function UnionCommandChangeDuty:New()
	local obj = UnionCommandBase:New()
	setmetatable(obj,{__index = self})
	return obj
end

function UnionCommandChangeDuty:ExecuteCommand(data)
	FTrace(data, 'UnionCommandChangeDuty:ExecuteCommand()')
	
	local pos = UnionUtils:GetChangeOperDuty(data.operId)
	
	if not pos then FPrint('没有找到转让对应的帮派职位'..data.operId) return end
	if not data.targetRoleId then FPrint('没有找到要转让的玩家') return end
	
	-- 任命职位
	local tipStr = string.format(StrConfig["union11"], data.targetRoleName, UnionUtils:GetOperDutyName(UnionUtils:GetChangeOperDuty(data.operId)))
	UIConfirm:Open(tipStr, function() UnionController:ReqChangeGuildPos(data.targetRoleId, pos) end,nil)
end

UnionCommandManager:AddCommand(UnionCommandChangeDuty.CName, UnionCommandChangeDuty:New())