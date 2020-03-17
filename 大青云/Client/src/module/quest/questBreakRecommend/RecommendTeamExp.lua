--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendTeamExp = QuestBreakRecommend:new()

RecommendTeamExp.funcId = nil

function RecommendTeamExp:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendType_TeamExp")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendTeamExp:GetType()
	return QuestConsts.RecommendType_TeamExp
end

function RecommendTeamExp:GetLabel()
	local cfg = t_funcOpen[FuncConsts.teamExper]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendTeamExp:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.teamExper)
end

function RecommendTeamExp:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendTeamExp:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.teamExper)
end

function RecommendTeamExp:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.teamExper) and TimeDungeonModel:GetEnterNum() > 0;
end