--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendHone = QuestBreakRecommend:new()

RecommendHone.funcId = nil

function RecommendHone:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendHone")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendHone:GetType()
	return QuestConsts.RecommendType_Hone
end

function RecommendHone:GetLabel()
	local cfg = t_funcOpen[FuncConsts.QuestRandom]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendHone:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.QuestRandom)
end

function RecommendHone:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendHone:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.QuestRandom)
end

function RecommendHone:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.QuestRandom) and QuestModel.randomQuestFinishedCount < RandomQuestConsts:GetRoundsPerDay()
end