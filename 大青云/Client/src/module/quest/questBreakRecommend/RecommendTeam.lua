--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendTeam = QuestBreakRecommend:new()

RecommendTeam.funcId = nil

function RecommendTeam:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendType_TeamExp")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendTeam:GetType()
	return QuestConsts.RecommendType_Team
end

function RecommendTeam:GetLabel()
	local cfg = t_funcOpen[FuncConsts.teamDungeon]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendTeam:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.teamDungeon)
end

function RecommendTeam:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendTeam:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.teamDungeon)
end

function RecommendTeam:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.teamDungeon) and QiZhanDungeonUtil:GetNowEnterNum() > 0;
end