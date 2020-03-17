--[[
任务断档推荐：推荐仙缘洞府
2015年6月15日20:44:57
haohu
]]
-------------------------------------------------------------

_G.RecommendCave = QuestBreakRecommend:new()

RecommendCave.funcId = nil

function RecommendCave:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendCave:GetType()
	return QuestConsts.RecommendType_Cave
end

function RecommendCave:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendCave:DoRecommend()
	FuncManager:OpenFunc( self.funcId )
end

function RecommendCave:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendCave:CheckEnterCondition()
	if ActivityXuanYuanCave:CanIn() ~= 1 then
		return false, -1
	end
	if ActivityXuanYuanCave:IsExcessivePilao() then
		return false, -2
	end
	return true
end

function RecommendCave:IsAvailable()
	return FuncManager:GetFuncIsOpen( self.funcId )
end