--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendBXDG = QuestBreakRecommend:new()

RecommendBXDG.funcId = nil

function RecommendBXDG:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendBXDG")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendBXDG:GetType()
	return QuestConsts.RecommendType_BXDG
end

function RecommendBXDG:GetLabel()
	local cfg = t_funcOpen[FuncConsts.singleDungeon]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendBXDG:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.singleDungeon, false, DungeonConsts.SingleDungeon_BXDG);
end

function RecommendBXDG:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendBXDG:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon)
end

function RecommendBXDG:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon) and DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_BXDG) > 0
end