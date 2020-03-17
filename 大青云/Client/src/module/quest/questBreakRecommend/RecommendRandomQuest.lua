--[[
任务断档推荐 奇遇
2015年10月11日10:16:45
haohu
]]
-------------------------------------------------------------


_G.RecommendRandomQuest = QuestBreakRecommend:new()

RecommendRandomQuest.funcId = nil

function RecommendRandomQuest:Init(param)
	if #param < 2 then
		Error("quest break recommend config error")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendRandomQuest:GetType()
	return QuestConsts.RecommendType_RandomQuest
end

function RecommendRandomQuest:GetLabel()
	local cfg = t_funcOpen[self.funcId]
	local name = cfg.name
	return string.format( StrConfig['quest604'], name )
end

function RecommendRandomQuest:DoRecommend()
	RandomQuestController:DoRandomQuest() -- 做奇遇任务
end

function RecommendRandomQuest:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendRandomQuest:CheckEnterCondition()
	return true
end

function RecommendRandomQuest:IsAvailable()
	return FuncManager:GetFuncIsOpen( self.funcId ) and not RandomQuestModel:IsTodayFinish()
end