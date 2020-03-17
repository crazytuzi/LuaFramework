--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendBabel = QuestBreakRecommend:new()

RecommendBabel.funcId = nil

function RecommendBabel:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendBabel")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendBabel:GetType()
	return QuestConsts.RecommendType_Babel
end

function RecommendBabel:GetLabel()
	local cfg = t_funcOpen[FuncConsts.Babel]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendBabel:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.Babel)
end

function RecommendBabel:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendBabel:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.Babel)
end

function RecommendBabel:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.Babel) and BabelModel:GetTotalTimesAvailable() > 0
end