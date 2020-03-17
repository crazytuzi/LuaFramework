--[[
    Created by IntelliJ IDEA.
    断档推荐 讨伐
    User: Hongbin Yang
    Date: 2016/11/11
    Time: 15:16
   ]]


_G.RecommendSGZC = QuestBreakRecommend:new()

RecommendSGZC.funcId = nil

function RecommendSGZC:Init(param)
	if #param < 2 then
		Error("quest break recommend config error, RecommendSGZC")
		return
	end
	self.funcId = tonumber( param[2] )
end

function RecommendSGZC:GetType()
	return QuestConsts.RecommendType_SGZC
end

function RecommendSGZC:GetLabel()
	local cfg = t_funcOpen[FuncConsts.singleDungeon]
	local name = cfg.name
	return string.format( StrConfig['quest605'], name )
end

function RecommendSGZC:DoRecommend()
	FuncManager:OpenFunc(FuncConsts.singleDungeon, false, DungeonConsts.SingleDungeon_BXZC);
end

function RecommendSGZC:GetTipsTxt()
	if not self:CheckEnterCondition() then
		return StrConfig['quest703']
	end
	return StrConfig['quest701']
end

function RecommendSGZC:CheckEnterCondition()
	return FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon)
end

function RecommendSGZC:IsAvailable()
	return FuncManager:GetFuncIsOpen(FuncConsts.singleDungeon) and DungeonUtils:GetSingleDungeonFreeTimes(DungeonConsts.SingleDungeonGroupID_SGZC) > 0
end