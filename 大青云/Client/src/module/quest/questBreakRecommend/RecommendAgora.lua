--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendAgora = QuestBreakRecommend:new()

RecommendAgora.funcId = nil

function RecommendAgora:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendAgora")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendAgora:GetType()
	return QuestConsts.RecommendType_Agora
end

function RecommendAgora:GetLabel()
	local cfg = t_funcOpen[FuncConsts.Agora]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendAgora:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.Agora)
end

function RecommendAgora:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendAgora:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.Agora)
end

function RecommendAgora:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.Agora) and AgoraModel.curTimes < AgoraModel:GetDayMaxCount()
end