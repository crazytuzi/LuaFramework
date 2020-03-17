--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendTaoFa = QuestBreakRecommend:new()

RecommendTaoFa.funcId = nil

function RecommendTaoFa:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendTaoFa")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendTaoFa:GetType()
	return QuestConsts.RecommendType_TaoFa
end

function RecommendTaoFa:GetLabel()
	local cfg = t_funcOpen[FuncConsts.LieMo]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendTaoFa:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.LieMo)
end

function RecommendTaoFa:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendTaoFa:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.LieMo)
end

function RecommendTaoFa:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.LieMo) and not TaoFaUtil:IsTodayFinish()
end